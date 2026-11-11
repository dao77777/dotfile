# 全机 / 网络文档

> 只放**跨主机**的事：网络怎么搭的、排障怎么做。
> 单台设备的型号/地址/固件在 [`../AGENTS.md`](../AGENTS.md)「网络设备」；文档分类与写作规范同那一份。

| 文档 | 覆盖什么 | 什么时候看 |
| --- | --- | --- |
| [knowledge/ipv6-inbound.md](knowledge/ipv6-inbound.md) | 公网 IPv6 入站为什么不通、卡在哪台、怎么放行、怎么验证 | 要从外网访问家里设备时 |
| [logs/2026-11-11-ipv6-inbound.md](logs/2026-11-11-ipv6-inbound.md) | 这次排查的完整流水 + 两次误判复盘 | 想知道结论是怎么来的 |
| [examples/h3c-ipv6-allow.sh](examples/h3c-ipv6-allow.sh) | 可直接抄的命令片段（开 telnet / 放行 / 持久化） | 要重新放行时 |

## 一句话现状

公网 IPv6 **能**打到内网，卡点只有一处：**NX15000 的 `ip6tables zone_wan_forward` 末尾那条 `zone_wan_dest_REJECT`**。光猫是清白的。
