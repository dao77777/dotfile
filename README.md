# 当前环境软件清单

> home-manager 管理（`home.nix` 的 `home.packages` + `programs.*`），整理日期 2026-10。
>
> **本文件只列"装了什么"。** 怎么改、有哪些坑 → [AGENTS.md](AGENTS.md)；为什么这么做 → [docs/](docs/README.md)。

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
| nodejs | Node.js 通用版（nixpkgs 默认，24.x LTS），含 npm/npx/corepack；**已被官方 Node 临时覆盖** → [docs/runtime-node.md](docs/runtime-node.md) |
| pnpm | Node 包管理器（含 pnpx；由 Nix 独立提供） → [store 位置](docs/packages-npm-pnpm.md) |
| yarn-berry | Yarn 4.x（含 yarn/yarnpkg） |
| bun | Bun 运行时 / 包管理器 / 测试器 |
| go | Go 工具链 |
| rustup | Rust 全家桶（rustc/cargo/rust-analyzer/rustfmt/clippy） |
| nvim | 编辑器 |
| direnv | 目录级环境自动切换（含 nix-direnv） |
| sops | 密钥加密：只加密结构化文件的值，密文可入 git → [密钥体系](docs/secrets-sops-age.md) |
| age | 现代 GPG（含 `age` / `age-keygen`）；私钥在本机 `~/.config/sops/age/keys.txt` |

> `go` / `rustup` 目前**无活跃项目使用**（`~/Code` 下都是 TypeScript/JS 项目），装着备用。

## 进程与服务管理

| 软件 | 用途 |
|---|---|
| process-compose | 多进程编排（`up` / `down` / `restart`，带 TUI 日志与状态） |

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
| nix | 包管理器本体 |
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

定义在 `home.nix` 的 `programs.zsh.shellAliases` / `initContent`。

## 常用命令

```sh
home-manager switch            # 应用配置
command -v <新命令>             # 验证：路径应在 ~/.nix-profile/bin 下
nixfmt flake.nix               # Nix 文件格式化（RFC 166）
home-manager news              # 查看未读变更说明
```

> 本仓库外的运行数据（npm 全局包、pnpm store、age 私钥）见 [docs/layout.md](docs/layout.md)。
