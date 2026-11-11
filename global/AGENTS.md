# AGENTS.md — 全局规则

> 本机**所有目录**生效，多个 agent 共用同一份。
> 正本：本文件（`~/Code/_dotfile/global/`，受 git 管理）。**只改这一份，不要改软链另一端。**
> 软链：`~/.pi/agent/AGENTS.md` · `~/.codex/AGENTS.md` · `~/.config/opencode/AGENTS.md` · `~/.claude/CLAUDE.md`
> 优先级：项目 `AGENTS.md` > `~/Code/AGENTS.md` > **本文件**
> ⚠️ 本文件被软链到多处，**只能用 `~` 绝对路径，不能用相对链接**。

## ⚠️ 硬规矩：没有硬规矩

本文件、任何项目 `AGENTS.md`、任何设计文档里的「规则 / 硬规矩 / 别做什么 / 红线」，都是**当前有效的约定**，不是不可动的法律。
**唯一能称为硬规矩的，是这一句：没有硬规矩。**

| 情形 | 怎么做 |
| --- | --- |
| 条文与它写的理由冲突 | **理由优先**；顺手把条文改成与理由一致 |
| 找到更好的做法 | 直接改；把**代价**与**复查条件**写进 `docs/decisions/`，别默默违反 |
| 条文已经过时 | 删掉它，不要留着「以防万一」 |
| 想用「规矩这么写的」当理由 | 这不是理由。说清它当初防的是什么，再判断那件事还成不成立 |
| 用户/上层明确要求绕开某条 | 照做，同时把这条标成 superseded，别留两份相反的说法 |

判断标准只有一条：**改完之后，下一个人能不能从文档里看出为什么这样改**。看不出，就是改坏了，而不是改错了。

## 本机拓扑

