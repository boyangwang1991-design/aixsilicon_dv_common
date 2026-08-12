//======================================================================
// AIX DV Common - mem backdoor 单元测试
// File    : unit/memory/dv_mem_backdoor_unit_test.sv
// Purpose : 测试计划说明（正式断言见 dv_mem_backdoor_unit_tb.sv）。
// Author  : dv-platform
// Date    : 2026-08-12
//======================================================================

// 测试覆盖：
// - backdoor adapter 契约（bd_write / bd_read / data_width）
// - ECC 数据插入/提取往返
// - 奇偶位辅助
// 注：具体 HDL/DPI backdoor adapter 依赖 DUT，属于项目层。
