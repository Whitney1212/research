# 需要保留的冲突或解释风险

- 当前理论讨论中曾指出 EA 原始总输送可包含湍流和平均垂直输送项，但当前代码中的 EA 使用 \(w'\) 并去除了 30 min 平均垂直风，因此当前 `F_EA_general` 不包含 \(\bar w\bar c\) 形式的平均垂直输送。这个差异不是矛盾，而是“理论总输送形式”和“当前实现的湍流条件积分形式”之间的定义差异。 [来源: 用户当前对话 2026-05-18] [已核验: D:\00 博士阶段\博一\05 Project\ecpreproc\run_ea_preprocess.R]
- 当前 lag 结果中仍有 `edge_hit`，但它已经是在 metadata 约束的 ±0.2 s 窗口边界上触发，不再代表早期宽 lag 窗口下的多秒级异常。后续若解释 lag，应把它看作“协方差峰在物理允许窗口边界”的质量标记，而不是直接等同于真实管路延迟很长。 [已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_lag_stats.csv] [已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_lag_config.csv]
