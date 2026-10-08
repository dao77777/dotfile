# 目录结构与归属边界

> 状态: 生效中 · 类型: 设计

## 一张图

```
/Users/zephyr
├── .config/home-manager/        ⭐ 本仓库：shell 环境正本（dotfiles，受 git 管理）
│   ├── flake.nix  flake.lock        Nix 输入与 devShell
│   ├── home.nix                     全部配置：装包 / 模块 / 别名 / PATH / 环境变量
│   ├── AGENTS.md                    规则（给 agent）
│   ├── README.md                    清单（给人）
│   └── docs/                        ← 你在这里：决策与设计
│
├── Code/                        ⭐ 工作区：所有代码项目
│   ├── AGENTS.md                    工作区约定（process-compose 编排）
│   ├── process-compose.yaml         所有 dev server 的统一入口
│   ├── vault/                       密钥库（私有 git，只存密文）
└── └── <project>/                   一个项目一个目录
```



## 为什么要把"正本"放在 `.config/home-manager/`

三个约束推导出来的：

1. **配置必须由 Nix 生成** → 不能直接改 `~/.zshrc`（那是软链，`switch` 会覆盖回来）
2. **必须能跨机器重现** → 所以要有 git 仓库 + flake
3. **agent 要能读到全局规则** → 各 agent 的全局文件（`~/.pi/agent/AGENTS.md` 等）都**软链**到本仓库这一份

→ 于是本目录既是"配置正本"，也是"全局 AGENTS.md 正本"。**只改这一份，别改软链另一端。**

> 22 端口在部分网络下不通，某些仓库 remote 已改成 `ssh://git@ssh.github.com:443/...`。 ? 某些是哪些, 补充完整
> 一劳永逸的解法是给 `~/.ssh/config` 加 `Host github.com → HostName ssh.github.com / Port 443`。
├── .npm-global/                 npm 全局包（独立于 Nix）
├── .local/share/node/           官方 Node tarball（见 runtime-node.md）