```
~/Code/_dotfile/               ⭐ 环境正本：CLI / 别名 / PATH / shell 都由它生成
│   ├── home.nix                   全部配置（装包 / 模块 / 别名 / PATH / 环境变量）
│   ├── global/                    ⭐ 全机信息
│   │   ├── AGENTS.md              本文件
│   │   └── docs/                  全机 / 网络排障文档
│   └── docs/                      本仓库（CLI / shell 环境）自身的设计与决策
│      （`~/.config/home-manager` 是它的软链；调 Nix 一律用本路径）
│
~/Code/                        ⭐ 代码工作区
│   ├── AGENTS.md                  工作区约定（process-compose 编排）
│   ├── process-compose.yaml       所有 dev server 的统一入口
│   ├── docs/                      文档（按生命周期分目录，见「docs/ 目录规则」）
│   ├── _vault/                    meta：密钥库（私有 git，只存密文）
│   ├── _dotfile/                  meta：home-manager 配置（本文件所在仓库，submodule）
│   ├── _lab/                      meta：试验性项目与临时产物
│   ├── _asset/                    meta：本地大文件资产（模型 / 音视频 / 中间产物），不入 git
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

## 主机清单

我拥有的主机。**凭据一律从 `~/Code/_vault` 取，不写在这里、不写进项目**（键名见「取用」）。

| 主机 | 地址 | 系统 | 角色 / 备注 |
| --- | --- | --- | --- |
| **MacBook Air**（本机） | `192.168.124.4`（Wi-Fi）· `zephyrdeMacBook-Air.local` | macOS | 日常开发机；登录用户 `zephyr`；`~/Code` 在这台；**SSH 未开**（要用时在系统设置里开「远程登录」） |
| **飞牛 NAS** `FN-EVO4-RK3588` | `192.168.124.7` · 别名 `fn` / `fn.local` · `FN-EVO4-RK3588.local` | Debian 12（fnOS） | 存储 / 常开服务；`smb`(445) + `ssh`(22)，用户 `admin`；Samba `netbios aliases = fn` + avahi 服务 `avahi-alias-fn.service` 发布 `fn.local` |
| **Mac mini M6** `Mac-mini-M6` | `192.168.124.17`（**只走网线**，Wi-Fi 已关）· `Mac-mini-M6.local` | macOS | 第二台 Mac；登录用户 `zephyr`；`smb` + `ssh` 都开 |
| **腾讯云 VM** | 地址 / 账号见 `_vault` 的 `TENCENT_VM_*` | Linux | 公网机器（用途以实际部署为准） |

- 局域网网段 `192.168.124.0/24`，网关 `192.168.124.1`（是 NX15000，不是光猫）；主机名走 mDNS（`.local`），不依赖路由器 DNS。
- vault 键：`FN_EVO4_RK3588_{HOST,USER,PASSWORD}`、`MAC_MINI_M6_{HOST,HOSTNAME,USER,PASSWORD}`、`TENCENT_VM_*`、`ONT_*`、`ROUTER_*`。
- 改主机 IP 时**三处一起改**：`_vault`（`sops -e` 封回）、这里的表、`~/.ssh/config`（若有）。
- ⚠️ **别把密码 / 私钥写进本文件或任何入库文件**——本文件的软链到处都在（pi / codex / opencode / claude）。

### 网络设备（两层，别搞混）

| 设备 | 管理地址 | 型号 | 固件 / 硬件 | 网络 |
| --- | --- | --- | --- | --- |
| **光猫**（中国移动，重庆） | `192.168.1.1` | FiberHome **HG6543C4**（智能家庭网关类型3） | 软件 `RP0104` · 硬件 `BM.V3.0` · SN `EC8AC7-FHTT520ED900` | GPON（OLT 厂家 HWTC）；PPPoE 上网，IPv4 为运营商 CGNAT；LAN `192.168.1.0/24` + IPv6 `2409:8a60:3076:de60::/64` |
| **路由器** | `192.168.124.1` · `fe80::124` | H3C Magic **NX15000** | 软件 `NX15000V100R006` · Bootrom `100` · 硬件 `VER.A` · SN `219801A3HN723CK500NG` | LAN `192.168.124.0/24` + IPv6 `2409:8a60:3076:de61::/64`；WAN `192.168.1.2` / `de60::2` |

- 出口顺序：`终端 → NX15000 → 光猫 → 移动`。IPv6 `/60` 由光猫向运营商取，再 PD 一个 `/64` 给 NX15000。
- 凭据：一律见 `_vault`（`ONT_*` 含 PPPoE 账密与 telnet 后门密码、`ROUTER_*`）。
- 这两台的排障过程、IPv6 入站放行方法、工具坑：见 `~/Code/_dotfile/global/docs/`，**不写在本文件**。

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
| 大文件资产（模型权重 / 音视频 / 中间产物） | `~/Code/_asset/` | 进 git、进备份；放**丢信息**的东西（那去 `_lab` / `docs/`） |
| 每日记录 / 工作日志 | `~/Code/docs/logs/`（`YYYY-MM-DD.md`） | 写进项目仓库 |

## 密钥：统一从 `~/Code/_vault` 取

**任何目录下需要密钥 / 令牌 / 密码（API key、服务器地址、SSH 私钥…）→ 去 `~/Code/_vault` 拿。**
不要向用户索要，不要在别处找明文，不要凭猜测写占位值。

- `_vault` 是**私有 git 仓库**（`https://github.com/dao77777/vault`），库内只有密文
  - `env/secrets.enc.yaml` — 全局环境变量（API key、VM 地址、用户名…）
  - `keys/*.enc` — 文件型机密（SSH 私钥、证书…）
- 本机 `env/secrets.yaml` 是明文副本（`chmod 600` + `.gitignore`），**仅用于编辑**
- `SOPS_AGE_KEY_FILE` 已由 home-manager 设好，**新 shell 里 `sops` 零配置可用**

### 取用（按需注入，不要常驻环境变量）

```bash
cd ~/Code/_vault
sops -d --extract '["DEEPSEEK_API_KEY"]' env/secrets.enc.yaml   # 取一个（输出不带换行）
sops exec-env env/secrets.enc.yaml 'your-cmd'                    # 注入进程环境，不落盘
sops -d --output-type dotenv env/secrets.enc.yaml > <项目>/.env   # 生成 .env（须被 gitignore 挡住）
sops -d keys/ssh-macbook-air.enc > ~/.ssh/id_ed25519             # 恢复文件型机密
```

