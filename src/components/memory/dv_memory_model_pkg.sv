//======================================================================
// AIX DV Common - L3 Memory 模型
// File    : src/components/memory/dv_memory_model_pkg.sv
// Purpose : 稀疏/密集镜像、byte enable、unknown policy。
// Author  : dv-platform
// Date    : 2026-08-12
//======================================================================

package dv_memory_model_pkg;

  import dv_common_types_pkg::*;

  //--------------------------------------------------------------------------
  // 存储模式
  //--------------------------------------------------------------------------
  typedef enum int {
    DV_MEM_SPARSE = 0,   // 稀疏：仅保存被写过的字
    DV_MEM_DENSE  = 1    // 密集：全量镜像
  } dv_mem_mode_e;

  //--------------------------------------------------------------------------
  // Unknown 策略
  //--------------------------------------------------------------------------
  typedef enum int {
    DV_MEM_UNKNOWN_X     = 0, // 未初始化读返回 X
    DV_MEM_UNKNOWN_ZERO  = 1, // 未初始化读返回 0
    DV_MEM_UNKNOWN_ERROR = 2  // 未初始化读触发错误
  } dv_mem_unknown_policy_e;

  //--------------------------------------------------------------------------
  // 内存镜像
  //--------------------------------------------------------------------------
  class dv_memory_model;

    protected dv_mem_mode_e           m_mode;
    protected dv_mem_unknown_policy_e m_policy;
    protected longint                 m_words;
    protected int unsigned            m_data_w;
    protected bit [63:0]              m_mem[longint]; // sparse storage
    protected bit                     m_written[longint];
    protected longint                 m_read_count;
    protected longint                 m_write_count;

    function new(dv_mem_mode_e mode = DV_MEM_SPARSE,
                 dv_mem_unknown_policy_e policy = DV_MEM_UNKNOWN_ZERO,
                 longint words = 1024,
                 int unsigned data_w = 32);
      m_mode   = mode;
      m_policy = policy;
      m_words  = words;
      m_data_w = data_w;
    endfunction

    // 写：带 byte enable
    function void write(longint addr, logic [63:0] data, logic [7:0] be = '1);
      bit [63:0] mask = 64'h0;
      for (int i = 0; i < 8; i++)
        if (be[i]) mask[i*8 +: 8] = '1;
      if (m_written.exists(addr))
        m_mem[addr] = (m_mem[addr] & ~mask) | (data & mask);
      else
        m_mem[addr] = data & mask;
      m_written[addr] = 1;
      m_write_count++;
    endfunction

    // 读：按 unknown policy 返回
    function bit read(longint addr, output logic [63:0] data);
      m_read_count++;
      if (m_written.exists(addr)) begin
        data = m_mem[addr];
        return 1;
      end
      case (m_policy)
        DV_MEM_UNKNOWN_X:     data = 'x;
        DV_MEM_UNKNOWN_ZERO:  data = '0;
        DV_MEM_UNKNOWN_ERROR: return 0;
        default:              data = '0;
      endcase
      return 1;
    endfunction

    // 初始化整块
    function void init_all(bit [63:0] value);
      for (longint a = 0; a < m_words; a++) begin
        m_mem[a] = value;
        m_written[a] = 1;
      end
    endfunction

    function longint read_count();  return m_read_count;  endfunction
    function longint write_count(); return m_write_count; endfunction

  endclass

endpackage : dv_memory_model_pkg
