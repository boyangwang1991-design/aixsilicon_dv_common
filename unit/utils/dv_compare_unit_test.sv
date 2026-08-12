//======================================================================
// AIX DV Common - compare 单元测试
// File    : unit/utils/dv_compare_unit_test.sv
// Purpose : 测试计划说明（正式断言见 dv_compare_unit_tb.sv）。
// Author  : dv-platform
// Date    : 2026-08-12
//======================================================================

// 测试覆盖：
// - exact / mask / tolerance / float / dontcare 模式
// - X/Z 策略（treat_as_dontcare / match_x / mismatch_if_x）
// - wildcard 比较
// - 结构化 diff 输出
// - 非法输入（字段数量不匹配）
