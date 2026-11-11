# IPv6 公网入站：为什么不通，怎么放行

> 2026-11 实测结论。设备型号/地址见 [`../../AGENTS.md`](../../AGENTS.md)「网络设备」。

## 一句话

**能通。** 唯一卡点是 **NX15000 的 `ip6tables` 在 `zone_wan_forward` 末尾挂了一条 `zone_wan_dest_REJECT`**，把所有入站 IPv6 新建连接挡了。**光猫是清白的**（会正常按 PD 路由转发）。

## 地址从哪来

```
运营商 ──PD /60──> 光猫 ──PD /64──> NX15000 ──> 终端
     2409:8a60:3076:de60::/60   de61::/64
```

| 位置 | IPv6 |
| --- | --- |
| 光猫 WAN（ppp0） | `2409:8a60:3007:7da9:edb1:b203:a59f:419f` |
| 光猫 LAN（br0） | `2409:8a60:3076:de60::/64`，自身 `…:6e9e:7cff:fe0e:d900`，网关 `fe80::1` |
| NX15000 WAN | `2409:8a60:3076:de60::2/128`，链路本地 `fe80::de65:55ff:fe58:6705` |
| NX15000 LAN | `2409:8a60:3076:de61::/64`，自身 `de61::1` |
| 光猫里的 PD 路由 | `de61::/64 via fe80::de65:55ff:fe58:6705 dev br0` ✅ |

**PD（Prefix Delegation）只做"分配地址"，数据面要靠路由。** 这两层在这里都没问题：

| 检查项 | 结果 |
| --- | --- |
| 光猫有没有 `de61::/64` 的路由 | ✅ 有，下一跳是 NX15000 的 WAN 链路本地 |
| 光猫 `ip6tables` 策略 | ✅ 全 `ACCEPT`，`IP_FILTER_IN` / `FORWARD_FIREWALL` 都是空链 |
| 外部包能不能到光猫 | ✅ tcpdump 抓到 `2001:41d0:…` → `de61::71e:80`，并从 br0 转出 |
| NX15000 的转发链 | ❌ `zone_wan_forward` 第 12 条 `zone_wan_dest_REJECT` |

## 放行

在 NX15000 上加规则（`forwarding_wan_rule` 排在 `zone_wan_dest_REJECT` 之前）：

```
ip6tables -A forwarding_wan_rule -p tcp --dport 80 -d ::71e/::ffff:ffff:ffff:ffff -j ACCEPT
```

- `-d ::71e/::ffff:ffff:ffff:ffff`：掩码只比**后 48 位**，所以运营商换前缀后规则不用改。
- 只放需要的端口，别 `-j ACCEPT` 全开——那等于把整台设备裸放到公网。
- ⚠️ **重启失效**（规则在内存里）。

## 验证（有个大坑）

`https://ipv6-test.com/json/webserver.php?url=<host>:<port>&scheme=http` 能从外部发起 TCP，是当时唯一能用的外部视角。**但它 `url` 里的端口会被忽略，永远只连 80**：

| 探测 | 返回 | 说明 |
| --- | --- | --- |
| `NAS:80`（放行前） | `Connection refused` | H3C 的 REJECT |
| `NAS:80`（放行后） | `{"server":"nginx"}` | ✅ 通 |
| `NAS:9999`（无人监听） | `{"server":"nginx"}` | ⚠️ 证明端口被忽略 |

→ **判断非 80 端口是否开放，不能用这个接口**，要用真机（手机流量）或其他工具。

校准探针是否可信的最低要求：先打一个已知目标。`2606:4700:4700::1111` 应返回 `{"server":"cloudflare"}`。

## 持久化

NX15000 是 OpenWrt fw3 二次开发，开机把 `/mnt/config/firewall` 复制成 `/etc/config/firewall` 再加载。所以要把规则写成 fw3 语法加进 `/mnt/config/firewall`：

```
config rule 'allow_nas_http'
    option name 'Allow NAS HTTP'
    option family 'ipv6'
    option proto 'tcp'
    option src 'wan'
    option dest 'lan'
    option dest_ip '::71e/-64'
    option dest_port '80'
    option target 'ACCEPT'
```

`/opt/upt/...` 那套是光猫的 LXC 路径，别混。

## 还要注意

- **前缀会变**：`de60::/60` 是运营商动态发的，重启光猫/换拨号都可能换。直连必须配 DDNS。
- **后缀**：`::71e` 来自 DHCPv6（DUID 派生，稳定）；SLAAC 那个 `e04a:b425:a83f:b259` 随前缀变。临时地址（`temporary`）会轮换，别拿来做服务地址。
- **安全**：IPv6 是可直接路由的公网地址，不经过 NAT。放行就是真的暴露，服务本身要有强认证/TLS；优先只放 VPN 端口，其余走 VPN 回家。
