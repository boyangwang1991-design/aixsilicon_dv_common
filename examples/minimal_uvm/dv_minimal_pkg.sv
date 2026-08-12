//======================================================================
// AIX DV Common - Minimal UVM Example 包
// File    : examples/minimal_uvm/dv_minimal_pkg.sv
// Purpose : 最小 UVM 示例的包，演示 dv_base_test 装配。
// Author  : dv-platform
// Date    : 2026-08-12
//======================================================================

package dv_minimal_pkg;

  import uvm_pkg::*;
  import dv_common_types_pkg::*;
  import dv_status_pkg::*;
  import dv_config_pkg::*;
  import dv_base_test_pkg::*;

  //--------------------------------------------------------------------------
  // 最小测试：继承 dv_base_test，演示公共服务装配
  //--------------------------------------------------------------------------
  class dv_minimal_test extends dv_base_test;

    `uvm_component_utils(dv_minimal_test)

    function new(string name = "dv_minimal_test", uvm_component parent = null);
      super.new(name, parent);
    endfunction

    // 极简 run_phase：等待若干时钟后直接 PASS
    virtual task run_phase(uvm_phase phase);
      phase.raise_objection(this);
      `uvm_info("DV_MINIMAL", "minimal test running", UVM_LOW)
      repeat (10) #10ns;
      `uvm_info("DV_MINIMAL", "minimal test done", UVM_LOW)
      phase.drop_objection(this);
    endtask

  endclass

endpackage : dv_minimal_pkg
