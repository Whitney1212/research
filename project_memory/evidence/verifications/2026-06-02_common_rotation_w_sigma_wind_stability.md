# 2026-06-02 com_rotation 的 w_mean/sigma_w、风向扇区、稳定度和日出窗口诊断

## 本轮新增内容

本轮在 `D:\00 博士阶段\博一\05 Project\com_rotation` 中继续推进固定站点四方法坐标旋转敏感性分析，重点从单纯比较 `F_EC` 扩展到解释旋转为什么会造成差异。新增并运行脚本 `D:\00 博士阶段\博一\05 Project\com_rotation\scripts\07_w_sigma_rotation_diagnostics.R`，从 Level0 高频风重新计算四种 rotation 下的 `w_mean` 与 `sigma_w`，并与既有通量结果合并。该脚本输出报告 `D:\00 博士阶段\博一\05 Project\com_rotation\results\analysis\w_sigma_rotation_diagnostics_report.html`，以及表格 `11_w_sigma_rotation_diagnostics_raw.csv`、`12_w_sigma_rotation_diagnostics.csv`、`13_w_sigma_flux_joined.csv`、`14_w_sigma_flux_summary.csv` 到 `18_*` 等结果表。图件包括 `fig06_w_sigma_flux_by_rotation_boxplot.png`、`fig07_w_sigma_flux_sensitivity_vs_dr.png`、`fig08_w_sigma_flux_relative_range_heatmap.png` 和 `fig09_w_sigma_ustar_diurnal_by_rotation.png`。其中 `11_w_sigma_rotation_diagnostics_raw.csv` 为 `22832` 行，`12_w_sigma_rotation_diagnostics.csv` 为 `22828` 行，`13_w_sigma_flux_joined.csv` 为 `20492` 行。 [来源: 用户当前对话 2026-06-02] [已核验: D:\00 博士阶段\博一\05 Project\com_rotation\scripts\07_w_sigma_rotation_diagnostics.R] [已核验: D:\00 博士阶段\博一\05 Project\com_rotation\results\analysis\w_sigma_rotation_diagnostics_report.html]

本轮又新增并运行脚本 `D:\00 博士阶段\博一\05 Project\com_rotation\scripts\08_priority_wind_stability_sunrise_analysis.R`，用于输出第一优先级与第二优先级的计算和可视化。该脚本输出报告 `D:\00 博士阶段\博一\05 Project\com_rotation\results\analysis\priority_wind_stability_sunrise_report.html`，以及表格 `19_state_reference_wind_stability_sunrise.csv`、`20_method_range_by_timestamp_with_state.csv`、`21_wind_sector_method_range_summary.csv`、`22_stability_method_range_summary.csv`、`23_sunrise_window_method_range_summary.csv` 和 `24_sunrise_window_by_method_summary.csv`。其中 `19_state_reference_wind_stability_sunrise.csv` 为 `5132` 行，`20_method_range_by_timestamp_with_state.csv` 为 `30738` 行，`21_wind_sector_method_range_summary.csv` 为 `288` 行，`22_stability_method_range_summary.csv` 为 `72` 行，`23_sunrise_window_method_range_summary.csv` 为 `120` 行，`24_sunrise_window_by_method_summary.csv` 为 `480` 行。图件包括 `fig10_wind_sector_method_range_heatmap.png`、`fig11_wind_arrow_timeline_wmean_range.png`、`fig12_stability_method_range_boxplot.png`、`fig13_sunrise_window_method_range_boxplot.png` 和 `fig14_sunrise_window_method_medians.png`。 [来源: 用户当前对话 2026-06-02] [已核验: D:\00 博士阶段\博一\05 Project\com_rotation\scripts\08_priority_wind_stability_sunrise_analysis.R] [已核验: D:\00 博士阶段\博一\05 Project\com_rotation\results\analysis\priority_wind_stability_sunrise_report.html]

## 时间解析修正

