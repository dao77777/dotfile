# home-manager

本机 shell 环境的**唯一真源**：CLI 工具、别名、PATH、环境变量全部由这里的 Nix flake 生成。

```sh
home-manager switch      # 应用配置
nixfmt flake.nix         # 格式化
```

> 改配置改 `home.nix`。**不要**改 `~/.zshrc` `.zshenv` `.npmrc`（它们是软链，理由见 [AGENTS.md](AGENTS.md)）。

## 仓库结构

```
flake.nix / flake.lock     Nix 输入与版本锁定
home.nix                   全部配置：装包 / 模块 / 别名 / PATH / 环境变量
GLOBAL_AGENTS.md           全局规则（软链到各 agent）
AGENTS.md                  本仓库规则
docs/                      顶层设计与关键决策
```

## 读什么

| 你是 | 读 |
| --- | --- |
| 想装工具 / 改 shell | [`home.nix`](home.nix) + [AGENTS.md](AGENTS.md) |
| 想知道装了哪些工具 | [`docs/design/packages.md`](docs/design/packages.md) |
| 想知道**为什么**这么设计 | [`docs/`](docs/README.md)（从 [overview](docs/design/overview.md) 开始） |
| agent，且工作目录在别处 | [`GLOBAL_AGENTS.md`](GLOBAL_AGENTS.md) |
