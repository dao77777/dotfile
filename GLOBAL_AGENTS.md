# GLOBAL_AGENTS.md — 全局规则

> 本机**所有目录**生效，多个 agent 共用同一份。
> 正本：本文件（`~/.config/home-manager/`，受 git 管理）。**只改这一份，不要改软链另一端。**
> 软链：`~/.pi/agent/AGENTS.md` · `~/.codex/AGENTS.md` · `~/.config/opencode/AGENTS.md` · `~/.claude/CLAUDE.md`
> 优先级：项目 `AGENTS.md` > `~/Code/AGENTS.md` > **本文件**

## 去哪找

| 要什么 | 去哪 |
| --- | --- |
| 装 CLI、改别名 / PATH / shell 行为 | `~/.config/home-manager/home.nix` |
| 写代码、起 dev server | `~/Code/`（先读 `~/Code/AGENTS.md`） |
| 密钥 / 令牌 / 密码 | `~/Code/vault` |
| 某选择**为什么**是这样 | `~/.config/home-manager/docs/` |

## 硬约束

| ❌ 不要 | ✅ 应该 |
| --- | --- |
| 改 `~/.zshrc` `.zshenv` `.npmrc` | 它们是只读软链，会被 `switch` 覆盖 → 改 `home.nix` |
| 用 Homebrew，或手动往 PATH 塞二进制 | 用 `home.packages` |
| 把密钥写进任何被 git 跟踪的文件 | 放 `~/Code/vault` |
| 在输出里回显密钥值 | 只把值传给需要的命令；不打印、不复述 |
| 假设 `node` 来自 Nix | 项目自带 `flake.nix` |
| 在 `~/Code` 裸跑 dev server 常驻 | 走 process-compose |

## 通用约定

- 中文回答；代码、标识符保持英文
- 先读现有约定，再动手，不猜
- 只改与任务相关的文件
- 破坏性操作（删除、覆盖、改全局配置）先确认
- 声称完成前先验证：跑命令，而不是只口头说完成
