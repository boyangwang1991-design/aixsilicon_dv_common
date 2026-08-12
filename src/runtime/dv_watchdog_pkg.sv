//======================================================================
// AIX DV Common - L2 看门狗服务
// File    : src/runtime/dv_watchdog_pkg.sv
// Purpose : 活跃度、事务进展、deadlock 观察。
//           Watchdog 通过 heartbeat 判断线程是否仍有有效进展。
// Author  : dv-platform
// Date    : 2026-08-12
//======================================================================

package dv_watchdog_pkg;

  import dv_common_types_pkg::*;
  import dv_log_pkg::*;

  //--------------------------------------------------------------------------
  // 看门狗条目：每个被监控线程一份
  //--------------------------------------------------------------------------
  class dv_watchdog_entry;

    string            name;
    time              last_heartbeat;
    time              timeout;
    longint           progress_count;  // 有效进展计数
    bit               enabled;

    function new(string n, time tmo);
      name            = n;
      timeout         = tmo;
      progress_count  = 0;
      enabled         = 1;
      last_heartbeat  = $time;
    endfunction

    function void kick();
      last_heartbeat = $time;
    endfunction

    function void bump_progress();
      progress_count++;
      last_heartbeat = $time;
    endfunction

    function bit is_stalled();
      if (!enabled) return 0;
      return (($time - last_heartbeat) >= timeout);
    endfunction

  endclass

  class dv_watchdog_service;

    protected dv_watchdog_entry m_entries[$];
    protected dv_log_context    m_log;
    protected bit               m_halt_on_stall;

    function new(string path = "watchdog", bit halt_on_stall = 1);
      m_log = new(path, "WATCHDOG");
      m_halt_on_stall = halt_on_stall;
    endfunction

    function dv_watchdog_entry add_entry(string name, time timeout);
      dv_watchdog_entry e = new(name, timeout);
      m_entries.push_back(e);
      return e;
    endfunction

    // 检查所有 entry，返回是否发现 stalled
    function bit check_all();
      bit stall = 0;
      foreach (m_entries[i]) begin
        if (m_entries[i].is_stalled()) begin
          m_log.error("DEADLOCK",
            $sformatf("watchdog '%s' stalled: no heartbeat for %0t (progress=%0d)",
                      m_entries[i].name, $time - m_entries[i].last_heartbeat,
                      m_entries[i].progress_count));
          stall = 1;
        end
      end
      return stall && m_halt_on_stall;
    endfunction

    function int active_count();
      int n = 0;
      foreach (m_entries[i])
        if (m_entries[i].enabled) n++;
      return n;
    endfunction

  endclass

endpackage : dv_watchdog_pkg
