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
bootstrap.sh               换机：建软链 + 应用配置
docs/                      顶层设计与关键决策
```

## 换机 / 恢复

新机顺序：装 Nix → `git clone --recurse-submodules <Code>` → 跑本仓库的 bootstrap。

```sh
cd ~/Code/dotfile
./bootstrap.sh              # 建软链 + home-manager switch
./bootstrap.sh --links-only # 只建软链，不跑 home-manager
```

它幂等地做三件事：

- `~/.config/home-manager` → 本仓库（保留旧路径）
- 4 条 agent 指令软链 → `GLOBAL_AGENTS.md`
- `home-manager switch --flake ~/Code/dotfile#zephyr`

⚠️ 不覆盖已存在的实体文件/目录（会跳过并提示）。Nix 一律用真实路径 `~/Code/dotfile`，
**不要**用 `~/.config/home-manager`（软链）去调，避开 Nix 对软链 flake 路径的坑。

## 读什么

| 你是 | 读 |
| --- | --- |
| 想装工具 / 改 shell | [`home.nix`](home.nix) + [AGENTS.md](AGENTS.md) |
| 想知道装了哪些工具 | [`docs/designs/packages.md`](docs/designs/packages.md) |
| 想知道**为什么**这么设计 | [`docs/`](docs/README.md)（从 [overview](docs/designs/overview.md) 开始） |
| agent，且工作目录在别处 | [`GLOBAL_AGENTS.md`](GLOBAL_AGENTS.md) |
