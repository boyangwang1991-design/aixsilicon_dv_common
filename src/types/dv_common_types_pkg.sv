//======================================================================
// AIX DV Common - L0 基础类型
// File    : src/types/dv_common_types_pkg.sv
// Purpose : status、severity、result、ID、time 等公共类型。
//           本包不依赖 UVM，可在非 UVM 测试台中使用。
// Author  : dv-platform
// Date    : 2026-08-12
// Notes   :
//   - Message ID 格式：AIX_DV_<DOMAIN>_<EVENT>
//   - Exit Code 与 plan.md 第 11.4 节保持一致。
//======================================================================

package dv_common_types_pkg;

  //--------------------------------------------------------------------------
  // 版本
  //--------------------------------------------------------------------------
  localparam string DV_COMMON_TYPES_VERSION = "1.0.0";
  localparam int    DV_SCHEMA_VERSION       = 1;

  //--------------------------------------------------------------------------
  // 严重度（沿用 UVM 概念但独立定义，避免 L0 依赖 UVM）
  //--------------------------------------------------------------------------
  typedef enum int {
    DV_NONE   = 0,
    DV_INFO   = 1,
    DV_WARNING= 2,
    DV_ERROR  = 3,
    DV_FATAL  = 4
  } dv_severity_e;

  //--------------------------------------------------------------------------
  // 测试最终状态
  //--------------------------------------------------------------------------
  typedef enum int {
    DV_STATUS_PASS = 0,
    DV_STATUS_FAIL = 1,
    DV_STATUS_SKIP = 2,
    DV_STATUS_ABORT= 3
  } dv_status_e;

  //--------------------------------------------------------------------------
  // 运行结果判定（status + exit_code 的组合视图）
  //--------------------------------------------------------------------------
  typedef enum int {
    DV_RESULT_PASS = 0,
    DV_RESULT_FAIL = 1
  } dv_result_e;

  //--------------------------------------------------------------------------
  // 退出码（与 plan.md 11.4 对齐）
  //   0 PASS
  //   1 DUT/Checker 功能失败
  //   2 Testbench 基础设施失败
  //   3 Compile/Elaboration 失败
  //   4 Timeout/Deadlock
  //   5 配置或 Schema 错误
  //   6 Tool/License/Environment 错误
  //   7 ABORT/用户终止
  //   8 SKIP/不适用（是否视为流水线成功由 Flow 决定）
  //--------------------------------------------------------------------------
  typedef enum int {
    DV_EXIT_PASS                 = 0,
    DV_EXIT_DUT_FAIL             = 1,
    DV_EXIT_TB_FAIL              = 2,
    DV_EXIT_COMPILE_FAIL         = 3,
    DV_EXIT_TIMEOUT_DEADLOCK     = 4,
    DV_EXIT_CONFIG_SCHEMA_ERR    = 5,
    DV_EXIT_TOOL_ENV_ERR         = 6,
    DV_EXIT_ABORT                = 7,
    DV_EXIT_SKIP                 = 8
  } dv_exit_code_e;

  //--------------------------------------------------------------------------
  // 复位相关
  //--------------------------------------------------------------------------
  typedef enum int {
    DV_RESET_NONE   = 0,
    DV_RESET_POR    = 1, // Power-On Reset
    DV_RESET_WARM   = 2, // Warm Reset
    DV_RESET_SW     = 3, // Software Reset
    DV_RESET_OTHER  = 4
  } dv_reset_type_e;

  //--------------------------------------------------------------------------
  // 事务方向 / 端点 ID
  //--------------------------------------------------------------------------
  typedef enum int {
    DV_EP_REQ = 0,
    DV_EP_RSP = 1,
    DV_EP_OBS = 2
  } dv_endpoint_kind_e;

  //--------------------------------------------------------------------------
  // 时间与统计
  //--------------------------------------------------------------------------
  typedef realtime dv_time_t;
  typedef longint   dv_cycle_t;
  typedef longint   dv_count_t;

  //--------------------------------------------------------------------------
  // ID 类型
  //--------------------------------------------------------------------------
  typedef int unsigned dv_id_t;

  // 稳定的组件路径（例如 "env.agent.monitor"）
  typedef string dv_path_t;

  //--------------------------------------------------------------------------
  // 从状态到退出码的映射辅助
  //--------------------------------------------------------------------------
  function automatic dv_exit_code_e dv_status_to_exit(dv_status_e s);
    case (s)
      DV_STATUS_PASS : dv_status_to_exit = DV_EXIT_PASS;
      DV_STATUS_FAIL : dv_status_to_exit = DV_EXIT_DUT_FAIL;
      DV_STATUS_SKIP : dv_status_to_exit = DV_EXIT_SKIP;
      DV_STATUS_ABORT: dv_status_to_exit = DV_EXIT_ABORT;
      default        : dv_status_to_exit = DV_EXIT_TB_FAIL;
    endcase
  endfunction

  //--------------------------------------------------------------------------
  // 状态转字符串
  //--------------------------------------------------------------------------
  function automatic string dv_status_name(dv_status_e s);
    case (s)
      DV_STATUS_PASS : dv_status_name = "PASS";
      DV_STATUS_FAIL : dv_status_name = "FAIL";
      DV_STATUS_SKIP : dv_status_name = "SKIP";
      DV_STATUS_ABORT: dv_status_name = "ABORT";
      default        : dv_status_name = "UNKNOWN";
    endcase
  endfunction

  //--------------------------------------------------------------------------
  // 严重度转字符串
  //--------------------------------------------------------------------------
  function automatic string dv_severity_name(dv_severity_e s);
    case (s)
      DV_NONE    : dv_severity_name = "NONE";
      DV_INFO    : dv_severity_name = "INFO";
      DV_WARNING : dv_severity_name = "WARNING";
      DV_ERROR   : dv_severity_name = "ERROR";
      DV_FATAL   : dv_severity_name = "FATAL";
      default    : dv_severity_name = "UNKNOWN";
    endcase
  endfunction

endpackage : dv_common_types_pkg
