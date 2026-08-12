//======================================================================
// AIX DV Common - memory 单元测试
// File    : unit/memory/dv_memory_unit_test.sv
// Purpose : 测试计划说明（正式断言见 dv_memory_unit_tb.sv）。
// Author  : dv-platform
// Date    : 2026-08-12
//======================================================================

// 测试覆盖：
// - sparse / dense 模式
// - byte enable 部分写
// - unknown policy（X / ZERO / ERROR）
// - init_all
// - 读/写计数
