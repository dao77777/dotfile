# GLOBAL_AGENTS.md — 全局规则

> 本机**所有目录**生效，多个 agent 共用同一份。
> 正本：本文件（`~/.config/home-manager/`，受 git 管理）。**只改这一份，不要改软链另一端。**
> 软链：`~/.pi/agent/AGENTS.md` · `~/.codex/AGENTS.md` · `~/.config/opencode/AGENTS.md` · `~/.claude/CLAUDE.md`
> 优先级：项目 `AGENTS.md` > `~/Code/AGENTS.md` > **本文件**
> ⚠️ 本文件被软链到多处，**只能用 `~` 绝对路径，不能用相对链接**。

## 本机拓扑

```
~/.config/home-manager/        ⭐ 环境正本：CLI / 别名 / PATH / shell 都由它生成
│   ├── home.nix                   全部配置（装包 / 模块 / 别名 / PATH / 环境变量）
│   ├── GLOBAL_AGENTS.md           本文件
│   └── docs/                      顶层设计与决策
│
~/Code/                        ⭐ 代码工作区
│   ├── AGENTS.md                  工作区约定（process-compose 编排）
│   ├── process-compose.yaml       所有 dev server 的统一入口
│   ├── vault/                     密钥库（私有 git，只存密文）
│   ├── tmp/                       临时产物与调研文档
│   └── <project>/                 一个项目一个目录
│
~/.config/<tool>/              工具自己的配置（git / nvim / btop / direnv…）
~/.config/sops/age/keys.txt    age 私钥（600，永不外传）
~/.npm-global/                 npm 全局包（不归 Nix 管）
~/.nix-profile/                Nix 提供的 CLI 全在这里

~/.zshrc  ~/.zshenv  ~/.npmrc  软链 → /nix/store（只读，勿直接改）
~/.pi/  ~/.codex/  ~/.opencode/ agent 运行数据
Library/  Desktop/  …          macOS 自己的，不手动改
```

## 归谁管 · 别做什么

| 什么 | 归谁 | ❌ 不要 |
| --- | --- | --- |
| CLI、别名、PATH、shell 行为 | `~/.config/home-manager/home.nix` | 改 `~/.zshrc` `.zshenv` `.npmrc`（只读软链，会被 `switch` 覆盖）；用 Homebrew 或手动往 PATH 塞二进制 |
| 工具配置（git / nvim / direnv…） | `~/.config/<tool>/`；被 home-manager 接管的回 `home.nix` | —— |
| npm 全局包 | `~/.npm-global`（**不归本仓库**） | —— |
| 项目依赖、node 版本 | 项目自己的 `flake.nix` | 假设 `node` 来自 Nix |
| dev server 起停 | `~/Code/process-compose.yaml` | 在 `~/Code` 裸跑 `npm run dev` 常驻 |
| 密钥、令牌、密码 | `~/Code/vault` | 写进被 git 跟踪的文件；在输出里回显（会进会话记录） |
| 一次性产物、调研 | `~/Code/tmp/` | 塞进项目仓库 |

## 通用约定

- 中文回答；代码、标识符保持英文
- 先读现有约定，再动手，不猜
- 只改与任务相关的文件
- 破坏性操作（删除、覆盖、改全局配置）先确认
- 声称完成前先验证：跑命令，而不是只口头说完成
