# docs

本仓库的**决策记录**与**设计说明**。

> 规则在 [`../AGENTS.md`](../AGENTS.md)（本仓库）+ [`../GLOBAL_AGENTS.md`](../GLOBAL_AGENTS.md)（全局）；
> 清单在 [`../README.md`](../README.md)。**"为什么这么做"全在这里。**

## 两个目录

| 目录 | 放什么 | 回答的问题 |
| --- | --- | --- |
| [`decision/`](decision/) | 选型、取舍、妥协、代价、复查条件 | *为什么是现在这样？* |
| [`design/`](design/) | 结构图、数据流、硬规矩、操作步骤 | *它长什么样、怎么用？* |

同题**成对**出现，例如：

```
decision/secrets-sops-age.md   为什么选 sops + age
design/secrets-sops-age.md     密钥体系的具体结构与用法
```

目录名已经表达了类型，**文件名不再加前缀**。

## 索引

| 文档 | 什么时候看 |
| --- | --- |
| [design/layout.md](design/layout.md) | 想知道某个东西该放哪、归谁管 |
| [design/shell-config.md](design/shell-config.md) | 改 zsh / 别名 / 加载顺序 |
| [design/secrets-sops-age.md](design/secrets-sops-age.md) | 要密钥、换机器、加密钥 |
| [decision/runtime-node.md](decision/runtime-node.md) | node 版本怪异、`pnpm dsh` 启动失败 |
| [decision/packages-npm-pnpm.md](decision/packages-npm-pnpm.md) | 装全局包、pnpm 报 store 相关错 |
| [decision/secrets-sops-age.md](decision/secrets-sops-age.md) | 想知道密钥为什么这么放、什么时候该换方案 |

## 骨架

### `decision/`

```md
# 决策：<一句话结论>
> 状态: 生效中 / ⚠️ 临时妥协（计划移除） / 已废弃 · 起始 YYYY-MM · 落点: home.nix 的哪一段

## 问题        一句话说清要解决什么
## 决定        最终怎么做的（给最小可读的证据：那几行配置 / 那张图）
## 理由        为什么，含可复现的证据（命令、日志路径）
## 代价        这个选择带来的坏处
## 复查条件    什么情况下该把它推翻（含具体回退动作）
```

**"代价"和"复查条件"最容易被忽略，也最重要** —— 没有它们，临时妥协会变成永久负债。

### `design/`

```md
# 设计：<对象>
> 状态 · 落点

结构图 → 各层职责表 → 数据流 → 硬规矩
```

两种都要求**一屏能看完**。
