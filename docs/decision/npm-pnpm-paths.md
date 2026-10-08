# 决策：npm 全局包与 pnpm store 放哪

> 生效中 · 所属设计 [packages.md](../design/packages.md) · 落点 `programs.npm` + pnpm 自身配置

## 矛盾

两种包管理器的"全局位置"都不能用默认值：

| 管理器 | 默认的问题 |
| --- | --- |
| npm | 默认装进 Nix profile 管辖范围，会被 `switch` 冲掉 |
| pnpm | 默认 store 位置不理想；而我们希望它**固定**、可预测 |

## 处理

```
Nix ~/.nix-profile/bin        node / pnpm / yarn / bun
        │
npm i -g ────────────────────► ~/.npm-global/          ← 独立于 Nix
                               └─ bin 已进 home.sessionPath

pnpm ─────────────────────────► ~/Library/pnpm/store    ← 固定 store
                                配置写在 pnpm 自己的全局 config.yaml（键 storeDir）
```

```nix
programs.npm = {
  package = null;                                   # 不额外注入一份 nodejs
  settings.prefix = "${config.home.homeDirectory}/.npm-global";
};
```

重装环境时要手动恢复 pnpm 那一项：

```sh
pnpm config set --global store-dir ~/Library/pnpm/store
```

## 两个坑

| 坑 | 现象 | 原因 |
| --- | --- | --- |
| **不能写进 `.npmrc`** | 每条 npm 命令都报 `Unknown user config "store-dir"` | `store-dir` 是 pnpm 专有键，npm 不认 |
| **值必须是绝对路径** | 受限环境（如 DSH 沙箱）下 `~/Code` 冒出 `.pnpm-store` | `~` 开头会触发 pnpm 的「仓库可写性探测」，探测失败就退化为在项目**祖先目录**另建 `.pnpm-store`，污染 `~/Code`；绝对路径跳过探测 |

`package = null` 的理由：不设的话该模块会默认再注入一份 `pkgs.nodejs`，与 `home.packages` 里的重复。

## 代价

- 全局包与 Nix 管理的东西分成两套，升级/清理要分别处理
- pnpm store 位置不写在仓库里（属于 pnpm 自身配置），**换机器要记得手动恢复**

## 复查条件

1. pnpm 支持在 `.npmrc` 里共存（npm 不再报未知键）
2. nixpkgs 的 pnpm 默认 store 位置变得合理（当前默认不理想才需要手动固定）
