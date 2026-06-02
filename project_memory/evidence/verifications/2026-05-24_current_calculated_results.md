# 2026-05-24 当前计算结果整理

## 本次记录目的

本次按照用户要求，将当前已经计算出的 raw-w 分解、时间线对齐、机制可视化和初步机制判断集中记录到项目记忆中。该记录不新增计算，只整理当前已核验本地输出和当前对话中的解释边界。 [来源: 用户当前对话 2026-05-24]

## 已完成的主要计算输出

- 时间线对齐输出位于 `D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_timeline_alignment`。全天 30 min 对齐表 `all_day_timeline_alignment_30min.csv` 共有 `576` 行，即四天、三个站点、每天 48 个半小时窗口；事件窗口表 `event_window_timeline_alignment_0400_1200_30min.csv` 共有 `202` 行，其中 `CVT:67`、`FL:68`、`MT:67`。 [已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_timeline_alignment\all_day_alignment_qc_30min.csv] [已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_timeline_alignment\event_alignment_qc_0400_1200_30min.csv]
- 机制可视化输出位于 `D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_timeline_alignment\figures_mechanism`。当前已包含全天机制时间线、全天相位叠加、全天 FL 位置热图、事件窗口相位叠加、相对次高峰 lead-lag 图、机制证据矩阵、CO2 廓线结构图和事件窗口 FL 位置热图。 [已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_timeline_alignment\figures_mechanism]
- raw-w 上升/下沉气团分解的核心输出仍是 `D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_raw_w_up_down_airmass_details\EA_raw_w_up_down_airmass_metrics_all_windows.csv`。其中 `F_air_amount_window` 和 `F_concentration_anomaly_window` 用于把 raw-w 总输送拆为空气量项和浓度异常项。 [已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_raw_w_up_down_airmass_details\EA_raw_w_up_down_airmass_metrics_all_windows.csv]

## F_air 与 F_conc 的计算口径

当前 raw-w 总输送定义为：

\[
F_{\mathrm{total}}=\frac{A^+c^+-A^-c^-}{T}=\overline{wc}
\]

其中 \(A^+=\sum_{w_i>0} w_i\Delta t\)，\(A^-=\sum_{w_i<0}|w_i|\Delta t\)，\(c^+\) 与 \(c^-\) 分别是按上升/下沉通量权重计算的 CO2 气团浓度，\(T\) 是窗口名义长度。 [已核验: D:\00 博士阶段\博一\05 Project\ecpreproc\plot_ea_raw_w_up_down_airmass_details.R]

当前分解为：

\[
F_{\mathrm{air}}=\frac{A^+-A^-}{T}\bar c
\]

\[
F_{\mathrm{conc}}=\frac{A^+(c^+-\bar c)-A^-(c^--\bar c)}{T}
\]

脚本中对应列为 `F_air_amount_window` 和 `F_concentration_anomaly_window`。这个分解满足 \(F_{\mathrm{total}}=F_{\mathrm{air}}+F_{\mathrm{conc}}\)，用于区分 raw 坐标平均垂直运动携带背景 CO2 的空气量项，以及上升/下沉气团 CO2 浓度异常项。 [已核验: D:\00 博士阶段\博一\05 Project\ecpreproc\plot_ea_raw_w_up_down_airmass_details.R] [推断: 基于当前公式分解整理]

## 09:00-15:00 白天强混合期的站点结果

基于 `all_day_timeline_alignment_30min.csv` 的 `09:00-15:00` 统计，三站 raw-w 空气量项和 CO2 浓度异常项分离得很清楚：

