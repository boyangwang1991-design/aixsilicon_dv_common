# 迁移指南

现有环境迁移采用四步，不做大爆炸迁移：

1. **Inventory**：扫描重复 base class、timeout、scoreboard、CSR sequence；
2. **Adapter**：为旧环境提供兼容 adapter；
3. **Pilot**：选择一个简单 IP 和一个复杂 IP 迁移；
4. **Default**：新项目默认使用，旧项目按版本窗口迁移。

优先迁移：日志和 result、timeout、clk/rst、CSR sequence、compare 工具。
后迁移：Base Test 继承体系、scoreboard、reset lifecycle、virtual sequence 结构。

当前为占位，正式迁移文档随各组件发布补齐。
