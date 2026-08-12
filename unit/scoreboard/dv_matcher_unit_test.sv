//======================================================================
// AIX DV Common - matcher 单元测试
// File    : unit/scoreboard/dv_matcher_unit_test.sv
// Purpose : 测试计划说明（正式断言见 dv_matcher_unit_tb.sv）。
// Author  : dv-platform
// Date    : 2026-08-12
//======================================================================

// 测试覆盖：
// - in-order FIFO 匹配
// - out-of-order key 匹配
// - 不匹配计数
// - flush / pending
// - 空队列匹配
