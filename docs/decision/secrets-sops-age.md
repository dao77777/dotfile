# 决策：密钥体系用 sops + age

> 状态: 生效中 · 起始 2026-10 · 落点: `home.packages` 的 `sops` / `age` + `home.sessionVariables`
> 落地结构见 [design-secrets-sops-age.md](../design/secrets-sops-age.md)；通用 how-to 见 `~/Code/tmp/docs/sops-age-secrets.md`

## 问题

密钥有三个"最方便"的存放处，而它们**都不能用**：

| ❌ 去处 | 为什么不行 |
| --- | --- |
| `home.nix` / Nix store | store 只读且**全世界可读**；每次 `switch` 还留一份新副本 |
| 明文文件进 git | 一次提交 = 永久泄漏（要改历史 + 轮换上游 token） |
| 常驻环境变量（`.zshrc` / direnv） | 同机**任何进程**可读（`ps eww` 就能看到），agent 一条 `env` 全拿走 |

## 决定

**sops + age**：密文进一个私有 git 仓库，私钥只留本机。

```
私有库（可推远端）          本机（永不外传）
密文 + age 公钥      ←→     age 私钥 ~/.config/sops/age/keys.txt
```

本仓库（home-manager）里**只有两行** —— 工具 + 一个路径：

```nix
home.packages = with pkgs; [ sops age ];
home.sessionVariables.SOPS_AGE_KEY_FILE = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
```

## 理由

### 1. 为什么不选别的

| 方案 | 为什么不选 |
| --- | --- |
| **明文 + gitignore** | 只是把明文换个地方放；agent/进程照样能读 |
| **Bitwarden / Vaultwarden** | 有 UI 和手机端，但 `bw` 的会话 token 是对话式登录，**无人任务（cron / CI）不友好**；本场景以"程序按需取用"为主 |
| **1Password / Doppler** | 收费，且不是全开源 |
| **`pass`（GPG）** | 功能等价，但 GPG 的密钥管理体验明显更重，跨机器维护成本高 |
| **HashiCorp Vault / OpenBao** | 面向"服务动态凭证、TTL、轮换"，个人场景是过度设计，且每次读都依赖后端在线 |

**sops + age 的两个决定性优势**：

```
① git-native        密文可以直接进仓库，和代码一起 review / 回滚
② 没有 session 概念  私钥就是个文件，cron / 无交互任务直接能解 ← 这一条排除了 Bitwarden
```

> age 是"现代 GPG"：单二进制、无依赖、无私钥环、无信任网，只有"公钥加密文件"这一件事。

### 2. 为什么必须显式设 `SOPS_AGE_KEY_FILE`

这是踩出来的，不设就是不自明的坑：

```
sops 找默认 age 私钥用的是 Go 的 os.UserConfigDir()
  Linux  → ~/.config/sops/age/keys.txt                        ← 文档和网上教程写的都是这个
  macOS  → ~/Library/Application Support/sops/age/keys.txt    ← 实际是这个
```

实测（密钥只放 `~/.config/sops/age/`）：

```
$ sops -d env/secrets.enc.yaml
Failed to get the data key ... age: identity did not match any of the recipients
```

把同一把密钥**也**复制到 `~/Library/Application Support/sops/age/` → 立刻能解。证明就是路径问题，不是密钥问题。

**选择显式指到 `~/.config`**：跨平台一致，不让密钥散落在应用数据目录（那里同步/备份行为不可控）。

## 代价

| 代价 | 说明 |
| --- | --- |
| 多一个私有仓库要维护 | `~/Code/vault`，需要自己 push |
| 明文副本常驻磁盘 | `env/secrets.yaml`（600 + gitignore）—— 为了编辑方便而接受的取舍 |
| 明文/密文可能漂移 | 改完明文忘了 `sops -e`，别的机器拿到旧值 |
| **挡不住 agent** | 能跑 shell 的 agent 就能执行 `sops -d`。加密解决的是"git 泄漏 / 磁盘失窃 / 单机吊销"，**不是** LLM 隔离 |
| 仓库里有两条 remote 历史 | 曾经明文存在过 → 相关 token 应该轮换，而非只做清理 |

## 复查条件

1. **需要挡住 agent** → 引入 `age-plugin-yubikey`（每次解密必须物理触碰；无人任务也解不了，正好是要的效果）
2. **密钥数量 / 协作方变多，需要 UI** → 换 Bitwarden / Infisical；本仓库只需改"推密钥的方式"，`home.nix` 那两行随之调整
3. **sops 上游修了 macOS 默认路径** → 可以删掉 `SOPS_AGE_KEY_FILE` 那一行
