//======================================================================
// AIX DV Common - timeout 单元测试顶层
// File    : unit/runtime/dv_timeout_unit_tb.sv
// Purpose : dv_timeout_service 单测。
// Author  : dv-platform
// Date    : 2026-08-12
//======================================================================

module dv_timeout_unit_tb;

  import dv_timeout_pkg::*;

  int errors = 0;
  dv_timeout_service svc;
  dv_timeout_service svc2;
  dv_timeout_item it;
  dv_timeout_item it2;

  initial begin
    svc = new();

    // 短超时：立即过期
    it = svc.add_timeout(DV_TIMEOUT_OPERATION, "op", 1ns, "tb");
    #2ns;
    if (!it.is_expired()) errors++;
    if (!svc.check_all()) errors++;  // stop_on_timeout 默认 1，应返回 1

    // 长超时：不触发
    svc2 = new("timeout2", 0);
    it2 = svc2.add_timeout(DV_TIMEOUT_OPERATION, "op2", 1ms, "tb");
    #1ns;
    if (it2.is_expired()) errors++;
    if (svc2.check_all()) errors++;

    if (errors == 0)
      $display("PASS: dv_timeout_unit_tb");
    else
      $display("FAIL: dv_timeout_unit_tb errors=%0d", errors);
    $finish;
  end

endmodule : dv_timeout_unit_tb
