# 决策：npm 全局包与 pnpm store 的位置

> 状态: 生效中 · 类型: 决策 · 落点: `programs.npm`（`.npmrc`）+ pnpm 自身配置

## 一张图

```
Nix  (~/.nix-profile/bin)          node / pnpm / yarn / bun —— 由 home.nix 提供
                                            │
npm i -g ──────────────────────────► ~/.npm-global/         ← 独立于 Nix，不归本仓库管
                                     └─ bin 已进 home.sessionPath

pnpm ──────────────────────────────► ~/Library/pnpm/store   ← 包仓库（硬链接源）
                                     配置写在 pnpm 自己的全局 config.yaml（键 storeDir）
```

## 决定 1：npm 全局包放在 `~/.npm-global`

由 `programs.npm` 管：

```nix
programs.npm = {
  package = null;                                    # 不额外注入一份 nodejs
  settings.prefix = "${config.home.homeDirectory}/.npm-global";
};
```

| 项 | 值 |
| --- | --- |
| 包目录 | `~/.npm-global/lib/node_modules` |
| bin 目录 | `~/.npm-global/bin`（已在 `home.sessionPath`） |
| 当前装的 | `opencode-ai`、`@earendil-works/pi-coding-agent` |

`package = null` 的理由：不设的话该模块会默认再注入一份 `pkgs.nodejs`，与 `home.packages` 里的重复。

## 决定 2：pnpm 的 store 固定在 `~/Library/pnpm/store`

写在 **pnpm 自己的全局配置** `~/Library/Preferences/pnpm/config.yaml`，键 `storeDir`。
不进 `.npmrc`，也不写进 `home.nix`。

重装环境时要手动恢复：

```sh
pnpm config set --global store-dir ~/Library/pnpm/store
```

## 两个坑（都很隐蔽）

| 坑 | 现象 | 原因 |
| --- | --- | --- |
| **不能写进 `.npmrc`** | 每条 npm 命令都报 `Unknown user config "store-dir"` | `store-dir` 是 pnpm 专有键，npm 不认 |
| **值必须是绝对路径** | 受限环境（如 DSH 沙箱）下 `~/Code` 里冒出 `.pnpm-store` | 值以 `~` 开头会触发 pnpm 的「仓库可写性探测」；探测失败即退化为在项目**祖先目录**另建 `.pnpm-store`，污染 `~/Code`。绝对路径跳过探测 |

## 附带说明

| 项 | 说明 |
| --- | --- |
| `corepack` | 随 nodejs 24.x 提供；上游自 Node 25+ 起移除，届时需单独处理 |
| 项目依赖 | 一律项目内 `pnpm install`，不要全局装运行时 |
| `yarn-berry` / `bun` | 由 `home.packages` 独立提供，不走 corepack |

## 复查条件

1. pnpm 上游支持在 `.npmrc` 里共存（npm 不再报未知键）
2. nixpkgs 的 pnpm 默认 store 位置变得合理（当前默认不理想，才需要手动固定）
