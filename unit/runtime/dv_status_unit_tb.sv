//======================================================================
// AIX DV Common - status 单元测试顶层
// File    : unit/runtime/dv_status_unit_tb.sv
// Purpose : dv_status_service 单测（失败聚合、首错、signature）。
// Author  : dv-platform
// Date    : 2026-08-12
//======================================================================

module dv_status_unit_tb;

  import dv_common_types_pkg::*;
  import dv_status_pkg::*;
  import dv_result_types_pkg::*;

  int errors = 0;
  dv_status_service svc;
  dv_failure_t f;

  initial begin
    svc = new();

    if (svc.get_status() != DV_STATUS_PASS) errors++;

    // 上报失败
    f.signature.message_id = "AIX_DV_SB_MISMATCH";
    f.signature.component_path = "tb.sb";
    f.signature.transaction_type = "txn";
    f.signature.normalized_location = "unit_test";
    f.signature.root_cause_tag = "data";
    f.detail = "mismatch 1";
    f.count = 1;

    svc.report_failure(f);
    svc.report_failure(f);  // 同 signature 聚合

    if (svc.get_status() != DV_STATUS_FAIL) errors++;
    if (svc.failure_count() != 1) errors++;          // 聚合成 1 条
    if (svc.get_exit_code() != DV_EXIT_DUT_FAIL) errors++;
    if (svc.get_primary_signature() == "") errors++;

    if (errors == 0)
      $display("PASS: dv_status_unit_tb");
    else
      $display("FAIL: dv_status_unit_tb errors=%0d", errors);
    $finish;
  end

endmodule : dv_status_unit_tb
