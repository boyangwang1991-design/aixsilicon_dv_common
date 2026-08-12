# 依赖规则与版本治理

## 1. 单向依赖

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

## 2. 禁止

- `dv-common → axi-vip`；
- `dv-common → concrete IP RAL model`；
- `dv-common → soc_top_pkg`；
- `dv-common → project test`；
- 底层 package 反向依赖聚合 package。

## 3. 边界判断原则

1. **是否与协议有关**：有关则优先进入 VIP；无关且可被三类以上环境使用，才考虑 DV Common。
2. **是否与 DUT 功能有关**：有关则留在 IP/Subsystem/SoC 项目；公共库只提供机制和扩展点。
3. **是否负责"怎么运行"**：大规模回归和 EDA 命令属于 Flow；DV Common 只提供仿真内运行时能力和结构化输出。

## 4. 禁止万能 Base Env

- 不发布包含所有服务的单一 `aix_base_env`；
- 小型 service/component 按需实例化；
- 通过显式 config object 传递依赖；
- 聚合 Core 仅方便依赖，不形成运行时强绑定。

## 5. FuseSoC Core 与 VLNV

| Core | VLNV |
|---|---|
| common_types | `aix:dv:common_types:1.0.0` |
| common_utils | `aix:dv:common_utils:1.0.0` |
| common_runtime | `aix:dv:common_runtime:1.0.0` |
| common_scoreboard | `aix:dv:common_scoreboard:1.0.0` |
| common_ral | `aix:dv:common_ral:1.0.0` |
| common_memory | `aix:dv:common_memory:1.0.0` |
| common_uvm | `aix:dv:common_uvm:1.0.0` |
| common_all | `aix:dv:common_all:1.0.0` |

聚合 Core `common_all` 只聚合依赖，不允许：增加运行时全局对象、改变子 Core 编译宏、隐式启用 DPI、隐式启用 coverage、引入任何 VIP。

## 6. SemVer 规则

| 变更 | 版本 |
|---|---|
| 新增可选组件/方法，默认行为不变 | Minor |
| 修复 bug，不改变合法用户行为 | Patch |
| 删除/改名公共类、方法、字段 | Major |
| 默认 compare/reset/timeout 语义变化 | Major |
| 结果 Schema 新增可选字段 | Minor |
| 结果 Schema 删除/改变必选字段 | Major |

## 7. API 稳定性

- `public`、`protected extension`、`internal` 三级；
- 只有 public 进入兼容承诺；
- extension point 有明确 override 契约；
- internal 文件不允许下游直接 import；
- field macro、factory override、config key 也属于 API。

## 8. 弃用流程

1. Minor 版本标记 deprecated；
2. 提供替代 API 和迁移文档；
3. 至少保留一个稳定发布周期；
4. Major 版本才删除；
5. Catalog 记录影响范围；
6. Skill 模板先迁移，再允许删除旧接口。

## 9. UVM 多工具策略

双 profile：`uvm12_legacy`（兼容现网）、`uvm1800_2`（新项目演进基线）。

- 尽量使用公共标准 API；
- 不访问 UVM 未文档化内部成员；
- 版本差异集中在 `compat/` 薄层；
- 每个 Release 声明已验证的仿真器/UVM 组合。
