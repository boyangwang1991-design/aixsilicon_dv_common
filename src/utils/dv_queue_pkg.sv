//======================================================================
// AIX DV Common - L1 队列工具
// File    : src/utils/dv_queue_pkg.sv
// Purpose : typed queue 封装、bounded queue、flush/peek 辅助。
//           不绑定 UVM，泛型以 string 键承载类型标签。
// Author  : dv-platform
// Date    : 2026-08-12
//======================================================================

package dv_queue_pkg;

  import dv_common_types_pkg::*;

  //--------------------------------------------------------------------------
  // 队列条目：内容以 string 承载（序列化），配合 id/tag 用于乱序匹配。
  // 正式实现时建议改为类句柄队列（dv_queue_item）。
  //--------------------------------------------------------------------------
  typedef struct {
    dv_id_t  id;
    string   tag;
    string   payload;
    longint  epoch;      // reset epoch 关联
    time     enqueue_time;
  } dv_queue_item_t;

  //--------------------------------------------------------------------------
  // 队列行为枚举
  //--------------------------------------------------------------------------
  typedef enum int {
    DV_QUEUE_FIFO   = 0,   // 先进先出（in-order）
    DV_QUEUE_LIFO   = 1,   // 后进先出
    DV_QUEUE_PRIO   = 2    // 按 tag/priority 出队
  } dv_queue_mode_e;

  //--------------------------------------------------------------------------
  // 边界策略
  //--------------------------------------------------------------------------
  typedef enum int {
    DV_BOUND_REJECT   = 0, // 满则拒绝入队
    DV_BOUND_OVERWRITE= 1  // 满则覆盖最旧
  } dv_bound_policy_e;

  //--------------------------------------------------------------------------
  // 有界队列
  //--------------------------------------------------------------------------
  class dv_bounded_queue;

    protected dv_queue_item_t m_q[$];
    protected int unsigned    m_max;
    protected dv_bound_policy_e m_policy;
    protected int unsigned    m_reject_count;
    protected int unsigned    m_overwrite_count;

    function new(int unsigned max_size = 64,
                 dv_bound_policy_e policy = DV_BOUND_REJECT);
      m_max    = max_size;
      m_policy = policy;
    endfunction

    // 入队，返回是否成功
    function bit enqueue(dv_queue_item_t item);
      if (m_q.size() >= m_max) begin
        if (m_policy == DV_BOUND_OVERWRITE) begin
          void'(m_q.pop_front());
          m_overwrite_count++;
        end else begin
          m_reject_count++;
          return 0;
        end
      end
      m_q.push_back(item);
      return 1;
    endfunction

    // 出队（FIFO 语义）
    function bit dequeue(output dv_queue_item_t item);
      if (m_q.size() == 0)
        return 0;
      item = m_q.pop_front();
      return 1;
    endfunction

    // 窥视队首
    function bit peek(output dv_queue_item_t item);
      if (m_q.size() == 0)
        return 0;
      item = m_q[0];
      return 1;
    endfunction

    // 按 id 找到并出队（用于乱序匹配）
    function bit dequeue_by_id(dv_id_t id, output dv_queue_item_t item);
      for (int i = 0; i < m_q.size(); i++) begin
        if (m_q[i].id == id) begin
          item = m_q[i];
          m_q.delete(i);
          return 1;
        end
      end
      return 0;
    endfunction

    // flush：清空并返回清空数量
    function int unsigned flush();
      int unsigned n = m_q.size();
      m_q.delete();
      return n;
    endfunction

    function int unsigned size();
      return m_q.size();
    endfunction

    function bit is_empty();
      return (m_q.size() == 0);
    endfunction

    // 移除属于指定 epoch 的条目，返回数量
    function int unsigned flush_epoch(longint epoch);
      int unsigned n = 0;
      for (int i = m_q.size()-1; i >= 0; i--) begin
        if (m_q[i].epoch == epoch) begin
          m_q.delete(i);
          n++;
        end
      end
      return n;
    endfunction

    function string stats_string();
      return $sformatf("size=%0d max=%0d reject=%0d overwrite=%0d",
                       m_q.size(), m_max, m_reject_count, m_overwrite_count);
    endfunction

  endclass

endpackage : dv_queue_pkg
