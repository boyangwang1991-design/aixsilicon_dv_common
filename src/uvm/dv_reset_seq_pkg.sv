//======================================================================
// AIX DV Common - L4 Reset Sequence
// File    : src/uvm/dv_reset_seq_pkg.sv
// Purpose : 通用 reset 操作接口（assert/deassert/pulse/wait）。
// Author  : dv-platform
// Date    : 2026-08-12
//======================================================================

package dv_reset_seq_pkg;

  import uvm_pkg::*;
  import dv_common_types_pkg::*;

  class dv_reset_sequence extends uvm_sequence;

    `uvm_object_utils(dv_reset_sequence)

    // 复位配置
    dv_reset_type_e reset_type;
    time            pulse_width;
    bit             async;

    function new(string name = "dv_reset_sequence");
      super.new(name);
      reset_type  = DV_RESET_POR;
      pulse_width = 100ns;
      async       = 0;
    endfunction

    // 通用复位操作（具体时序由 reset driver 提供，此处为骨架）
    virtual task body();
      `uvm_info("DV_RESET_SEQ",
        $sformatf("issue reset type=%0d width=%0t async=%0d",
                  reset_type, pulse_width, async), UVM_MEDIUM)
      // 正式实现：驱动 rtl/dv_rst_gen.sv 接口
    endtask

    // 等待指定 epoch 的复位完成
    virtual task wait_reset_complete(int unsigned epoch);
      // 正式实现：等待 reset service 通知
    endtask

  endclass

endpackage : dv_reset_seq_pkg
