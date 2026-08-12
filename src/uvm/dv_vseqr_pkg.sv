//======================================================================
// AIX DV Common - L4 Virtual Sequencer
// File    : src/uvm/dv_vseqr_pkg.sv
// Purpose : dv_virtual_sequencer_base 仅提供注册机制，不预定义具体 VIP sequencer。
// Author  : dv-platform
// Date    : 2026-08-12
//======================================================================

package dv_vseqr_pkg;

  import uvm_pkg::*;
  import dv_common_types_pkg::*;

  class dv_virtual_sequencer_base extends uvm_sequencer;

    // 命名 sequencer 注册表：项目将具体 sequencer handle 放入此处
    uvm_sequencer_base sequencers[string];

    `uvm_component_utils(dv_virtual_sequencer_base)

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction

    // 注册一个 sequencer
    function void add_sequencer(string name, uvm_sequencer_base seqr);
      sequencers[name] = seqr;
    endfunction

    // 按名获取
    function uvm_sequencer_base get_sequencer(string name);
      if (sequencers.exists(name))
        return sequencers[name];
      return null;
    endfunction

  endclass

endpackage : dv_vseqr_pkg
