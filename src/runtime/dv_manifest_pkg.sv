//======================================================================
// AIX DV Common - L2 Run Manifest 服务
// File    : src/runtime/dv_manifest_pkg.sv
// Purpose : 生成 run manifest，记录仿真器/UVM/FuseSoC/seed/配置快照等。
//           与 schemas/run_manifest.schema.yaml 对齐。
// Author  : dv-platform
// Date    : 2026-08-12
//======================================================================

package dv_manifest_pkg;

  import dv_common_types_pkg::*;

  //--------------------------------------------------------------------------
  // manifest 结构（核心字段）
  //--------------------------------------------------------------------------
  typedef struct {
    string schema_version;
    string simulator;
    string simulator_version;
    string uvm_profile;
    string uvm_version;
    string fusesoc_version;
    string edalize_version;
    string top_core_vlnv;
    string top_core_git_revision; // 运行时填充
    int unsigned seed;
    string config_snapshot_json;
    string os_profile;
    string toolchain_profile;
    string start_time;
  } dv_run_manifest_t;

  class dv_manifest_service;

    protected dv_run_manifest_t m_manifest;

    function new();
      m_manifest.schema_version = "1.0";
    endfunction

    function void set_simulator(string name, string version);
      m_manifest.simulator        = name;
      m_manifest.simulator_version= version;
    endfunction

    function void set_uvm(string profile, string version);
      m_manifest.uvm_profile = profile;
      m_manifest.uvm_version = version;
    endfunction

    function void set_seed(int unsigned seed);
      m_manifest.seed = seed;
    endfunction

    function void set_config_snapshot(string json);
      m_manifest.config_snapshot_json = json;
    endfunction

    function void set_top_core(string vlnv, string git_rev);
      m_manifest.top_core_vlnv      = vlnv;
      m_manifest.top_core_git_revision = git_rev;
    endfunction

    // 输出 YAML 风格 manifest 文本
    function string to_yaml();
      return $sformatf("schema_version: %s\nsimulator: %s\nsimulator_version: %s\nuvm_profile: %s\nuvm_version: %s\nfusesoc_version: %s\nedalize_version: %s\ntop_core_vlnv: %s\ntop_core_git_revision: %s\nseed: %0d\nconfig_snapshot: %s\nos_profile: %s\ntoolchain_profile: %s\nstart_time: %s",
                       m_manifest.schema_version, m_manifest.simulator,
                       m_manifest.simulator_version, m_manifest.uvm_profile,
                       m_manifest.uvm_version, m_manifest.fusesoc_version,
                       m_manifest.edalize_version, m_manifest.top_core_vlnv,
                       m_manifest.top_core_git_revision, m_manifest.seed,
                       m_manifest.config_snapshot_json, m_manifest.os_profile,
                       m_manifest.toolchain_profile, m_manifest.start_time);
    endfunction

  endclass

endpackage : dv_manifest_pkg
