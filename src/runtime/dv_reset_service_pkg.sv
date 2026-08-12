//======================================================================
// AIX DV Common - L2 复位服务
// File    : src/runtime/dv_reset_service_pkg.sv
// Purpose : Reset 事件、epoch、reset-aware 通知。
//           Reset assert 时 epoch 递增，跨 reset 保存状态的组件必须使用 epoch。
// Author  : dv-platform
// Date    : 2026-08-12
//======================================================================

package dv_reset_service_pkg;

  import dv_common_types_pkg::*;
  import dv_log_pkg::*;

  //--------------------------------------------------------------------------
  // 复位订阅者接口（component 实现以获得 reset 通知）
  //--------------------------------------------------------------------------
  virtual class dv_reset_subscriber_if;
    pure virtual function void on_reset_assert(dv_reset_type_e rtype, int unsigned epoch);
    pure virtual function void on_reset_deassert(dv_reset_type_e rtype, int unsigned epoch);
  endclass

  class dv_reset_service;

    protected int unsigned            m_epoch;
    protected dv_reset_type_e         m_active_type;
    protected bit                     m_asserted;
    protected dv_log_context          m_log;
    protected dv_reset_subscriber_if  m_subs[$];

    function new(string path = "reset");
      m_epoch       = 0;
      m_asserted    = 0;
      m_active_type = DV_RESET_NONE;
      m_log = new(path, "RESET");
    endfunction

    function void subscribe(dv_reset_subscriber_if s);
      m_subs.push_back(s);
    endfunction

    // 广播 reset assert：epoch 递增
    function void assert_reset(dv_reset_type_e rtype);
      m_epoch++;
      m_asserted    = 1;
      m_active_type = rtype;
      m_log.info("RESET_EPOCH",
        $sformatf("reset assert type=%0d epoch=%0d", rtype, m_epoch));
      foreach (m_subs[i])
        m_subs[i].on_reset_assert(rtype, m_epoch);
    endfunction

    // 广播 reset deassert
    function void deassert_reset(dv_reset_type_e rtype);
      m_asserted = 0;
      m_log.info("RESET_EPOCH",
        $sformatf("reset deassert type=%0d epoch=%0d", rtype, m_epoch));
      foreach (m_subs[i])
        m_subs[i].on_reset_deassert(rtype, m_epoch);
    endfunction

    function int unsigned get_epoch();
      return m_epoch;
    endfunction

    function bit is_in_reset();
      return m_asserted;
    endfunction

    function dv_reset_type_e active_type();
      return m_active_type;
    endfunction

  endclass

endpackage : dv_reset_service_pkg
