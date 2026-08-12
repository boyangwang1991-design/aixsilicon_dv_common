# Minimal UVM Example

最小 UVM 示例，演示 `dv_base_test` 的公共服务装配：

- `dv_minimal_pkg.sv`：定义 `dv_minimal_test`（继承 `dv_base_test`）；
- `dv_minimal_test.sv`：占位文件；
- `dv_minimal_test_top.sv`：顶层，调用 `run_test("dv_minimal_test")`。

运行（经由 FuseSoC）：

```bash
fusesoc run --target=smoke aix:dv:common_all
```

预期输出：`minimal test running` → `minimal test done` → test result 与 manifest 打印。
