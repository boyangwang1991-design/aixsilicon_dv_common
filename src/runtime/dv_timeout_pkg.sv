//======================================================================
// AIX DV Common - L2 超时服务
// File    : src/runtime/dv_timeout_pkg.sv
// Purpose : 全局/局部 timeout、进度 timeout、诊断回调。
//           Timeout 触发时先执行诊断 hook（outstanding、pending、
//           objection holder、heartbeat、reset 状态）再结束测试。
// Author  : dv-platform
// Date    : 2026-08-12
//======================================================================

package dv_timeout_pkg;

  import dv_common_types_pkg::*;
  import dv_log_pkg::*;

  //--------------------------------------------------------------------------
  // 超时层级
  //--------------------------------------------------------------------------
  typedef enum int {
    DV_TIMEOUT_GLOBAL   = 0,  // 防止整个 test 无限运行
    DV_TIMEOUT_PHASE    = 1,  // 约束某阶段
    DV_TIMEOUT_OPERATION= 2,  // CSR、memory、sequence 等单操作
    DV_TIMEOUT_PROGRESS = 3,  // 有线程但无有效进展
    DV_TIMEOUT_DRAIN    = 4   // 结束时等待 outstanding 清空
  } dv_timeout_kind_e;

  //--------------------------------------------------------------------------
  // 诊断回调接口（由装配方注入）
  //--------------------------------------------------------------------------
  virtual class dv_timeout_diag_if;
    pure virtual function string dump_diagnostics();
  endclass

  //--------------------------------------------------------------------------
  // 单条 timeout 实例
  //--------------------------------------------------------------------------
  class dv_timeout_item;

    dv_timeout_kind_e kind;
    string            name;
    time              start_time;
    time              duration;
    bit               armed;
    bit               fired;
    string            owner;         // 负责报告进度的组件路径

    function new(dv_timeout_kind_e k, string n, time dur, string own = "");
      kind = k;
      name = n;
      duration = dur;
      owner = own;
      armed = 0;
      fired = 0;
    endfunction

    function void arm();
      start_time = $time;
      armed = 1;
    endfunction

    function void disarm();
      armed = 0;
    endfunction

    // 检查是否已超时
    function bit is_expired();
      if (!armed) return 0;
      return (($time - start_time) >= duration);
    endfunction

  endclass

  //--------------------------------------------------------------------------
  // 超时服务
  //--------------------------------------------------------------------------
  class dv_timeout_service;

    protected dv_timeout_item m_items[$];
    protected dv_log_context   m_log;
    protected dv_timeout_diag_if m_diag;
    protected bit             m_stop_on_timeout;

    function new(string path = "timeout", bit stop_on_timeout = 1);
      m_log = new(path, "TIMEOUT");
      m_stop_on_timeout = stop_on_timeout;
    endfunction

    function void set_diag(dv_timeout_diag_if d);
      m_diag = d;
    endfunction

    // 创建并 arm 一个 timeout
    function dv_timeout_item add_timeout(dv_timeout_kind_e kind, string name,
                                         time duration, string owner = "");
      dv_timeout_item it = new(kind, name, duration, owner);
      it.arm();
      m_items.push_back(it);
      return it;
    endfunction

    // 周期性调用：检查所有 timeout
    function bit check_all();
      foreach (m_items[i]) begin
        if (m_items[i].is_expired() && !m_items[i].fired) begin
          m_items[i].fired = 1;
          on_timeout(m_items[i]);
          if (m_stop_on_timeout)
            return 1;
        end
      end
      return 0;
    endfunction

    protected function void on_timeout(dv_timeout_item it);
      m_log.fatal("TIMEOUT_GLOBAL",
        $sformatf("timeout '%s' kind=%0d owner=%s expired at %0t",
                  it.name, it.kind, it.owner, $time));
      if (m_diag != null) begin
        m_log.info("TIMEOUT_DIAG", m_diag.dump_diagnostics());
      end
    endfunction

    function int active_count();
      int n = 0;
      foreach (m_items[i])
        if (m_items[i].armed && !m_items[i].fired) n++;
      return n;
    endfunction

  endclass

endpackage : dv_timeout_pkg
