# REgov 可视化入口

## 固定绘图风格

- 后续当前项目中代表 `CVT`、`FL`、`MT` 三个观测站点的点线图，默认采用 `EA_raw_w_CO2_decomposition_components_30min.png` 对应脚本中的站点配色：`CVT = #F8766D`，`FL = #00BA38`，`MT = #619CFF`。该配色用于保持不同图组中的站点识别一致，不随变量、窗口或分析分支改变。 [来源: 用户当前对话 2026-06-02] [已核验: D:\00 博士阶段\博一\05 Project\ecpreproc\plot_ea_raw_w_total_transport.R]
- 后续 EA/raw-w/FL 诊断图的默认风格采用 `ggplot2::theme_bw()` 的白底论文图样式：去掉 minor grid，图例放在顶部且不显示图例标题，分面标题使用浅灰背景，主标题加粗，坐标文字适当放大，输出使用较大画布和 `300 dpi`。对有正负号含义的变量，默认加 `y = 0` 的灰色参考线。 [来源: 用户当前对话 2026-06-02] [已核验: D:\00 博士阶段\博一\05 Project\ecpreproc\plot_ea_raw_w_total_transport.R]
- 对多日、多分量时间序列，默认优先使用清晰的分面结构，例如 `facet_grid(component ~ date, scales = "free_y")`。当不同分量数量级差异很大时，可以使用独立 y 轴让小分量可见，但图注或解释中必须说明独立 y 轴不适合直接比较分量数量级；数量级比较应另配汇总表、固定 y 轴图或 log 尺度图。 [来源: 用户当前对话 2026-06-02] [已核验: D:\00 博士阶段\博一\05 Project\ecpreproc\plot_ea_raw_w_total_transport.R] [推断：基于该图代码和解释边界整理]

## 当前 dashboard

- 当前 dashboard 路径为 `C:\Users\admin\Documents\New project\regov_dashboard\workstream_map.md`。 [已核验: C:\Users\admin\Documents\New project\regov_dashboard\workstream_map.md]

## 刷新方式

```powershell
python "C:\Users\admin\.codex\skills\regov\scripts\build_workstream_map.py" --root "C:\Users\admin\Documents\New project" --output "regov_dashboard\workstream_map.md"
```

## 多项目刷新方式

补齐 `04 Lee` 路径后使用：

```powershell
python "C:\Users\admin\.codex\skills\regov\scripts\build_workstream_map.py" --project "Current=C:\Users\admin\Documents\New project" --project "04 Lee=D:\00 博士阶段\99 Project\04 Lee" --output "C:\Users\admin\Documents\New project\regov_dashboard\workstream_map.md"
```
