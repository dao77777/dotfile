# 附录：零散备忘

> **这里故意不分类。** 放的是：默认就该知道的、边界情况、以及"不确定要不要写、但不写又会含糊"的东西
> （比如"`command -v` 是什么"、macOS 的那几个坑）。
>
> 单独堆在一起，是为了让 `designs/` 和 `decisions/` 保持干净。
> **有新东西拿不准就丢这里，不要塞进别的文档。**

## 常用命令

| 操作 | 命令 |
| --- | --- |
| 应用配置 | `home-manager switch` |
| 格式化 Nix | `nixfmt flake.nix` |
| 查看未读变更 | `home-manager news` |
| 验证新包 | `command -v <cmd>`，路径应在 `~/.nix-profile/bin` 下 |
| 查命令来源/类型 | `command -v x`（POSIX，含内建/别名）；`type x`（bash/zsh，更啰嗦） |

> `command -v` 比 `which` 可靠：它是 shell 内建，认内建命令和别名，
> 而 macOS 的 `which` 会把 `cd` 报成 `/usr/bin/cd`（那是个没人用的包装器）。

## 验证的陷阱

| 现象 | 原因 / 对策 |
| --- | --- |
| 新加的环境变量"没生效" | `__HM_SESS_VARS_SOURCED` 守卫 → 机制与对策见 [designs/shell.md](designs/shell.md) 的「加载链」 |
| 登录 shell 与普通 shell 行为不同 | 同上（`if [[ ! -o login ]]`） |
| `switch` 后命令找不到 | 旧 shell 的 `PATH` 是缓存的；开新终端 |

## 网络与推送

| 事 | 说明 |
| --- | --- |
| **SSH 22 端口不可用** | TCP 握手能过，但一进 SSH 协议就被切断（5/5 复现） |
| **SSH 443 也不稳** | 走 mihomo TUN 的兜底规则链，时好时坏 |
| **HTTPS 是稳定路径** | 实测 5/5 成功 |
| 本仓库的推送方式 | `https://github.com/dao77777/dotfile.git` + 仓库级 `credential.helper = !gh auth git-credential` |
| 顺便一提 | 流量走 Clash Party（mihomo）的 TUN，`route get` 会看到 `utun1500` |

## 待定 / 未决
- `go` / `rustup` 无活跃项目使用，是否移除？（装了备用）
- 是否给 `~/.ssh/config` 加 `Host github.com → ssh.github.com:443`？
  目前判断**收益不大**：根因在代理规则，SSH 走哪个端口都可能被兜底链吃掉
- `home-manager news` 里有 297 条未读，未逐条评估

## 文档自身的坑

| 坑 | 说明 |
| --- | --- |
| **`GLOBAL_AGENTS.md` 不能用相对链接** | 它被软链到 `~/.pi/agent/AGENTS.md` 等 4 处；相对链接会按**软链所在目录**解析（`~/.pi/agent/docs/…`）→ 断。只能用 `~` 绝对路径 |
| `AGENTS.md` 可以用相对链接 | 它不被软链，只在本仓库内读 |
