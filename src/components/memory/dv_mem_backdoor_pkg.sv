//======================================================================
// AIX DV Common - L3 Memory Backdoor
// File    : src/components/memory/dv_mem_backdoor_pkg.sv
// Purpose : backdoor/frontdoor 抽象与 ECC 数据辅助。
//           具体 adapter（HDL/DPI/abstract）由项目或 VIP 提供。
// Author  : dv-platform
// Date    : 2026-08-12
//======================================================================

package dv_mem_backdoor_pkg;

  import dv_common_types_pkg::*;

  //--------------------------------------------------------------------------
  // Backdoor adapter 契约
  //--------------------------------------------------------------------------
  virtual class dv_backdoor_if;

    // 向 DUT 内部存储写入（跳过协议 frontdoor）
    pure virtual function bit bd_write(longint addr, logic [63:0] data,
                                       logic [7:0] be = '1);

    // 从 DUT 内部存储读取
    pure virtual function bit bd_read(longint addr, output logic [63:0] data);

    // 返回支持的位宽
    pure virtual function int unsigned data_width();
  endclass

  //--------------------------------------------------------------------------
  // ECC 数据辅助（仅位置/奇偶示例，不绑定某协议）
  //--------------------------------------------------------------------------
  class dv_ecc_helper;

    // 简单奇偶位生成（示例）
    function logic[0:0] parity_even(logic [63:0] data);
      return ^data;
    endfunction

    // ECC 数据插入/提取占位（正式实现见 CRC/ECC 工具层）
    function logic [71:0] inject_ecc(logic [63:0] data, logic [7:0] ecc);
      return {ecc, data};
    endfunction

    function void extract_ecc(logic [71:0] word, output logic [63:0] data,
                              output logic [7:0] ecc);
      data = word[63:0];
      ecc  = word[71:64];
    endfunction

  endclass

endpackage : dv_mem_backdoor_pkg
