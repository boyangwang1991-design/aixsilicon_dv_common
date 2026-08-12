//======================================================================
// AIX DV Common - L4 Base Virtual Sequence
// File    : src/uvm/dv_base_vseq_pkg.sv
// Purpose : objection、reset、timeout、cfg handle 的公共基类。
// Author  : dv-platform
// Date    : 2026-08-12
//======================================================================

package dv_base_vseq_pkg;

  import uvm_pkg::*;
  import dv_common_types_pkg::*;
  import dv_config_pkg::*;
  import dv_timeout_pkg::*;
  import dv_vseqr_pkg::*;

  class dv_base_virtual_sequence extends uvm_sequence;

    `uvm_object_utils(dv_base_virtual_sequence)
    `uvm_declare_p_sequencer(dv_vseqr_pkg::dv_virtual_sequencer_base)

    // 强类型配置 handle（由 test 下发）
    dv_run_cfg_t run_cfg;

    function new(string name = "dv_base_virtual_sequence");
      super.new(name);
    endfunction

    // 公共执行模板：对象期 + body
    virtual task body();
      uvm_objection obj = null;
      // 对象期保护
      `uvm_info("DV_BASE_VSEQ", "base virtual sequence start", UVM_LOW)
      // 子类实现具体激励
    endtask

    // 等待 reset deassert 的辅助（由 reset service 驱动）
    virtual task wait_reset_deassert();
      // 正式实现：轮询 reset service 状态或事件
    endtask

  endclass

endpackage : dv_base_vseq_pkg
