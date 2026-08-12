//======================================================================
// AIX DV Common - CSR seq 单元测试
// File    : unit/ral/dv_csr_seq_unit_test.sv
// Purpose : 测试计划说明。完整 CSR sequence 行为测试需 RAL 模型 + adapter，
//           属于 APB 穿刺场景（examples/apb_csr_ip）。
// Author  : dv-platform
// Date    : 2026-08-12
//======================================================================

// 测试覆盖：
// - 测试名/排除策略映射
// - smoke 遍历读
// - HW reset 值校验
// - RW 读写比较
// - bit-bash 逐位翻转
// - 排除模式通配匹配（uvm_re_match）
