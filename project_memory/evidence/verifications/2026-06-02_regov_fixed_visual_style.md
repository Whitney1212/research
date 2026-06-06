# 2026-06-02 REgov 固定 EA/raw-w 绘图风格

## 来源

- 用户要求将 `EA_raw_w_CO2_decomposition_components_30min.png` 这张图的作图风格和三个站点配色固定到 REgov，以后固定采用这个风格。 [来源: 用户当前对话 2026-06-02]
- 该 PNG 的作图代码已核验为 `D:\00 博士阶段\博一\05 Project\ecpreproc\plot_ea_raw_w_total_transport.R` 中的 `plot_decomposition_components("30min")`，并由 `theme_raw()` 与 `site_cols` 控制主要样式和站点配色。 [已核验: D:\00 博士阶段\博一\05 Project\ecpreproc\plot_ea_raw_w_total_transport.R]

## 固定规则

- 后续当前项目中代表 `CVT`、`FL`、`MT` 三个观测站点的点线图，默认固定使用 `CVT = #F8766D`、`FL = #00BA38`、`MT = #619CFF`。 [来源: 用户当前对话 2026-06-02] [已核验: D:\00 博士阶段\博一\05 Project\ecpreproc\plot_ea_raw_w_total_transport.R]
- 后续 EA/raw-w/FL 诊断图默认采用 `ggplot2::theme_bw()` 的白底、简洁、报告型图面：去掉 minor grid，图例置顶且不设标题，分面标题浅灰底，主标题加粗，坐标文字和图注适当放大，输出保持较大画布和 `300 dpi`。对有正负号含义的变量，默认加入 `y = 0` 灰色参考线。 [来源: 用户当前对话 2026-06-02] [已核验: D:\00 博士阶段\博一\05 Project\ecpreproc\plot_ea_raw_w_total_transport.R]
- 多日、多分量时间序列可以沿用 `facet_grid(component ~ date, scales = "free_y")` 一类结构；当使用独立 y 轴时，解释中必须说明该图用于看形态和站点差异，不应用面板高度直接比较分量数量级。 [来源: 用户当前对话 2026-06-02] [推断：基于当前图代码和之前对图的解释整理]

## 已写入位置

- REgov 可视化规范已写入 `D:\00 博士阶段\99 Project\06 EA\regov_memory\03_visualization.md`。 [已核验: D:\00 博士阶段\99 Project\06 EA\regov_memory\03_visualization.md]
- REgov 共享背景中的生效分析决策也已补充该可视化规范指针，后续新工作线可以从共享背景继承该规则。 [已核验: D:\00 博士阶段\99 Project\06 EA\regov_memory\00_shared_research_context.md]
- 当前项目生效决策同步更新到 `D:\00 博士阶段\99 Project\06 EA\project_memory\anchors\03_active_decisions.md`。 [已核验: D:\00 博士阶段\99 Project\06 EA\project_memory\anchors\03_active_decisions.md]
