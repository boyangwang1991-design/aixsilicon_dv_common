//======================================================================
// AIX DV Common - compare 单元测试顶层
// File    : unit/utils/dv_compare_unit_tb.sv
// Purpose : dv_compare_pkg 单测。
// Author  : dv-platform
// Date    : 2026-08-12
//======================================================================

module dv_compare_unit_tb;

  import dv_compare_pkg::*;

  int errors = 0;
  string fields[$], exp[$], act[$];
  dv_compare_result_t res;

  initial begin
    // masked 比较：mask 覆盖 [31:16]，低位差异被屏蔽
    if (!dv_compare_masked(64'h0000_0000_ABCD_1234, 64'h0000_0000_ABCD_5678,
                           64'h0000_0000_FFFF_0000, DV_XZ_TREAT_AS_DONTCARE))
      errors++;  // 低位不同但被屏蔽，应匹配
    if (dv_compare_masked(64'h0000_0000_ABCD_1234, 64'h0000_0000_ABBD_1234,
                          64'h0000_0000_FFFF_0000, DV_XZ_TREAT_AS_DONTCARE))
      errors++;  // [31:16] 不同，应不匹配

    // tolerance 比较
    if (!dv_compare_tolerance(100, 105, 5)) errors++;
    if (dv_compare_tolerance(100, 106, 5)) errors++;

    // 浮点容差
    if (!dv_compare_float(1.0, 1.05, 0.0, 0.1)) errors++;
    if (dv_compare_float(1.0, 1.2, 0.0, 0.1)) errors++;

    // wildcard：exp 中的 X 视作 don't care（hex 末位 X = 整个 nibble 为 X）
    if (!dv_compare_wildcard(64'h0000_0000_0000_00X0, 64'h0000_0000_0000_00A0))
      errors++;  // 差异仅在 exp 的 X nibble（bits[7:4]），应匹配
    if (dv_compare_wildcard(64'h0000_0000_0000_00X0, 64'h0000_0000_0000_00A1))
      errors++;  // bit0 不同（exp bit0=0，act bit0=1），应不匹配

    // 结构化 diff
    fields = {fields, "a", "b"};
    exp = {exp, "1", "2"};
    act = {act, "1", "3"};
    res = dv_diff_fields(fields, exp, act);
    if (res.all_matched) errors++;
    if (res.diffs.size() != 1) errors++;

    if (errors == 0)
      $display("PASS: dv_compare_unit_tb");
    else
      $display("FAIL: dv_compare_unit_tb errors=%0d", errors);
    $finish;
  end

endmodule : dv_compare_unit_tb
