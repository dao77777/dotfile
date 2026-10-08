# GLOBAL_AGENTS.md — 全局规则

> 本机**所有目录**生效，多个 agent 共用同一份。
> 正本：本文件（`~/.config/home-manager/`，受 git 管理）。**只改这一份，不要改软链另一端。**
> 软链：`~/.pi/agent/AGENTS.md` · `~/.codex/AGENTS.md` · `~/.config/opencode/AGENTS.md` · `~/.claude/CLAUDE.md`
> 优先级：项目 `AGENTS.md` > `~/Code/AGENTS.md` > **本文件**

## 本机拓扑

| 位置 | 是什么 | 什么时候去 |
| --- | --- | --- |
| `~/.config/home-manager/` | 环境正本：CLI / 别名 / PATH / shell 都由它生成 | 装工具、改 shell 行为 |
| `~/Code/<project>/` | 代码项目 | 写代码、起 dev server（先读 `~/Code/AGENTS.md`） |
| `~/Code/vault/` | 密钥库（私有 git，只存密文） | 要密钥 / 令牌 / 密码 |
| `~/.config/<tool>/` | 工具自己的配置 | 改 git / nvim / direnv… |
| `~/Code/tmp/` | 临时产物与调研文档 | 放一次性的东西 |

> 完整目录树（macOS 目录、agent 数据目录、Nix profile 位置）见
> `~/.config/home-manager/docs/design/layout.md`。
> 本文件**只能用绝对路径**（它被软链到多处，相对链接会断）。

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
