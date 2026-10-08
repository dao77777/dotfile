# 设计：装了哪些工具

> 顶层设计见 [overview.md](overview.md) · 落地决策见 [../decision/](../decision/)
>
> 分类原则：**按"用它能干什么"分**，不按它是怎么装的、也不按语言生态。
> 上游是 `home.nix` 的 `home.packages`，改包时同步本表。

## 文件系统

| 场景 | 工具 |
| --- | --- |
| 浏览 / 管理 | `yazi`（`y` 包装，退出自动 cd）· `eza`（`ls`） · `zoxide`（`z` 跳转） |
| 占用 / 容量 | `dua`（交互式）· `duf`（总览） |
| 搜索 | `fd`（`find`）· `ripgrep`（`grep`）· `fzf`（模糊选择） |
| 处理 / 转换 | `jq` · `yq` · `p7zip` · `curl`/`wcurl` · `wget` |
| 渲染 / 预览 | `bat` · `poppler-utils` · `resvg` · `ffmpeg` · `imagemagick` |

> 后四个是给 `yazi` 做预览的：PDF / SVG / 视频 / 图片。

## 开发

| 类别 | 工具 |
| --- | --- |
| 版本控制 | `git` · `gh` · `lazygit` · `scalar`（巨型仓库加速，随 git 附带） |
| 运行时 | `nodejs`（24.x LTS，含 npm/npx/corepack）· `go` · `rustup` |
| 包管理 | `pnpm` · `yarn-berry` · `bun` |
| 编辑器 | `nvim` |
| 环境 | `direnv`（含 nix-direnv） |
| 密钥 | `sops` · `age` → [secrets.md](secrets.md) |

**注意两处非默认**：

- `node` 实际不是 Nix 那份 → [../decision/runtime-node.md](../decision/runtime-node.md)
- `go` / `rustup` 目前**无活跃项目使用**（`~/Code` 下都是 TS/JS），装着备用

## 进程与服务

| 工具 | 用途 |
| --- | --- |
| `process-compose` | 多进程编排：`up` / `down` / `process restart` / `process logs`，带 TUI |

## Shell 与系统

| 工具 | 用途 |
| --- | --- |
| `zsh` | 主 shell（oh-my-zsh + vi 模式）→ [shell.md](shell.md) |
| `starship` | 提示符 |
| `btop` | 系统监控（Catppuccin Frappe） |
| `pfetch` | 系统信息 |

## Nix 生态

`nix`（包管理器本体）· `home-manager`（配置管理器）
