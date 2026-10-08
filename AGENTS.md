# AGENTS.md — home-manager 仓库规则

> **仅当工作目录位于 `~/.config/home-manager/` 内时适用。**
> 用户级全局规则在 [`GLOBAL_AGENTS.md`](GLOBAL_AGENTS.md)（**那份**才是软链到各 agent 的）。

## 1. 改 `home.nix` 的三步

```
① 改 home.nix
② 同一次修改里同步文档（映射见 §2）
③ home-manager switch && command -v <新命令>
                          └─ 路径应在 ~/.nix-profile/bin 下
```

## 2. 文档同步映射

| 改了什么 | 必须同步 |
| --- | --- |
| `home.packages` 增删 | `README.md` 对应分类表格增删行 |
| `programs.*` 模块、别名、shell 集成 | `README.md`「别名速查」或对应板块 |
| 影响"为什么这么做"的选择 | `docs/decision/` 新增或更新一篇 |
| 结构 / 流程发生变化 | `docs/design/` 对应文档 |
| 只改注释 / 排版 | 不用同步 |

## 3. 提交前自检

- [ ] `home.nix` 有改动 → `README.md` 必须有对应改动（否则视为**未完成**）
- [ ] 新包验证过：`command -v <cmd>` 且路径在 `~/.nix-profile/bin` 下
- [ ] `git diff` 里**没有**密钥 / 令牌 / 私钥
- [ ] 破坏性操作（删除、覆盖、改全局配置）已先问过用户
- [ ] 远端推送用 HTTPS（见 §5），`git push` 后确认 `status -sb` 无 ahead

## 4. 文档边界

| 文件 | 只放 | 不放 |
| --- | --- | --- |
| [`GLOBAL_AGENTS.md`](GLOBAL_AGENTS.md) | 全局规则（对所有目录生效） | 本仓库专属流程 |
| `AGENTS.md`（本文件） | 本仓库的规则 | 清单、决策理由 |
| [`README.md`](README.md) | 清单：装了什么、有什么别名 | 规则、决策理由 |
| `docs/decision/` | **决策**：选型、取舍、代价、复查条件 | 操作步骤 |
| `docs/design/` | **设计**：结构、数据流、操作 | 选型论证 |

骨架与索引见 [`docs/README.md`](docs/README.md)。**不要把决策理由塞回规则或清单文件。**

## 5. 本仓库速查

| 操作 | 命令 |
| --- | --- |
| 应用配置 | `home-manager switch` |
| 格式化 Nix | `nixfmt flake.nix` |
| 查看未读变更 | `home-manager news` |
| 验证新包 | `command -v <cmd>` |

**推送**：remote 是 `https://github.com/dao77777/dotfile.git` + 仓库级
`credential.helper = !gh auth git-credential`。
不用 SSH —— 22 端口在部分网络下被中间设备切断，443 也不稳（走代理兜底规则链），
HTTPS 才是稳定路径。

## 6. commit 风格

`type: 中文描述` —— type 用英文（`feat` / `fix` / `docs` / `chore` / `refactor`），描述用中文。

```
feat: 新增 sops/age 并显式指定 age 私钥路径
docs: 重构文档为「规则 / 清单 / 决策」三层
```
