# 决策：密钥用 sops + age

> 生效中 · 起始 2026-10 · 所属设计 [secrets.md](../design/secrets.md) · 落点 `home.packages` + `home.sessionVariables`

## 矛盾

密钥有三个"最方便"的去处，**都不能用**：

| ❌ 去处 | 为什么不行 |
| --- | --- |
| `home.nix` / Nix store | store 只读且**全世界可读**；每次 `switch` 还留一份新副本 |
| 明文进 git | 一次提交 = 永久泄漏（要改历史 + 轮换上游 token） |
| 常驻环境变量 | 同机**任何进程**可读（`ps eww` 就能看到），agent 一条 `env` 全拿走 |

同时还有两个硬要求：**能跨机器**、**无人任务也能取**（cron / CI 没有交互）。

## 处理

**sops + age**：密文进私有 git 仓库，私钥只留本机。结构、命令、硬规矩见
[design/secrets.md](../design/secrets.md)。

本仓库里只有两行 —— 工具 + 一个路径：

```nix
home.packages = with pkgs; [ sops age ];
home.sessionVariables.SOPS_AGE_KEY_FILE = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
```

## 为什么是它

| 候选 | 落选原因 |
| --- | --- |
| 明文 + gitignore | 只是换个地方放明文；agent / 进程照样能读 |
| Bitwarden / Vaultwarden | 有 UI 和手机端，但 `bw` 靠会话 token，**无人任务不友好** ← 关键 |
| 1Password / Doppler | 收费，且非全开源 |
| `pass`（GPG） | 功能等价，但 GPG 密钥管理重，跨机器维护成本高 |
| Vault / OpenBao | 面向动态凭证与 TTL；个人场景过度设计，且每次读都依赖后端在线 |

**两个决定性优势**：

```
① git-native        密文直接进仓库，和代码一起 review / 回滚
② 没有 session 概念  私钥就是个文件，cron / 无交互任务直接能解
```

## 附带决策：为什么显式设 `SOPS_AGE_KEY_FILE`

```
sops 找默认私钥用的是 Go 的 os.UserConfigDir()
  Linux  → ~/.config/sops/age/keys.txt                        ← 文档和教程都这么写
  macOS  → ~/Library/Application Support/sops/age/keys.txt    ← 实际是这个
```

实测（密钥只放 `~/.config` 时）：`Failed to get the data key ... identity did not match`；
把同一把密钥**也**复制到 `~/Library/Application Support/sops/age/` 就立刻能解 → 就是路径问题。

选择显式指到 `~/.config`：跨平台一致，不让密钥散落在应用数据目录。

## 代价

| 代价 | 说明 |
| --- | --- |
| 多一个私有仓库 | 需要自己 push |
| 明文副本常驻磁盘 | 为了编辑方便而接受的取舍 |
| 明文/密文可能漂移 | 提交前跑 [漂移检查](../design/secrets.md) |
| **挡不住 agent** | 能跑 shell 的 agent 就能执行 `sops -d`。加密解决的是「git 泄漏 / 磁盘失窃 / 单机吊销」，**不是** LLM 隔离 |

## 复查条件

1. **需要挡住 agent** → `age-plugin-yubikey`（每次解密要物理触碰；无人任务也解不了，正好是要的效果）
2. **密钥变多、需要 UI** → 换 Bitwarden / Infisical；只需改"推密钥的方式"，本仓库那两行随之调整
3. **sops 修了 macOS 默认路径** → 可以删掉 `SOPS_AGE_KEY_FILE` 那一行
