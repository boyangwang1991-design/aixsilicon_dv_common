# tools/doc_gen

API 文档生成器。

## 功能（已实现）

- 从 SV 源码头注释与公共符号（package/class/function/task/typedef/enum）生成 Markdown；
- 输出到 `docs/api/`（文件路径以 `__` 分隔命名）；
- `--dry-run` 只打印不写文件。

## 用法

```bash
python3 tools/doc_gen/doc_gen.py
python3 tools/doc_gen/doc_gen.py --dry-run
```
