//======================================================================
// AIX DV Common - L1 ID 分配器
// File    : src/utils/dv_id_pkg.sv
// Purpose : ID 分配、回收、泄漏检查。
// Author  : dv-platform
// Date    : 2026-08-12
//======================================================================

package dv_id_pkg;

  import dv_common_types_pkg::*;

  class dv_id_allocator;

    protected dv_id_t          m_next;
    protected dv_id_t          m_high_water;
    protected bit [31:0]       m_in_use;
    protected int unsigned     m_alloc_count;
    protected int unsigned     m_free_count;
    protected int unsigned     m_leak_count;
    protected dv_id_t          m_histogram[longint]; // id -> 使用计数

    function new(dv_id_t start_id = 0);
      m_next       = start_id;
      m_high_water = start_id;
      m_in_use     = 32'h0;
      m_alloc_count= 0;
      m_free_count = 0;
      m_leak_count = 0;
    endfunction

    // 分配一个 ID
    function dv_id_t alloc(string tag = "");
      dv_id_t id = m_next;
      m_next++;
      m_high_water = (m_high_water < m_next) ? m_next : m_high_water;
      m_in_use[id % 32] = 1'b1;
      m_alloc_count++;
      m_histogram[longint'(id)]++;
      return id;
    endfunction

    // 回收 ID
    function void free(dv_id_t id);
      if (m_in_use[id % 32] == 1'b0) begin
        m_leak_count++;  // 重复释放视为异常
        return;
      end
      m_in_use[id % 32] = 1'b0;
      m_free_count++;
    endfunction

    // 在 use 中？
    function bit in_use(dv_id_t id);
      return m_in_use[id % 32];
    endfunction

    // 泄漏检查：返回仍在使用（无法回收）的 ID 列表
    function int unsigned leak_check(output dv_id_t leaked[$]);
      leaked.delete();
      for (dv_id_t i = 0; i < m_high_water; i++) begin
        if (m_in_use[i % 32])
          leaked.push_back(i);
      end
      m_leak_count = leaked.size();
      return m_leak_count;
    endfunction

    function int unsigned alloc_count();
      return m_alloc_count;
    endfunction

    function int unsigned free_count();
      return m_free_count;
    endfunction

    function string stats_string();
      return $sformatf("alloc=%0d free=%0d high_water=%0d leak=%0d",
                       m_alloc_count, m_free_count, m_high_water, m_leak_count);
    endfunction

  endclass

endpackage : dv_id_pkg
