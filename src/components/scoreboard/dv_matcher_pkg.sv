//======================================================================
// AIX DV Common - L3 Matcher
// File    : src/components/scoreboard/dv_matcher_pkg.sv
// Purpose : in-order / out-of-order matcher。
//           in-order：FIFO 顺序匹配；out-of-order：按 key/tag/ID 匹配。
// Author  : dv-platform
// Date    : 2026-08-12
//======================================================================

package dv_matcher_pkg;

  import dv_common_types_pkg::*;
  import dv_queue_pkg::*;

  //--------------------------------------------------------------------------
  // Matcher 模式
  //--------------------------------------------------------------------------
  typedef enum int {
    DV_MATCH_IN_ORDER  = 0,
    DV_MATCH_OUT_OF_ORDER = 1
  } dv_match_mode_e;

  //--------------------------------------------------------------------------
  // 匹配结果
  //--------------------------------------------------------------------------
  typedef struct {
    bit    found;
    string key;
    int unsigned queue_size;
  } dv_match_result_t;

  //--------------------------------------------------------------------------
  // In-order matcher：先进先出，按 arrival 顺序匹配
  //--------------------------------------------------------------------------
  class dv_in_order_matcher;

    protected dv_queue_item_t m_exp_q[$];
    protected int unsigned    m_matched;
    protected int unsigned    m_mismatched;

    function void push_expected(dv_queue_item_t item);
      m_exp_q.push_back(item);
    endfunction

    // 以队首 expected 与 actual 比较
    function bit match_next(dv_queue_item_t act, output dv_queue_item_t exp);
      if (m_exp_q.size() == 0) begin
        m_mismatched++;
        return 0;
      end
      exp = m_exp_q.pop_front();
      if (exp.payload === act.payload) begin
        m_matched++;
        return 1;
      end else begin
        m_mismatched++;
        return 0;
      end
    endfunction

    function int unsigned pending();
      return m_exp_q.size();
    endfunction

    function int unsigned flush();
      int unsigned n = m_exp_q.size();
      m_exp_q.delete();
      return n;
    endfunction

  endclass

  //--------------------------------------------------------------------------
  // Out-of-order matcher：按 key/id 匹配（内部使用哈希映射）
  //--------------------------------------------------------------------------
  class dv_out_of_order_matcher;

    protected dv_queue_item_t m_pool[string];  // key -> item
    protected int unsigned    m_matched;
    protected int unsigned    m_mismatched;

    function void push_expected(dv_queue_item_t item);
      m_pool[item.tag] = item;
    endfunction

    // 按 key 取出 expected 并匹配
    function bit match_by_key(string key, dv_queue_item_t act, output dv_queue_item_t exp);
      if (!m_pool.exists(key)) begin
        m_mismatched++;
        return 0;
      end
      exp = m_pool[key];
      m_pool.delete(key);
      if (exp.payload === act.payload) begin
        m_matched++;
        return 1;
      end else begin
        m_mismatched++;
        return 0;
      end
    endfunction

    function int unsigned pending();
      return m_pool.num();
    endfunction

    function int unsigned flush();
      int unsigned n = m_pool.num();
      m_pool.delete();
      return n;
    endfunction

  endclass

endpackage : dv_matcher_pkg
