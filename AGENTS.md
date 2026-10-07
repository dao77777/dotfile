# AGENTS.md

> **用户级全局上下文文件，对本机所有工作目录生效。**
>
> - 正本（唯一真源）：`~/.config/home-manager/AGENTS.md`（即本文件，属 dotfiles 仓库，受 git 管理）
> - 通过软链挂到各 agent 的全局路径：
>   `~/.pi/agent/AGENTS.md`、`~/.codex/AGENTS.md`、`~/.config/opencode/AGENTS.md`、`~/.claude/CLAUDE.md`
> - **只改这一份**，不要改软链另一端。新增 agent 时，把它的全局文件软链到本文件即可。
> - 生效优先级：**项目 `AGENTS.md` > 工作区 `~/Code/AGENTS.md` > 本文件**。
> - 本文件同时是 home-manager 仓库的说明，§4 仅在该仓库内适用。

---

## 1. 用户目录结构

```
/Users/zephyr
├── .config/home-manager/     # ⭐ A. shell 环境正本（home-manager flake，dotfiles 仓库）
│   ├── flake.nix / flake.lock
│   ├── home.nix              # 所有包、模块、别名、PATH
│   ├── README.md             # 面向人的软件清单，必须与 home.nix 同步
│   └── AGENTS.md             # 本文件
│
├── Code/                     # ⭐ B. 写代码的地方（工作区）
│   ├── AGENTS.md             # 工作区约定：process-compose 统一编排
│   ├── process-compose.yaml  # 所有项目的统一启动入口
│   └── <project>/            # 每个项目一个目录
│
├── .config/                  # 各工具配置：direnv / git / gh / btop / nvim / opencode / nix
├── .pi/agent/                # pi 的 agent 目录（settings / mcp / sessions / 全局 AGENTS.md 软链）
├── .codex/                   # Codex 配置（全局 AGENTS.md 软链）
├── .opencode/                # opencode 运行数据
├── .npm-global/              # npm 全局包，独立于 Nix，不归 home-manager 管
├── .local/share/node/        # 手动解压的官方 Node（临时置顶，见 §2.4）
├── .local/bin/               # 用户自置脚本
├── .nix-profile → ~/.local/state/nix/profiles/profile   # Nix 提供的 CLI 全在这里
├── Desktop / Documents / Downloads / Pictures / …        # macOS 默认目录
└── Library/                  # macOS 应用数据，不手动改
```

**速查：想干什么 → 去哪**

| 想干什么 | 去哪 |
| --- | --- |
| 改 shell、装 CLI 工具、改别名 / PATH | `~/.config/home-manager/home.nix`（§2） |
| 写代码、起项目 dev server | `~/Code/`（§3） |
| 改某工具配置（git / nvim / direnv…） | `~/.config/<tool>/`；若由 hm 管理则回 `home.nix` |
| 改 agent 的全局行为 | 本文件 |

---

## 2. Shell 环境：home-manager flake（`~/.config/home-manager/`）

整个用户的 shell 环境由这个 home-manager flake 管理（standalone + flakes，远程 `git@github.com:dao77777/dotfile.git`，分支 `main`）。

- **入口**：`flake.nix` — nixpkgs-unstable + home-manager，`homeConfigurations.zephyr`，`aarch64-darwin`
- **全部配置**：`home.nix` — `home.packages`（装包）+ `programs.*`（模块）+ `shellAliases` + `home.sessionPath`
- **应用**：`home-manager switch`
- **验证**：`command -v <新命令>`

### 2.1 不要直接编辑 shell dotfile

`~/.zshrc`、`~/.zshenv`、`~/.zprofile`、`~/.npmrc` 都是 home-manager 生成的**软链，指向 `/nix/store/.../home-manager-files/`**。改它们不会持久，`home-manager switch` 会覆盖回来。

要改 shell 行为 → 改 `home.nix` 里的 `programs.zsh.*` → `home-manager switch`。

### 2.2 环境基调

