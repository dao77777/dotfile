#!/usr/bin/env bash
# bootstrap.sh — 换机/新机后，把本仓库的文件软链到正确位置，并应用 home-manager。
# 幂等，可重复跑。
#
#   ./bootstrap.sh               建软链 + home-manager switch
#   ./bootstrap.sh --links-only  只建软链，不跑 home-manager
#
# 前置：Nix 已装；本仓库已在 ~/Code/dotfile（由 ~/Code 的 submodule 提供）。
set -euo pipefail

REPO="$(cd "$(dirname "$0")" && pwd -P)"   # 真实路径（解析软链），勿用 ~/.config/home-manager 调 Nix
USER_CFG="zephyr"

LINKS_ONLY=0
[ "${1:-}" = "--links-only" ] && LINKS_ONLY=1

# ── 声明式软链：源(相对仓库) → 目标 ────────────────────────────────
# 「.」= 仓库根目录本身。只增不删；需要新软链就在这里加一行。
# ⚠️ 不要放 home.nix 已经生成的东西（~/.zshrc 等），否则两边打架。
links=(
  ".|$HOME/.config/home-manager"
  "GLOBAL_AGENTS.md|$HOME/.pi/agent/AGENTS.md"
  "GLOBAL_AGENTS.md|$HOME/.codex/AGENTS.md"
  "GLOBAL_AGENTS.md|$HOME/.config/opencode/AGENTS.md"
  "GLOBAL_AGENTS.md|$HOME/.claude/CLAUDE.md"
)

link() {  # src dst
  local src="$1" dst="$2"
  mkdir -p "$(dirname "$dst")"
  if [ -e "$dst" ] && [ ! -L "$dst" ]; then
    echo "⚠️  跳过：$dst 是实体文件/目录（先手动处理再重跑）" >&2
    return 0
  fi
  ln -sfn "$src" "$dst"
  echo "✓  $dst → $src"
}

echo "== 建软链 =="
for row in "${links[@]}"; do
  src="${row%%|*}"; dst="${row##*|}"
  [ "$src" = "." ] && src="$REPO" || src="$REPO/$src"
  link "$src" "$dst"
done

if [ "$LINKS_ONLY" = 1 ]; then
  echo "== --links-only：跳过 home-manager =="
  exit 0
fi

echo "== 应用 home-manager =="
if command -v home-manager >/dev/null 2>&1; then
  exec home-manager switch --flake "$REPO#$USER_CFG"
else
  exec nix run github:nix-community/home-manager -- switch --flake "$REPO#$USER_CFG"
fi
