# 2026-11-11 · IPv6 公网入站排查流水

> 结论与做法已沉淀到 [knowledge/ipv6-inbound.md](../knowledge/ipv6-inbound.md)。这里只记过程与复盘。

## 流水

| # | 做了什么 | 得到什么 |
| --- | --- | --- |
| 1 | `ifconfig` / `netstat -rn -f inet6` | 本机有全局 `2409:8a60:3076:de61::/64`，出站 ICMP/TCP 正常 |
| 2 | 发现 `2000::/3 → utun1500`（Clash Party TUN） | **误判 ①**：以为入站被 TUN 吞了 |
| 3 | 测 NAS（`192.168.124.7`）+ 抓它自己的配置 | NAS 双栈、`[::]` 在听、`ufw inactive`、无 ip6tables 规则，但外部同样不通 → 排除 Clash |
| 4 | 找外部视角 | `ipv6-test.com/json/webserver.php` + `sslip.io`（IPv6→AAAA 域名）+ DoH（本机 DNS 被 fake-ip 劫持） |
| 5 | 校准探针 | Cloudflare → `{"server":"cloudflare"}`；Google:443 → timout。确认能区分 refused/timeout |
| 6 | 登录 `192.168.124.1` | 发现是 **H3C NX15000**，不是光猫；`IsSupport_FireWall=0`，防火墙页被固件隐藏 |
| 7 | 顺着 WAN 找到 `192.168.1.1` | **光猫 = FiberHome HG6543C4**（移动，重庆）；`IPv6FirewallEnable=0` |
| 8 | 比较 `de60::5`(No route) vs `de61::5`(refused) | **误判 ②**：认定 H3C。结论碰巧对，但论证是错的 |
| 9 | 在 NX15000 的 `mangle PREROUTING` 加计数器 | `dpt:22` 始终 0 → **误判 ③**：认定光猫不转发 |
| 10 | `debug.asp` → telnet 15000 → `debugshell` | 拿到 NX15000 root（OpenWrt / armv7l），看到 `zone_wan_dest_REJECT` |
| 11 | 光猫 `telnetenable.cgi?key=<MAC>` → telnet | 拿到光猫 root（BusyBox 1.27.2） |
| 12 | 光猫上 `tcpdump` | 抓到外部包进入并按 PD 路由转出 → **推翻 ③** |
| 13 | 用 `:9999` 探 NAS | 照样返回 `{"server":"nginx"}` → **发现探针忽略端口** |
| 14 | 在 `forwarding_wan_rule` 加 ACCEPT dport 80 | `{"server":"nginx"}` ✅ 通了 |

## 复盘：三次翻车

| 判断 | 依据 | 错在哪 | 怎么纠正的 |
| --- | --- | --- | --- |
| ① Clash TUN 吞了回程 | 路由表有 `2000::/3 → utun1500` | 那条路由确实存在，但入站压根没到这里；**有相关性不等于因果** | 换一台没有 TUN 的 NAS 测，现象一样 → 排除 |
| ② H3C 是元凶 | `de60` 报 No route、`de61` 报 refused | 论证错了：refused 其实是"H3C 的 REJECT 回 ICMP 不可达"。结论对，推理不成立 | 后来被 ③ 带偏才回头重验 |
| ③ 光猫不转发 PD 前缀 | `dpt:22` 计数器 0 | **测量工具连的端口不是 22**。工具永远连 80，我却用它测 22 | 换端口校准 + 光猫抓包 |

教训只有一条：**先校准测量工具，再相信测量结果。** 计数器、探针、错误码都是间接信号，很容易编出一个自洽但错误的故事。

## 动过的东西

| 设备 | 改动 | 现状 |
| --- | --- | --- |
| NX15000 | `debug.asp` 开 telnet(15000) | 用到时开、用完关；实际这版固件**连上不验密码** |
| NX15000 | `forwarding_wan_rule` 加 ACCEPT（dpt 80 / 22） | 在，**重启失效** |
| NX15000 | `mangle` 计数器、`/tmp` 抓包 | 已删 |
| 光猫 | `telnetenable=1` → 用完 `=0` | 已关；连接即被 RST |
| 光猫 | `/tmp` 抓包 | 已删 |
| 光猫 | 超密 `CMCCAdmin/aDm8H%MdA` 登录尝试 | 失败（`login_result=4`），未做任何修改 |
| `_vault` | 新增 `ONT_*` / `ONT_PPPOE_*` / `ONT_MAC` / `ONT_TELNET_*` / `ROUTER_*` | 已提交 |