- **CLI 全部走 Nix**（`~/.nix-profile/bin`），**不引入 Homebrew**
- npm 全局包在 `~/.npm-global`，独立于 Nix，不归本仓库管
- `pnpm` 的 store 固定在 `~/Library/pnpm/store`（pnpm 自己的全局配置，不写进 `.npmrc`）

### 2.3 工具链

由 `home.nix` 提供：zsh + oh-my-zsh + starship、direnv（含 nix-direnv）、git、gh、lazygit、neovim、btop、yazi、zoxide、`nodejs` / `pnpm` / `yarn-berry` / `bun`、go、rustup、process-compose。

### 2.4 注意：全局 node 被临时置顶

`home.sessionPath` 把 `~/.local/share/node/bin` 排在最前，**覆盖 Nix 的 node**：

```
command -v node   # → ~/.local/share/node/bin/node（v24.19.0，手动解压的官方 tarball）
nix 的 node       # → 24.21.0
```

这是为 `deepseek-harness` 的原生插件加的**临时妥协**，原因写在 `home.nix` 的 PATH 注释里。因此：

- 不要假设 `node` 来自 Nix
- 项目若要固定 Node 版本，**用自己的 `flake.nix`**（参考 `~/Code/effect-web`），不要依赖全局 node

---

## 3. 写代码的地方：`~/Code/`

所有项目都放在 **`~/Code/`**。工作区有自己的约定文件 **`~/Code/AGENTS.md`**，进入任何项目前先读它。要点：

- 项目的 dev server 统一由 **process-compose** 管理，**不要**用裸命令（`npm run dev` 等）常驻
- 总入口 `~/Code/process-compose.yaml`；进程名 = 项目目录名，`working_dir: ./<name>`
- 新增 / 删除项目、改启动命令，**必须同步该文件**
- 端口冲突在同一文件里显式分配
- 常用命令：`process-compose up -D`、`process-compose process logs <name>`、`process-compose process restart <name>`

---

## 4. 本仓库（home-manager）专属规则

**仅当工作目录位于 `~/.config/home-manager/` 内时适用。**

### 4.1 改 `home.nix` 必须同步 `README.md`

任何对 `home.nix` 的改动，只要影响到「装了什么、有什么别名 / 功能」，**同一次修改中必须同步更新 `README.md`**：

- 新增 / 删除 `home.packages` 里的包 → 在 README 对应分类表格增删行（选一个最贴切的板块，如 开发 / 文件系统 / 进程与服务管理）
- 新增 `programs.*` 模块，或修改别名、shell 集成 → 同步 README 对应表格
- 按需更新 README 顶部「整理日期」

README 板块与 `home.nix` 的对应：

| README 板块 | `home.nix` 来源 |
| --- | --- |
| 文件系统 / 处理与转换 / 渲染与预览 | `home.packages` 各分类 |
| 开发 | `home.packages` 开发类 + `programs.git` / `programs.direnv` / `programs.neovim` 等 |
| 进程与服务管理 | `home.packages` 中编排类工具 |
| Shell 与系统 | `programs.zsh` / `programs.starship` / `programs.btop` 等 |
| 别名速查 | `programs.zsh.shellAliases` / `initContent` |

### 4.2 改完要应用并验证

```sh
home-manager switch          # 应用配置
command -v <新命令>           # 确认新包可用
```

### 4.3 提交前自检

- `git diff` 中若只改了 `home.nix` 而 `README.md` 无对应改动 → 视为未完成
- 不确定新包该放哪个板块时，保持与现有分类风格一致，不要新造过度细分的分类
- 修改 shell `initContent` 时注意 zsh 加载顺序（如 oh-my-zsh 会覆盖 `bindkey`）

---

## 5. 通用约定

- 默认用中文回答；代码、标识符、commit message 保持英文
- 动手前先读现有文件与约定，不凭猜测
- 只改与任务相关的文件，不做顺手重构
- 破坏性操作（删除、覆盖、改全局配置）先确认
- 声称完成前要真的验证：跑检查 / 实际运行，不要只口头说完成
