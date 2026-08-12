//======================================================================
// AIX DV Common - Minimal UVM Example Top
// File    : examples/minimal_uvm/dv_minimal_test_top.sv
// Purpose : 顶层模块，启动 UVM 并运行 dv_minimal_test。
// Author  : dv-platform
// Date    : 2026-08-12
//======================================================================

module dv_minimal_test_top;

  import uvm_pkg::*;
  import dv_minimal_pkg::*;

  initial begin
    run_test("dv_minimal_test");
  end

endmodule : dv_minimal_test_top
