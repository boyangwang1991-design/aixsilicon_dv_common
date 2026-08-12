//======================================================================
// AIX DV Common - L1 数据工具
// File    : src/utils/dv_data_pkg.sv
// Purpose : endian、pack/unpack、byte enable、alignment 辅助。
// Author  : dv-platform
// Date    : 2026-08-12
//======================================================================

package dv_data_pkg;

  import dv_common_types_pkg::*;

  typedef enum int {
    DV_ENDIAN_LITTLE = 0,
    DV_ENDIAN_BIG    = 1
  } dv_endian_e;

  //--------------------------------------------------------------------------
  // 字节序交换（32 位）
  //--------------------------------------------------------------------------
  function automatic logic [31:0] dv_bswap32(logic [31:0] v);
    return {v[7:0], v[15:8], v[23:16], v[31:24]};
  endfunction

  //--------------------------------------------------------------------------
  // 字节序交换（64 位）
  //--------------------------------------------------------------------------
  function automatic logic [63:0] dv_bswap64(logic [63:0] v);
    return {v[7:0], v[15:8], v[23:16], v[31:24],
            v[39:32], v[47:40], v[55:48], v[63:56]};
  endfunction

  //--------------------------------------------------------------------------
  // 按字节使能屏蔽（用于写比较）
  //--------------------------------------------------------------------------
  function automatic logic [63:0] dv_apply_byte_enable(
      input logic [63:0] data,
      input logic [7:0]  be);
    logic [63:0] out = 64'h0;
    for (int i = 0; i < 8; i++)
      if (be[i])
        out[i*8 +: 8] = data[i*8 +: 8];
    return out;
  endfunction

  //--------------------------------------------------------------------------
  // 对齐检查
  //--------------------------------------------------------------------------
  function automatic bit dv_is_aligned(input longint addr, input int unsigned align);
    if (align == 0) return 1;
    return ((addr % align) == 0);
  endfunction

  //--------------------------------------------------------------------------
  // 向上取整对齐
  //--------------------------------------------------------------------------
  function automatic longint dv_align_up(input longint addr, input int unsigned align);
    if (align == 0) return addr;
    return ((addr + align - 1) / align) * align;
  endfunction

  //--------------------------------------------------------------------------
  // pack：把 byte queue 打包为 64 位向量（little-endian 方式）
  //--------------------------------------------------------------------------
  function automatic logic [63:0] dv_pack_bytes(
      input byte bytes[$],
      input dv_endian_e endian = DV_ENDIAN_LITTLE);
    logic [63:0] out = 64'h0;
    for (int i = 0; i < bytes.size() && i < 8; i++) begin
      if (endian == DV_ENDIAN_LITTLE)
        out[i*8 +: 8] = bytes[i];
      else
        out[(7-i)*8 +: 8] = bytes[i];
    end
    return out;
  endfunction

endpackage : dv_data_pkg
