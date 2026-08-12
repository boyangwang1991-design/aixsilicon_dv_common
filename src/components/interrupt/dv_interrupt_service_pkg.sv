//======================================================================
// AIX DV Common - L3 Interrupt 服务
// File    : src/components/interrupt/dv_interrupt_service_pkg.sv
// Purpose : 与协议无关的中断等待/记录抽象。
// Author  : dv-platform
// Date    : 2026-08-12
//======================================================================

package dv_interrupt_service_pkg;

  import dv_common_types_pkg::*;

  //--------------------------------------------------------------------------
  // 中断类型
  //--------------------------------------------------------------------------
  typedef enum int {
    DV_IRQ_LEVEL = 0,
    DV_IRQ_PULSE = 1,
    DV_IRQ_EDGE  = 2
  } dv_irq_type_e;

  //--------------------------------------------------------------------------
  // 中断记录
  //--------------------------------------------------------------------------
  typedef struct {
    int unsigned  irq_id;
    dv_irq_type_e irq_type;
    longint       assert_epoch;   // reset epoch
    time          assert_time;
    bit           cleared;
  } dv_irq_record_t;

  class dv_interrupt_service;

    protected dv_irq_record_t m_records[$];
    protected int unsigned    m_irq_count;
    protected string          m_path;

    function new(string path = "irq");
      m_path = path;
    endfunction

    // 记录一次中断 assert
    function void record_assert(int unsigned irq_id, dv_irq_type_e irq_type,
                                int unsigned epoch);
      dv_irq_record_t r;
      r.irq_id       = irq_id;
      r.irq_type     = irq_type;
      r.assert_epoch = epoch;
      r.assert_time  = $time;
      r.cleared      = 0;
      m_records.push_back(r);
      m_irq_count++;
    endfunction

    // 标记某中断已清除
    function bit record_clear(int unsigned irq_id);
      for (int i = m_records.size()-1; i >= 0; i--) begin
        if (m_records[i].irq_id == irq_id && !m_records[i].cleared) begin
          m_records[i].cleared = 1;
          return 1;
        end
      end
      return 0;
    endfunction

    function int unsigned count();
      return m_irq_count;
    endfunction

    function int unsigned pending_clear();
      int unsigned n = 0;
      foreach (m_records[i])
        if (!m_records[i].cleared) n++;
      return n;
    endfunction

  endclass

endpackage : dv_interrupt_service_pkg
