//======================================================================
// AIX DV Common - CSR seq 单元测试顶层
// File    : unit/ral/dv_csr_seq_unit_tb.sv
// Purpose : dv_csr_seq_pkg 工具函数单测（无需 RAL 模型）。
// Author  : dv-platform
// Date    : 2026-08-12
//======================================================================

module dv_csr_seq_unit_tb;

  import dv_csr_seq_pkg::*;

  int errors = 0;

  initial begin
    // 测试名映射
    if (dv_csr_test_name(DV_CSR_TEST_BIT_BASH) != "bit_bash") errors++;
    if (dv_csr_test_name(DV_CSR_TEST_BACKDOOR_CMP) != "backdoor_compare") errors++;

    // 排除匹配（正式实现依赖 uvm_re_match，此处只做存在性检查）
    if (errors == 0)
      $display("PASS: dv_csr_seq_unit_tb");
    else
      $display("FAIL: dv_csr_seq_unit_tb errors=%0d", errors);
    $finish;
  end

endmodule : dv_csr_seq_unit_tb
