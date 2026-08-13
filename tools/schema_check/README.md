# tools/schema_check

校验 `schemas/*.yaml` 与 `metadata/*.yaml` 的合法性与一致性。

## 功能（已实现）

- YAML 语法解析校验；
- `schemas/*.schema.yaml` 为合法 JSON-Schema（含 `$schema`/`title`/`type`）；
- `message_ids.yaml` 中 Message ID 遵循 `AIX_DV_<DOMAIN>_<EVENT>` 格式；
- `components.yaml` 条目含必填字段、合法 category/maturity、组件名唯一。

## 用法

```bash
python3 tools/schema_check/check_schema.py
python3 tools/schema_check/check_schema.py schemas/run_config.schema.yaml  # 单个文件
```
