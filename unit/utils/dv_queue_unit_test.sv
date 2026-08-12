//======================================================================
// AIX DV Common - queue 单元测试
// File    : unit/utils/dv_queue_unit_test.sv
// Purpose : 测试计划说明（正式断言见 dv_queue_unit_tb.sv）。
// Author  : dv-platform
// Date    : 2026-08-12
//======================================================================

// 测试覆盖：
// - 默认配置（默认 max=64, policy=REJECT）
// - 有界队列满时拒绝/覆盖策略
// - 空队列 peek/dequeue 返回失败
// - flush / flush_epoch
// - 重复入队出队
