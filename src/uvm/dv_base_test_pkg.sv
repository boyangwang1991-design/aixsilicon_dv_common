//======================================================================
// AIX DV Common - L4 Base Test
// File    : src/uvm/dv_base_test_pkg.sv
// Purpose : dv_base_test 只负责：
//           - 创建/获取强类型 run config；
//           - 安装 status、failure、timeout 和 manifest 服务；
//           - 统一 test start/end；
//           - 收集最终结果。
//           不实例化任何具体 VIP；不假设某个 DUT 寄存器模型存在；
//           不写项目专用 virtual sequence 选择逻辑。
// Author  : dv-platform
// Date    : 2026-08-12
//======================================================================

package dv_base_test_pkg;

  import uvm_pkg::*;
  import dv_common_types_pkg::*;
  import dv_result_types_pkg::*;
  import dv_status_pkg::*;
  import dv_timeout_pkg::*;
  import dv_config_pkg::*;
  import dv_manifest_pkg::*;
  import dv_log_pkg::*;

  class dv_base_test extends uvm_test;

    `uvm_component_utils(dv_base_test)

    // 公共服务
    dv_config_service      cfg_svc;
    dv_status_service      status_svc;
    dv_timeout_service     timeout_svc;
    dv_manifest_service    manifest_svc;
    dv_log_context         log_ctx;

    // 运行配置
    dv_run_cfg_t           run_cfg;

    function new(string name = "dv_base_test", uvm_component parent = null);
      super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      // 装配服务
      cfg_svc     = new();
      cfg_svc.parse_plusargs();
      run_cfg     = cfg_svc.get_run_cfg();

      status_svc  = new();
      timeout_svc = new();
      manifest_svc= new();
      log_ctx     = new({get_full_name(), ".log"}, "TEST");

      // 全局 timeout
      if (run_cfg.global_timeout > 0)
        timeout_svc.add_timeout(DV_TIMEOUT_GLOBAL, "global", run_cfg.global_timeout, get_full_name());

      // 下发强类型配置到 config_db（顶层少量强类型 handle）
      uvm_config_db#(dv_run_cfg_t)::set(this, "*", "run_cfg", run_cfg);
    endfunction

    // 统一 test start（end_of_elaboration 时记录 manifest）
    virtual function void end_of_elaboration_phase(uvm_phase phase);
      super.end_of_elaboration_phase(phase);
      manifest_svc.set_seed(run_cfg.seed);
      manifest_svc.set_config_snapshot(cfg_svc.snapshot_json());
      `uvm_info("DV_BASE_TEST", "base test elaborated", UVM_LOW)
    endfunction

    // 统一 test end：收集最终结果并输出
    virtual function void report_phase(uvm_phase phase);
      dv_test_result_t result;
      super.report_phase(phase);
      result.schema_version = DV_SCHEMA_VERSION;
      result.test.name = get_name();
      result.run.id = $sformatf("run-%0d", $urandom()); // 正式实现按日期/序号
      result.run.seed = run_cfg.seed;
      result = status_svc.collect_result(result);

      `uvm_info("DV_BASE_TEST",
        $sformatf("test result: %s", status_svc.status_string()), UVM_LOW)
      `uvm_info("DV_BASE_TEST",
        $sformatf("manifest:\n%s", manifest_svc.to_yaml()), UVM_LOW)
    endfunction

  endclass

endpackage : dv_base_test_pkg
