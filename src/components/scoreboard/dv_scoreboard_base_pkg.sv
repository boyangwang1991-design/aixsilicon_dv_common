//======================================================================
// AIX DV Common - L3 Scoreboard 基础
// File    : src/components/scoreboard/dv_scoreboard_base_pkg.sv
// Purpose : dv_scoreboard_base 提供公共 API：
//             write_actual / write_expected / match / flush / drain /
//             get_pending_count / get_statistics，以及 matcher/compare policy 插槽。
//           业务层负责 transaction key、compare policy、reference model 调用。
// Author  : dv-platform
// Date    : 2026-08-12
//======================================================================

package dv_scoreboard_base_pkg;

  import dv_common_types_pkg::*;
  import dv_compare_pkg::*;

  //--------------------------------------------------------------------------
  // 通用事务句柄（业务层可扩展）
  //--------------------------------------------------------------------------
  virtual class dv_txn_base;
    pure virtual function string get_key();
    pure virtual function string get_transaction_type();
    pure virtual function longint get_epoch();
  endclass

  //--------------------------------------------------------------------------
  // Scoreboard 统计
  //--------------------------------------------------------------------------
  typedef struct {
    longint received_expected;
    longint received_actual;
    longint matched;
    longint mismatched;
    longint flushed;
    longint dropped_epoch;
  } dv_sb_stats_t;

  //--------------------------------------------------------------------------
  // Scoreboard 基础类（UVM 环境在子类中继承并实现业务 hook）
  //--------------------------------------------------------------------------
  class dv_scoreboard_base;

    protected dv_sb_stats_t m_stats;
    protected dv_compare_pkg::dv_compare_result_t m_last_diff;

    function new();
      m_stats = '{default:0};
    endfunction

    // 公共 API
    virtual function void write_expected(dv_txn_base txn);
      m_stats.received_expected++;
    endfunction

    virtual function void write_actual(dv_txn_base txn);
      m_stats.received_actual++;
    endfunction

    // 匹配：业务层实现（调用 matcher 与 compare policy）
    virtual function bit match(dv_txn_base exp, dv_txn_base act);
      return 0;
    endfunction

    // flush：清空待匹配，返回清空数量
    virtual function int unsigned flush(string reason);
      return 0;
    endfunction

    // drain：等待 outstanding 清空
    virtual function bit drain(time timeout);
      return 1;
    endfunction

    virtual function int unsigned get_pending_count();
      return 0;
    endfunction

    function dv_sb_stats_t get_statistics();
      return m_stats;
    endfunction

    function string statistics_string();
      return $sformatf("exp=%0d act=%0d matched=%0d mismatched=%0d flushed=%0d pending=%0d",
                       m_stats.received_expected, m_stats.received_actual,
                       m_stats.matched, m_stats.mismatched, m_stats.flushed,
                       get_pending_count());
    endfunction

  endclass

endpackage : dv_scoreboard_base_pkg
