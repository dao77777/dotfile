# GLOBAL_AGENTS.md — 用户级全局规则

> **对本机所有工作目录生效。**多个 agent 共用同一份。
>
> | | |
> |---|---|
> | 正本 | `~/.config/home-manager/GLOBAL_AGENTS.md`（dotfiles 仓库，受 git 管理） |
> | 软链到 | `~/.pi/agent/AGENTS.md` · `~/.codex/AGENTS.md` · `~/.config/opencode/AGENTS.md` · `~/.claude/CLAUDE.md` |
> | 优先级 | 项目 `AGENTS.md` > 工作区 `~/Code/AGENTS.md` > **本文件** |
>
> **只改这一份，不要改软链另一端。** 新增 agent 时，把它的全局文件软链到本文件即可。
> home-manager 仓库**自己**的规则在 [`AGENTS.md`](AGENTS.md)，只在那个目录内生效。

## 1. 目录速查

```
~/.config/home-manager/    shell 环境正本（Nix 管一切）→ 改这里，别改 ~/.zshrc
~/Code/                    所有代码项目 → 先读 ~/Code/AGENTS.md
~/Code/vault/              密钥库（私有 git，只存密文）
~/.config/<tool>/          工具自己的配置；若被 home-manager 接管则应回改 home.nix
```

| 想干什么 | 去哪 |
| --- | --- |
| 装 CLI / 改别名 / 改 PATH / 改 shell 行为 | `~/.config/home-manager/home.nix` |
| 写代码、起 dev server | `~/Code/`（编排走 process-compose） |
| 要密钥 / 令牌 / 密码 | `~/Code/vault` |
| 改某工具配置 | `~/.config/<tool>/`；先看它是软链还是真文件 |
| 想知道某选择**为什么**这么做 | `~/.config/home-manager/docs/` |

## 2. 硬约束

| ❌ 不要 | 为什么 | ✅ 应该 |
| --- | --- | --- |
| 直接改 `~/.zshrc` `.zshenv` `.npmrc` | 它们是 `/nix/store` 的**只读软链**，`switch` 会覆盖回来 | 改 `home.nix` |
| 用 Homebrew / 手动往 PATH 塞二进制 | CLI 统一走 Nix | `home.packages` |
| 把密钥 / 令牌 / 私钥写进任何**被 git 跟踪**的文件 | Nix store 全世界可读；一次提交 = 永久泄漏 | `~/Code/vault` |
| 在输出里回显密钥值（`echo` / `cat` / 复述到对话） | agent 的输出会进会话记录，等于**第二次泄漏** | 只把值传给需要的命令 |
| 假设 `node` 来自 Nix | 官方 Node 被临时置顶覆盖了 | 项目用自带 `flake.nix` |
| 在 `~/Code` 裸跑 `npm run dev` 常驻 | 编排统一走 process-compose | `~/Code/AGENTS.md` |

## 3. 通用约定

- 默认用**中文**回答；代码、标识符保持英文
- 动手前先读现有文件与约定，**不凭猜测**
- 只改与任务相关的文件，不做顺手重构
- 破坏性操作（删除、覆盖、改全局配置）**先确认**
- 声称完成前要真的验证：跑命令 / 实际运行，不要只口头说完成

## 4. 深入

| 想了解 | 位置 |
| --- | --- |
| 本机环境的设计与决策（为什么这么搭） | `~/.config/home-manager/docs/` |
| 工作区编排约定 | `~/Code/AGENTS.md` |
| home-manager 仓库自身规则 | `~/.config/home-manager/AGENTS.md` |
