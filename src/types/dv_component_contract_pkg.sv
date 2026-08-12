//======================================================================
// AIX DV Common - L0 组件契约
// File    : src/types/dv_component_contract_pkg.sv
// Purpose : service lifecycle、reset-aware、drainable 等接口契约。
//           以纯 virtual class 表达 contract，不绑定 UVM。
// Author  : dv-platform
// Date    : 2026-08-12
// Notes   :
//   Service 统一生命周期：
//     configure → start → reset_notify → quiesce → drain → finalize
//======================================================================

package dv_component_contract_pkg;

  import dv_common_types_pkg::*;

  //--------------------------------------------------------------------------
  // 服务阶段
  //--------------------------------------------------------------------------
  typedef enum int {
    DV_PHASE_UNCONFIGURED = 0,
    DV_PHASE_CONFIGURED   = 1,
    DV_PHASE_STARTED      = 2,
    DV_PHASE_QUIESCED     = 3,
    DV_PHASE_DRAINED      = 4,
    DV_PHASE_FINALIZED    = 5,
    DV_PHASE_RESET        = 6
  } dv_lifecycle_phase_e;

  //--------------------------------------------------------------------------
  // 组件能力声明（用于 Catalog 与兼容性检查）
  //--------------------------------------------------------------------------
  typedef struct {
    bit reset_aware;
    bit drainable;
    bit produces_metric;
    bit affects_pass_fail;
  } dv_capability_t;

  //--------------------------------------------------------------------------
  // 生命周期契约基类
  //--------------------------------------------------------------------------
  virtual class dv_lifecycle_if;

    pure virtual function void dv_configure();
    pure virtual function void dv_start();
    pure virtual function void dv_quiesce();
    pure virtual function void dv_drain(time dv_timeout);
    pure virtual function void dv_finalize();

    // reset_notify：reset assert 时 epoch 递增并通知组件
    pure virtual function void dv_reset_notify(dv_reset_type_e rtype);

    virtual function dv_lifecycle_phase_e dv_phase();
      dv_phase = DV_PHASE_UNCONFIGURED;
    endfunction

  endclass

  //--------------------------------------------------------------------------
  // Reset-aware 契约
  //--------------------------------------------------------------------------
  virtual class dv_reset_aware_if;

    // 返回组件当前持有的 reset epoch
    pure virtual function int unsigned dv_get_reset_epoch();

    // 组件决定跨 reset 的 outstanding 处理策略：
    //   flush / error / preserve
    pure virtual function void dv_on_reset(dv_reset_type_e rtype);

  endclass

  //--------------------------------------------------------------------------
  // Drainable 契约
  //--------------------------------------------------------------------------
  virtual class dv_drainable_if;

    pure virtual function int unsigned dv_get_pending_count();
    pure virtual function bit    dv_is_drained();
    pure virtual function void   dv_drain(time dv_timeout);

  endclass

  //--------------------------------------------------------------------------
  // 指标生产者契约
  //--------------------------------------------------------------------------
  virtual class dv_metric_producer_if;

    // 输出结构化 metric（以 "key=value" 或 JSON 片段形式）
    pure virtual function string dv_get_metrics_json();

  endclass

endpackage : dv_component_contract_pkg
