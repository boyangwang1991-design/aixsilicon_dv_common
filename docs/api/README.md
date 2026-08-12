# API 文档

公共 API 文档按组件生成，遵循 `public` / `protected extension` / `internal` 三级。

- 由 `tools/doc_gen` 从源码头注释生成；
- 只有 public API 进入兼容承诺；
- internal 文件禁止下游直接 import。

当前为占位，正式文档待 `tools/doc_gen` 实现后生成。
