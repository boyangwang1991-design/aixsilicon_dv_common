//======================================================================
// AIX DV Common - L1 统计工具
// File    : src/utils/dv_stats_pkg.sv
// Purpose : counter、histogram、latency 统计。
// Author  : dv-platform
// Date    : 2026-08-12
//======================================================================

package dv_stats_pkg;

  import dv_common_types_pkg::*;

  //--------------------------------------------------------------------------
  // 简单计数器
  //--------------------------------------------------------------------------
  class dv_counter;

    protected string        m_name;
    protected longint       m_count;
    protected longint       m_min;
    protected longint       m_max;
    protected longint       m_sum;

    function new(string name = "counter");
      m_name  = name;
      m_count = 0;
      m_min   = 0;
      m_max   = 0;
      m_sum   = 0;
    endfunction

    function void increment(longint by = 1);
      m_count += by;
    endfunction

    function void add_sample(longint value);
      m_sum += value;
      if (m_count == 0) begin
        m_min = value;
        m_max = value;
      end else begin
        if (value < m_min) m_min = value;
        if (value > m_max) m_max = value;
      end
      m_count++;
    endfunction

    function longint count();
      return m_count;
    endfunction

    function real avg();
      if (m_count == 0) return 0.0;
      return real'(m_sum) / real'(m_count);
    endfunction

    function string stats_string();
      return $sformatf("%s count=%0d min=%0d max=%0d avg=%0f",
                       m_name, m_count, m_min, m_max, avg());
    endfunction

  endclass

  //--------------------------------------------------------------------------
  // 直方图
  //--------------------------------------------------------------------------
  class dv_histogram;

    protected longint m_bins[longint];
    protected string  m_name;

    function new(string name = "hist");
      m_name = name;
    endfunction

    function void add(longint key, longint by = 1);
      if (m_bins.exists(key))
        m_bins[key] += by;
      else
        m_bins[key] = by;
    endfunction

    function longint get(longint key);
      if (m_bins.exists(key))
        return m_bins[key];
      return 0;
    endfunction

    function longint total();
      longint t = 0;
      foreach (m_bins[k]) t += m_bins[k];
      return t;
    endfunction

    function string stats_string();
      string s = {m_name, ":"};
      foreach (m_bins[k]) begin
        s = {s, $sformatf(" [%0d]=%0d", k, m_bins[k])};
      end
      return s;
    endfunction

  endclass

  //--------------------------------------------------------------------------
  // 延迟统计（request/response 配对）
  //--------------------------------------------------------------------------
  class dv_latency_tracker;

    protected dv_histogram   m_hist;
    protected dv_counter     m_counter;
    protected realtime       m_req_time[longint];
    protected string         m_name;

    function new(string name = "latency");
      m_name    = name;
      m_hist    = new({name, ".hist"});
      m_counter = new({name, ".count"});
    endfunction

    // 记录 request 时间点
    function void request(longint id);
      m_req_time[id] = $realtime;
    endfunction

    // 记录 response，计算延迟（ps）
    function void response(longint id);
      realtime lat = $realtime - m_req_time[id];
      m_hist.add(longint'(lat / 1ps));
      m_counter.add_sample(longint'(lat / 1ps));
      m_req_time.delete(id);
    endfunction

    function longint outstanding();
      return m_req_time.num();
    endfunction

    function string stats_string();
      return $sformatf("%s %s outstanding=%0d",
                       m_name, m_counter.stats_string(), outstanding());
    endfunction

  endclass

endpackage : dv_stats_pkg
