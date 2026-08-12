//======================================================================
// AIX DV Common - L2 配置服务
// File    : src/runtime/dv_config_pkg.sv
// Purpose : 配置解析、快照、来源追踪。
//           配置优先级：
//             Schema Default < Organization Profile < Project Config
//                            < Test Config < CLI Override
//           最终值必须记录来源，避免"为什么这个开关是 1"无法追溯。
// Author  : dv-platform
// Date    : 2026-08-12
//======================================================================

package dv_config_pkg;

  import dv_common_types_pkg::*;

  //--------------------------------------------------------------------------
  // 配置来源优先级
  //--------------------------------------------------------------------------
  typedef enum int {
    DV_CFG_SRC_SCHEMA_DEFAULT = 0,
    DV_CFG_SRC_ORG_PROFILE    = 1,
    DV_CFG_SRC_PROJECT        = 2,
    DV_CFG_SRC_TEST           = 3,
    DV_CFG_SRC_CLI_OVERRIDE   = 4
  } dv_cfg_source_e;

  //--------------------------------------------------------------------------
  // 单个配置项：值 + 来源
  //--------------------------------------------------------------------------
  typedef struct {
    string         key;
    string         value;
    dv_cfg_source_e source;
    string         source_detail; // 例如 plusarg 名 / 文件:行
  } dv_cfg_entry_t;

  //--------------------------------------------------------------------------
  // 运行配置（run_cfg）：seed、timeout、verbosity、wave、tool profile
  //--------------------------------------------------------------------------
  typedef struct {
    int unsigned seed;
    time         global_timeout;
    int          verbosity;
    bit          enable_wave;
    string       tool_profile;
    string       sim_top;
  } dv_run_cfg_t;

  class dv_config_service;

    protected dv_cfg_entry_t m_entries[string];
    protected dv_run_cfg_t   m_run_cfg;
    protected bit            m_run_cfg_set;

    function new();
      m_run_cfg_set = 0;
    endfunction

    // 设置配置项（记录来源）
    function void set(string key, string value,
                      dv_cfg_source_e source,
                      string source_detail = "");
      dv_cfg_entry_t e;
      // 覆盖规则：高优先级覆盖低优先级；同优先级后者覆盖前者
      if (m_entries.exists(key) && m_entries[key].source > source)
        return;
      e.key = key;
      e.value = value;
      e.source = source;
      e.source_detail = source_detail;
      m_entries[key] = e;
    endfunction

    function bit get(string key, output string value, output dv_cfg_entry_t entry);
      if (m_entries.exists(key)) begin
        value = m_entries[key].value;
        entry = m_entries[key];
        return 1;
      end
      return 0;
    endfunction

    // 解析常见 plusarg 到 run_cfg
    function void parse_plusargs();
      string s;
      if ($value$plusargs("seed=%d", m_run_cfg.seed))
        set("run.seed", $sformatf("%0d", m_run_cfg.seed), DV_CFG_SRC_CLI_OVERRIDE, "+seed");
      if ($value$plusargs("verbosity=%0d", m_run_cfg.verbosity))
        set("run.verbosity", $sformatf("%0d", m_run_cfg.verbosity), DV_CFG_SRC_CLI_OVERRIDE, "+verbosity");
      if ($test$plusargs("wave"))
        begin
          m_run_cfg.enable_wave = 1;
          set("run.wave", "1", DV_CFG_SRC_CLI_OVERRIDE, "+wave");
        end
      m_run_cfg_set = 1;
    endfunction

    function dv_run_cfg_t get_run_cfg();
      return m_run_cfg;
    endfunction

    // 配置快照（用于 manifest）
    function string snapshot_json();
      string s = "{";
      bit first = 1;
      foreach (m_entries[k]) begin
        if (!first) s = {s, ","};
        first = 0;
        s = {s, $sformatf("\"%s\":{\"value\":\"%s\",\"source\":\"%0d\"}",
                          m_entries[k].key, m_entries[k].value, m_entries[k].source)};
      end
      return {s, "}"};
    endfunction

  endclass

endpackage : dv_config_pkg
