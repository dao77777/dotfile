# 设计：shell 配置怎么组织

> 顶层设计见 [overview.md](overview.md) · 装了哪些工具见 [packages.md](packages.md)

## 一、dotfile 全是软链

```
~/.zshrc ─┐
~/.zshenv ─┼─► /nix/store/<hash>-home-manager-files/.zshrc   （只读，-r--r--r--）
~/.npmrc ─┘
```

| 事实 | 后果 |
| --- | --- |
| 指向 `/nix/store` | 直接改**不持久**，`switch` 会覆盖回来 |
| store **只读**且**全世界可读** | 写不进去；就算能写也等于公开 |
| 每次 `switch` 生成新 hash 目录 | 旧副本留在 store 里 → **密钥绝不能进这里** |

**改 shell 行为的唯一入口**：`home.nix` → `home-manager switch`。

## 二、配置从哪来

```
home.nix
├── home.packages          装哪些 CLI        → packages.md
├── home.sessionPath       PATH 顺序         ← 有陷阱，见 decisions/runtime-node.md
├── home.sessionVariables  环境变量（只放"路径"这类非机密值）
├── home.activation.*      switch 时跑一次的钩子
└── programs.zsh
    ├── shellAliases       别名             → 下表
    ├── initContent        自定义片段
    └── oh-my-zsh          主题 / 插件
```

## 三、加载链

```
新终端
  └─ ~/.zshenv
       ├─ 非登录 shell →  source hm-session-vars.sh   ← 环境变量在这里注入
       └─ 登录 shell   →  跳过（走 /etc/zprofile 那条链）
     └─ ~/.zshrc → oh-my-zsh → starship → 别名 / 函数
```

**验证时的两个陷阱**（每次改 `sessionVariables` 都会遇到）：

| 现象 | 原因 |
| --- | --- |
| 新变量"没生效" | `hm-session-vars.sh` 有 `__HM_SESS_VARS_SOURCED` 守卫，**从旧 shell 继承来的子 shell 会跳过**。开新终端，或 `env -u __HM_SESS_VARS_SOURCED zsh -c '…'` |
| 登录 shell 与普通 shell 行为不同 | 上面那条 `if [[ ! -o login ]]` |

## 四、别名与函数

**纯别名** → `programs.zsh.shellAliases`；**需要逻辑的** → `programs.zsh.initContent` 里定义函数。

| 别名 | 内容 |
| --- | --- |
| `l` / `ls` / `la` / `ll` / `lla` / `lt` | eza 的几种视角（网格 / 隐藏 / 详细 / 树形，均带 git 状态） |
| `y` | yazi（**函数**：退出后 cd 到浏览过的目录） |
| `v` / `vi` / `vim` | nvim |
| `g` `gs` `gl` `ga` `gc` `gp` `gpl` `gd` `gco` `gb` | git 简写 |
| `..` / `...` / `....` | cd 上级 |
| `c` / `h` / `bt` | clear / history / btop |
| `bathelp` / `fzfp` / `rgi` | bat 渲染 help / fzf+bat 预览 / `rg -i` |
| `ports` / `reload` | 查看监听端口 / source `~/.zshrc` |

## 五、加一个新工具

```sh
# ① home.nix：home.packages 加包，或 programs.<tool> 加模块
# ② 同步文档：包 → designs/packages.md；别名 → 本文件第四节
# ③ home-manager switch && command -v <新命令>     # 应在 ~/.nix-profile/bin 下
```
