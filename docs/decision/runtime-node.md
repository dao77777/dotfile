# 决策：官方 Node 置顶

> ⚠️ **临时妥协，计划移除** · 起始 2026-09 · 所属设计 [packages.md](../design/packages.md) / [shell.md](../design/shell.md) · 落点 `home.nix` 的 `home.sessionPath`

## 矛盾

`deepseek-harness` 源码启动（`pnpm dsh`）**用 nixpkgs 的 node 必挂，用官方 node 正常**：

```
nixpkgs node  → Unsupported / no-getter
官方 node     → 正常
```

## 处理

把官方 Node 目录排到 `PATH` 最前，覆盖 nixpkgs 的 `node`：

```nix
home.sessionPath = [ "$HOME/.local/share/node/bin"  "$HOME/.npm-global/bin"  "$HOME/.local/bin" ];
#                     └─ 排第一
```

```
command -v node  →  ~/.local/share/node/bin/node   官方 tarball v24.19.0
nix 的 node      →  ~/.nix-profile/bin/node        nixpkgs 24.21.0（仍在 PATH 里）
```

## 根因

`node-addon-require-builtin` 的原生插件**按机器码模式**定位 getter：

```
它扫 node 二进制的 arm64 机器码，匹配 PrincipalRealm::builtin_module_require

nixpkgs 的 cc-wrapper 默认全局加 -fno-omit-frame-pointer
  → getter 多出栈帧 prologue/epilogue
  → 不再是插件认识的 "ldr x0,[this,#imm] ; ret" 模式 → 匹配失败
官方 Node 省略 frame pointer → 匹配成功
```

证据：`~/Code/deepseek-harness/tmp/dsh-restart.log`（启动失败）、同目录的反汇编对比、
`pkgs/build-support/cc-wrapper/default.nix`（加该 flag 的依据）。

## 代价

| 代价 | 说明 |
| --- | --- |
| `node` 不再来自 Nix | 不能假设它指向 `~/.nix-profile/bin` |
| 版本会漂 | 手动 tarball 不随 nixpkgs 升级，现在比 nixpkgs 的**旧**两个小版本 |
| 多一份影子运行时 | `~/.local/share/node/` 不在 `switch` 管辖内 |
| 项目不能依赖它 | 项目要固定版本就用**项目自己的** `flake.nix` |

> 只覆盖了 `node` 的解析。Nix 的 `nodejs` / `pnpm` 仍在，`pnpm` 从 `PATH` 取 node 跑脚本。

## 复查条件

满足任一即回退：**① Node 升级后**（先验 `pnpm dsh` 是否还报错）· **② nixpkgs 去掉该 flag** · **③ 插件改用符号表/DWARF 定位**

```sh
# 回退三步
# 1. home.nix 的 home.sessionPath 删掉 "$HOME/.local/share/node/bin"
# 2. rm -rf ~/.local/share/node
# 3. home-manager switch && command -v node      # 应指向 ~/.nix-profile/bin/node
```
