# tools/dep_check

依赖方向与循环检查（Gate G1）。

## 功能（已实现）

- 解析 `fusesoc/*.core` 的 fileset 级 `depend`，构建 VLNV 依赖图；
- DFS 检测依赖环；
- 校验依赖方向：底层 package 不得反向依赖聚合 package；
- 校验公共库不得依赖 VIP/IP/SoC/Project 类 VLNV；
- 校验 Core 引用的源文件存在。

## 用法

```bash
python3 tools/dep_check/check_deps.py
```
