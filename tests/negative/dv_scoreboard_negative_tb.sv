//======================================================================
// AIX DV Common - Scoreboard Negative 测试
// File    : tests/negative/dv_scoreboard_negative_tb.sv
// Purpose : 失败路径：不匹配、pending 非空、非法输入。
// Author  : dv-platform
// Date    : 2026-08-12
//======================================================================

module dv_scoreboard_negative_tb;

  import dv_matcher_pkg::*;
  import dv_queue_pkg::*;

  int errors = 0;

  initial begin
    dv_in_order_matcher io = new();
    dv_queue_item_t it, exp;

    // 空队列匹配 -> 失败（negative）
    it.payload = "orphan";
    if (io.match_next(it, exp)) errors++;

    // 内容不匹配 -> 失败
    it.payload = "exp";
    io.push_expected(it);
    it.payload = "act";
    if (io.match_next(it, exp)) errors++;

    // 非法：多余 actual 应产生 mismatch 计数
    if (io.pending() != 0) errors++;

    if (errors == 0)
      $display("PASS: dv_scoreboard_negative_tb (negative paths handled)");
    else
      $display("FAIL: dv_scoreboard_negative_tb errors=%0d", errors);
    $finish;
  end

endmodule : dv_scoreboard_negative_tb
