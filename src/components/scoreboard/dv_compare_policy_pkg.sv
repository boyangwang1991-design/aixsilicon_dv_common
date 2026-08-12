//======================================================================
// AIX DV Common - L3 Compare Policy
// File    : src/components/scoreboard/dv_compare_policy_pkg.sv
// Purpose : 可插拔比较策略：exact、field mask、tolerance、don't-care、
//           X/Z 策略、浮点容差。比较失败输出结构化 diff。
// Author  : dv-platform
// Date    : 2026-08-12
//======================================================================

package dv_compare_policy_pkg;

  import dv_common_types_pkg::*;
  import dv_compare_pkg::*;

  //--------------------------------------------------------------------------
  // 比较模式
  //--------------------------------------------------------------------------
  typedef enum int {
    DV_CMP_EXACT     = 0,
    DV_CMP_MASKED    = 1,
    DV_CMP_TOLERANCE = 2,
    DV_CMP_FLOAT     = 3,
    DV_CMP_DONTCARE  = 4
  } dv_cmp_mode_e;

  //--------------------------------------------------------------------------
  // 比较策略对象（composition over inheritance）
  //--------------------------------------------------------------------------
  class dv_compare_policy;

    protected dv_cmp_mode_e    m_mode;
    protected logic [63:0]     m_mask;
    protected longint          m_tolerance;
    protected real             m_abs_tol;
    protected real             m_rel_tol;
    protected dv_xz_policy_e   m_xz_policy;

    function new(dv_cmp_mode_e mode = DV_CMP_EXACT);
      m_mode     = mode;
      m_mask     = '1;
      m_tolerance= 0;
      m_abs_tol  = 0.0;
      m_rel_tol  = 0.0;
      m_xz_policy= DV_XZ_TREAT_AS_DONTCARE;
    endfunction

    function void set_mask(logic [63:0] mask); m_mask = mask; endfunction
    function void set_tolerance(longint tol); m_tolerance = tol; endfunction
    function void set_float_tolerance(real at, real rt);
      m_abs_tol = at;
      m_rel_tol = rt;
    endfunction
    function void set_xz_policy(dv_xz_policy_e p); m_xz_policy = p; endfunction

    // 执行比较（64 位数据向量）
    function bit compare(logic [63:0] exp, logic [63:0] act,
                         output dv_compare_result_t diff);
      bit ok;
      case (m_mode)
        DV_CMP_EXACT:
          ok = (exp === act);
        DV_CMP_MASKED:
          ok = dv_compare_masked(exp, act, m_mask, m_xz_policy);
        DV_CMP_TOLERANCE:
          ok = dv_compare_tolerance(longint'(exp), longint'(act), m_tolerance);
        DV_CMP_FLOAT:
          ok = dv_compare_float(real'(exp), real'(act), m_abs_tol, m_rel_tol);
        DV_CMP_DONTCARE:
          ok = 1;
        default:
          ok = 0;
      endcase
      diff.all_matched = ok;
      if (!ok) begin
        dv_field_diff_t d;
        d.field    = "data";
        d.matched  = 0;
        d.expected = $sformatf("%h", exp);
        d.actual   = $sformatf("%h", act);
        diff.diffs.push_back(d);
      end
      return ok;
    endfunction

    function string mode_name();
      case (m_mode)
        DV_CMP_EXACT:     return "exact";
        DV_CMP_MASKED:    return "masked";
        DV_CMP_TOLERANCE: return "tolerance";
        DV_CMP_FLOAT:     return "float";
        DV_CMP_DONTCARE:  return "dontcare";
        default:          return "unknown";
      endcase
    endfunction

  endclass

endpackage : dv_compare_policy_pkg
