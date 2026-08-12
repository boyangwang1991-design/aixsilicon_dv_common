# Changelog

本仓库所有值得注意的变更均记录于此，遵循 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.0.0/) 与 [SemVer](https://semver.org/lang/zh-CN/)。

## [Unreleased]

### 新增

- 建立仓库框架与 FuseSoC Core 骨架（types/utils/runtime/ral/scoreboard/mem/uvm/all）。
- 新增 L0 基础类型与契约：`dv_common_types_pkg`、`dv_component_contract_pkg`、`dv_result_types_pkg`。
- 新增 L1 工具层骨架：queue、ID、compare、data、stats。
- 新增 L2 运行时服务骨架：log、status、timeout、watchdog、reset、config、manifest。
- 新增 L3 可复用组件目录骨架：clk_rst、scoreboard、memory、coverage、interrupt、fault。
- 新增 L4 UVM 框架骨架：base_test、base_vseq、vseqr、ral、csr_seq。
- 新增 `rtl/` 非综合模块骨架与 `dpi/` 严格受限目录。
- 新增 `schemas/` 与 `metadata/` YAML/JSON Schema 与 Catalog 元数据 V0.1。
- 新增 `unit/`、`examples/`、`tests/`、`docs/`、`tools/`、`release/` 目录骨架。

### 待办（一期 P0）

- [ ] 实现 `dv_common_types` 与 contract 的正式行为。
- [ ] 实现 log/status/failure service。
- [ ] 实现 timeout/watchdog。
- [ ] 实现 clk/rst module 与 reset service。
- [ ] 实现 config snapshot 与 run manifest。
- [ ] 实现 queue/ID/compare utils。
- [ ] 建立 unit/negative/portability target。
- [ ] 建立 API diff 与 dependency check。
- [ ] 完成 minimal UVM example。

### 变更

- 无（首版框架）。

### 修复

- 无。