### 增改密钥

```bash
cd ~/Code/_vault
$EDITOR env/secrets.yaml                         # 改明文
sops -e env/secrets.yaml > env/secrets.enc.yaml  # 封回密文
git add env/secrets.enc.yaml && git commit       # 只提交密文
```

### 硬规矩（红线）

- ⚠️ **密钥值不得出现在任何输出里**：不要 `echo` / `cat` / 打印，也不要复述到对话里（会进会话记录）
- **只有 `.enc` 能进 git**；`.sops.yaml` 只含 age 公钥，可以入库
- age 私钥 `~/.config/sops/age/keys.txt`（本机）：**永不复制、永不提交、永不外传**
- 项目要密钥时，让**启动命令自己注入**（项目零感知），不要往项目里塞明文
- 原理、macOS 路径坑与排错 → `~/Code/docs/knowledge/sops-age-secrets.md`

## 命名：`.` / `_` / `@` 前缀

| 前缀 | 语义 | 谁读写 | 可见性 | 例 |
| --- | --- | --- | --- | --- |
| `.` | **工具的领地**：实现细节 / 本地状态，删了可重建 | 工具自动 | `ls` 默认隐藏 | `.git` `.vscode` `.direnv` |
| `_` | **人的领地**：工作区 meta，是你的资产，但不被当作普通单元 | 你手动 | 默认可见且排最前 | `_lab` `_vault` `_asset` `_dotfile` |
| `@` | **别人的领地**：外部仓库（上游 / 参考），只读引用，**你不能 push** | 上游维护 | 默认可见 | `@deepseek-harness` |
| 无 | 正常内容，或生态保留名（`README.md` `AGENTS.md` `docs/`） | 人 / 双方 | 正常 | `effect-web/` |

- 判据：**这是谁的东西？** 工具的用 `.`，你的 meta 用 `_`，别人的库用 `@`，其余用普通名。
- `docs/` 内的 `_` 子目录（如 `knowledge/_timelines/`）沿用同一思路：**该类目的规则与索引排最前**，内容按专题分在旁边。
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
| `examples/` | 示例：可运行的最小样板 / 用法片段（能直接抄的那种，不是教程） | 随 API / 接口变化更新 |
| `README.md` | **全部文档的索引**：链接 + 一句话描述 | 随文档增删 |
| `appendix.md` | 服务于其它文档的补充（术语表 / 来源 / 索引） | —— |

- `README.md` 只做**导航**：逐篇列出**链接 + 描述**（覆盖什么、什么时候看），不写规范、不重复正文。
- 判据（信息往哪写）：**全机拓扑 / 归属 / 命名等规范** → 本文件；**怎么跑 / 有哪些功能** → 仓库根 `README.md`；**agent 动手前必须遵守** → 该层 `AGENTS.md`；其余按上表加工阶段——**原始 → 草稿 → 方案 / 取舍 → 沉淀**。
- **大件二进制不进 `docs/`**：模型权重、音视频、中间产物这类“删了只损失时间、不损失信息”的东西 → `~/Code/_asset/`。
- 定稿内容不得滞留 `drafts/`；能被上表某类吸收的，不要塞进 `appendix.md`。
- 子目录内可再按专题分（如 `knowledge/_timelines/`、`knowledge/ai/`）；`logs/` `progress/` `knowledge/` `examples/` 用到再建，`designs/` `decisions/` `drafts/` 建议先备好。
- `examples/` 只收**能跑 / 能抄**的完整片段（含它需要的输入与环境说明），不放「怎么用」的讲解——讲解归 `knowledge/`，方案归 `designs/`。
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
- `~/Code` 下 **`_` 前缀目录是工作区 meta（`_lab` `_vault` `_asset` `_dotfile`），不是项目**，目录名以 `_` 与普通项目区分
- 破坏性操作（删除、覆盖、改全局配置）先确认
- 声称完成前先验证：跑命令，而不是只口头说完成
