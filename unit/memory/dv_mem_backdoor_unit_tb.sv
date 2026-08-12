//======================================================================
// AIX DV Common - mem backdoor 单元测试顶层
// File    : unit/memory/dv_mem_backdoor_unit_tb.sv
// Purpose : dv_ecc_helper 单测（骨架）。
// Author  : dv-platform
// Date    : 2026-08-12
//======================================================================

module dv_mem_backdoor_unit_tb;

  import dv_mem_backdoor_pkg::*;

  int errors = 0;
  dv_ecc_helper ecc;
  logic [71:0] word;
  logic [63:0] data;
  logic [63:0] d2;
  logic [7:0]  e;
  logic [7:0]  e2;

  initial begin
    ecc = new();
    data = 64'h1234_5678_9ABC_DEF0;
    e = 8'hA5;

    word = ecc.inject_ecc(data, e);
    ecc.extract_ecc(word, d2, e2);
    if (d2 !== data) errors++;
    if (e2 !== e) errors++;

    // 奇偶位
    if (ecc.parity_even(data) !== ^data) errors++;

    if (errors == 0)
      $display("PASS: dv_mem_backdoor_unit_tb");
    else
      $display("FAIL: dv_mem_backdoor_unit_tb errors=%0d", errors);
    $finish;
  end

endmodule : dv_mem_backdoor_unit_tb
