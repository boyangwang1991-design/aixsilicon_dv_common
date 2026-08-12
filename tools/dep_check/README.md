# tools/dep_check

依赖方向与循环检查（Gate G1）。

## 功能（规划）

- 解析 FuseSoC Core 的 `depend` 与源码 `import`；
- 校验 DAG 无环；
- 校验不依赖 VIP/IP/SoC/项目包；
- 校验底层 package 不反向依赖聚合 package。

## 状态

占位骨架。
