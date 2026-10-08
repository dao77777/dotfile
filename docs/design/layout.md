# 设计：目录结构与归属边界

> 顶层设计见 [overview.md](overview.md)

## 一张图

```
/Users/zephyr
├── .config/home-manager/        ⭐ 环境正本（本仓库，受 git 管理）
│   ├── flake.nix  home.nix          入参与全部配置
│   ├── GLOBAL_AGENTS.md             全局规则（软链到各 agent）
│   ├── AGENTS.md  README.md         仓库规则 / 门面
│   └── docs/                        design · decision · appendix
│
├── Code/                        ⭐ 工作区（每个项目一个目录）
│   ├── AGENTS.md                    工作区约定
│   ├── process-compose.yaml         所有 dev server 的统一入口
│   └── vault/                       密钥库（私有 git，只存密文）
│
├── .nix-profile → ~/.local/state/nix/profiles/profile
│                                   Nix 提供的 CLI 全在这里（软链，勿动）
│
├── .config/sops/age/keys.txt        age 私钥（600，永不入库）
├── .npm-global/                     npm 全局包
├── .local/share/node/               官方 Node tarball（[原因](../decision/runtime-node.md)）
│
├── .zshrc  .zshenv  .npmrc  …      软链 → /nix/store，勿直接改
├── .pi/  .codex/  .opencode/       agent 运行数据与配置
└── Library/  Desktop/  …           macOS 自己的，不手动改
```

## 归属边界

| 东西 | 归谁 | 改法 |
| --- | --- | --- |
| CLI、别名、PATH、环境变量 | **本仓库** | 改 `home.nix` → `switch` |
| shell 行为（提示符、补全、键位） | **本仓库** `programs.zsh.*` | 同上 |
| 工具配置（git / nvim / btop / direnv） | `~/.config/<tool>/`；被 hm 接管的回 `home.nix` | 先看它是软链还是真文件 |
| npm 全局包 | `~/.npm-global`（**不归本仓库**） | `npm i -g` |
| 项目依赖 / node 版本 | 项目自己的 `flake.nix` | 不要依赖全局 |
| dev server 启停 | `~/Code/process-compose.yaml` | 见 `~/Code/AGENTS.md` |
| 密钥 | `~/Code/vault` | 见 [secrets.md](secrets.md) |

## Nix 层

| 项 | 值 |
| --- | --- |
| 形态 | standalone + flakes（不是 nix-darwin） |
| 输入 | `nixpkgs-unstable` + `home-manager`，版本由 `flake.lock` 锁定 |
| 配置 | `homeConfigurations.zephyr`，`aarch64-darwin` |
| 入口 | `flake.nix`（devShell） → `home.nix`（一切） |
| 远端 | `https://github.com/dao77777/dotfile.git`，分支 `main` |

## 为什么正本放在 `.config/home-manager/`

三个约束推导出来的：

```
① 配置必须由 Nix 生成      → 不能直接改 ~/.zshrc（软链，会被覆盖）
② 必须能跨机器重现          → 要有 git 仓库 + flake
③ agent 要能读到全局规则    → 各 agent 的全局文件软链到本目录

  ⇒ 本目录同时是「环境正本」和「全局规则正本」，只改这一份
```
