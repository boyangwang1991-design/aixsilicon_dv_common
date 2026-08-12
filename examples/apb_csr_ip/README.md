# APB 寄存器 IP 示例（穿刺场景 A）

验证链：

```text
SystemRDL → PeakRDL RAL → APB VIP → CSR sequence
          → Scoreboard/Status → Result/Manifest
```

覆盖：

- Clock/Reset；
- RAL adapter 和 predictor；
- CSR smoke / reset / rw / bit-bash；
- timeout 和非法配置 negative test；
- requirement ID 与结果绑定；
- FuseSoC Release。

## 状态

**占位骨架**。完整实现依赖：

- APB VIP（协议事务/driver/monitor 属 VIP Repo）；
- PeakRDL 生成的 UVM RAL 模型（SystemRDL 事实源属 IP Repo）；
- 本仓库 L4 RAL/CSR 公共组件。

## 目录规划（待实现）

```text
examples/apb_csr_ip/
├── README.md
├── ral/            # PeakRDL 生成 + adapter 连接
├── env/            # APB env 装配
├── seq/            # virtual sequence
├── tb/             # 顶层与 RAL block
└── fusesoc/        # 项目顶层 Core
```
