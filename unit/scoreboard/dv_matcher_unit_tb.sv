//======================================================================
// AIX DV Common - matcher 单元测试顶层
// File    : unit/scoreboard/dv_matcher_unit_tb.sv
// Purpose : in-order / out-of-order matcher 单测。
// Author  : dv-platform
// Date    : 2026-08-12
//======================================================================

module dv_matcher_unit_tb;

  import dv_matcher_pkg::*;
  import dv_queue_pkg::*;

  int errors = 0;
  dv_in_order_matcher io;
  dv_out_of_order_matcher ooo;
  dv_queue_item_t it, exp;

  initial begin
    io = new();

    // in-order
    for (int i = 0; i < 3; i++) begin
      it.id = i;
      it.payload = $sformatf("p%0d", i);
      io.push_expected(it);
    end
    it.payload = "p0";
    if (!io.match_next(it, exp)) errors++;
    it.payload = "p2";  // 乱序 -> mismatch
    if (io.match_next(it, exp)) errors++;
    if (io.pending() != 1) errors++;  // 剩余 p1
    if (io.flush() != 1) errors++;

    // out-of-order
    ooo = new();
    for (int i = 0; i < 3; i++) begin
      it.id = i;
      it.tag = $sformatf("key%0d", i);
      it.payload = $sformatf("p%0d", i);
      ooo.push_expected(it);
    end
    it.tag = "key2";
    it.payload = "p2";
    if (!ooo.match_by_key("key2", it, exp)) errors++;
    if (ooo.pending() != 2) errors++;
    if (ooo.flush() != 2) errors++;

    if (errors == 0)
      $display("PASS: dv_matcher_unit_tb");
    else
      $display("FAIL: dv_matcher_unit_tb errors=%0d", errors);
    $finish;
  end

endmodule : dv_matcher_unit_tb