本轮复核了时间相位问题。原始高频 TOA5 读取函数已经按既定规则处理：先将时间戳按字符读入，再按 `Asia/Shanghai` 解析。真正造成风险的是中间结果通过 `readr::write_csv()` 写出 POSIXct 时被格式化为 UTC `Z`，后续再读取时可能把局地时间相位错移 `8 h`。因此 `07_w_sigma_rotation_diagnostics.R` 已修正为：读取 segment 中间结果时先把 `timestamp` 当作字符，如果识别到旧的 `...Z` 格式，则先按 UTC 读入再转换回 `Asia/Shanghai`；如果是普通字符串，则直接按 `Asia/Shanghai` 解析；最终输出中的时间写为本地时间字符串。修正后 `13_w_sigma_flux_joined.csv` 的起始时间为局地 `2025-01-22 16:30:00`。 [来源: 用户当前对话 2026-06-02] [已核验: D:\00 博士阶段\博一\05 Project\com_rotation\scripts\07_w_sigma_rotation_diagnostics.R] [推断：基于本轮时间相位复核和脚本修正整理]

## 核心结果解释

当前结果显示，坐标旋转对 `w_mean` 的影响最强。double rotation 按定义会把窗口内 `w_mean` 强制压到接近 `0`；no rotation 下 `MT` 的 `w_mean` 为明显正值，A 系统中位数约 `0.118 m/s`，B 系统中位数约 `0.070 m/s`；`CVT` no rotation 下为轻微负值，约 `-0.026` 到 `-0.027 m/s`。planar fit 与 sector-wise planar fit 会显著减小残余 `w_mean`，但不会像 double rotation 那样对每个窗口逐一归零。 [来源: 用户当前对话 2026-06-02] [已核验: D:\00 博士阶段\博一\05 Project\com_rotation\results\analysis\tables\14_w_sigma_flux_summary.csv]

`sigma_w` 对 rotation 的敏感性明显低于 `w_mean` 和通量项。当前 `sigma_w` 的方法间中位相对 range 约为 `8-10%`，并且相对于 double rotation 的相关性通常高于 `0.98`。这说明 rotation 主要改变的是平均流线方向、垂直风均值约束和协方差投影，而不是把垂直湍流强度本身完全改写。与此相比，`u*` 为中等敏感，方法间中位相对 range 约为 `19-31%`；`co2_flux/H/LE` 的方法敏感性更高，常见中位相对 range 约为 `33-50%`。 [来源: 用户当前对话 2026-06-02] [已核验: D:\00 博士阶段\博一\05 Project\com_rotation\results\analysis\tables\14_w_sigma_flux_summary.csv] [推断：基于 `w_mean`、`sigma_w`、`u*` 和通量敏感性比较整理]

因此，本轮对 rotation 差异的机制解释应表述为：在当前复杂地形固定站点背景下，坐标旋转差异主要不是因为湍流强度 `sigma_w` 被大幅改变，而是因为不同 rotation 对平均流线、垂直速度零均值约束、动量与标量协方差投影的处理不同。对 `w_mean` 来说，double rotation 是窗口级强约束；planar fit 是长期平均流面约束；sector-wise planar fit 是按风向扇区给出的长期流面约束；no rotation 则保留仪器坐标和局地流线倾斜中的平均垂直分量。 [推断：基于本轮四方法结果、EC 坐标旋转定义和复杂地形流线倾斜背景整理]

## 风向、稳定度与日出窗口

风向箭矢图采用沿时间轴叠加风向箭矢的方法，并使用 double rotation 的 `geo_wind_from_deg` 作为参考风向；图中箭头绘制的是流向，即 `wind_from + 180°`。初步结果显示，`MT` 的 `w_mean` rotation 敏感性在若干风向扇区内更集中，尤其在约 `090-150°` 及相关相邻扇区表现突出；`CVT` 的集中性相对较弱，但部分扇区仍有较高方法 range。这一结果支持后续把风向依赖的地形流线修正作为主要分析对象，而不是只报告一个全局平均的 rotation 差异。 [来源: 用户当前对话 2026-06-02] [已核验: D:\00 博士阶段\博一\05 Project\com_rotation\results\analysis\figures\fig10_wind_sector_method_range_heatmap.png] [已核验: D:\00 博士阶段\博一\05 Project\com_rotation\results\analysis\figures\fig11_wind_arrow_timeline_wmean_range.png] [推断：基于风向扇区 heatmap 和时间轴风向箭矢图整理]

