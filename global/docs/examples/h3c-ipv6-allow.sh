#!/usr/bin/env bash
# NX15000 IPv6 入站放行 —— 可抄片段
# 背景：../knowledge/ipv6-inbound.md · 设备细节：../knowledge/h3c-nx15000.md
#
# 当前分工：路由器对 NAS 全端口放行（临时，重启失效）→ 细粒度白名单交给 NAS 自己的防火墙（持久）
#
# ⚠️ 密码不写在这里：从 _vault 取
#    sops -d --extract '["ROUTER_PASSWORD"]' ~/Code/_vault/env/secrets.enc.yaml

set -euo pipefail

ROUTER=192.168.124.1
TELNET_PORT=15000

# ── 1. 开 telnet ────────────────────────────────────────────────
#   http://192.168.124.1/debug.asp → 勾「启用 Telnet 管理」→ 应用
#   实测：这版固件连上不验密码，直接 `<H3C_NX15000>`，输 debugshell 即 root
#   关掉：同页取消勾选再应用（只提交 Asp_SetTelnetDebug，不影响别的设置）
nc -z "$ROUTER" "$TELNET_PORT"

# ── 2. 加放行规则（重启失效）─────────────────────────────────────
#   ::71e/::ffff:ffff:ffff:ffff → 掩码只比后 48 位，换前缀不用改
cat <<'SHELL'
# 方式 A（当前采用）：对 NAS 全端口放行，靠 NAS 侧防火墙把关
ip6tables -A forwarding_wan_rule -d ::71e/::ffff:ffff:ffff:ffff -j ACCEPT

# 方式 B：在路由器上按端口收窄
ip6tables -A forwarding_wan_rule -p tcp --dport 5666 -d ::71e/::ffff:ffff:ffff:ffff -j ACCEPT
ip6tables -A forwarding_wan_rule -p tcp --dport 5667 -d ::71e/::ffff:ffff:ffff:ffff -j ACCEPT

ip6tables -nL forwarding_wan_rule --line     # 核对
SHELL

# 撤销（规则文本必须与添加时完全一致）：
#   ip6tables -D forwarding_wan_rule -d ::71e/::ffff:ffff:ffff:ffff -j ACCEPT

# ── 3. 持久化：这台做不到 ──────────────────────────────────────
# / 是 overlayfs:/tmp/root，upper 在内存 → /etc 改动重启即失。
# 闪存上的 /mnt/cfg/startup 是厂商 key=value 配置，不是 shell，别往里塞命令。
# /mnt/config/firewall 在这台上不存在（那是 NX15 的布局）。
# → 重启后重跑第 2 步。想一劳永逸：换能管 IPv6 防火墙的路由器，或用隧道。

# ── 4. 验证 ───────────────────────────────────────────────────
# ⚠️ ipv6-test.com 的探针忽略端口，永远只连 80；非 80 端口要用手机流量或 nmap 实测
#   nmap -6 -Pn -p 22,5666,49152 <addr>
#     open     = 通
#     filtered = 被 drop（NAS 的 XDP 白名单 / 路由器 REJECT）
#     closed   = 主机在、但没人监听

# 光猫侧（只在需要排障时开，用完关）：
#   开：http://192.168.1.1/cgi-bin/telnetenable.cgi?telnetenable=1&key=<MAC大写去冒号>
#   关：...?telnetenable=0&key=<同>
#   登录：admin / 密码见 _vault 的 ONT_TELNET_PASSWORD
