//======================================================================
// AIX DV Common - L2 状态服务
// File    : src/runtime/dv_status_pkg.sv
// Purpose : PASS/FAIL/SKIP/ABORT 统一判定、首错、错误聚合与退出码。
// Author  : dv-platform
// Date    : 2026-08-12
//======================================================================

package dv_status_pkg;

  import dv_common_types_pkg::*;
  import dv_result_types_pkg::*;

  class dv_status_service;

    protected dv_status_e       m_status;
    protected dv_failure_t      m_failures[$];
    protected int unsigned      m_error_count;
    protected int unsigned      m_fatal_count;
    protected bit               m_first_error_recorded;
    protected dv_failure_t      m_first_failure;
    protected string            m_primary_signature;

    function new();
      m_status                = DV_STATUS_PASS;
      m_error_count           = 0;
      m_fatal_count           = 0;
      m_first_error_recorded  = 0;
    endfunction

    // 记录失败，聚合同 signature 的重复失败
    function void report_failure(dv_failure_t f);
      m_error_count++;
      if (f.signature.message_id == "") begin
        // 无 Message ID 视为非法，仍记录但不进入聚类
      end
      if (!m_first_error_recorded) begin
        m_first_failure = f;
        m_first_error_recorded = 1;
        m_status = DV_STATUS_FAIL;
        m_primary_signature = build_signature(f);
      end
      // 聚合：若已有同 signature 条目则 count++
      foreach (m_failures[i]) begin
        if (m_failures[i].signature.message_id == f.signature.message_id &&
            m_failures[i].signature.component_path == f.signature.component_path) begin
          m_failures[i].count++;
          return;
        end
      end
      m_failures.push_back(f);
    endfunction

    // 显式跳过
    function void set_skip(string reason);
      m_status = DV_STATUS_SKIP;
    endfunction

    // 显式中止
    function void set_abort(string reason);
      m_status = DV_STATUS_ABORT;
    endfunction

    function dv_status_e get_status();
      return m_status;
    endfunction

    function dv_exit_code_e get_exit_code();
      return dv_status_to_exit(m_status);
    endfunction

    function int unsigned failure_count();
      return m_failures.size();
    endfunction

    function string get_primary_signature();
      return m_primary_signature;
    endfunction

    // 稳定 signature 构成：message_id + component_path + transaction_type + normalized_location + root_cause_tag
    protected function string build_signature(dv_failure_t f);
      return $sformatf("%s|%s|%s|%s|%s",
                       f.signature.message_id,
                       f.signature.component_path,
                       f.signature.transaction_type,
                       f.signature.normalized_location,
                       f.signature.root_cause_tag);
    endfunction

    // 汇总为 test_result
    function dv_test_result_t collect_result(dv_test_result_t base);
      base.run.status   = m_status;
      base.run.exit_code= get_exit_code();
      base.failure_count= failure_count();
      base.primary_signature = m_primary_signature;
      foreach (m_failures[i])
        base.failures.push_back(m_failures[i]);
      return base;
    endfunction

    function string status_string();
      return $sformatf("status=%s errors=%0d failures=%0d signature=%s",
                       dv_status_name(m_status), m_error_count,
                       failure_count(), m_primary_signature);
    endfunction

  endclass

endpackage : dv_status_pkg
