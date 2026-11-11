# 全机 / 网络文档

> 只放**跨主机**的事：网络怎么搭的、排障怎么做。
> 单台设备的型号/地址/固件在 [`../AGENTS.md`](../AGENTS.md)「网络设备」；文档分类与写作规范同那一份。

| 文档 | 覆盖什么 | 什么时候看 |
| --- | --- | --- |
| [knowledge/networking-model.md](knowledge/networking-model.md) | **通用模型**：多道防火墙各管什么、IPv4/IPv6 的差别、怎么定位卡在哪一层、两条排障纪律 | 任何"外部连不进来"的问题 |
| [knowledge/ipv6-inbound.md](knowledge/ipv6-inbound.md) | **这套网络的具体事实**：拓扑、地址来源、卡点证据、放行命令、为什么不能持久化 | 要放行/排查本机 IPv6 入站时 |
| [decisions/0001-ipv6-inbound.md](decisions/0001-ipv6-inbound.md) | 为什么选"临时放行"而不是换设备/隧道，代价与复查条件 | 想改方案、或又坏了的时候 |
| [logs/2026-11-11-ipv6-inbound.md](logs/2026-11-11-ipv6-inbound.md) | 完整流水 + 三次误判复盘 + 动过哪些东西 | 想知道结论怎么来的 |
| [examples/h3c-ipv6-allow.sh](examples/h3c-ipv6-allow.sh) | 可直接抄的命令（开 telnet / 放行 / 撤规则） | 重启后要重放时 |

## 一句话现状

公网 IPv6 **能**打到内网，卡点只有一处：**NX15000 的 `ip6tables zone_wan_forward` 末尾那条 `zone_wan_dest_REJECT`**。光猫是清白的。已放行 80/22/5666/5667，**路由器重启后需手动重放**。
