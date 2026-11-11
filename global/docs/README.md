# 全机 / 网络文档

> 只放**跨主机**的事：网络怎么搭的、排障怎么做。
> 单台设备的型号/地址/固件在 [`../AGENTS.md`](../AGENTS.md)「网络设备」；文档分类与写作规范同那一份。

| 文档 | 覆盖什么 | 什么时候看 |
| --- | --- | --- |
| [knowledge/networking-model.md](knowledge/networking-model.md) | **通用模型**：多道防火墙各管什么、IPv4/IPv6 的差别、怎么定位卡在哪一层、两条排障纪律 | 任何"外部连不进来"的问题 |
| [knowledge/h3c-nx15000.md](knowledge/h3c-nx15000.md) | **这台路由器怎么操作**：进 root 的路径、Web UI 与接口结构、防火墙链图、能力边界、为什么改了不保存、常用命令 | 要改路由器、或又需要进 telnet 时 |
| [knowledge/ipv6-inbound.md](knowledge/ipv6-inbound.md) | **这套网络的具体事实**：拓扑、地址来源、卡点证据、放行命令、为什么不能持久化 | 要放行/排查本机 IPv6 入站时 |
| [decisions/0001-ipv6-inbound.md](decisions/0001-ipv6-inbound.md) | 为什么选"临时放行"而不是换设备/隧道，代价与复查条件 | 想改方案、或又坏了的时候 |
| [logs/2026-11-11-ipv6-inbound.md](logs/2026-11-11-ipv6-inbound.md) | 完整流水 + 三次误判复盘 + 动过哪些东西 | 想知道结论怎么来的 |
| [examples/h3c-ipv6-allow.sh](examples/h3c-ipv6-allow.sh) | 可直接抄的命令（开 telnet / 放行 / 撤规则） | 重启后要重放时 |

## 一句话现状

公网 IPv6 **能**打到内网。当前分工：**路由器对 NAS 全端口放行（临时，重启失效）**，真正的白名单由 **NAS 自己的 XDP 防火墙**做（持久，只放 `fw.conf` 里列出的端口）。光猫是清白的。
