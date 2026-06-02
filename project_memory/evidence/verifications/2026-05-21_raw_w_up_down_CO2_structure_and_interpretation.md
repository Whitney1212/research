# 2026-05-21 raw-w 上升/下沉气团 CO2 结构与初步解释

## 来源

- 这份记录整理自 2026-05-21 当前窗口中关于 raw `w` 总输送、上升/下沉气团空气量不平衡、CO2 浓度结构和后续验证方向的讨论。 [来源: 用户当前对话 2026-05-21]
- 本次记录同时核验了脚本 `D:\00 博士阶段\博一\05 Project\ecpreproc\plot_ea_raw_w_up_down_airmass_details.R`、输出目录 `D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_raw_w_up_down_airmass_details`、图件目录及主要汇总表。 [已核验: D:\00 博士阶段\博一\05 Project\ecpreproc\plot_ea_raw_w_up_down_airmass_details.R] [已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_raw_w_up_down_airmass_details]

## 计算目标

- 当前 raw-w 分支的目标不是复刻原始 EA 中通过 \(w'\) 去除背景流后的协方差通量，而是先聚焦总输送 \(F_{\mathrm{total}}=\overline{wc}\)。因此该分支保留原始 `w` 的平均垂直运动信息，并按 `w` 的符号把上升与下沉气团分开，再检查总输送由空气量不平衡还是 CO2 浓度结构控制。 [来源: 用户当前对话 2026-05-21] [已核验: D:\00 博士阶段\博一\05 Project\ecpreproc\run_ea_raw_w_total_transport.R]
- 新增上升/下沉气团细分图的目标，是把 raw-w 总输送中已经观察到的“平均流项主导”继续拆开：一部分看 \(A^+\)、\(A^-\)、\(A_{\mathrm{net}}\) 的空气量结构，另一部分看 \(c^+\)、\(c^-\)、\(c^+-c^-\) 的 CO2 浓度结构。 [来源: 用户当前对话 2026-05-21] [已核验: D:\00 博士阶段\博一\05 Project\ecpreproc\plot_ea_raw_w_up_down_airmass_details.R]

## 计算思路

- 在每个 5 min 或 30 min 窗口内，按原始 `w` 的符号分组。定义 \(w^+=\max(w,0)\)、\(w^-=\max(-w,0)\)，则 \(A^+=\sum w^+\Delta t\)、\(A^-=\sum w^-\Delta t\)、\(A_{\mathrm{net}}=A^+-A^-=\sum w\Delta t\)。这里 \(A^+\) 和 \(A^-\) 是窗口内上升/下沉空气量的运动学权重。 [已核验: D:\00 博士阶段\博一\05 Project\ecpreproc\plot_ea_raw_w_up_down_airmass_details.R]
- 上升和下沉气团浓度使用权重平均，而不是普通时间平均：\(c^+=\sum_{w>0} wc\Delta t/A^+\)，\(c^-=\sum_{w<0}|w|c\Delta t/A^-\)。分母是对应气团的空气量权重，因为这里要问的是“参与上升或下沉输送的那部分空气平均携带多少 CO2”，而不是“这些时刻的算术平均 CO2 是多少”。 [来源: 用户当前对话 2026-05-21] [已核验: D:\00 博士阶段\博一\05 Project\ecpreproc\plot_ea_raw_w_up_down_airmass_details.R]
- raw-w 总输送可写成 \(F_{\mathrm{total}}=(A^+c^+-A^-c^-)/T\)，并等价于窗口内 \(\sum wc\Delta t/T\)。如果再加减窗口平均浓度 \(\bar c\)，则可分解为 \(F_{\mathrm{air}}=(A^+-A^-)\bar c/T\) 和 \(F_{\mathrm{conc}}=[A^+(c^+-\bar c)-A^-(c^--\bar c)]/T\)。脚本中对应列为 `F_air_amount_window` 和 `F_concentration_anomaly_window`。 [已核验: D:\00 博士阶段\博一\05 Project\ecpreproc\plot_ea_raw_w_up_down_airmass_details.R]
- 空气量不平衡指数定义为 \(I_A=(A^+-A^-)/(A^++A^-)\)。时间不平衡定义为 \((t^+-t^-)/(t^++t^-)\)，速度不平衡定义为 \((\overline{|w|}_{up}-\overline{|w|}_{down})/(\overline{|w|}_{up}+\overline{|w|}_{down})\)。因此 \(I_A\) 同时受上升/下沉持续时间差异和平均速度强度差异影响。 [来源: 用户当前对话 2026-05-21] [已核验: D:\00 博士阶段\博一\05 Project\ecpreproc\plot_ea_raw_w_up_down_airmass_details.R]

## 结果与储存位置

- 上升/下沉气团细分结果储存在 `D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_raw_w_up_down_airmass_details`。主要表格包括 `EA_raw_w_up_down_airmass_metrics_all_windows.csv`、`EA_raw_w_up_down_airmass_period_summary.csv`、`EA_raw_w_up_down_airmass_date_site_summary.csv`、`EA_raw_w_up_down_airmass_date_site_period_summary.csv` 和 `EA_raw_w_up_down_airmass_site_differences.csv`。 [已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_raw_w_up_down_airmass_details]
- 图件储存在 `D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_raw_w_up_down_airmass_details\figures`。已经生成 5 min 和 30 min 两套图，包括空气量项、空气量不平衡热图、时间/速度不平衡散点、\(I_A\) 与 `c_up-c_down` 散点、CO2 `c_up/c_down/c_mean` 热图、`c_up-c_down` 热图、`F_air_amount` 与 `F_conc_anom` 分解图、以及 \(I_A\) 与 `c_up-c_down` 的时间轨迹图。 [已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_raw_w_up_down_airmass_details\figures]
- 已按用户要求把 `EA_raw_w_air_amount_terms_30min.png` 和 `EA_raw_w_air_imbalance_heatmap_30min.png` 调整为行 = 站点、列 = 日期；把 `EA_raw_w_up_down_airmass_diagnostic_stack_30min.png` 调整为约 4:3 的宽图；并把代表三个观测位置的线色固定为 `CVT = #F8766D`、`FL = #00BA38`、`MT = #619CFF`。 [来源: 用户当前对话 2026-05-21] [已核验: D:\00 博士阶段\博一\05 Project\ecpreproc\plot_ea_raw_w_up_down_airmass_details.R]
- 30 min 结果共核验到 576 个窗口记录。分解闭合检查显示，`F_total_raw_window - F_air_amount_window - F_concentration_anomaly_window` 的最大绝对残差约为 `1.56e-12`，`F_total_raw_window - F_up_raw_window - F_down_raw_window` 的最大绝对残差约为 `1.02e-12`，`A_net/T` 与 `w_mean_window` 的最大差异约为 `3.11e-15`。 [已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_raw_w_up_down_airmass_details\EA_raw_w_up_down_airmass_metrics_all_windows.csv]

## 主要计算结果

- 30 min 白天 `midday_09_15` 三个站点普遍表现为 `c_up-c_down < 0`：`CVT` 约 `-0.609 ppm`，`FL` 约 `-0.490 ppm`，`MT` 约 `-0.504 ppm`。这说明白天上升气团 CO2 偏低、下沉气团 CO2 偏高。 [已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_raw_w_up_down_airmass_details\EA_raw_w_up_down_airmass_period_summary.csv]
- 30 min 夜间 `night_00_06` 的 `c_up-c_down` 多转为小正值：`CVT` 约 `+0.179 ppm`，`FL` 约 `+0.073 ppm`，`MT` 约 `+0.103 ppm`。这与夜间呼吸和近地层 CO2 富集的方向一致。 [已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_raw_w_up_down_airmass_details\EA_raw_w_up_down_airmass_period_summary.csv]
- 30 min 白天 `F_total` 仍几乎完全由空气量项控制。`CVT` 的 `F_total/F_air/F_conc` 约为 `-77.512/-77.351/-0.162`，`FL` 约为 `145.103/145.278/-0.176`，`MT` 约为 `183.502/183.670/-0.168`。因此，raw-w 总输送的大数值主要反映 \(A_{\mathrm{net}}\bar c/T\)，而不是 CO2 浓度异常项本身。 [已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_raw_w_up_down_airmass_details\EA_raw_w_up_down_airmass_metrics_all_windows.csv]

## 初步推测

- 推断：当前 raw-w 总输送更适合作为“原始坐标下平均垂直运动携带背景 CO2”的诊断量。它可以帮助发现站点间净上升/净下沉结构，但不应直接写成生态系统 CO2 交换强度或最终碳汇强度。 [推断：基于本次公式分解和 30 min 数值结果整理]
- 推断：白天三站普遍 `c_up-c_down < 0` 的更合理微气象解释是，地表或植被吸收 CO2 后，近地层或冠层附近形成相对低 CO2 空气；这些低 CO2 空气被上升湍动或局地环流带起，而相对高 CO2 空气在下沉支或补偿运动中回到近地层附近。这个结构支持白天区域内存在 CO2 消耗和混合输送，但单靠 raw-w 图还不能证明 CO2 最终去了哪一条通道。 [来源: 用户当前对话 2026-05-21] [推断：基于 `c_up-c_down` 时段统计和微气象过程整理]
- 推断：区域内 CO2 的可能去向包括被植被/地表生态系统吸收固定、被湍流和坡面/谷地环流向上或向谷外输送、以及上午混合层发展时把夜间积累的 CO2 稀释和通风带走。后续应优先用 H2O、水汽、辐射/PAR、标准 EC \(\overline{w'c'}\)、水平风速和风向来验证；AP/气压数据更适合用于密度换算或压力背景诊断，不是解释 ppm 形式 `c_up/c_down` 结构的第一优先变量。 [来源: 用户当前对话 2026-05-21] [推断：基于本次讨论和当前处理边界整理]

## 后续最小验证方向

- 下一步应先验证白天 `c_up-c_down < 0` 是否与生态吸收过程同步：若 H2O 或水汽结构显示上升气团更湿、且该信号与辐射/PAR 增强和标准 EC CO2 负通量同步，会更支持“植被吸收 + 湍流/局地环流输送低 CO2 空气”的解释。 [来源: 用户当前对话 2026-05-21] [推断：基于当前 CO2 结构结果整理]
- 后续还需要按风向、水平风速、稳定度或 `u*` 分组，检查 `I_A`、`c_up-c_down` 和 `F_conc_anom` 是否只在特定气象背景下出现。如果只在特定风向或强水平风下出现，要继续排查坐标倾斜、流线倾斜和水平风混入风险。 [来源: 用户当前对话 2026-05-21] [推断：基于当前 raw-w 解释边界整理]
