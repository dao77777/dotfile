# docs

本仓库的**顶层设计**与其**关键决策**。

```
docs/
├── design/        顶层设计：环境应该长成什么样     → "是什么、怎么组织"
├── decision/      落地时的主要矛盾与处理方式       → "为什么是这样"
└── appendix.md    零散备忘（故意不分类）
```

**判断一条信息往哪写**：是什么 → `design/`；为什么 → `decision/`；拿不准 → `appendix.md`。
规则在 [`../AGENTS.md`](../AGENTS.md)（本仓库）+ [`../GLOBAL_AGENTS.md`](../GLOBAL_AGENTS.md)（全局）。

## 顶层设计

| 文档 | 覆盖 | 什么时候看 |
| --- | --- | --- |
| [design/overview.md](design/overview.md) | ⭐ 目标、三层结构、设计原则、管/不管 | **先读这篇** |
| [design/layout.md](design/layout.md) | 目录结构与归属边界 | 不知道某个东西该放哪 |
| [design/packages.md](design/packages.md) | 装了哪些工具（分类清单） | 想知道有什么可用 |
| [design/shell.md](design/shell.md) | shell 组织、加载链、别名 | 改 zsh / 别名 |
| [design/secrets.md](design/secrets.md) | 密钥体系 | 要密钥、换机器 |

## 关键决策

| 文档 | 矛盾 | 所属设计 |
| --- | --- | --- |
| [decision/runtime-node.md](decision/runtime-node.md) | nixpkgs 的 node 跑不了 `pnpm dsh`，官方的可以 | packages / shell |
| [decision/npm-pnpm-paths.md](decision/npm-pnpm-paths.md) | npm 全局包与 pnpm store 都不能用默认位置 | packages |
| [decision/secrets-sops-age.md](decision/secrets-sops-age.md) | 密钥既不能进 git/store/env，又要跨机器且能无人取用 | secrets |

## 写作规范

| 规范 | 说明 |
| --- | --- |
| **一屏能看完** | 一图一表优先于成段文字；超过一屏就该拆 |
| 主次分明 | 结论在前，细节在后；关键项用 ⚠️ / **粗体**标，但别滥用 |
| 不写默认知识 | 默认就该知道的 → 不要写；拿不准 → 丢 [`appendix.md`](appendix.md) |
| **不复制** | 同一事实只出现一处，其余用链接 |
| 决策必写两条 | **代价** 与 **复查条件** —— 缺了它们，临时妥协会变成永久负债 |

### 骨架

```md
# 决策：<一句话结论>
> 状态 · 起始日期 · 所属设计 · 落点

## 矛盾     冲突在哪（表格式对照最好）
## 处理     怎么做的（给最小可读的证据）
## 为什么   为什么是它，其余候选为何落选
## 代价     坏了什么（必须写）
## 复查条件 什么情况下推翻它 + 具体回退动作
```

```md
# 设计：<对象>
> 顶层设计见 overview.md

结构图 → 各层职责 / 归属 → 操作或数据流 → 硬规矩
```
