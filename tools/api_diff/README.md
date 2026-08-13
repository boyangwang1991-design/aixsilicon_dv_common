# tools/api_diff

API 差异检查（PR/Release 时运行）。

## 功能（已实现）

- 从 SV 源码提取公共符号（package/class/function/task/typedef/enum）；
- 对比两个版本/目录，输出新增/删除符号；
- git 模式：对比最近两次 commit 的 `src/` 符号；
- `--dump`：输出当前全部符号快照（可归档）。

## 用法

```bash
python3 tools/api_diff/api_diff.py                  # git HEAD~1..HEAD
python3 tools/api_diff/api_diff.py old_dir new_dir  # 目录对比
python3 tools/api_diff/api_diff.py --dump           # 符号快照
```
