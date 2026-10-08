# 顶层设计

> ⭐ **先读这篇。**其余 design 文档都是它的展开；decision 文档是落地时对它的取舍。
> 本机目录拓扑（全机信息）在 `~/.config/home-manager/GLOBAL_AGENTS.md`。

## 目标（按优先级）

| # | 目标 | 意味着 |
| --- | --- | --- |
| 1 | **可重现** | 换台机器 `git clone` + `switch` 就得到同样环境；不依赖手工步骤 |
| 2 | **单一真源** | 每个事实只存在一处；其余都是软链或指针，不复制 |
| 3 | **最小意外** | 不魔改标准工具；每一处偏离常规都必须在 `decision/` 留痕 |

## 三层结构

```
┌─ 环境层 ── Nix（home-manager）───────────────────────────────┐
│  唯一真源   ~/.config/home-manager/{flake,home}.nix           │
│  产物       ~/.nix-profile/bin（所有 CLI） + 软链的 dotfile   │
│  硬约束     store 只读且全世界可读 → 不放密钥，也不当工作区   │
└──────────────────────────────────────────────────────────────┘
                             │ 提供
┌─ 工具链层 ── packages + shell ───────────────────────────────┐
│  [packages.md](packages.md)   装了哪些 CLI、怎么分类          │
│  [shell.md](shell.md)         shell 怎么组织、别名、加载链    │
│  [secrets.md](secrets.md)     密钥怎么接进环境                │
└──────────────────────────────────────────────────────────────┘
                             │ 被使用
┌─ 项目层 ── ~/Code/<project> ─────────────────────────────────┐
│  运行时由**项目自己的** flake.nix 锁定                        │
│  dev server 统一走 process-compose（见 ~/Code/AGENTS.md）    │
└──────────────────────────────────────────────────────────────┘
```

### 环境层的事实

| 项 | 值 |
| --- | --- |
| 形态 | standalone + flakes（**不是** nix-darwin） |
| 输入 | `nixpkgs-unstable` + `home-manager`，版本由 `flake.lock` 锁定 |
| 配置 | `homeConfigurations.zephyr`，`aarch64-darwin` |
| 入口 | `flake.nix`（devShell） → `home.nix`（一切） |
| 远端 | `https://github.com/dao77777/dotfile.git`，分支 `main` |

## 设计原则

| 原则 | 具体体现 |
| --- | --- |
| **环境归 Nix，业务归项目** | 本仓库只装通用 CLI；项目依赖一律进项目自己的 `flake.nix` |
| **正本唯一，其余皆指针** | dotfile 是软链、`GLOBAL_AGENTS.md` 是软链、文档相互引用而非复制 |
| **宁可显式多写一行** | 例：`SOPS_AGE_KEY_FILE` 显式指路，因为 macOS 默认路径反直觉 |
| **妥协必须留痕** | 临时方案进 `decision/`，且必须写「代价」与「复查条件」 |

## 管 / 不管

本仓库只管**通用 CLI 与 shell 环境**；其余归属见 `GLOBAL_AGENTS.md` 的「归谁管」。
具体到本仓库，边界是：

| 本仓库管 | 不管（归别人） |
| --- | --- |
| CLI 工具、别名、PATH、环境变量 | npm 全局包 → `~/.npm-global` |
| shell 行为与提示符 | 项目依赖与 node 版本 → 项目自带 flake |
| 工具的配置文件（git / nvim / direnv…） | dev server 生命周期 → process-compose |
| 密钥工具的**接线** | 密钥内容本身 → `~/Code/vault` |

## 为什么正本放在 `.config/home-manager/`

三个约束推导出来的：

```
① 配置必须由 Nix 生成     → 不能直接改 ~/.zshrc（软链，会被覆盖）
② 必须能跨机器重现         → 要有 git 仓库 + flake
③ agent 要能读到全局规则   → 各 agent 的全局文件软链到本目录

  ⇒ 本目录同时是「环境正本」和「全局规则正本」，只改这一份
```

## 文档怎么组织

`design/` 是什么 · `decision/` 为什么 · `appendix.md` 拿不准 —— 详见 [`docs/README.md`](../README.md)。
**全机信息**（目录拓扑、归属）不进这里，进 `GLOBAL_AGENTS.md`。
