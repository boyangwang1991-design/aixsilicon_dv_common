//======================================================================
// AIX DV Common - L2 日志服务
// File    : src/runtime/dv_log_pkg.sv
// Purpose : 统一 Message ID、结构化字段、日志上下文。
//           Message ID 格式：AIX_DV_<DOMAIN>_<EVENT>
//           Message ID 是回归 signature 的稳定组成，禁止用自由文本。
// Author  : dv-platform
// Date    : 2026-08-12
//======================================================================

package dv_log_pkg;

  import dv_common_types_pkg::*;

  //--------------------------------------------------------------------------
  // 日志上下文（每个组件实例一份）
  //--------------------------------------------------------------------------
  class dv_log_context;

    protected string m_path;        // 组件路径，例如 env.agent.monitor
    protected string m_domain;      // Message ID 的 domain 段
    protected dv_severity_e m_threshold;

    function new(string path, string domain = "GEN",
                 dv_severity_e threshold = DV_INFO);
      m_path      = path;
      m_domain    = domain;
      m_threshold = threshold;
    endfunction

    // 组装完整 Message ID
    function string msg_id(string event_id);
      return $sformatf("AIX_DV_%s_%s", m_domain, event_id);
    endfunction

    function void log(dv_severity_e sev, string event_id, string text);
      if (sev < m_threshold) return;
      $display("[%0t] [%s] [%s] %s : %s",
               $realtime, dv_severity_name(sev), m_path, msg_id(event_id), text);
    endfunction

    function void info (string event_id, string text); log(DV_INFO,    event_id, text); endfunction
    function void warn (string event_id, string text); log(DV_WARNING, event_id, text); endfunction
    function void error(string event_id, string text); log(DV_ERROR,   event_id, text); endfunction
    function void fatal(string event_id, string text); log(DV_FATAL,   event_id, text); endfunction

    function string get_path();
      return m_path;
    endfunction

  endclass

  //--------------------------------------------------------------------------
  // 全局日志注册表（按路径查询上下文）
  //--------------------------------------------------------------------------
  class dv_log_registry;

    protected dv_log_context m_ctx[string];

    function void register(dv_log_context c);
      m_ctx[c.get_path()] = c;
    endfunction

    function dv_log_context get(string path);
      if (m_ctx.exists(path))
        return m_ctx[path];
      return null;
    endfunction

    function int count();
      return m_ctx.num();
    endfunction

  endclass

endpackage : dv_log_pkg
