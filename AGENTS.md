# AGENTS.md

> **用户级全局上下文，对本机所有工作目录生效。**
>
> | | |
> |---|---|
> | 正本 | `~/.config/home-manager/AGENTS.md`（本文件，属 dotfiles 仓库，受 git 管理）|
> | 软链到 | `~/.pi/agent/AGENTS.md` · `~/.codex/AGENTS.md` · `~/.config/opencode/AGENTS.md` · `~/.claude/CLAUDE.md` |
> | 优先级 | 项目 `AGENTS.md` > `~/Code/AGENTS.md` > **本文件** |
>
> **只改这一份，不要改软链另一端。** 新增 agent 时把它的全局文件软链到本文件即可。

## 先读哪

| 你要做的事 | 读 |
| --- | --- |
| 装 CLI / 改别名 / 改 PATH / 改 shell 行为 | 本文件 §2 + [README.md](README.md) |
| 写代码、起 dev server | `~/Code/AGENTS.md` |
| 要密钥 | `~/Code/vault`（见 [docs/secrets-sops-age.md](docs/secrets-sops-age.md)） |
| 想知道**为什么**是现在这样 | `~/.config/home-manager/docs/` |

---

## 1. 硬约束

| ❌ 不要 | 为什么 | ✅ 应该 |
| --- | --- | --- |
| 直接改 `~/.zshrc` `.zshenv` `.npmrc` | 它们是 `/nix/store` 的**只读软链**，`switch` 会覆盖回来 | 改 `home.nix` |
| 引入 Homebrew / 手动往 PATH 塞二进制 | CLI 统一走 Nix | `home.packages` |
| 把密钥写进 `home.nix` 或任何被 git 跟踪的文件 | Nix store 全世界可读；一次提交 = 永久泄漏 | `~/Code/vault` |
| 假设 `node` 来自 Nix | 官方 Node 被临时置顶覆盖了 | 项目用自带 `flake.nix` |
| 在 `~/Code` 裸跑 `npm run dev` 常驻 | 编排统一走 process-compose | 见 `~/Code/AGENTS.md` |

## 2. 改 `home.nix` 的流程

```
① 改 home.nix
② 同一次修改里同步：README.md（清单）+ docs/（若涉及"为什么"）
③ home-manager switch && command -v <新命令>
```

**同步映射**（② 具体改哪）：

| 改了什么 | 必须同步 |
| --- | --- |
| `home.packages` 增删 | README 对应分类表格增删行 |
| `programs.*` 模块、别名、shell 集成 | README「别名速查」或对应板块 |
| 影响"为什么这么做"的选择 | `docs/` 新增或更新一篇决策文档 |
| 只改注释 / 排版 | 不用同步 |

## 3. 提交前自检

- [ ] `git diff` 里 `home.nix` 有改动 → `README.md` 必须有对应改动（否则视为**未完成**）
- [ ] 新包验证过：`command -v <cmd>` 且路径在 `~/.nix-profile/bin` 下
- [ ] diff 里**没有**密钥 / 令牌 / 私钥
- [ ] 破坏性操作（删除、覆盖、改全局配置）已先问过用户

## 4. 文档边界（重要）

| 文件 | 只放 | 不放 |
| --- | --- | --- |
| `AGENTS.md`（本文件） | **规则**：怎么改、别踩什么坑 | 清单、决策理由 |
| `README.md` | **清单**：装了什么、有什么别名 | 规则、决策理由 |
| `docs/` | **决策与设计**：为什么这么做 | 随时会变的清单 |

**不要把决策理由塞回上面两个文件。** 新决策按 `docs/README.md` 的模板写（含"复查条件"）。

## 5. 通用约定

- 默认用中文回答；代码、标识符保持英文。本仓库 commit 用 `type: 中文描述`（如 `feat: 新增 sops/age`）
- 动手前先读现有文件与约定，不凭猜测
- 只改与任务相关的文件，不做顺手重构
- 声称完成前要真的验证：跑命令 / 实际运行，不要只口头说完成
