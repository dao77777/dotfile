# shell 配置怎么组织

> 状态: 生效中 · 类型: 设计

## 核心规则：所有 dotfile 都是软链

```
~/.zshrc ─┐
~/.zshenv ─┼─► /nix/store/<hash>-home-manager-files/.zshrc   （只读，-r--r--r--）
~/.npmrc ─┘
```

含义（三条，都别忘）：

| 事实 | 后果 |
| --- | --- |
| 软链指向 `/nix/store` | 直接改**不持久**，下次 `switch` 被覆盖 |
| Nix store 是**只读**且**全世界可读** | 写进去会报错；就算能写也等于公开 |
| 每次 `switch` 生成新 hash 目录 | 旧副本仍留在 store 里（**所以密钥绝不能进这里**） |

**改 shell 行为的唯一入口**：`home.nix` → `home-manager switch`。

## 配置从哪来

```
home.nix
├── home.packages          → 装哪些 CLI（清单见 README.md）
├── home.sessionPath       → PATH 顺序（有陷阱，见 runtime-node.md）
├── home.sessionVariables  → 环境变量（只放"路径"这类非机密值）
├── programs.zsh
│   ├── shellAliases       → 别名（清单见 README.md「别名速查」）
│   ├── initContent        → 自定义脚本片段
│   └── oh-my-zsh          → 主题 / 插件
├── programs.<tool>        → git / direnv / neovim / starship / btop / yazi / zoxide …
└── home.activation.*      → switch 时执行一次的钩子
```

## 加载顺序的坑

| 现象 | 原因 | 处理 |
| --- | --- | --- |
| 自己设的 `bindkey` 不生效 | oh-my-zsh 在 `initContent` 之后覆盖键位 | 用 `lib.mkAfter` 把自己的片段排到最后 |
| 环境变量在新 shell 里没有 | `hm-session-vars.sh` 有 `__HM_SESS_VARS_SOURCED` 守卫，**继承来的 shell 会跳过** | 开新终端；或在脚本里 `env -u __HM_SESS_VARS_SOURCED zsh -c '…'` 验证 |
| 登录 shell 与普通 shell 行为不同 | `~/.zshenv` 里是 `if [[ ! -o login ]]`，登录 shell 走另一条链 | 验证时两种都测 |

## 别名 / 函数的归属

- **纯别名** → `programs.zsh.shellAliases`（清单在 README.md）
- **需要逻辑的** → 写成脚本放 `home.packages` 之外，用 `programs.zsh.initContent` 定义函数
  - 例：`y` 是 yazi 的包装函数（退出时 `cd` 到浏览过的目录），不是别名

## 加一个新工具的标准流程

```sh
# 1. 改 home.nix：home.packages 加包 / programs.<tool> 加模块
# 2. 同步 README.md 对应表格（硬要求，见 AGENTS.md）
# 3. 应用 + 验证
home-manager switch
command -v <新命令>        # 必须确认路径在 ~/.nix-profile/bin 下
```
