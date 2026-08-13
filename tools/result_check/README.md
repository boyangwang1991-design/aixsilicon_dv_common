# tools/result_check

结果自校验（Gate G7 证据校验）。

## 功能（已实现）

- 校验 `test_result`：`schema_version`/`test`/`run` 必填，`status` 与 `exit_code` 枚举合法；
- 校验 `run_manifest`：`schema_version`、`uvm_profile`、`seed` 类型合法。

## 用法

```bash
python3 tools/result_check/check_result.py result.yaml
python3 tools/result_check/check_result.py manifest.yaml --manifest
```
