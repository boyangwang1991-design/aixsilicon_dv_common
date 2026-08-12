//======================================================================
// AIX DV Common - L1 比较工具
// File    : src/utils/dv_compare_pkg.sv
// Purpose : mask、wildcard、tolerance、field policy 比较辅助。
//           比较失败应输出结构化 diff。
// Author  : dv-platform
// Date    : 2026-08-12
//======================================================================

package dv_compare_pkg;

  import dv_common_types_pkg::*;

  //--------------------------------------------------------------------------
  // X/Z 策略
  //--------------------------------------------------------------------------
  typedef enum int {
    DV_XZ_TREAT_AS_DONTCARE = 0,  // 比较时忽略 X/Z
    DV_XZ_MATCH_X           = 1,  // X 与 X 匹配
    DV_XZ_MISMATCH_IF_X     = 2   // 出现 X 即视为不匹配
  } dv_xz_policy_e;

  //--------------------------------------------------------------------------
  // 单条字段比较结果
  //--------------------------------------------------------------------------
  typedef struct {
    string field;
    bit    matched;
    string expected;
    string actual;
  } dv_field_diff_t;

  //--------------------------------------------------------------------------
  // 结构化比较结果
  //--------------------------------------------------------------------------
  typedef struct {
    bit             all_matched;
    dv_field_diff_t diffs[$];
  } dv_compare_result_t;

  //--------------------------------------------------------------------------
  // 按 mask 比较（mask 为 1 的位参与比较）
  //--------------------------------------------------------------------------
  function automatic bit dv_compare_masked(
      input  logic [63:0] exp,
      input  logic [63:0] act,
      input  logic [63:0] mask,
      input  dv_xz_policy_e xz_policy = DV_XZ_TREAT_AS_DONTCARE);
    logic [63:0] e = exp & mask;
    logic [63:0] a = act & mask;
    if (xz_policy == DV_XZ_TREAT_AS_DONTCARE) begin
      // 4 态逐位比较，exp 中 X/Z 位视为匹配
      for (int i = 0; i < 64; i++) begin
        if (e[i] === 1'bx || e[i] === 1'bz) continue;
        if (a[i] !== e[i]) return 0;
      end
      return 1;
    end
    return (e === a);
  endfunction

  //--------------------------------------------------------------------------
  // 整数容差比较
  //--------------------------------------------------------------------------
  function automatic bit dv_compare_tolerance(
      input  longint exp,
      input  longint act,
      input  longint tolerance);
    longint diff = (exp > act) ? (exp - act) : (act - exp);
    return (diff <= tolerance);
  endfunction

  //--------------------------------------------------------------------------
  // 浮点容差（absolute / relative / ULP）
  //--------------------------------------------------------------------------
  function automatic bit dv_compare_float(
      input  real exp,
      input  real act,
      input  real abs_tol,
      input  real rel_tol);
    real diff = (exp > act) ? (exp - act) : (act - exp);
    real scale = (exp != 0.0) ? ((exp > 0) ? exp : -exp) : 1.0;
    return (diff <= abs_tol) || (diff <= rel_tol * scale);
  endfunction

  //--------------------------------------------------------------------------
  // wildcard 比较：exp 中的 X/Z 位视作 don't care
  //--------------------------------------------------------------------------
  function automatic bit dv_compare_wildcard(
      input  logic [63:0] exp,
      input  logic [63:0] act);
    for (int i = 0; i < 64; i++) begin
      if (exp[i] === 1'bx || exp[i] === 1'bz) continue;
      if (act[i] !== exp[i]) return 0;
    end
    return 1;
  endfunction

  //--------------------------------------------------------------------------
  // 结构化 diff：将两个字符串化对象的字段差异输出
  //--------------------------------------------------------------------------
  function automatic dv_compare_result_t dv_diff_fields(
      input string fields[$],
      input string expected[$],
      input string actual[$]);
    dv_compare_result_t res;
    res.all_matched = 1;
    if (fields.size() != expected.size() || fields.size() != actual.size()) begin
      res.all_matched = 0;
      return res;
    end
    for (int i = 0; i < fields.size(); i++) begin
      dv_field_diff_t d;
      d.field    = fields[i];
      d.expected = expected[i];
      d.actual   = actual[i];
      d.matched  = (expected[i] === actual[i]);
      if (!d.matched) begin
        res.all_matched = 0;
        res.diffs.push_back(d);  // 仅记录不匹配字段
      end
    end
    return res;
  endfunction

endpackage : dv_compare_pkg
