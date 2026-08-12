//======================================================================
// AIX DV Common - ID 单元测试顶层
// File    : unit/utils/dv_id_unit_tb.sv
// Purpose : dv_id_allocator 单测。
// Author  : dv-platform
// Date    : 2026-08-12
//======================================================================

module dv_id_unit_tb;

  import dv_common_types_pkg::*;
  import dv_id_pkg::*;

  int errors = 0;
  dv_id_allocator alloc;
  dv_id_t ids[4];
  dv_id_t leaked[$];
  int unsigned n;

  initial begin
    alloc = new(0);

    for (int i = 0; i < 4; i++) begin
      ids[i] = alloc.alloc($sformatf("id%0d", i));
    end

    if (ids[0] != 0 || ids[3] != 3) errors++;
    if (alloc.alloc_count() != 4) errors++;

    // 回收两个
    alloc.free(ids[0]);
    alloc.free(ids[3]);
    if (alloc.free_count() != 2) errors++;

    // 泄漏检查应只剩 2 个
    n = alloc.leak_check(leaked);
    if (n != 2) errors++;

    // 重复释放（异常）不应导致崩溃
    alloc.free(ids[0]);

    if (errors == 0)
      $display("PASS: dv_id_unit_tb");
    else
      $display("FAIL: dv_id_unit_tb errors=%0d", errors);
    $finish;
  end

endmodule : dv_id_unit_tb
