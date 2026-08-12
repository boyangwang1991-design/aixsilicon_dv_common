# 组件 Catalog

机器可读版本见 [`metadata/components.yaml`](../metadata/components.yaml)。
Skill Suite 只从 Catalog 中选择达到 `qualified` 且兼容目标 tool profile 的组件。

## 成熟度定义

| 状态 | 含义 |
|---|---|
| Draft | API 和行为仍可重构 |
| Experimental | 可 PoC，不允许关键项目默认使用 |
| Candidate | API 冻结，进入多项目验证 |
| Qualified | 通过完整 Gate，可进入正式项目 |
| Deprecated | 只维护兼容和安全修复 |
| Retired | Catalog 不再推荐，新项目禁止使用 |

## 当前 Catalog（V0.1，均为框架骨架）

### L0 Types & Contracts（`aix:dv:common_types`）

| 组件 | 成熟度 |
|---|---|
| dv_common_types | candidate |
| dv_component_contract | candidate |

### L1 Utilities（`aix:dv:common_utils`）

| 组件 | 成熟度 |
|---|---|
| dv_queue | experimental |
| dv_id | experimental |
| dv_compare | experimental |
| dv_data | experimental |
| dv_stats | experimental |

### L2 Runtime Services（`aix:dv:common_runtime`）

| 组件 | 成熟度 |
|---|---|
| dv_log | experimental |
| dv_status | experimental |
| dv_timeout | experimental |
| dv_watchdog | experimental |
| dv_reset_service | experimental |
| dv_config | experimental |
| dv_manifest | experimental |

### L3 Reusable Components

| 组件 | Core | 成熟度 |
|---|---|---|
| dv_clk_rst | common_runtime | experimental |
| dv_scoreboard | common_scoreboard | experimental |
| dv_memory | common_memory | experimental |
| dv_coverage_control | common_runtime | draft |
| dv_interrupt_service | common_runtime | draft |
| dv_fault_control | common_runtime | draft |

### L4 UVM Framework & RAL

| 组件 | Core | 成熟度 |
|---|---|---|
| dv_base_test | common_uvm | experimental |
| dv_base_virtual_sequence | common_uvm | experimental |
| dv_virtual_sequencer | common_uvm | experimental |
| dv_ral | common_ral | experimental |
| dv_csr_seq | common_ral | experimental |

## 质量 Gate 状态

当前所有组件 `lint/unit_test/negative_test/portability` 均为 `not_run`（框架骨架）。
达成 Qualified 需通过 G0~G9 全部 Gate（见 `plan.md` 第 15.2 节）。
