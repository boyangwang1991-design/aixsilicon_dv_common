//======================================================================
// AIX DV Common - log 单元测试顶层
// File    : unit/runtime/dv_log_unit_tb.sv
// Purpose : dv_log_context / dv_log_registry 单测。
// Author  : dv-platform
// Date    : 2026-08-12
//======================================================================

module dv_log_unit_tb;

  import dv_common_types_pkg::*;
  import dv_log_pkg::*;

  int errors = 0;
  dv_log_context  ctx;
  dv_log_registry registry;

  initial begin
    ctx = new("tb.mon", "MON");
    registry = new();

    // Message ID 组装
    if (ctx.msg_id("EVENT_A") != "AIX_DV_MON_EVENT_A") errors++;

    // 低于阈值不打印（此处阈值 INFO，WARNING 应打印）
    ctx.warn("W", "test warning");
    ctx.error("E", "test error");

    // registry
    registry.register(ctx);
    if (registry.count() != 1) errors++;
    if (registry.get("tb.mon") == null) errors++;

    if (errors == 0)
      $display("PASS: dv_log_unit_tb");
    else
      $display("FAIL: dv_log_unit_tb errors=%0d", errors);
    $finish;
  end

endmodule : dv_log_unit_tb
