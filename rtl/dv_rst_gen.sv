//======================================================================
// AIX DV Common - Reset Generator
// File    : rtl/dv_rst_gen.sv
// Purpose : 通用复位生成：active-high/low、同步/异步、pulse width、POR/warm。
//           非综合，仅供验证环境使用。
// Author  : dv-platform
// Date    : 2026-08-12
//======================================================================

module dv_rst_gen #(
    parameter bit  RST_ACTIVE_HIGH = 1'b0,  // 0=active-low, 1=active-high
    parameter time RST_PULSE_WIDTH = 100ns,
    parameter bit  RST_ASYNC       = 1'b1
) (
    input  logic clk,
    output logic rst_o
);

  bit  asserted = 1'b1;  // 默认上电复位
  time pulse_w  = RST_PULSE_WIDTH;

  // 输出逻辑：依据 active polarity
  assign rst_o = RST_ACTIVE_HIGH ? asserted : ~asserted;

  // 复位脉冲任务
  task automatic dv_assert_reset();
    asserted = 1'b1;
  endtask

  task automatic dv_deassert_reset();
    asserted = 1'b0;
  endtask

  // 上电复位：默认 assert 一段时间后释放
  initial begin
    if (RST_ASYNC) begin
      asserted = 1'b1;
      #(RST_PULSE_WIDTH);
      asserted = 1'b0;
    end else begin
      @(posedge clk);
      asserted = 1'b1;
      repeat (1) @(posedge clk);
      asserted = 1'b0;
    end
  end

  // 复位周期任务（供 UVM 侧调用）
  task automatic dv_reset_pulse();
    dv_assert_reset();
    #(pulse_w);
    dv_deassert_reset();
  endtask

  initial begin
    $display("[%0t] [DV_RST_GEN] active_high=%0d async=%0d pulse=%0t",
             $time, RST_ACTIVE_HIGH, RST_ASYNC, RST_PULSE_WIDTH);
  end

endmodule : dv_rst_gen
