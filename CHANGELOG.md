# Changelog

本仓库所有值得注意的变更均记录于此，遵循 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.0.0/) 与 [SemVer](https://semver.org/lang/zh-CN/)。

## [Unreleased]

### 新增

- 建立仓库框架与 FuseSoC Core 骨架（types/utils/runtime/ral/scoreboard/mem/uvm/all）。
- 新增 L0 基础类型与契约：`dv_common_types_pkg`、`dv_component_contract_pkg`、`dv_result_types_pkg`。
- 新增 L1 工具层：queue、ID、compare、data、stats（compare 含 masked/wildcard/tolerance/float/结构化 diff）。
- 新增 L2 运行时服务：log（Message ID）、status（signature 聚合）、timeout（含诊断 hook）、watchdog、reset、config（来源追踪）、manifest。
- 新增 L3 可复用组件：clk_rst、scoreboard、memory、coverage、interrupt、fault。
- 新增 L4 UVM 框架：base_test、base_vseq、vseqr、ral、csr_seq。
- 新增 `rtl/` 非综合模块（clk_gen/rst_gen/sim_timeout/signal_probe_if）与 `dpi/` 严格受限目录。
- 新增 `schemas/` 与 `metadata/` YAML/JSON Schema 与 Catalog 元数据 V0.1。
- 新增 `unit/`、`examples/`、`tests/`、`docs/`、`tools/`、`release/` 目录。
- 新增 `tests/smoke/dv_rtl_smoke_tb.sv` RTL 模块 smoke 测试与 common_all `rtl_smoke` target。
- 新增 `TODO.md` 项目任务清单。

### 验证（P0 公共底座）

- [x] 非 UVM 单测 12/12 通过（VCS -full64）。
- [x] FuseSoC `smoke`（minimal UVM example）经 VCS 后端全链路 PASS。
- [x] FuseSoC `rtl_smoke`（clk/rst/timeout）经 VCS 后端 PASS。
- [x] Core 文件统一 CAPI=2 格式（depend 位于 fileset、bool 参数 target 覆盖用 true/false）。
- [x] VCS 统一 `-timescale=1ns/1ps`（命令行）以兼容内置 UVM 库，避免 ITSFM。

### 变更

- `dv_config_pkg`：布尔 plusarg 解析改用 `$test$plusargs`（修复 `$value$plusargs` 无效格式）。
- `dv_compare_pkg`：`dv_diff_fields` 仅将不匹配字段写入 `diffs`；wildcard 比较去除循环内块声明。
- FuseSoC smoke/rtl_smoke/compile/lint/package target 增加 VCS 工具选项（-sverilog/-full64/-ntb_opts uvm-1.2/-timescale）。

### 修复

- `event`/`assert`/`reg` 保留字作为标识符导致的编译错误。
- `uvm_reg::read` 双输出参数（status/value）调用。
- 单元测试数据修正（masked/wildcard 位宽语义、byte-enable 字节对齐）。

### 待办（P0 后续）

- [ ] 实现 RAL base 与 CSR sequence 正式行为。
- [ ] 接入 PeakRDL UVM RAL 输出链与 APB VIP adapter/predictor。
- [ ] 完成 APB 寄存器 IP 穿刺（`examples/apb_csr_ip`）。
- [ ] 建立 API diff 与 dependency check 工具实现。
- [ ] 补齐 `tools/schema_check`、`tools/result_check` 实现。
- [ ] `compat/` UVM 双 profile 薄层（uvm12_legacy / uvm1800_2）。
