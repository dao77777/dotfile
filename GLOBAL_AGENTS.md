# GLOBAL_AGENTS.md — 全局规则

> 本机**所有目录**生效，多个 agent 共用同一份。
> 正本：本文件（`~/.config/home-manager/`，受 git 管理）。**只改这一份，不要改软链另一端。**
> 软链：`~/.pi/agent/AGENTS.md` · `~/.codex/AGENTS.md` · `~/.config/opencode/AGENTS.md` · `~/.claude/CLAUDE.md`
> 优先级：项目 `AGENTS.md` > `~/Code/AGENTS.md` > **本文件**
> ⚠️ 本文件被软链到多处，**只能用 `~` 绝对路径，不能用相对链接**。

## 本机拓扑

```
~/.config/home-manager/        ⭐ 环境正本：CLI / 别名 / PATH / shell 都由它生成
│   ├── home.nix                   全部配置（装包 / 模块 / 别名 / PATH / 环境变量）
│   ├── GLOBAL_AGENTS.md           本文件
│   └── docs/                      文档（按生命周期分目录，见「docs/ 目录规则」）
│
~/Code/                        ⭐ 代码工作区
│   ├── AGENTS.md                  工作区约定（process-compose 编排）
│   ├── process-compose.yaml       所有 dev server 的统一入口
│   ├── docs/                      文档（按生命周期分目录，见「docs/ 目录规则」）
│   ├── _vault/                    meta：密钥库（私有 git，只存密文）
│   ├── _lab/                      meta：试验性项目与临时产物
│   └── <project>/                 长期主力项目（一个项目一个目录）
│
~/.config/<tool>/              工具自己的配置（git / nvim / btop / direnv…）
~/.config/sops/age/keys.txt    age 私钥（600，永不外传）
~/.npm-global/                 npm 全局包（不归 Nix 管）
~/.nix-profile/                Nix 提供的 CLI 全在这里

~/.zshrc  ~/.zshenv  ~/.npmrc  软链 → /nix/store（只读，勿直接改）
~/.pi/  ~/.codex/  ~/.opencode/ agent 运行数据
Library/  Desktop/  …          macOS 自己的，不手动改
```

## 归谁管 · 别做什么

| 什么 | 归谁 | ❌ 不要 |
| --- | --- | --- |
| CLI、别名、PATH、shell 行为 | `~/.config/home-manager/home.nix` | 改 `~/.zshrc` `.zshenv` `.npmrc`（只读软链，会被 `switch` 覆盖）；用 Homebrew 或手动往 PATH 塞二进制 |
| 工具配置（git / nvim / direnv…） | `~/.config/<tool>/`；被 home-manager 接管的回 `home.nix` | —— |
| npm 全局包 | `~/.npm-global`（**不归本仓库**） | —— |
| 项目依赖、node 版本 | 项目自己的 `flake.nix` | 假设 `node` 来自 Nix |
| dev server 起停 | `~/Code/process-compose.yaml` | 在 `~/Code` 裸跑 `npm run dev` 常驻 |
| 密钥、令牌、密码 | `~/Code/_vault` | 写进被 git 跟踪的文件；在输出里回显（会进会话记录） |
| 文档（调研 / 设计 / 决策 / 知识…） | 各自的 `docs/`（工作区级为 `~/Code/docs/`） | 散落在项目根或仓库外 |
| 试验性项目、一次性产物 | `~/Code/_lab/` | 塞进项目仓库 |
| 每日记录 / 工作日志 | `~/Code/docs/logs/`（`YYYY-MM-DD.md`） | 写进项目仓库 |

## 命名：`.` 与 `_` 前缀

| 前缀 | 语义 | 谁读写 | 可见性 | 例 |
| --- | --- | --- | --- | --- |
| `.` | **工具的领地**：实现细节 / 本地状态，删了可重建 | 工具自动 | `ls` 默认隐藏 | `.git` `.vscode` `.direnv` |
| `_` | **人的领地**：工作区 meta，是你的资产，但不被当作普通单元 | 你手动 | 默认可见且排最前 | `_lab` `_vault` |
| 无 | 正常内容，或生态保留名（`README.md` `AGENTS.md` `docs/`） | 人 / 双方 | 正常 | `deepseek-harness/` |

