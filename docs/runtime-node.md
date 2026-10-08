# 决策：官方 Node 置顶（临时妥协）

> 状态: ⚠️ **临时妥协中**，计划移除 · 起始 2026-09-25 · 落点: `home.nix` 的 `home.sessionPath`

## 问题

`deepseek-harness` 源码启动（`pnpm dsh`）在 app-boot 时报 `Unsupported / no-getter`，**用 nixpkgs 的 node 必挂，用官方 node 正常**。

## 决定

在 `home.sessionPath` 里把官方 Node 目录**排到最前**，覆盖 nixpkgs 的 `node`：

```
home.sessionPath = [ "$HOME/.local/share/node/bin"  "$HOME/.npm-global/bin"  "$HOME/.local/bin" ];
                     └─ 排第一，覆盖 ~/.nix-profile/bin/node
```

```
command -v node   →  ~/.local/share/node/bin/node      v24.19.0   官方 tarball（手动解压）
nix 的 node       →  ~/.nix-profile/bin/node           24.21.0    nixpkgs 构建，仍在 PATH 里
```

## 理由

根因在 `node-addon-require-builtin` 这个原生插件的工作方式：

```
它扫描 node 二进制的 arm64 机器码，定位 PrincipalRealm::builtin_module_require 的 getter，
用固定的指令模式去匹配。

nixpkgs 的 cc-wrapper 默认全局加 -fno-omit-frame-pointer
   → 该 getter 多出栈帧 prologue/epilogue
   → 不再是插件认识的 "ldr x0,[this,#imm] ; ret" 模式
   → 匹配失败，报 Unsupported / no-getter

官方 Node 省略 frame pointer
   → 指令模式匹配成功 ✅
```

**证据**（可复现）：

| 材料 | 位置 |
| --- | --- |
| 启动失败日志 | `~/Code/deepseek-harness/tmp/dsh-restart.log` |
| 两个 node 的反汇编对比 | 同目录 |
| cc-wrapper 加 `-fno-omit-frame-pointer` 的依据 | `pkgs/build-support/cc-wrapper/default.nix` |

## 代价

| 代价 | 说明 |
| --- | --- |
| `node` 不再来自 Nix | 不能假设 `command -v node` 指向 `~/.nix-profile/bin` |
| 版本会漂 | 手动解压的 tarball 不会随 nixpkgs 升级；现在比 nixpkgs 的**旧**两个小版本 |
| 多一份运行时 | `~/.local/share/node/` 是仓库外的"影子环境"，不在 `switch` 管辖内 |
| 项目不能依赖它 | 项目要固定 Node 版本就用**项目自己的 `flake.nix`**（参考 `~/Code/effect-web`） |

> 注意：只覆盖了 `node` 的解析。Nix 的 `nodejs` / `pnpm` 仍在，`pnpm` 会从 PATH 取 node 来跑脚本。

## 复查条件（满足任一即回退）

1. **Node 版本升级后** → 先验证 `pnpm dsh` 源码启动是否还报错
2. **nixpkgs 改了 cc-wrapper 默认**（去掉 `-fno-omit-frame-pointer`）
3. **`node-addon-require-builtin` 改成不依赖机器码模式匹配**（例如改用符号表/DWARF）

回退动作：

```sh
# 1. 从 home.nix 的 home.sessionPath 删除 "$HOME/.local/share/node/bin"
# 2. rm -rf ~/.local/share/node
# 3. home-manager switch && command -v node   # 应指向 ~/.nix-profile/bin/node
```
