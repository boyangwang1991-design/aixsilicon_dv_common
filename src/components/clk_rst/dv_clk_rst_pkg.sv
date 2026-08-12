//======================================================================
// AIX DV Common - L3 Clock/Reset 组件
// File    : src/components/clk_rst/dv_clk_rst_pkg.sv
// Purpose : 通用 Clock/Reset 生成、监测、序列和 Reset 通知（UVM 侧装配）。
//           波形产生的协议性 assertion 属于 HW Interface / VIP checker，
//           本组件只负责产生、监测与事件服务。
// Author  : dv-platform
// Date    : 2026-08-12
//======================================================================

package dv_clk_rst_pkg;

  import dv_common_types_pkg::*;

  //--------------------------------------------------------------------------
  // 时钟配置
  //--------------------------------------------------------------------------
  typedef struct {
    real            period;       // 周期（可配置）
    real            freq_mhz;     // 或频率
    real            duty_cycle;   // 0.0 ~ 1.0
    real            phase_deg;    // 相位偏移（度）
    bit             start_enabled;
    string          name;
  } dv_clk_cfg_t;

  //--------------------------------------------------------------------------
  // 复位配置
  //--------------------------------------------------------------------------
  typedef struct {
    bit             active_high;
    bit             async_assert;
    bit             async_deassert;
    time            pulse_width;
    dv_reset_type_e reset_type;
    string          name;
  } dv_rst_cfg_t;

  //--------------------------------------------------------------------------
  // 时钟状态（供查询与 metric 输出）
  //--------------------------------------------------------------------------
  typedef struct {
    string name;
    bit    running;
    real   freq_mhz;
    real   duty_cycle;
    longint edge_count;
  } dv_clk_status_t;

  //--------------------------------------------------------------------------
  // UVM 侧时钟驱动骨架（具体驱动调用 rtl/dv_clk_gen.sv）
  //--------------------------------------------------------------------------
  class dv_clk_driver;

    protected dv_clk_cfg_t    m_cfg;
    protected dv_clk_status_t m_status;
    protected string          m_path;
    protected bit             m_running;

    function new(string path, dv_clk_cfg_t cfg);
      m_path  = path;
      m_cfg   = cfg;
      m_running = cfg.start_enabled;
      m_status.name      = cfg.name;
      m_status.running   = cfg.start_enabled;
      m_status.freq_mhz  = (cfg.freq_mhz > 0.0) ? cfg.freq_mhz : (1.0e6 / cfg.period);
      m_status.duty_cycle= cfg.duty_cycle;
    endfunction

    function void start();
      m_running = 1;
      m_status.running = 1;
    endfunction

    function void stop();
      m_running = 0;
      m_status.running = 0;
    endfunction

    function bit is_running();
      return m_running;
    endfunction

    function void bump_edge();
      m_status.edge_count++;
    endfunction

    function dv_clk_status_t get_status();
      return m_status;
    endfunction

  endclass

  //--------------------------------------------------------------------------
  // 复位驱动骨架（具体时序调用 rtl/dv_rst_gen.sv）
  //--------------------------------------------------------------------------
  class dv_rst_driver;

    protected dv_rst_cfg_t m_cfg;
    protected bit          m_asserted;
    protected int unsigned m_epoch;
    protected string       m_path;

    function new(string path, dv_rst_cfg_t cfg);
      m_path  = path;
      m_cfg   = cfg;
      m_asserted = 0;
      m_epoch    = 0;
    endfunction

    // 发起一次复位 assert，返回递增后的 epoch
    function int unsigned assert_reset();
      m_epoch++;
      m_asserted = 1;
      return m_epoch;
    endfunction

    function void deassert();
      m_asserted = 0;
    endfunction

    function bit is_asserted();
      return m_asserted;
    endfunction

    function int unsigned get_epoch();
      return m_epoch;
    endfunction

  endclass

endpackage : dv_clk_rst_pkg
