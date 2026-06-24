# REgov 可视化入口

## 固定绘图风格

- 后续当前项目中代表 `CVT`、`FL`、`MT` 三个观测站点的点线图，默认采用 `EA_raw_w_CO2_decomposition_components_30min.png` 对应脚本中的站点配色：`CVT = #F8766D`，`FL = #00BA38`，`MT = #619CFF`。该配色用于保持不同图组中的站点识别一致，不随变量、窗口或分析分支改变。 [来源: 用户当前对话 2026-06-02] [已核验: D:\00 博士阶段\博一\05 Project\ecpreproc\plot_ea_raw_w_total_transport.R]
- 后续 EA/raw-w/FL 诊断图的默认风格采用 `ggplot2::theme_bw()` 的白底论文图样式：去掉 minor grid，图例放在顶部且不显示图例标题，分面标题使用浅灰背景，主标题加粗，坐标文字适当放大，输出使用较大画布和 `300 dpi`。对有正负号含义的变量，默认加 `y = 0` 的灰色参考线。 [来源: 用户当前对话 2026-06-02] [已核验: D:\00 博士阶段\博一\05 Project\ecpreproc\plot_ea_raw_w_total_transport.R]
- 对多日、多分量时间序列，默认优先使用清晰的分面结构，例如 `facet_grid(component ~ date, scales = "free_y")`。当不同分量数量级差异很大时，可以使用独立 y 轴让小分量可见，但图注或解释中必须说明独立 y 轴不适合直接比较分量数量级；数量级比较应另配汇总表、固定 y 轴图或 log 尺度图。 [来源: 用户当前对话 2026-06-02] [已核验: D:\00 博士阶段\博一\05 Project\ecpreproc\plot_ea_raw_w_total_transport.R] [推断：基于该图代码和解释边界整理]

## FL PF 拟合平面图规范

- FL PF 方法对比图统一使用短标签，避免长标签挤占图面：`A1 = 01 Global track`，`B1 = 02 6-bin`，`B2 = 03 8-bin`，`B3 = 04 10-bin`，`C1 = 05A Direction track`，`C2 = 05B Direction x bin`，`D1 = 06 Track sector`，`D2 = 07 Bin x sector`。 [来源: 用户当前对话 2026-06-15] [已核验: D:\00 博士阶段\99 Project\06 EA\project_memory\evidence\verifications\2026-06-15_fl_pf_fitted_plane_visualizations.md]
- A/B 类 PF 平面图优先采用 `track position × u_perp × w_plane` 的轨道剖面式布局，用颜色深浅表达 `tilt_deg`。这种图适合展示全轨道、6-bin、8-bin 和 10-bin 方法的沿轨道空间变化，也能直接说明为什么 B2/8-bin 是空间分辨率和样本稳定性之间的主推荐折中。 [已核验: D:\00 博士阶段\99 Project\06 EA\project_memory\evidence\verifications\2026-06-15_fl_pf_fitted_plane_visualizations.md] [推断：基于 A/B 图件结构整理]
- C 类 PF 平面图用于方向诊断：C1 展示 `fw/bw` 分开的全轨道 PF 平面，C2 展示 `fw/bw × bin` 的拼接平面。它们主要用于检查小车运动修正、方向一致性和端点或局地位置问题，不应自动替代主推荐 `PF_8bin`。 [已核验: D:\00 博士阶段\99 Project\06 EA\project_memory\evidence\verifications\2026-06-15_fl_pf_fitted_plane_visualizations.md] [推断：基于 C1/C2 分组逻辑整理]
- D 类 PF 图用于风向依赖诊断。D1 每个面板代表一个 `wind_from` 扇区的全轨道 PF 平面；D2 用 `bin × wind_from sector` 倾角矩阵检查局地位置和来流方向共同影响。D2 中灰色 `fail` 格子表示样本不足或拟合失败，因此它是诊断图，不是优先参数图。 [已核验: D:\00 博士阶段\99 Project\06 EA\project_memory\evidence\verifications\2026-06-15_fl_pf_fitted_plane_visualizations.md]
- D 系列风向扇区必须明确标注为 `wind_from`。当前实现为 8 个 `45 deg` 扇区，且分类基于 PF 输入统计点的平均风向，而不是 10 Hz 瞬时风向逐点分类。 [已核验: E:\FL_pf\R\fl_pf_common.R] [已核验: D:\00 博士阶段\99 Project\06 EA\project_memory\evidence\verifications\2026-06-15_fl_pf_fitted_plane_visualizations.md]

## 当前 dashboard

- 当前 dashboard 路径为 `D:\00 博士阶段\99 Project\06 EA\regov_dashboard\workstream_map.md`。 [已核验: D:\00 博士阶段\99 Project\06 EA\regov_dashboard\workstream_map.md]

## 刷新方式

```powershell
python "C:\Users\admin\.codex\skills\regov\scripts\build_workstream_map.py" --root "D:\00 博士阶段\99 Project\06 EA" --output "regov_dashboard\workstream_map.md"
```

## 多项目刷新方式

补齐 `04 Lee` 路径后使用：

```powershell
python "C:\Users\admin\.codex\skills\regov\scripts\build_workstream_map.py" --project "Current=D:\00 博士阶段\99 Project\06 EA" --project "04 Lee=D:\00 博士阶段\99 Project\04 Lee" --output "D:\00 博士阶段\99 Project\06 EA\regov_dashboard\workstream_map.md"
```
- FL质量守恒后垂直输送的月度热力色带图采用以下固定口径：每个有效月份一张、每天一列、纵轴固定0–24时；只填充成功实现质量平衡的mixed-sign单程；所有月份共用以0为中心的稳健对称色标，extreme_lambda与低分钟覆盖分别使用实线和虚线边框。当前实现脚本为 `E:\FL_MASSBALANCE\plot_fl_mass_balance_monthly_transport_heatbands.R`。 [来源: 用户当前对话 2026-06-24] [已核验: project_memory/evidence/verifications/2026-06-24_fl_mass_balance_monthly_transport_heatbands.md]
- FL质量守恒后垂直输送的跨月份合并图只排列存在有效结果的日期，标签采用完整 `YYYY-MM-DD`，无效日期不生成横轴占位；该版本不标注 `low_minute_coverage`，只保留 extreme-lambda 黑色实线边框。当前实现脚本为 `E:\FL_MASSBALANCE\plot_fl_mass_balance_combined_transport_heatband.R`。 [来源: 用户当前对话 2026-06-24] [已核验: project_memory/evidence/verifications/2026-06-24_fl_mass_balance_combined_transport_heatband.md]
