# tools/schema_check

校验 `schemas/*.yaml` 与 `metadata/*.yaml` 的合法性与一致性。

## 功能（规划）

- YAML 语法与 JSON Schema 结构校验；
- `components.yaml` 条目遵循 `component.schema.yaml`；
- `message_ids.yaml` 中 ID 遵循 `AIX_DV_<DOMAIN>_<EVENT>` 格式。

## 状态

占位骨架。建议实现为 Python（依赖 `pyyaml` / `jsonschema`）或脚本。
