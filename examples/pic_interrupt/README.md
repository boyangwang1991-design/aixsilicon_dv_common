# PIC 功能安全中断控制器示例（穿刺场景 C）

覆盖：

- pulse/level interrupt；
- interrupt record/clear；
- fault request/activation/observation；
- stuck/lost/duplicate 注入；
- reset epoch；
- Safety mechanism 响应时延；
- requirement、fault ID 和 test evidence 绑定。

## 状态

**占位骨架**。完整实现依赖：

- PIC DUT（属 IP Repo）；
- 中断/故障行为契约（属 HW Interface Repo）；
- 本仓库 `dv_interrupt_service`、`dv_fault_control`、`dv_reset_service`。

## 目录规划（待实现）

```text
examples/pic_interrupt/
├── README.md
├── env/
├── seq/
├── fault/
├── tb/
└── fusesoc/
```
