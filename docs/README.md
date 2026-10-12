# docs

本仓库的**顶层设计**与**关键决策**。分类、写作规范与骨架见 [`../GLOBAL_AGENTS.md`](../GLOBAL_AGENTS.md)「docs/ 目录规则」。

## 顶层设计

| 文档 | 覆盖 | 什么时候看 |
| --- | --- | --- |
| [designs/overview.md](designs/overview.md) | ⭐ 目标、三层结构、设计原则、管/不管 | **先读这篇** |
| [designs/packages.md](designs/packages.md) | 装了哪些工具（分类清单） | 想知道有什么可用 |
| [designs/shell.md](designs/shell.md) | shell 组织、加载链、别名 | 改 zsh / 别名 |
| [designs/secrets.md](designs/secrets.md) | 密钥体系 | 要密钥、换机器 |

## 关键决策

| 文档 | 矛盾 | 所属设计 |
| --- | --- | --- |
| [decisions/runtime-node.md](decisions/runtime-node.md) | nixpkgs 的 node 跑不了 `pnpm dsh`，官方的可以 | packages / shell |
| [decisions/npm-pnpm-paths.md](decisions/npm-pnpm-paths.md) | npm 全局包与 pnpm store 都不能用默认位置 | packages |
| [decisions/secrets-sops-age.md](decisions/secrets-sops-age.md) | 密钥既不能进 git/store/env，又要跨机器且能无人取用 | secrets |

## 其它

- [appendix.md](appendix.md) — 零散备忘（故意不分类）
