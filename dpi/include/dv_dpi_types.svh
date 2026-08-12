//======================================================================
// AIX DV Common - DPI 类型头文件
// File    : dpi/include/dv_dpi_types.svh
// Purpose : DPI 相关类型声明。DPI 仅用于文件、压缩、性能敏感模型、
//           外部模型桥接等必要场景。每个 DPI 组件必须有纯 SV fallback
//           或明确声明不支持；公共核心组件不依赖 DPI。
// Author  : dv-platform
// Date    : 2026-08-12
//======================================================================

`ifndef DV_DPI_TYPES_SVH
`define DV_DPI_TYPES_SVH

  // DPI 组件平台/编译器矩阵占位（由具体 DPI 组件声明）
  typedef struct {
    string name;
    string platform;
    string compiler;
    string simulator;
  } dv_dpi_component_info_t;

  // DPI 错误码（0=OK）
  typedef int dv_dpi_rc_t;

`endif // DV_DPI_TYPES_SVH
