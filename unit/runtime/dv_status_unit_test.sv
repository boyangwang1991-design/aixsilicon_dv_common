//======================================================================
// AIX DV Common - status 单元测试
// File    : unit/runtime/dv_status_unit_test.sv
// Purpose : 测试计划说明（正式断言见 dv_status_unit_tb.sv）。
// Author  : dv-platform
// Date    : 2026-08-12
//======================================================================

// 测试覆盖：
// - 初始 PASS
// - 失败上报后转为 FAIL
// - 同 signature 聚合
// - SKIP / ABORT 显式设置
// - exit code 映射
// - collect_result 汇总
