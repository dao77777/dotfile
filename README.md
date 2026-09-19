# 当前环境软件清单

> 由 home-manager 管理（`home.nix` 的 `home.packages` + `programs.*` 模块），2026-09-19 整理。

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
| nodejs | Node/npm/npx/corepack |
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
- go / rustup 当前无活跃项目使用（~/Code 下均为 TypeScript/JS 项目）
- npm 全局包（`~/.npm-global`）独立于 Nix：
  - opencode-ai
  - @earendil-works/pi-coding-agent
- nix flake 输入：nixpkgs-unstable + home-manager，2026-09-11 已更新
