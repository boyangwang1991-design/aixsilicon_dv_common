# Contributing

欢迎向 AIX DV Common 贡献代码、文档与示例。请先阅读 [`docs/architecture.md`](docs/architecture.md) 与 [`docs/dependency_rules.md`](docs/dependency_rules.md)。

## 边界与依赖规则

本仓库**不得**依赖任何协议 VIP、具体 IP、SoC 项目或项目 test：

- 禁止 `dv-common → axi-vip`；
- 禁止 `dv-common → concrete IP RAL model`；
- 禁止 `dv-common → soc_top_pkg`；
- 禁止 `dv-common → project test`；
- 底层 package 禁止反向依赖聚合 package。

## 组件提案

新组件必须提交组件提案（Component Proposal），内容包含：

- 组件名称、VLNV、分层（L0~L5）；
- 职责边界与明确不做什么；
- input/output 与生命周期；
- 依赖列表（仅允许指向更低层）；
- 成熟度目标（Draft/Experimental/Candidate/Qualified）；
- reset-aware / drainable / 影响 pass-fail 声明；
- 单元测试与 negative 测试计划。

## 代码规范

- SystemVerilog 采用 UVM 1.2 / IEEE 1800.2 公共子集，不访问未文档化内部成员；
- 每个文件包含 license header 与文件头注释（作用、作者、日期）；
- 公共 API 分为 `public` / `protected extension` / `internal` 三级，只有 public 进入兼容承诺；
- internal 文件禁止被下游直接 import；
- 不允许自由文本作为回归 signature，统一使用 Message ID（`AIX_DV_<DOMAIN>_<EVENT>`）。

## 提交前检查（PR Gate）

1. Schema/metadata 校验通过；
2. 依赖方向与循环检查通过；
3. 格式、lint、license header 通过；
4. 受影响 Core 编译通过；
5. 单元测试与 negative 测试通过；
6. 最小示例可运行；
7. API diff 无意外破坏；
8. 文档链接检查通过；
9. 结果 Schema 自校验通过。

## 开源引入

不得整仓复制 OpenTitan / CORE-V-VERIF 等开源项目，也不得把不同 license 代码混入而不保留来源。
引入流程见 `docs/architecture.md` 第 18.2 节：来源与 license 确认 → 依赖审计 → 行为测试 → 多工具编译 → 隔离 PoC → 决策 → 保留 NOTICE → SBOM 固化。

## 版本与弃用

- SemVer 规则见 `docs/dependency_rules.md` 第 17 节；
- 弃用流程：Minor 标记 deprecated → 提供替代 API 与迁移文档 → 保留一个稳定发布周期 → Major 才删除。

## 问题跟踪

- Bug：说明复现步骤、影响组件、期望行为；
- 增强：绑定组件提案与需求 ID；
- 文档：指出具体文件与行号。