`fig12_stability_method_range_boxplot.png` 中的 relative range 到 `200%` 是图件显示上限，而不是真实最大值。脚本采用 `method_rel_range = method_range / median(abs(value_methods))`，并在绘图时使用 `rel_capped = pmin(method_rel_range, 2)`，因此 `200%` 表示该点或该分布已经达到可视化截断上限。实际相对 range 可以远高于 `200%`，尤其是 `w_mean` 这类在 double rotation 下接近 `0` 的变量，或 `H/LE/co2_flux` 这类在不同 rotation 下接近零值或发生符号切换的变量。 [来源: 用户当前对话 2026-06-02] [已核验: D:\00 博士阶段\博一\05 Project\com_rotation\scripts\08_priority_wind_stability_sunrise_analysis.R] [推断：基于相对 range 定义和图件截断规则整理]

日出窗口分析已经完成第一版，但需要保留坐标元数据 caveat。脚本使用 metadata 中的经纬度计算日出窗口；`CVT` metadata 为 `25.03,116.48`，而 `MT` metadata 为 `35,120`，这一组值可能是占位值或不准确值。如果后续要正式解释 `MT` 的日出窗口统计，必须先修正 `MT` 坐标并重跑日出窗口分析。 [来源: 用户当前对话 2026-06-02] [已核验: D:\00 博士阶段\博一\05 Project\com_rotation\scripts\08_priority_wind_stability_sunrise_analysis.R]

## H/LE 离群点处理边界

`fig06_w_sigma_flux_by_rotation_boxplot.png` 中 `H` 和 `LE` 的大离群值可能来自强白天湍流事件、残余质量控制问题、水汽异常以及 rotation 投影放大共同作用。已检查到的典型例子包括 `MT B 2025-03-28 09:30 dr`，其 `H=653 W/m2`、`LE=1043 W/m2`、`co2_flux=81.6`、`u*=0.94`、`sigma_w=0.81`，同时质量标记较差，`qc_H=2`、`qc_h2o=2`、`flag9_H=5`、`flag9_h2o=5`，stationarity 约 `0.87/0.92`。另有 `MT B 2025-03-19/17` 白天高 `H` 点，可能更接近强混合物理事件。 [来源: 用户当前对话 2026-06-02] [已核验: D:\00 博士阶段\博一\05 Project\com_rotation\results\analysis\figures\fig06_w_sigma_flux_by_rotation_boxplot.png] [推断：基于本轮离群点追查和 QC 标记整理]

因此后续不宜简单删除全部 H/LE 离群点。更稳妥的做法是保留 all-data 诊断图作为方法敏感性全貌，同时补充 QC-screened 图、robust 或 winsorized 图和缩放版图。正式解释 `H/LE` 时应使用变量特异的 QC 口径，例如 `qc_H <= 1` 或 `flag9_H <= 3` 用于 `H`，`qc_h2o <= 1` 或 `flag9_h2o <= 3` 用于 `LE`；如果用于说明 rotation 对方法不确定性的放大，则可以保留离群点但必须明确其 QC 状态。 [推断：基于 EC 质量控制逻辑和本轮离群点诊断整理]

## 方法边界

本轮的 `w_mean/sigma_w` 诊断是 rotation 机制诊断，不等同于完整替代原始通量处理链。`w_mean` 和 `sigma_w` 是从 Level0 高频风按四种 rotation 重新计算得到，用于解释 rotation 对平均垂直风、垂直湍流强度和通量投影的影响；它未必完全复刻完整通量流水线中的每一个 QC、despike 和频率修正边界。不过最终合并表已经与既有 flux rows 配对，因此足以支撑当前“rotation 差异从哪里来”的方法敏感性讨论。 [来源: 用户当前对话 2026-06-02] [推断：基于脚本处理范围和合并表用途整理]
