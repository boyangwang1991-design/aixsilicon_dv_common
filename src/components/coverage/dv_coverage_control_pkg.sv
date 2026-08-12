//======================================================================
// AIX DV Common - L3 Coverage 控制
// File    : src/components/coverage/dv_coverage_control_pkg.sv
// Purpose : enable、sample gating、instance 标识。
// Author  : dv-platform
// Date    : 2026-08-12
//======================================================================

package dv_coverage_control_pkg;

  import dv_common_types_pkg::*;

  class dv_coverage_control;

    protected bit       m_enable;
    protected bit       m_sample_gate;
    protected string    m_instance_id;
    protected int unsigned m_sample_count;

    function new(string instance_id = "");
      m_instance_id = instance_id;
      m_enable      = 1;
      m_sample_gate = 1;
    endfunction

    function void set_enable(bit e);
      m_enable = e;
    endfunction

    function bit is_enabled();
      return m_enable;
    endfunction

    // gate 控制：例如 reset 期间关闭采样
    function void set_sample_gate(bit g);
      m_sample_gate = g;
    endfunction

    // 采样前调用，返回是否应采样
    function bit should_sample();
      return (m_enable && m_sample_gate);
    endfunction

    function void bump_sample();
      m_sample_count++;
    endfunction

    function int unsigned sample_count();
      return m_sample_count;
    endfunction

  endclass

endpackage : dv_coverage_control_pkg
