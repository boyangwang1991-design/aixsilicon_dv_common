//======================================================================
// AIX DV Common - RTL 模块 smoke 测试
// File    : tests/smoke/dv_rtl_smoke_tb.sv
// Purpose : 实例化 dv_clk_gen / dv_rst_gen / dv_sim_timeout，
//           验证时钟翻转、复位释放与超时保护的实际行为。
// Author  : dv-platform
// Date    : 2026-08-12
//======================================================================

module dv_rtl_smoke_tb;

  logic       clk;
  logic       clk_en;
  logic       rst_n;
  logic [15:0] clk_edges = 16'h0;

  // 时钟：10ns 周期，50% 占空比
  dv_clk_gen #(
      .CLK_PERIOD(10.0),
      .CLK_DUTY(0.5),
      .CLK_PHASE_DEG(0.0)
  ) u_clk_gen (
      .clk_o(clk),
      .clk_en_o(clk_en)
  );

  // 复位：active-low，30ns 上电脉冲
  dv_rst_gen #(
      .RST_ACTIVE_HIGH(1'b0),
      .RST_PULSE_WIDTH(30ns),
      .RST_ASYNC(1'b1)
  ) u_rst_gen (
      .clk(clk),
      .rst_o(rst_n)
  );

  // 全局超时保护：200ns 后强制结束（不应触发）
  dv_sim_timeout #(
      .TIMEOUT(200ns),
      .EXIT_CODE(4)
  ) u_timeout (
      .enable(1'b1)
  );

  // 统计时钟上升沿
  always @(posedge clk) begin
    if (clk_en)
      clk_edges = clk_edges + 16'h1;
  end

  int errors = 0;

  initial begin
    #100ns;
    // 时钟应已翻转多次（100ns / 10ns ≈ 10 个上升沿）
    if (clk_edges < 5) errors++;
    // active-low 复位在 30ns 后应已释放
    if (rst_n !== 1'b1) errors++;
    // 时钟使能应有效
    if (clk_en !== 1'b1) errors++;

    if (errors == 0)
      $display("PASS: dv_rtl_smoke_tb (clk_edges=%0d rst_n=%b clk_en=%b)",
               clk_edges, rst_n, clk_en);
    else
      $display("FAIL: dv_rtl_smoke_tb errors=%0d", errors);
    $finish;
  end

endmodule : dv_rtl_smoke_tb
