# 目录结构与归属边界

> 状态: 生效中 · 类型: 设计

## 一张图

```
/Users/zephyr
├── .config/home-manager/        ⭐ 本仓库：shell 环境正本（dotfiles，受 git 管理）
│   ├── flake.nix  flake.lock        Nix 输入与 devShell
│   ├── home.nix                     全部配置：装包 / 模块 / 别名 / PATH / 环境变量
│   ├── AGENTS.md                    规则（给 agent）
│   ├── README.md                    清单（给人）
│   └── docs/                        ← 你在这里：决策与设计
│
├── Code/                        ⭐ 工作区：所有代码项目
│   ├── AGENTS.md                    工作区约定（process-compose 编排）
│   ├── process-compose.yaml         所有 dev server 的统一入口
│   ├── vault/                       密钥库（私有 git，只存密文）
│   └── <project>/                   一个项目一个目录
│
├── .nix-profile → ~/.local/state/nix/profiles/profile
│                                   Nix 提供的 CLI 全在这里（符号链接，勿动）
│
├── .npm-global/                 npm 全局包（独立于 Nix）
├── .local/share/node/           官方 Node tarball（见 runtime-node.md）
├── .local/bin/                  自置脚本
├── .config/sops/age/keys.txt    age 私钥（chmod 600，永不入库）
│
├── .zshrc  .zshenv  .npmrc  …   全是软链，指向 /nix/store（勿直接改）
├── .pi/  .codex/  .opencode/    agent 的运行数据与配置
│
├── Desktop/ Documents/ …        macOS 默认目录
└── Library/                     macOS 应用数据，不手动改
```

## 归属边界：什么归谁管

| 东西 | 归谁 | 改法 |
| --- | --- | --- |
| CLI 工具、别名、PATH、环境变量 | **本仓库** `home.nix` | 改 `home.nix` → `home-manager switch` |
| zsh 行为（提示符、补全、键位） | **本仓库** `programs.zsh.*` | 同上 |
| 工具自己的配置（git / nvim / btop / direnv） | `~/.config/<tool>/`，若被 hm 接管则回 `home.nix` | 先看它是软链还是真文件 |
| npm 全局包 | `~/.npm-global`（**不归本仓库**） | `npm i -g` |
| 项目的依赖与 node 版本 | **项目自己的 `flake.nix`** | 别依赖全局 node |
| dev server 的启停 | `~/Code/process-compose.yaml` | 见 `~/Code/AGENTS.md` |
| 密钥 | `~/Code/vault`（私有库，只存密文） | 见 [secrets-sops-age.md](secrets-sops-age.md) |

## 速查：想干什么 → 去哪

| 想干什么 | 去哪 |
| --- | --- |
| 装个 CLI、改别名、改 PATH | `home.nix` |
| 改 zsh 提示符 / 键位 | `home.nix` 的 `programs.zsh` |
| 写代码、起 dev server | `~/Code/`（先读 `~/Code/AGENTS.md`） |
| 要密钥 | `~/Code/vault` |
| 想知道某个选择为什么这么做 | 本目录 `docs/` |

## Nix 层

| 项 | 值 |
| --- | --- |
| 形态 | standalone + flakes（不是 nix-darwin） |
| 输入 | `nixpkgs-unstable` + `home-manager`（`flake.lock` 锁定） |
| 配置 | `homeConfigurations.zephyr`，`aarch64-darwin` |
| 入口 | `flake.nix`（devShell） → `home.nix`（全部配置） |
| 远端 | `git@github.com:dao77777/dotfile.git`，分支 `main` |

> 22 端口在部分网络下不通，本仓库 remote 已改成 `ssh://git@ssh.github.com:443/...`。
> 一劳永逸的解法是给 `~/.ssh/config` 加 `Host github.com → HostName ssh.github.com / Port 443`。

## 为什么要把"正本"放在 `.config/home-manager/`

三个约束推导出来的：

1. **配置必须由 Nix 生成** → 不能直接改 `~/.zshrc`（那是软链，`switch` 会覆盖回来）
2. **必须能跨机器重现** → 所以要有 git 仓库 + flake
3. **agent 要能读到全局规则** → 各 agent 的全局文件（`~/.pi/agent/AGENTS.md` 等）都**软链**到本仓库这一份

→ 于是本目录既是"配置正本"，也是"全局 AGENTS.md 正本"。**只改这一份，别改软链另一端。**