- 判据：**这是谁的东西？** 工具的用 `.`，你的 meta 用 `_`，其余用普通名。
- 保留名（`README.md` `AGENTS.md` `LICENSE`、`tmp/` 等）的含义与行为由**外部约定**定义、不可改；用前先确认行为与用途一致——`tmp/` 的“易失”契约就不适合要长期保留的内容。

## docs/ 目录规则

一切文档归入 `docs/`，按**加工到哪一步**分目录；越靠右越定稿、越可信、越长寿。

| 目录 | 放什么 | 可变性 |
| --- | --- | --- |
| `logs/` | 原始流水：时间线上一事一记（`YYYY-MM-DD.md`），含每日记录 | 只增不改 |
| `drafts/` | 未定稿草稿，允许烂尾 | 随便改 / 可删 |
| `designs/` | 方案：要做什么、怎么做 | 随实现修订 |
| `decisions/` | 取舍：为什么这么定（背景 / 选项 / 决定 / 后果） | 一旦接受即冻结，改动另开一条 supersede |
| `progress/` | 当前状态快照：现在到哪了；历史留在 `logs/` | 覆盖式 |
| `knowledge/` | 沉淀知识：事情怎么运作，稳定、答案型 | 稳定 |
| `README.md` | **全部文档的索引**：链接 + 一句话描述 | 随文档增删 |
| `appendix.md` | 服务于其它文档的补充（术语表 / 来源 / 索引） | —— |

- `README.md` 只做**导航**：逐篇列出**链接 + 描述**（覆盖什么、什么时候看），不写规范、不重复正文。
- 判据（信息往哪写）：**全机拓扑 / 归属 / 命名等规范** → 本文件；**怎么跑 / 有哪些功能** → 仓库根 `README.md`；**agent 动手前必须遵守** → 该层 `AGENTS.md`；其余按上表加工阶段——**原始 → 草稿 → 方案 / 取舍 → 沉淀**。
- 定稿内容不得滞留 `drafts/`；能被上表某类吸收的，不要塞进 `appendix.md`。
- 子目录内可再按专题分（如 `knowledge/timelines/`）；`logs/` `progress/` `knowledge/` 用到再建，`designs/` `decisions/` `drafts/` 建议先备好。
- 项目自己的文档放项目 `docs/`，工作区级放 `~/Code/docs/`，共用这一套规则。

### 写作规范

- **一屏能看完**：一图一表优先于成段文字；超过一屏就该拆。
- 主次分明：结论在前，细节在后；关键项用 ⚠️ / **粗体**标，别滥用。
- **不写默认知识**；**不复制**——同一事实只出现一处，其余用链接。
- 决策必写两条：**代价** 与 **复查条件**，缺了它们临时妥协会变成永久负债。

### 骨架

决策：

```md
# 决策：<一句话结论>
> 状态 · 起始日期 · 所属设计 · 落点

## 矛盾     冲突在哪（表格式对照最好）
## 处理     怎么做的（给最小可读的证据）
## 为什么   为什么是它，其余候选为何落选
## 代价     坏了什么（必须写）
## 复查条件 什么情况下推翻它 + 具体回退动作
```

设计：

```md
# 设计：<对象>
> 顶层设计见 overview.md

结构图 → 各层职责 / 归属 → 操作或数据流 → 硬规矩
```

## 通用约定

- 中文回答；代码、标识符保持英文
- 先读现有约定，再动手，不猜
- 只改与任务相关的文件
- `~/Code` 下 **`_` 前缀目录是工作区 meta（`_lab` `_vault`），不是项目**，目录名以 `_` 与普通项目区分
- 破坏性操作（删除、覆盖、改全局配置）先确认
- 声称完成前先验证：跑命令，而不是只口头说完成
