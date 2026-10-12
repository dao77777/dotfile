# AGENTS.md — home-manager 仓库

> **仅本目录生效。** 全局规则见 [`GLOBAL_AGENTS.md`](GLOBAL_AGENTS.md) —— 那份才是软链到各 agent 的。

## 改 `home.nix` 的三步

```
① 改 home.nix
② 同一次修改里同步文档（对应关系见下）
③ home-manager switch && command -v <新命令>      # 路径应在 ~/.nix-profile/bin 下
```

## 改动 → 文档往哪写

| 改了什么 | 写哪 |
| --- | --- |
| `home.packages` 增删 | [`docs/designs/packages.md`](docs/designs/packages.md) |
| 别名、shell 集成、`programs.*` | [`docs/designs/shell.md`](docs/designs/shell.md) |
| 一个"为什么这么做"的取舍 | `docs/decisions/` 新增一篇 |
| 结构 / 流程变化 | `docs/designs/` 对应文档 |

## 提交前

- [ ] `home.nix` 改了 → 上表对应的文档同步了
- [ ] 新包验证过：`command -v <cmd>`，路径在 `~/.nix-profile/bin` 下
- [ ] `git diff` 里没有密钥 / 令牌 / 私钥
- [ ] 破坏性操作已先问过

## 备忘

- commit：`type: 中文描述`（type 用英文，描述用中文）
- 推送方式、验证陷阱、零散知识 → [`docs/appendix.md`](docs/appendix.md)
