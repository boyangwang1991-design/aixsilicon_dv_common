//======================================================================
// AIX DV Common - Simulation Timeout
// File    : rtl/dv_sim_timeout.sv
// Purpose : 仿真级全局 timeout，防止整个 test 无限运行。
//           非综合，仅供验证环境使用。
// Author  : dv-platform
// Date    : 2026-08-12
//======================================================================

module dv_sim_timeout #(
    parameter time TIMEOUT = 1ms,
    parameter int  EXIT_CODE = 4
) (
    input logic enable
);

  initial begin
    if (enable) begin
      #(TIMEOUT);
      $display("ERROR: [%0t] [DV_SIM_TIMEOUT] global simulation timeout reached (%0t)", $time, TIMEOUT);
      $finish(EXIT_CODE);
    end
  end

  initial begin
    $display("[%0t] [DV_SIM_TIMEOUT] armed timeout=%0t exit_code=%0d enable=%0d",
             $time, TIMEOUT, EXIT_CODE, enable);
  end

endmodule : dv_sim_timeout
