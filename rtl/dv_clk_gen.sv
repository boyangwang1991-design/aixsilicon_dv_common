//======================================================================
// AIX DV Common - Clock Generator
// File    : rtl/dv_clk_gen.sv
// Purpose : 通用时钟生成：周期/频率、占空比、相位、动态启停。
//           非综合，仅供验证环境使用。
// Author  : dv-platform
// Date    : 2026-08-12
//======================================================================

module dv_clk_gen #(
    parameter real CLK_PERIOD  = 10.0,   // ns
    parameter real CLK_DUTY    = 0.5,    // 0.0 ~ 1.0
    parameter real CLK_PHASE_DEG = 0.0,  // 相位偏移（度）
    parameter bit  START_EN    = 1'b1
) (
    output logic clk_o,
    output logic clk_en_o
);

  real period_ns = CLK_PERIOD;
  real duty      = CLK_DUTY;
  bit  running   = START_EN;

  assign clk_en_o = running;

  // 相位偏移（初始延迟）
  initial begin
    clk_o = 1'b0;
    if (CLK_PHASE_DEG > 0.0)
      #(CLK_PHASE_DEG / 360.0 * CLK_PERIOD * 1ns);
  end

  // 时钟振荡
  always begin : clk_osc
    if (running) begin
      clk_o = 1'b1;
      #(period_ns * duty * 1ns);
      clk_o = 1'b0;
      #(period_ns * (1.0 - duty) * 1ns);
    end else begin
      clk_o = 1'b0;
      #1ns;
    end
  end

  // 动态启停接口
  task automatic dv_start();
    running = 1;
  endtask

  task automatic dv_stop();
    running = 0;
  endtask

  task automatic dv_set_period(real p);
    period_ns = p;
  endtask

  task automatic dv_set_duty(real d);
    duty = (d > 1.0) ? 1.0 : ((d < 0.0) ? 0.0 : d);
  endtask

  // 结构化 metric 输出
  initial begin
    $display("[%0t] [DV_CLK_GEN] period=%0fns duty=%0f phase=%0fdeg running=%0d",
             $time, period_ns, duty, CLK_PHASE_DEG, running);
  end

endmodule : dv_clk_gen
