# 架构

本文件是 AIX DV Common 的架构说明，对应 `plan.md` 的完整规划。

## 1. 定位

DV Common Repo 是组织级、与具体协议和具体 DUT 无关的验证基础设施库。

> HW Interface 定义"接口是什么"，VIP 定义"协议怎样激励和检查"，
> DV Common 定义"验证环境怎样运行、比较、结束和留证"，
> IP/SoC 项目定义"具体功能要验证什么"，EDA Flow 定义"怎样规模化执行"。

## 2. 六层组件模型

| 层 | 名称 | 主要内容 | 源码位置 |
|---|---|---|---|
| L0 | Types & Contracts | 类型、枚举、接口契约、Schema | `src/types/`、`schemas/` |
| L1 | Utilities | queue、ID、compare、data、stats | `src/utils/` |
| L2 | Runtime Services | log、status、timeout、watchdog、reset、config、manifest | `src/runtime/` |
| L3 | Reusable Components | clk/rst、scoreboard、memory、coverage、interrupt、fault | `src/components/` |
| L4 | UVM Framework | base test/env contract、sequence、RAL、virtual sequencer | `src/uvm/`、`src/ral/` |
| L5 | Integration Adapters | FuseSoC target、Flow 结果适配、Skill 模板、示例 | `fusesoc/`、`examples/` |

依赖只能从上层指向下层。L0/L1 尽量避免 UVM 依赖，使部分工具可用于非 UVM 测试台。

## 3. 组合优于继承

- Base Class 只定义最小稳定接口；
- 行为变化使用 policy object（如 `dv_compare_policy`）；
- 功能增加使用 service/component 组合；
- 端口连接使用 TLM 和显式 adapter；
- 状态传播使用 typed event/service，避免散落的 global event pool。

## 4. 配置显式化

公共配置四层：

1. `run_cfg`：seed、timeout、verbosity、wave、tool profile；
2. `env_cfg`：active/passive、scoreboard、coverage、RAL 开关；
3. `service_cfg`：某个公共服务的具体参数；
4. `project_cfg`：项目自定义，不进入公共库。

禁止任意组件通过通配路径从 `uvm_config_db` 搜索大量离散字段。

## 5. Service 生命周期

```text
configure → start → reset_notify → quiesce → drain → finalize
```

每个 service 应声明：是否 reset-aware、是否需要 drain、是否产生最终 metric、
是否影响 test pass/fail、thread ownership、销毁和重复启动语义。

## 6. Reset Epoch

所有可能跨 reset 保存状态的组件必须使用 `reset_epoch`：

- reset assert 时 epoch 递增；
- transaction 记录所属 epoch；
- scoreboard 默认禁止跨 epoch 匹配；
- outstanding 事务按 policy 选择 flush、error 或 preserve；
- coverage 可按 epoch 分组。

## 7. 源码目录

```text
src/
├── types/        # L0
├── utils/        # L1
├── runtime/      # L2
├── components/   # L3（clk_rst/scoreboard/memory/coverage/interrupt/fault）
├── ral/          # RAL/CSR 公共能力
└── uvm/          # L4 UVM 框架
```

## 8. 参考开源项目

- Accellera UVM Core（标准 API 基线）
- OpenTitan `hw/dv/sv`（DV utils/RAL 参考）
- PULP `common_verification`（轻量仿真组件 PoC）
- OpenHW CORE-V-VERIF（公共能力支撑多环境）

开源仅用于参考和审计，不整仓搬运，保留版权与 NOTICE。
