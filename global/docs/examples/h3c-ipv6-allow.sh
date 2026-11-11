#!/usr/bin/env bash
# NX15000 放行 IPv6 入站 —— 可抄片段
# 背景见 ../knowledge/ipv6-inbound.md
#
# ⚠️ 密码不写在这里：从 _vault 取
#    sops -d --extract '["ROUTER_PASSWORD"]' ~/Code/_vault/env/secrets.enc.yaml

set -euo pipefail

ROUTER=192.168.124.1
TELNET_PORT=15000

# ── 1. 开 telnet（浏览器，或 curl 也行；这是一次性动作）────────────────
#   http://192.168.124.1/debug.asp → 勾「启用 Telnet 管理」→ 应用
#   实测：这版固件连上直接进 CLI，不弹密码
#   关掉：同页取消勾选再应用（只提交 Asp_SetTelnetDebug，不影响别的设置）

# ── 2. 加放行规则（重启失效）────────────────────────────────────────
#   ::71e/::ffff:ffff:ffff:ffff → 掩码只比后 48 位，换前缀不用改规则
#   ⚠️ 只放需要的端口；-j ACCEPT 全开等于把设备裸放公网
nc -z "$ROUTER" "$TELNET_PORT"

# 进 debugshell 后执行：
cat <<'SHELL'
ip6tables -A forwarding_wan_rule -p tcp --dport 80   -d ::71e/::ffff:ffff:ffff:ffff -j ACCEPT
ip6tables -A forwarding_wan_rule -p tcp --dport 22   -d ::71e/::ffff:ffff:ffff:ffff -j ACCEPT
ip6tables -A forwarding_wan_rule -p tcp --dport 5666 -d ::71e/::ffff:ffff:ffff:ffff -j ACCEPT
ip6tables -A forwarding_wan_rule -p tcp --dport 5667 -d ::71e/::ffff:ffff:ffff:ffff -j ACCEPT
ip6tables -nL forwarding_wan_rule --line     # 核对
SHELL

# 撤销：
#   ip6tables -D forwarding_wan_rule -p tcp --dport 80 -d ::71e/::ffff:ffff:ffff:ffff -j ACCEPT

# ── 3. 持久化：NX15000 做不到 ──────────────────────────────────────
# / 是 overlayfs:/tmp/root，upper 在内存 → /etc 改动重启即失。
# 闪存上的 /mnt/cfg/startup 是厂商 key=value 配置，不是 shell，别往里塞命令。
# /mnt/config/firewall 在这台上不存在（那是 NX15 的布局）。
# → 重启后重跑第 2 步。想一劳永逸：换能管 IPv6 防火墙的路由器，或用隧道。

# ── 4. 验证 ────────────────────────────────────────────────────────
# ⚠️ ipv6-test.com 的探针忽略端口，永远只连 80；非 80 端口要用手机流量实测
#    curl -sk 'https://ipv6-test.com/json/webserver.php?url=<host>:80&scheme=http'
#    期望：{"server":"nginx"}   失败：error: ... Connection refused

# 光猫侧（只在需要排障时开，用完关）：
#   开：http://192.168.1.1/cgi-bin/telnetenable.cgi?telnetenable=1&key=<MAC大写去冒号>
#   关：...?telnetenable=0&key=<同>
#   登录：admin / 密码见 _vault 的 ONT_TELNET_PASSWORD
