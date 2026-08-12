//======================================================================
// AIX DV Common - scoreboard 单元测试顶层
// File    : unit/scoreboard/dv_scoreboard_unit_tb.sv
// Purpose : dv_scoreboard_base 统计单测（骨架）。
// Author  : dv-platform
// Date    : 2026-08-12
//======================================================================

module dv_scoreboard_unit_tb;

  import dv_scoreboard_base_pkg::*;

  int errors = 0;
  dv_scoreboard_base sb;
  dv_sb_stats_t st;

  initial begin
    sb = new();
    sb.write_expected(null);
    sb.write_actual(null);
    st = sb.get_statistics();
    if (st.received_expected != 1) errors++;
    if (st.received_actual != 1) errors++;
    if (sb.statistics_string() == "") errors++;

    if (errors == 0)
      $display("PASS: dv_scoreboard_unit_tb");
    else
      $display("FAIL: dv_scoreboard_unit_tb errors=%0d", errors);
    $finish;
  end

endmodule : dv_scoreboard_unit_tb
