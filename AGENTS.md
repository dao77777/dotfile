# AGENTS.md

本仓库是 home-manager 配置（standalone + flakes），管理 macOS 用户 `zephyr` 的开发环境。

## 文件布局

- `flake.nix` / `flake.lock`：flake 入口与锁定（nixpkgs-unstable + home-manager）
- `home.nix`：全部配置（`home.packages` 装包 + `programs.*` 模块 + 别名/环境变量）
- `README.md`：面向人的**软件清单**，与 `home.nix` 一一对应

## 核心约定

### 1. 改 `home.nix` 必须同步 `README.md`

任何对 `home.nix` 的改动，只要影响到「装了什么、有什么别名/功能」，**同一次修改中必须同步更新 `README.md`**：

- 新增 / 删除 `home.packages` 里的包 → 在 README 对应分类表格增删行（选一个最贴切的板块，如 开发 / 文件系统 / 进程与服务管理）
- 新增 `programs.*` 模块，或修改别名、shell 集成 → 同步 README 对应表格
- 每次按需更新 README 顶部「整理日期」

README 板块与 `home.nix` 的对应：

| README 板块 | home.nix 来源 |
|---|---|
| 文件系统 / 处理与转换 / 渲染与预览 | `home.packages` 各分类 |
| 开发 | `home.packages` 开发类 + `programs.git` / `programs.direnv` / `programs.neovim` 等 |
| 进程与服务管理 | `home.packages` 中编排类工具 |
| Shell 与系统 | `programs.zsh` / `programs.starship` / `programs.btop` 等 |
| 别名速查 | `programs.zsh.shellAliases` / initExtra |

### 2. 改完要应用并验证

```sh
home-manager switch          # 应用配置
command -v <新命令>           # 确认新包可用
```

### 3. 提交前自检

- `git diff` 中若只改了 `home.nix` 而 `README.md` 无对应改动 → 视为未完成
- 不确定新包该放哪个板块时，保持与现有分类风格一致，不要新造过度细分的分类

## 注意

- CLI 全部走 Nix（`~/.nix-profile`），**不引入 Homebrew**
- npm 全局包在 `~/.npm-global`，独立于 Nix，不属于本仓库管理范围
- 修改 shell 配置的 `initExtra` 时注意 zsh 加载顺序（如 oh-my-zsh 会覆盖 `bindkey`）
