//======================================================================
// AIX DV Common - timeout 单元测试
// File    : unit/runtime/dv_timeout_unit_test.sv
// Purpose : 测试计划说明（正式断言见 dv_timeout_unit_tb.sv）。
// Author  : dv-platform
// Date    : 2026-08-12
//======================================================================

// 测试覆盖：
// - global / phase / operation / progress / drain 各类
// - arm / disarm / is_expired
// - 诊断回调（diag dump）
// - stop_on_timeout 行为
// - 重复触发只 fir 一次
