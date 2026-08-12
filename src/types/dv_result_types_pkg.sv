//======================================================================
// AIX DV Common - L0 结果类型
// File    : src/types/dv_result_types_pkg.sv
// Purpose : test/run/failure/metric 结构，与 schemas/test_result.schema.yaml 对齐。
// Author  : dv-platform
// Date    : 2026-08-12
// Notes   :
//   Failure Signature 推荐构成：
//     message_id + component_path + transaction_type + normalized_location + root_cause_tag
//   动态数值、时间戳、seed、地址等不稳定字段不直接进入 signature。
//======================================================================

package dv_result_types_pkg;

  import dv_common_types_pkg::*;

  //--------------------------------------------------------------------------
  // failure signature 的稳定字段
  //--------------------------------------------------------------------------
  typedef struct {
    string message_id;          // AIX_DV_<DOMAIN>_<EVENT>
    string component_path;      // 例如 env.agent.monitor
    string transaction_type;    // 例如 apb_txn / axi_txn
    string normalized_location; // 归一化位置（文件名:行号 或 稳定代码位置）
    string root_cause_tag;      // 根因标签
  } dv_failure_signature_t;

  //--------------------------------------------------------------------------
  // 单条 failure
  //--------------------------------------------------------------------------
  typedef struct {
    dv_failure_signature_t signature;
    string                 detail;      // 人类可读详情（不用于聚类）
    string                 raw_location;// 原始位置（附加 context）
    longint                timestamp_ps;
    int unsigned           count;       // 同 signature 聚合次数
  } dv_failure_t;

  //--------------------------------------------------------------------------
  // metric（key -> value）
  //--------------------------------------------------------------------------
  typedef struct {
    string key;
    string value;   // 统一以字符串承载，便于序列化
    string unit;
  } dv_metric_t;

  //--------------------------------------------------------------------------
  // test 段
  //--------------------------------------------------------------------------
  typedef struct {
    string            name;
    string            requirement_ids[$]; // LRS-CSR-001 等
    string            category;
  } dv_test_info_t;

  //--------------------------------------------------------------------------
  // run 段
  //--------------------------------------------------------------------------
  typedef struct {
    string            id;          // run-YYYYMMDD-NNNNN
    int unsigned      seed;
    dv_status_e       status;
    dv_exit_code_e    exit_code;
    string            start_time;  // ISO8601
    real              duration_s;
  } dv_run_info_t;

  //--------------------------------------------------------------------------
  // 完整 test result（对应 test_result.schema.yaml）
  //--------------------------------------------------------------------------
  typedef struct {
    int            schema_version;
    dv_test_info_t test;
    dv_run_info_t  run;
    int unsigned   failure_count;
    string         primary_signature;
    dv_failure_t   failures[$];
    dv_metric_t    metrics[$];
    string         log_artifact;
    string         wave_artifact;
    string         coverage_artifact;
  } dv_test_result_t;

  //--------------------------------------------------------------------------
  // 辅助：向 result 追加 metric
  //--------------------------------------------------------------------------
  function automatic void dv_add_metric(
      inout dv_test_result_t r,
      input  string key,
      input  string value,
      input  string unit = "");
    dv_metric_t m;
    m.key   = key;
    m.value = value;
    m.unit  = unit;
    r.metrics.push_back(m);
  endfunction

endpackage : dv_result_types_pkg
