# AIX DV Common — TODO List

> 依据 `plan.md` 第 26 节「首批 TODO List」并结合当前仓库实际进度整理。
> 状态：`[ ]` 待办 / `[-]` 进行中 / `[x]` 已完成
> 所有里程碑与验收标准见 `plan.md` 第 25 节。
> 最近更新：2026-08-13（P0 公共底座实现 + tools 工具层完成）

## 0. 已完成：仓库框架骨架（2026-08-12）

- [x] 建立仓库根文件（README/LICENSE/CHANGELOG/CONTRIBUTING/CODEOWNERS/.gitignore）
- [x] 建立 FuseSoC Core 骨架（types/utils/runtime/ral/scoreboard/mem/uvm/all，8 个 Core 解析通过）
- [x] L0 types 层（dv_common_types / dv_component_contract / dv_result_types）
- [x] L1 utils 层（queue / id / compare / data / stats）
- [x] L2 runtime 层（log / status / timeout / watchdog / reset / config / manifest）
- [x] L3 components 层（clk_rst / scoreboard / memory / coverage / interrupt / fault）
- [x] L4 uvm / ral 层（base_test / base_vseq / vseqr / env_contract / reset_seq / ral / csr_seq）
- [x] rtl/ 与 dpi/ 骨架（clk_gen / rst_gen / sim_timeout / signal_probe_if）
- [x] schemas/ 与 metadata/（6 个 Schema + 4 个元数据，YAML/JSON 校验通过）
- [x] unit/ examples/ tests/ docs/ tools/ release/ 目录骨架
- [x] VCS 编译/细化验证（非 UVM 层 + UVM 层均通过）

## 0.2 已完成：P0 公共底座实现（2026-08-13）

- [x] 非 UVM 单测 12/12 通过（VCS `-full64`）
- [x] minimal UVM example 全链路运行（`fusesoc run --target=smoke --tool=vcs aix:dv:common_all` PASS）
- [x] RTL 模块验证（新增 `tests/smoke/dv_rtl_smoke_tb.sv`，`rtl_smoke` target PASS）
- [x] 修复 `dv_config_pkg` 布尔 plusarg、`dv_compare_pkg` wildcard/结构化 diff
- [x] 修复 `metadata/message_ids.yaml` Message ID 格式
- [x] 实现 tools 工具层（schema_check / dep_check / api_diff / result_check / doc_gen + run_checks.sh）
- [x] `tools/run_checks.sh` 本地检查入口 ALL CHECKS PASSED
- [x] `docs/api/` 34 份 API 文档已生成

## P0：立即启动，0～2 周

- [ ] 任命 DV Common Owner 和组件 Owner（CODEOWNERS 占位映射待实际负责人）
- [ ] 冻结 Repo 边界和依赖方向（对应 `docs/dependency_rules.md`）
- [ ] 盘点现有 IP/VIP 公共代码，形成 Inventory
- [ ] 确定 UVM 1.2/1800.2 兼容策略并建立 `compat/` 薄层
- [ ] 确定主力仿真器 CI 矩阵（vcs/xcelium/questa，参考 `metadata/compatibility.yaml`）
- [ ] 确定 APB 寄存器 IP 穿刺对象
- [ ] 定义组件提案与 ADR 模板
- [ ] 定义 result/manifest/failure Schema V0.1（当前骨架已建，需评审冻结）
- [ ] 建立 PR 流水线骨架（schema 校验 → 依赖检查 → lint → 编译 → 单测 → API diff）

## P0：公共底座实现，2～8 周

- [x] 实现 `dv_common_types` 与 contract 的正式行为
- [x] 实现 log/status/failure service（Message ID 治理 + signature 聚合）
- [x] 实现 timeout/watchdog（含诊断 hook 接口）
- [x] 实现 clk/rst module 与 reset service（`rtl/dv_clk_gen.sv`、`rtl/dv_rst_gen.sv` 行为经 rtl_smoke 验证）
- [x] 实现 config snapshot 与来源追踪（优先级覆盖规则）
- [x] 实现 run manifest 正式输出（YAML，smoke 中已验证）
- [x] 实现 queue/ID/compare utils 的完整行为与边界（单测修正并通过）
- [x] 建立 unit/smoke target 并通过 FuseSoC+VCS 运行（12/12 单测 + smoke + rtl_smoke）
- [x] 建立 API diff 与 dependency check（`tools/api_diff`、`tools/dep_check` 已实现）
- [x] 完成 minimal UVM example 全链路运行（`fusesoc run --target=smoke --tool=vcs aix:dv:common_all` PASS）
- [x] 补齐 `tools/schema_check`、`tools/result_check` 实现
- [x] 实现 `tools/doc_gen` API 文档生成器（已生成 docs/api/ 34 份）
- [x] 建立本地检查入口 `tools/run_checks.sh`（schema_check + dep_check + api_diff）

## P1：首个季度

- [ ] 实现 RAL base 与 CSR sequence 正式行为（smoke/reset/rw/bit-bash）
- [ ] 接入 PeakRDL UVM RAL 输出链
- [ ] 与 APB VIP 完成 adapter/predictor 连接（RAL adapter 契约）
- [ ] 实现 in-order scoreboard 业务装配（matcher/flush/drain/pending 基础已实现并单测通过）
- [x] 实现结构化 diff 输出（`dv_compare_pkg::dv_diff_fields` 字段级差异）
- [x] 实现 memory mirror/backdoor contract 基础（`dv_memory_model` / `dv_mem_backdoor` 单测通过）
- [ ] 完成 APB 寄存器 IP 穿刺（`examples/apb_csr_ip`）
- [ ] 发布首个 Candidate 版本
- [ ] 接入统一 Catalog（`metadata/components.yaml` 成熟度更新为 qualified 路径）
- [ ] UVM Verification Skill 改为消费公共组件

## P1/P2：两个季度

- [ ] 实现 out-of-order matcher 与乱序匹配
- [ ] 实现 reset epoch 与跨 reset 策略（flush/error/preserve）
- [ ] 实现 latency/outstanding 统计（`dv_latency_tracker`）
- [ ] 完成 AXI/X2X 穿刺（`examples/axi_bridge`）
- [ ] 实现 interrupt/fault control 正式行为
- [ ] 完成 PIC 功能安全穿刺（`examples/pic_interrupt`）
- [ ] 多仿真器完整 Release 矩阵
- [ ] 性能 benchmark 与回退 Gate（编译时间/内存/百万 transaction 开销）
- [ ] AIXSILICON 项目座舱接入（result/manifest/failure schema 消费）
- [ ] 至少三个真实项目复用

## 工程化完善（随阶段穿插）

- [ ] `compat/` UVM 双 profile（uvm12_legacy / uvm1800_2）薄层
- [x] FuseSoC 后端仿真运行验证（smoke / rtl_smoke 经 VCS 后端 PASS，`-full64` + 统一 `-timescale`）
- [x] `docs/api/` 由 `tools/doc_gen` 生成（34 份）
- [ ] `docs/migration/` 补齐旧环境迁移指南
- [ ] CI 接入（PR/Nightly/Release 三段，见 `plan.md` 第 16 节；可将 `tools/run_checks.sh` 挂入 PR）
- [ ] SBOM 与 license 治理流程落地
- [ ] 一期验收标准核对（`plan.md` 第 25 节 15 项）
