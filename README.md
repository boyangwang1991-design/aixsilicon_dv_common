# AIX DV Common

组织级、与具体协议和具体 DUT 无关的验证基础设施库（DV Common Repo）。

> 定位：不是某个项目的 `base_test` 集合，也不是 VIP 仓库的公共目录。它提供"验证环境怎样运行、比较、结束和留证"的统一机制。

## 在资产体系中的位置

```text
HW Interface Repo  ──定义接口契约──┐
                                   │
DV Common Repo ──提供通用验证机制──┼──> IP/CBB/VIP/SubSystem/SoC DV环境
                                   │
VIP Repo ──提供协议激励与检查──────┘

EDA Flow ──负责运行、调度、合并、报告和发布
```

## 核心目标

1. 让新 IP 验证环境不再重复生成日志、超时、Clock/Reset、RAL、Scoreboard 和结果收集代码；
2. 让不同 VIP、IP 和 SoC 级环境使用一致的配置、状态、错误码、事务比较和证据格式；
3. 为 UVM Verification Skill Suite 提供稳定、可发现、可版本锁定的组件；
4. 支持从 IP 单元验证平滑组合到 Subsystem/SoC 验证，而不构造臃肿的"万能 Base Env"；
5. 通过 FuseSoC、SemVer、Catalog 和质量 Gate 实现可复用验证资产的工程化发布。

## 分层组件模型

| 层 | 名称 | 主要内容 |
|---|---|---|
| L0 | Types & Contracts | 类型、枚举、接口契约、Schema |
| L1 | Utilities | queue、ID、random、string、CRC、mask、统计工具 |
| L2 | Runtime Services | log、status、timeout、objection、config、manifest |
| L3 | Reusable Components | clk/rst、scoreboard、memory、coverage、fault control |
| L4 | UVM Framework | base test/env contract、sequence、RAL 服务、virtual sequencer |
| L5 | Integration Adapters | FuseSoC target、Flow 结果适配、Skill 模板、示例环境 |

## 仓库结构

```text
aix-dv-common/
├── fusesoc/      # FuseSoC Core 定义
├── src/          # SV 源码（types/utils/runtime/components/ral/uvm）
├── rtl/          # 非综合 SystemVerilog 模块（clk/rst/timeout/probe）
├── dpi/          # DPI（严格受限）
├── schemas/      # YAML/JSON Schema
├── metadata/     # 组件 Catalog、兼容性、Message ID、弃用
├── unit/         # 组件单测
├── examples/     # 示例工程（minimal_uvm/apb_csr_ip/axi_bridge/pic_interrupt）
├── tests/        # compile_matrix/negative/reset_stress/portability
├── docs/         # 架构、依赖规则、组件 Catalog、API、迁移、示例
├── tools/        # schema_check/dep_check/api_diff/result_check/doc_gen
└── release/      # release_manifest/SBOM/evidence
```

## 快速开始

1. 安装 [FuseSoC](https://github.com/olofk/fusesoc)（v2.x）。
2. 将本仓库加入 FuseSoC 库：

   ```bash
   fusesoc library add aix-dv-common .
   ```

3. 编译聚合 Core：

   ```bash
   fusesoc run --target=compile aix:dv:common_all
   ```

4. 运行最小 UVM 示例：

   ```bash
   fusesoc run --target=smoke aix:dv:common_all
   ```

5. 查看组件 Catalog：`docs/component_catalog.md` 或 `metadata/components.yaml`。

## 依赖方向（单向，禁止反向）

```text
UVM / simulator abstraction
          ↓
dv_common_types
          ↓
utility + service + policy packages
          ↓
optional aggregate core
          ↓
VIP / IP Env / SoC Env
```

禁止：`dv-common → axi-vip`、`dv-common → concrete IP RAL model`、`dv-common → soc_top_pkg`、`dv-common → project test`。

## 文档

- 完整规划：[`docs/architecture.md`](docs/architecture.md)
- 依赖规则：[`docs/dependency_rules.md`](docs/dependency_rules.md)
- 组件 Catalog：[`docs/component_catalog.md`](docs/component_catalog.md)
- 贡献指南：[`CONTRIBUTING.md`](CONTRIBUTING.md)

## License

见 [`LICENSE`](LICENSE)。