- `CVT` 在白天平均 `w_mean_window ≈ -0.177409`，`F_air_amount_window ≈ -77.3509`，`F_concentration_anomaly_window ≈ -0.1616`，标准 EC `F_EC_cov ≈ -0.1616`，`c_up-c_down ≈ -0.6085 ppm`。 [已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_timeline_alignment\all_day_timeline_alignment_30min.csv]
- `FL` 在白天平均 `w_mean_window ≈ +0.337109`，`F_air_amount_window ≈ +145.2784`，`F_concentration_anomaly_window ≈ -0.1755`，标准 EC `F_EC_cov ≈ -0.1755`，`c_up-c_down ≈ -0.4902 ppm`。 [已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_timeline_alignment\all_day_timeline_alignment_30min.csv]
- `MT` 在白天平均 `w_mean_window ≈ +0.426754`，`F_air_amount_window ≈ +183.6699`，`F_concentration_anomaly_window ≈ -0.1682`，标准 EC `F_EC_cov ≈ -0.1682`，`c_up-c_down ≈ -0.5044 ppm`。 [已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_timeline_alignment\all_day_timeline_alignment_30min.csv]

这些数值说明，白天 raw-w `F_total` 的大数值主要由 `F_air_amount_window` 控制，而 `F_concentration_anomaly_window` 与标准 EC `F_EC_cov` 的量级和符号接近，主要反映 CO2 浓度异常结构。 [推断: 基于当前白天统计和公式分解整理]

## 次高峰机制对齐结果

基于 `mechanism_evidence_summary_0400_1200_30min.csv` 的事件计数：

- `pre-min` 在 `CVT/MT` 的 8 个事件中全部发生在 CO2 次高峰之前。 [已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_timeline_alignment\mechanism_evidence_summary_0400_1200_30min.csv]
- `profile switch` 已按跨日出 `05:30-11:00` 判据重跑；重跑后 `CVT/MT` 的 8 个事件全部发生在 CO2 次高峰之前。其中 `2025-03-21 MT` 的廓线结构切换时间为 `2025-03-21 06:00:00`，早于 `09:30` 次高峰 `210 min`。旧严格字段 `switch_time_0630_1100` 仍为空，用于表明它发生在 `06:30` 日出参考线之前。 [已核验: project_memory/evidence/verifications/2026-05-24_cross_sunrise_switch_rerun.md]
- `wind max` 有 4 次在峰前、4 次在峰后，当前不能单独作为稳定触发信号。 [已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_timeline_alignment\mechanism_evidence_summary_0400_1200_30min.csv]
- `raw w max` 与 `F_air max` 均表现为 1 次峰前、3 次近峰、4 次峰后，因此当前不支持把 raw-w 平均垂直运动或空气量项直接写成 CO2 次高峰的稳定峰前触发机制。 [已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_timeline_alignment\mechanism_evidence_summary_0400_1200_30min.csv]
- `F_conc max` 有 2 次峰前、5 次近峰、1 次峰后，说明浓度异常项与 CO2 次高峰相位更接近，但其量级远小于空气量项，因此更适合解释气团浓度结构，而不是 raw-w 总输送的大量级。 [已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_timeline_alignment\mechanism_evidence_summary_0400_1200_30min.csv] [推断: 基于事件计数和分解量级整理]

## 当前机制判断

当前最稳的事件链条是：廓线结构先发生切换，CO2 先下降到前期低点，然后在 `09:30-10:30` 左右回升形成次高峰。重跑后 `CVT/MT` 的 8 个事件都支持“廓线结构切换早于次高峰”这一链条。相比之下，水平风最大值、raw `w` 极值和 `F_air` 极值并没有稳定地早于次高峰，因此目前只能作为伴随背景或空间结构证据，不能单独提升为稳定触发因子。 [推断: 基于重跑后的 `event_key_times_0400_1200_30min.csv`、机制证据矩阵和当前机制框架整理]

当前白天三站都显示 `c_up-c_down < 0`，且 `F_concentration_anomaly_window` 与标准 EC `F_EC_cov` 均为小负值，这支持“白天低 CO2 上升气团与生态吸收/通风结构有关”的方向；但 raw-w 总输送本身仍主要由 `F_air_amount_window` 控制，应继续解释为原始坐标平均垂直运动携带背景 CO2 的诊断量。 [推断: 基于白天统计、F_air/F_conc 分解和当前方法边界整理]
