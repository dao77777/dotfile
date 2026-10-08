# 决策 + 设计：密钥体系（sops + age）

> 状态: 生效中 · 起始 2026-10 · 落点: `home.packages` 的 `sops` / `age` + `home.sessionVariables`
> 通用 how-to（安装、封筒模型、排错）在 `~/Code/tmp/docs/sops-age-secrets.md`，**本文只记本机怎么接的**。

## 问题

密钥有三个"不能去"的地方，而它们恰好都是最方便的地方：

| 不能去 | 为什么 |
| --- | --- |
| `home.nix` / Nix store | store 只读且**全世界可读**，每次 `switch` 还留新副本 |
| 明文文件进 git | 一次提交 = 永久泄漏（要改历史 + 轮换） |
| 常驻环境变量 | 同机**任何进程**都能读（`ps eww` 就能看到），agent 一条 `env` 全拿走 |

## 决定

```
┌─ 私有 git 仓库 ──────────────────────────────────┐
│  ~/Code/vault        （推送到 dao77777/vault）    │
│    env/secrets.enc.yaml      环境变量密文         │
│    keys/*.enc                SSH 私钥等文件型机密 │
│    .sops.yaml                只有 age 公钥        │
└──────────────────────────────────────────────────┘
          │ 解密的钥匙在哪？
          ▼
┌─ 本机 ───────────────────────────────────────────┐
│  ~/.config/sops/age/keys.txt    age 私钥 chmod 600 │
│                                永不进 git / 不外传 │
│  ~/Code/vault/env/secrets.yaml  明文副本，仅供编辑 │
│                                 被 .gitignore 挡住 │
└──────────────────────────────────────────────────┘
```

**本仓库（home-manager）里只有两样东西**：

```nix
home.packages = with pkgs; [ sops age ];          # 工具
home.sessionVariables.SOPS_AGE_KEY_FILE =          # 一行"路径"，不是密钥
  "${config.home.homeDirectory}/.config/sops/age/keys.txt";
```

密钥值、私库地址、私钥本身 —— **都不在本仓库**。

## 理由：为什么必须显式设 `SOPS_AGE_KEY_FILE`

这是踩出来的坑，值得单独记：

```
sops 找默认 age 私钥用的是 Go 的 os.UserConfigDir()
  Linux  → ~/.config/sops/age/keys.txt        ← 网上教程和文档写的都是这个
  macOS  → ~/Library/Application Support/sops/age/keys.txt   ← 实际是这个
```

实测（密钥只放 `~/.config/sops/age/` 时）：

```
$ sops -d env/secrets.enc.yaml
Failed to get the data key ... age: identity did not match any of the recipients
```

把密钥**也**复制到 `~/Library/Application Support/sops/age/` 就立刻能解 —— 证明就是路径问题。

**我们的选择**：显式指到 `~/.config/sops/age/keys.txt`（跨平台一致、不散落在应用数据目录），代价是 `home.nix` 多这一行。

## 硬规矩

| 规矩 | 原因 |
| --- | --- |
| 密钥值**不得出现在任何输出**里（`echo`/`cat`/打印/复述到对话） | agent 的输出会进会话记录，等于第二次泄漏 |
| 只有 `.enc` 能进 git；`.sops.yaml` 只含公钥 | 明文一进历史就要改历史 + 轮换 |
| age 私钥永不复制、永不提交、永不外传 | 它是唯一的信任根 |
| 项目要密钥时让**启动命令自己注入**（`sops exec-env`），不要往项目里塞明文 | 项目零感知，且泄漏面最小 |
| 换机器只交换**公钥** | 各机私钥独立 → 吊销一台 = 删它的公钥 + `sops updatekeys` |

## 代价

| 代价 | 说明 |
| --- | --- |
| 多一个私有仓库要维护 | `~/Code/vault` 需要自己 push（已配 remote） |
| 明文副本常驻磁盘 | `env/secrets.yaml` 是 600 + gitignore，但仍在盘上 |
| 明文/密文可能漂移 | 改完明文忘了 `sops -e`，别的机器拿到旧值 → **提交前跑漂移检查** |
| 挡不住 agent | 能跑 shell 的 agent 就能执行 `sops -d`。要真隔离得上 YubiKey |

漂移检查（无输出 = 一致）：

```sh
cd ~/Code/vault && diff <(sops -d env/secrets.enc.yaml) env/secrets.yaml
```

## 复查条件

1. 需要"挡住 agent"级别的隔离 → 引入 `age-plugin-yubikey`（每次解密要物理触碰）
2. 密钥数量/协作方变多 → 考虑换成有 UI 的方案（Bitwarden / Infisical），本仓库只需改推密钥的方式
3. sops 上游修了 macOS 默认路径 → 可以删掉 `SOPS_AGE_KEY_FILE` 那行
