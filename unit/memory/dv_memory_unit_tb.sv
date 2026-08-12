//======================================================================
// AIX DV Common - memory 单元测试顶层
// File    : unit/memory/dv_memory_unit_tb.sv
// Purpose : dv_memory_model 单测（byte enable、unknown policy）。
// Author  : dv-platform
// Date    : 2026-08-12
//======================================================================

module dv_memory_unit_tb;

  import dv_memory_model_pkg::*;

  int errors = 0;

  initial begin
    dv_memory_model mem = new(DV_MEM_SPARSE, DV_MEM_UNKNOWN_ZERO, 1024, 32);
    logic [63:0] d;

    // 未初始化读返回 0（ZERO policy）
    if (!mem.read(100, d) || d !== 0) errors++;

    // 带 byte enable 写：只写低 16 位
    mem.write(100, 64'h0000_0000_0000_DEAD, 8'h03);
    if (!mem.read(100, d)) errors++;
    if (d !== 64'h0000_0000_0000_DEAD) errors++;

    // 再写高字节（bytes 4~7，即 bits[63:32]），低字节保留
    mem.write(100, 64'hBEEF_0000_0000_0000, 8'hF0);
    if (!mem.read(100, d)) errors++;
    if (d !== 64'hBEEF_0000_0000_DEAD) errors++;

    // init_all
    mem.init_all(64'hAA55);
    if (!mem.read(0, d) || d !== 64'hAA55) errors++;

    if (errors == 0)
      $display("PASS: dv_memory_unit_tb");
    else
      $display("FAIL: dv_memory_unit_tb errors=%0d", errors);
    $finish;
  end

endmodule : dv_memory_unit_tb
