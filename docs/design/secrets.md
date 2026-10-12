# 设计：密钥体系

> 顶层设计见 [overview.md](overview.md) · **为什么选 sops + age** 见 [../decision/secrets-sops-age.md](../decision/secrets-sops-age.md)

## 结构

```
┌─ 私有 git 仓库 ── ~/Code/_vault ───────────────────────────┐
│  env/secrets.enc.yaml     环境变量密文（键名明文可读）      │
│  keys/*.enc               文件型机密（SSH 私钥、证书）      │
│  .sops.yaml              只有 age 公钥 → 可以入库           │
└────────────────────────────────────────────────────────────┘
                        │ 解密的钥匙在哪？
                        ▼
┌─ 本机（永不外传）──────────────────────────────────────────┐
│  ~/.config/sops/age/keys.txt    age 私钥 600               │
│  ~/Code/_vault/env/secrets.yaml  明文副本，仅供编辑        │
│                                 600 + gitignore            │
└────────────────────────────────────────────────────────────┘
                        │ 谁知道自己该用哪把钥匙？
                        ▼
┌─ 本仓库 ── 只有两行 ───────────────────────────────────────┐
│  home.packages          [ sops age ]                       │
│  home.sessionVariables  SOPS_AGE_KEY_FILE = <上面的路径>    │
│                                                            │
│  ⚠️ 密钥值 / 私库地址 / 私钥本身 —— 都不在这里             │
└────────────────────────────────────────────────────────────┘
```

**关键解耦**：本仓库只知道"一个路径"。换私库、换机器、换方案，`home.nix` 都不用动。

## 各层职责

| 层 | 存什么 | 进 git | 换机器 |
| --- | --- | --- | --- |
| 私有库 `vault` | 密文 + 公钥清单 | ✅ | `git clone` |
| 本机 age 私钥 | 唯一的信任根 | ❌ **永不** | 人工注入一次 |
| `vault/env/secrets.yaml` | 明文副本 | ❌ gitignore | 从密文解出 |
| 本仓库 `home.nix` | 工具 + 路径 | ✅ | 自动 |

## 操作

```sh
cd ~/Code/_vault

# 取用（三种，都不落盘）
sops -d --extract '["DEEPSEEK_API_KEY"]' env/secrets.enc.yaml   # 单值（输出不带换行）
sops exec-env env/secrets.enc.yaml 'your-cmd'                    # 注入进程环境
sops -d --output-type dotenv env/secrets.enc.yaml > ~/Code/<p>/.env   # 给项目生成 .env
sops -d keys/ssh-macbook-air.enc > ~/.ssh/id_ed25519             # 恢复文件型机密

# 增改
$EDITOR env/secrets.yaml                          # ① 改明文
sops -e env/secrets.yaml > env/secrets.enc.yaml   # ② 封回密文
git add env/secrets.enc.yaml && git commit        # ③ 只提交密文

# 换机器：各机私钥独立，只交换公钥
age-keygen -o ~/.config/sops/age/keys.txt         # 公钥 → 加进 .sops.yaml（两条规则都要）
sops updatekeys -y env/secrets.enc.yaml && sops updatekeys -y keys/ssh-macbook-air.enc
```

## 硬规矩

| 规矩 | 原因 |
| --- | --- |
| 密钥值**不得出现在任何输出**里 | agent 输出会进会话记录 → 第二次泄漏 |
| 只有 `.enc` 能进 git；`.sops.yaml` 只含公钥 | 明文进历史就要改历史 + 换 token |
| age 私钥永不复制、永不提交、永不外传 | 它是唯一信任根 |
| 项目要密钥时让**启动命令自己注入**（`sops exec-env`） | 项目零感知，泄漏面最小 |

**漂移检查**（明文与密文是两个文件，改完忘了封回去，别的机器就会拿到旧值）：

```sh
cd ~/Code/_vault && diff <(sops -d env/secrets.enc.yaml) env/secrets.yaml   # 无输出 = 一致
```

## 当前内容

| 键 | 说明 |
| --- | --- |
| `TENCENT_VM_DOMAIN` / `_IP` / `_USERNAME` | 腾讯云 VM 三件套 |
| `ZAI_API_KEY` / `KIMI_API_KEY` / `DEEPSEEK_API_KEY` | 三个模型的 API key |
| `keys/ssh-macbook-air.enc` | MacBook Air 的 Ed25519 私钥 |
