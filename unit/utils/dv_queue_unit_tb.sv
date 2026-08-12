//======================================================================
// AIX DV Common - queue 单元测试顶层
// File    : unit/utils/dv_queue_unit_tb.sv
// Purpose : dv_bounded_queue 单测。
// Author  : dv-platform
// Date    : 2026-08-12
//======================================================================

module dv_queue_unit_tb;

  import dv_queue_pkg::*;

  int errors = 0;
  int unsigned n;
  dv_bounded_queue q;

  initial begin
    dv_queue_item_t it, out;
    q = new(4, DV_BOUND_REJECT);

    // 空队列出队失败
    if (q.dequeue(out)) errors++;

    // 入队 4 个
    for (int i = 0; i < 4; i++) begin
      it.id = i;
      it.payload = $sformatf("item%0d", i);
      if (!q.enqueue(it)) errors++;
    end

    // 第 5 个被拒绝
    it.id = 99;
    it.payload = "overflow";
    if (q.enqueue(it)) errors++;

    if (q.size() != 4) errors++;

    // FIFO 出队
    if (!q.dequeue(out) || out.id != 0) errors++;
    if (!q.dequeue(out) || out.id != 1) errors++;

    // 按 id 出队（乱序）
    if (!q.dequeue_by_id(3, out) || out.id != 3) errors++;

    if (q.size() != 1) errors++;

    // flush
    n = q.flush();
    if (n != 1) errors++;
    if (!q.is_empty()) errors++;

    if (errors == 0)
      $display("PASS: dv_queue_unit_tb");
    else
      $display("FAIL: dv_queue_unit_tb errors=%0d", errors);
    $finish;
  end

endmodule : dv_queue_unit_tb
