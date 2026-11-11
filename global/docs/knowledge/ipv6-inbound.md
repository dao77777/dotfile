# IPv6 公网入站：这套网络的具体事实

> 分层模型见 [networking-model.md](networking-model.md) · 设备型号/地址见 [`../../AGENTS.md`](../../AGENTS.md)「网络设备」 · 取舍理由见 [../decisions/0001-ipv6-inbound.md](../decisions/0001-ipv6-inbound.md)

## 一句话

**能通。** 卡点只有一处：**NX15000 的 `ip6tables` 在 `zone_wan_forward` 末尾挂了 `zone_wan_dest_REJECT`**。光猫是清白的（正常按 PD 路由转发）。

现状（2026-11-11）：路由器对 NAS **全端口放行**（临时，重启失效），真正的白名单交给 **NAS 自己的 XDP 防火墙**（持久）。

## 地址从哪来

```
运营商 ──PD /60──> 光猫 ──PD /64──> NX15000 ──> 终端
     2409:8a60:3076:de60::/60   de61::/64
```

| 位置 | IPv6 |
| --- | --- |
| 光猫 WAN（ppp0） | `2409:8a60:3007:7da9:edb1:b203:a59f:419f` |
| 光猫 LAN（br0） | `…:de60::/64`，自身 `…:6e9e:7cff:fe0e:d900`，网关 `fe80::1` |
| NX15000 WAN | `…:de60::2/128`，链路本地 `fe80::de65:55ff:fe58:6705` |
| NX15000 LAN | `…:de61::/64`，自身 `de61::1` |
| 光猫里的 PD 路由 | `de61::/64 via fe80::de65:55ff:fe58:6705 dev br0` ✅ |

## 卡在哪一层

| 检查项 | 结果 |
| --- | --- |
| 光猫有 `de61::/64` 的路由 | ✅ 下一跳是 NX15000 的 WAN 链路本地 |
| 光猫 `ip6tables` | ✅ 策略全 ACCEPT，`IP_FILTER_IN` / `FORWARD_FIREWALL` 空链 |
| 外部包能到光猫 | ✅ tcpdump 抓到 `2001:41d0:…` → `de61::71e:80`，并从 br0 转出 |
| NAS 自己的防火墙 | ✅ 飞牛 XDP：`enable: true` + `rxfallback: false`（未匹配→拒绝），白名单端口之外的入站被 drop |
| **NX15000 的转发链** | ❌ `zone_wan_forward` 第 12 条 `zone_wan_dest_REJECT` |

## 现在怎么分工

```
路由器（NX15000）  →  对 NAS 全端口放行        ← 临时，重启失效
NAS（飞牛 XDP）    →  只放 fw.conf 里的白名单   ← 持久，真正把关
```

路由器上只要一条（`forwarding_wan_rule` 排在 `zone_wan_dest_REJECT` 之前）：

```
ip6tables -A forwarding_wan_rule -d ::71e/::ffff:ffff:ffff:ffff -j ACCEPT
```

- `-d ::71e/::ffff:ffff:ffff:ffff`：掩码只比**后 48 位**，运营商换前缀后规则不用改。
- 想按端口收窄也可以（`-p tcp --dport 5666`），但当前把细粒度限制放在了 NAS 侧。
- NAS 侧要点：`fw.conf` 的 `rxfallback` 必须是 `false`（未匹配→拒绝），否则白名单形同虚设。它的实现是 **XDP**，`iptables` / `nft` 里看不到规则。
- 完整命令见 [../examples/h3c-ipv6-allow.sh](../examples/h3c-ipv6-allow.sh)。

## 持久化：做不到（有据可查）

| 依据 | 内容 |
| --- | --- |
| H3C 官方《关闭 IPv6 防火墙》文档 | 结尾原话：「重启路由器后此命令会失效，需要重新关闭」 |
| H3C 知了社区 | 有人建议加 `ip6tables-save`，回复「**这个方法没用**」 |
| 恩山（RC3000/NX30 同固件族） | 「试了 crontab 和 `/etc/rc.local`，**连这个重启都会清空**」；其 `mount` 输出与本机一致 |
| 本机 `/mnt` | 只有 `bak cfg custom factorybackup …`，**没有 `config` / `backup` 目录** |
| 本机 `/mnt/cfg/startup` | 有 `@vserver`（IPv4 端口映射，**所以 v4 能持久**）· **无任何 `firewall` / `ip6` / `acl` 段** |

根因：`/` 是 `overlayfs:/tmp/root`，**upper 在内存**。不是"不会存"，是固件**没实现这个配置项**（`IsSupport_FireWall = 0`，整个防火墙页面被跳过）。

> 网上流传的 `cp /etc/config/firewall /mnt/config/` + 删 `cfgmd5` 校验，只适用于**有 `/mnt/config` 的型号**（NX30Pro 系）。NX15000 没有该目录，同族的 NX54 用户也没解决。

→ 每次重启需手动重放。想一劳永逸见 [../decisions/0001-ipv6-inbound.md](../decisions/0001-ipv6-inbound.md)。

## 还要注意

- **端口要选对**：NAS 的 80 只是 `302 → http://[addr]:5666/`（飞牛 UI 在 **5666** HTTP / **5667** HTTPS）。只放行 80 的话浏览器会跳到没放行的 5666 → 表现为"打不开"。
- **前缀会变**：`de60::/60` 是运营商动态发的，重启光猫/重拨都可能换 → 直连必须配 DDNS。
- **后缀**：`::71e` 来自 DHCPv6（DUID 派生，稳定）；SLAAC 那个随前缀变；`temporary` 地址会轮换，别拿来做服务地址。
- **安全**：IPv6 不经 NAT，放行就是真的暴露到公网。服务本身要有强认证/TLS；优先只放 VPN 端口，其余走 VPN 回家。
