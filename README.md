# 当前环境软件清单

> 由 home-manager 管理（`home.nix` 的 `home.packages` + `programs.*` 模块），2026-09-25 整理。

## 文件系统

### 浏览与管理

| 软件 | 用途 |
|---|---|
| yazi | 终端文件管理器（`y` 包装，退出自动 cd） |
| eza | ls 替代（图标 + git 状态） |
| zoxide | 智能 cd（`z` 命令） |
| dua | 交互式磁盘占用分析（`dua i`） |
| duf | 磁盘使用情况总览 |

### 搜索与查找

| 软件 | 用途 |
|---|---|
| fd | find 替代 |
| ripgrep | grep 替代 |
| fzf | 模糊查找（可配合 fd/rg/bat） |

### 处理与转换

| 软件 | 用途 |
|---|---|
| jq | JSON 查询与转换 |
| yq | YAML 处理（Python 版，复用 jq 语法，`-y` 输出 YAML） |
| p7zip | 7z/7za/7zr 压缩解压 |
| curl / wcurl | 网络下载（wcurl 随 curl 附带） |
| wget | 网络下载（GNU Wget） |

### 渲染与预览

| 软件 | 用途 |
|---|---|
| poppler-utils | PDF 渲染（pdftoppm/pdftotext，供 yazi 预览） |
| resvg | SVG 渲染 |
| ffmpeg | 音视频解码、抽帧（供 yazi 视频预览） |
| imagemagick | 图片处理（magick/convert） |
| bat | 代码/文本高亮渲染 |

## 开发

| 软件 | 用途 |
|---|---|
| git | 版本控制 |
| gh | GitHub CLI |
| lazygit | Git 终端 TUI |
| scalar | 巨型仓库加速（随 git 附带） |
| nodejs | Node.js 通用版（nixpkgs 默认 nodejs，当前 24.x LTS）含 npm/npx/corepack；已被官方 Node 临时覆盖，见备注 |
| pnpm | Node 包管理器（含 pnpx；由 Nix 独立提供，不依赖 Node 自带工具链） |
| yarn-berry | Yarn 4.x（含 yarn/yarnpkg） |
| bun | Bun 运行时 / 包管理器 / 测试器 |
| go | Go 工具链 |
| rustup | Rust 全家桶（rustc/cargo/rust-analyzer/rustfmt/clippy） |
| nvim | 编辑器 |
| direnv | 目录级环境自动切换（含 nix-direnv） |

## 进程与服务管理

| 软件 | 用途 |
|---|---|
| process-compose | 多进程编排（`process-compose up/down/restart`，带 TUI 日志与状态） |

## Shell 与系统

| 软件 | 用途 |
|---|---|
| zsh | 主 shell（oh-my-zsh + vi 模式） |
| starship | 提示符 |
| pfetch | 系统信息展示 |
| btop | 系统监控（Catppuccin Frappe 主题） |

## Nix 生态

| 软件 | 用途 |
|---|---|
| home-manager | 配置管理器自身 |

## 别名速查

| 别名 | 内容 | 说明 |
|---|---|---|
| `l` / `ls` | eza 网格 | 横向 |
| `la` | eza -a | 横向 + 隐藏 |
| `ll` | eza -l --git | 竖向详细 |
| `lla` | eza -la --git | 竖向 + 隐藏 |
| `lt` | eza 树形 | 2 层 |
| `y` | yazi 包装函数 | 退出自动 cd 到浏览目录 |
| `v`/`vi`/`vim` | nvim | |
| `g`/`gs`/`gl`/`ga`/`gc`/`gp`/`gpl`/`gd`/`gco`/`gb` | git 简写 | |
| `..`/`...`/`....` | cd 上级 | |
| `c` | clear | |
| `bt` | btop | |
| `bathelp` | bat 渲染 help 输出 | |
| `fzfp` | fzf + bat 预览 | |
| `rgi` | rg -i | |
| `h` | history | |
| `ports` | 查看监听端口 | |
| `reload` | source ~/.zshrc | |

## 备注

- CLI 全部走 Nix（`~/.nix-profile`），无 Homebrew
- Node 使用 nixpkgs 通用属性 `nodejs`（当前 24.x LTS），随 nixpkgs-unstable 自动跟随，不再手动指定版本
- corepack 随 nodejs 24.x 提供；上游自 Node 25+ 起移除
- **【临时妥协】官方 Node 置顶**：`home.sessionPath` 里 `~/.local/share/node/bin` 排在 `~/.nix-profile/bin` 之前，覆盖 nixpkgs 构建的 `node`（该目录为手动解压的官方 tarball，链到 `node-v24.19.0-darwin-arm64`）
  - 原因：DeepSeek Harness 源码启动（`pnpm dsh`）依赖原生插件 `node-addon-require-builtin` 扫描 arm64 机器码定位 `PrincipalRealm::builtin_module_require`；nixpkgs 的 cc-wrapper 默认加 `-fno-omit-frame-pointer`，使该 getter 多出栈帧指令，插件匹配失败报 `Unsupported/no-getter`，而官方 Node 省略 frame pointer 可正常工作
  - 仅覆盖 `node` 解析，Nix 的 `nodejs`/`pnpm` 仍保留；`pnpm` 会从 PATH 取 node 执行脚本
  - 计划：等 Node 版本升级（或 nixpkgs / `node-addon-require-builtin` 修复）后，先验证 `pnpm dsh` 源码启动不再报错，再删除此条目与 `~/.local/share/node`，回归纯 Nix
- go / rustup 当前无活跃项目使用（~/Code 下均为 TypeScript/JS 项目）
- npm 全局包（`~/.npm-global`）独立于 Nix：
  - opencode-ai
  - @earendil-works/pi-coding-agent
- pnpm 包仓库固定为 `~/Library/pnpm/store`，写在 pnpm 自己的全局配置 `~/Library/Preferences/pnpm/config.yaml`（键 `storeDir`）：
  - 不放进 `.npmrc`：`store-dir` 是 pnpm 专有键，npm 会报 `Unknown user config` 警告
  - 值必须是绝对路径：`~` 开头会触发 pnpm 的「仓库可写性探测」，探测失败时它会退化为在项目祖先目录另建 `.pnpm-store`（受限环境如 DSH 沙箱下会污染 `~/Code`）
- nix flake 输入：nixpkgs-unstable + home-manager，2026-09-11 已更新
