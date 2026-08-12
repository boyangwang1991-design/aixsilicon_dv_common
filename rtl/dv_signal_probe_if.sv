//======================================================================
// AIX DV Common - Signal Probe Interface
// File    : rtl/dv_signal_probe_if.sv
// Purpose : 通用信号探测接口，供 monitor / coverage / backdoor 连接。
//           非综合，仅供验证环境使用。
// Author  : dv-platform
// Date    : 2026-08-12
//======================================================================

interface dv_signal_probe_if #(
    parameter int unsigned DATA_W = 32
) (
    input logic clk
);

  // 复位（由 TB 通过层次连接驱动）
  logic rst_n;

  // 探测信号（由 TB 通过层次连接注入）
  logic [DATA_W-1:0] probe_data;
  logic              probe_valid;

  // 上升沿探测
  logic probe_rise;
  logic probe_fall;
  logic prev_probe;

  always_ff @(posedge clk or negedge rst_n) begin : probe_edge
    if (!rst_n)
      prev_probe <= 1'b0;
    else
      prev_probe <= probe_data[0];
  end

  assign probe_rise = probe_data[0] & ~prev_probe;
  assign probe_fall = ~probe_data[0] & prev_probe;

  // 命名探测函数（供 UVM 侧通过 interface 引用）
  function automatic logic [DATA_W-1:0] get_probe_data();
    return probe_data;
  endfunction

endinterface : dv_signal_probe_if
