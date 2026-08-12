//======================================================================
// AIX DV Common - L3 Fault Control
// File    : src/components/fault/dv_fault_control_pkg.sv
// Purpose : 通用故障请求与生命周期接口，不含具体故障模型。
// Author  : dv-platform
// Date    : 2026-08-12
//======================================================================

package dv_fault_control_pkg;

  import dv_common_types_pkg::*;

  //--------------------------------------------------------------------------
  // 故障阶段
  //--------------------------------------------------------------------------
  typedef enum int {
    DV_FAULT_IDLE         = 0,
    DV_FAULT_REQUESTED    = 1,
    DV_FAULT_ACTIVATED    = 2,
    DV_FAULT_OBSERVED     = 3,
    DV_FAULT_RECOVERED    = 4,
    DV_FAULT_FAILED       = 5
  } dv_fault_phase_e;

  //--------------------------------------------------------------------------
  // 故障请求
  //--------------------------------------------------------------------------
  typedef struct {
    int unsigned    fault_id;
    string          fault_tag;
    string          requirement_id;  // 功能安全需求绑定
    dv_fault_phase_e phase;
    int unsigned    epoch;
    string          detail;
  } dv_fault_request_t;

  //--------------------------------------------------------------------------
  // 故障控制器（生命周期模板）
  //--------------------------------------------------------------------------
  class dv_fault_control;

    protected dv_fault_request_t m_active;
    protected bit                m_busy;
    protected string             m_path;

    function new(string path = "fault");
      m_path = path;
      m_busy = 0;
      m_active.phase = DV_FAULT_IDLE;
    endfunction

    // 请求故障注入
    function bit request(dv_fault_request_t req);
      if (m_busy) return 0;
      m_active = req;
      m_active.phase = DV_FAULT_REQUESTED;
      m_busy = 1;
      return 1;
    endfunction

    // 激活故障
    function void activate();
      if (m_active.phase == DV_FAULT_REQUESTED)
        m_active.phase = DV_FAULT_ACTIVATED;
    endfunction

    // 观测到故障效应
    function void observe(string evidence);
      if (m_active.phase == DV_FAULT_ACTIVATED)
        m_active.phase = DV_FAULT_OBSERVED;
    endfunction

    // 恢复
    function void recover();
      if (m_active.phase == DV_FAULT_OBSERVED) begin
        m_active.phase = DV_FAULT_RECOVERED;
        m_busy = 0;
      end
    endfunction

    // 判定失败
    function void fail(string reason);
      m_active.phase = DV_FAULT_FAILED;
      m_active.detail = reason;
    endfunction

    function dv_fault_phase_e phase();
      return m_active.phase;
    endfunction

    function bit is_busy();
      return m_busy;
    endfunction

  endclass

endpackage : dv_fault_control_pkg
