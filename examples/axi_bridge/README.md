# X2X / AXI Bridge 示例（穿刺场景 B）

覆盖：

- 多 outstanding；
- 乱序匹配；
- 32～1024 bit 数据宽度；
- reset during traffic；
- backpressure；
- 多 Clock/异步场景；
- latency 和 throughput metric；
- scoreboard drain 与 pending 诊断。

## 状态

**占位骨架**。完整实现依赖：

- AXI VIP（属 VIP Repo）；
- 桥接 DUT（属 CBB/项目 Repo）；
- 本仓库 `dv_out_of_order_matcher`、`dv_compare_policy`、`dv_latency_tracker`。

## 目录规划（待实现）

```text
examples/axi_bridge/
├── README.md
├── env/
├── seq/
├── tb/
└── fusesoc/
```
