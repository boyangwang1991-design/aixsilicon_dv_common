//======================================================================
// AIX DV Common - L4 Env Contract
// File    : src/uvm/dv_env_contract_pkg.sv
// Purpose : env 需要暴露的最小状态/端口约定。
//           公共库只定义最小 contract，项目组合自己的 Base Env。
// Author  : dv-platform
// Date    : 2026-08-12
//======================================================================

package dv_env_contract_pkg;

  import uvm_pkg::*;
  import dv_common_types_pkg::*;
  import dv_result_types_pkg::*;
  import dv_status_pkg::*;

  //--------------------------------------------------------------------------
  // Env 契约：任何环境若要接入公共框架，应实现以下接口能力。
  // 通过 config object 显式下发，避免 config_db 通配搜索。
  //--------------------------------------------------------------------------
  virtual class dv_env_contract extends uvm_component;

    // 指向 status service 的句柄（由 test 装配后下发）
    dv_status_service status_svc;

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction

    // 收集最终结果（返回子环境的 test_result 段）
    virtual function void dv_collect_result(ref dv_test_result_t result);
      // 子类可按需补充 env 级 metric
    endfunction

    // drain：等待 outstanding 清空
    virtual function bit dv_drain(time timeout);
      return 1;
    endfunction

  endclass

endpackage : dv_env_contract_pkg
