//======================================================================
// AIX DV Common - types 单元测试顶层
// File    : unit/types/dv_common_types_unit_tb.sv
// Purpose : dv_common_types 单测顶层。
// Author  : dv-platform
// Date    : 2026-08-12
//======================================================================

module dv_common_types_unit_tb;

  import dv_common_types_pkg::*;

  int errors = 0;

  // 简单自检
  initial begin
    // status -> exit code 映射
    if (dv_status_to_exit(DV_STATUS_PASS) != DV_EXIT_PASS) errors++;
    if (dv_status_to_exit(DV_STATUS_FAIL) != DV_EXIT_DUT_FAIL) errors++;
    if (dv_status_to_exit(DV_STATUS_SKIP) != DV_EXIT_SKIP) errors++;
    if (dv_status_to_exit(DV_STATUS_ABORT) != DV_EXIT_ABORT) errors++;

    // 名称字符串
    if (dv_status_name(DV_STATUS_FAIL) != "FAIL") errors++;
    if (dv_severity_name(DV_FATAL) != "FATAL") errors++;

    if (errors == 0)
      $display("PASS: dv_common_types_unit_tb");
    else
      $display("FAIL: dv_common_types_unit_tb errors=%0d", errors);
    $finish;
  end

endmodule : dv_common_types_unit_tb
