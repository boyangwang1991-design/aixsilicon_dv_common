//======================================================================
// AIX DV Common - RAL Adapter/Predictor 契约
// File    : src/ral/dv_ral_adapter_contract_pkg.sv
// Purpose : adapter 和 predictor 连接辅助。
//           具体总线 RAL adapter（APB/AXI）由 VIP 提供，本包只定义契约。
// Author  : dv-platform
// Date    : 2026-08-12
//======================================================================

package dv_ral_adapter_contract_pkg;

  import uvm_pkg::*;
  import dv_common_types_pkg::*;

  //--------------------------------------------------------------------------
  // adapter 连接配置
  //--------------------------------------------------------------------------
  typedef struct {
    string  map_name;
    string  adapter_name;
    string  predictor_name;
    bit     use_predictor;
    bit     use_backdoor;
    string  backdoor_path;   // 可选的 backdoor 层级路径
  } dv_ral_connect_cfg_t;

  //--------------------------------------------------------------------------
  // RAL 连接辅助（静态工具）
  //--------------------------------------------------------------------------
  class dv_ral_connect_utils;

    // 校验连接配置的合理性
    static function bit validate_connect_cfg(dv_ral_connect_cfg_t cfg, ref string err);
      if (cfg.map_name == "") begin
        err = "map_name must not be empty";
        return 0;
      end
      if (cfg.use_predictor && cfg.predictor_name == "") begin
        err = "predictor_name required when use_predictor=1";
        return 0;
      end
      return 1;
    endfunction

    // 正式实现：set/connect adapter 与 predictor 到 map
    // static function void connect(uvm_reg_map map, uvm_reg_adapter adapter,
    //                              uvm_reg_predictor#(...) predictor, ...);

  endclass

endpackage : dv_ral_adapter_contract_pkg
