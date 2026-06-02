# 当前项目快照

## 当前重点

当前重点仍是 `W1`。主线现在回到未修正 raw `w` CO2 总输送：旧 `EA_flux_results.csv` 保留为 \(w'\) 协方差型结果，新 raw-w 分支保留 5 min 与 30 min 两个窗口；经验倾斜修正分支已经尝试，但暂不作为当前分析依据。 [已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_flux_results.csv] [已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_raw_w_total_transport\EA_raw_w_CO2_total_transport_all_windows.csv] [来源: 用户当前对话 2026-05-19]

当前最新阶段已经从“生成对齐图”推进到“基于对齐结果做机制排序”。廓线结构切换判据已从严格 `06:30-11:00` 改为跨日出 `05:30-11:00` 首次负转非负；机制可视化也已从 `F_air/F_conc` 通量分解主线改为气象过程主线。新的主图保留 CO2 廓线均值、廓线差值、风速、`u/v`、声学坐标风向、raw `w_mean`、标准 EC `F_EC_cov`、`sigma_w`、`ustar` 和 `H`。当前最稳链条仍是 `profile switch` 与 `pre-min` 均为 `8/8 before_peak`；气象极值更多表现为背景或伴随过程，尚不能单独写成稳定峰前触发因子。 [已核验: project_memory/evidence/verifications/2026-05-24_cross_sunrise_switch_rerun.md] [已核验: project_memory/evidence/verifications/2026-05-25_meteorology_focused_mechanism_visualization.md] [推断：基于重跑后的事件关键时间表和机制证据矩阵整理]

## 关键前置提醒

原始 `EA_flux_results.csv` 与 raw-w 主线结果仍应按未旋转、未做 WPL、未做频率修正和未做密度换算的口径解释。旧 `EA_flux_results.csv` 是基于仪器坐标 \(w'\) 的 30 min 湍流协方差型结果；新增 raw-w 输出对应原始 `w` 下的 CO2 总输送口径，但它同样仍是原始坐标和原始单位下的结果。另一个独立分支 `D:\00 博士阶段\博一\05 Project\com_rotation` 已经开始系统比较 `none/dr/pf/spf` 四种坐标处理，它用于方法敏感性和复杂地形计量不确定性评估，不能直接覆盖旧 raw-w 主线口径。 [来源: 用户当前对话 2026-05-18] [已核验: D:\00 博士阶段\博一\05 Project\ecpreproc\run_ea_preprocess.R] [已核验: D:\00 博士阶段\博一\05 Project\ecpreproc\run_ea_raw_w_total_transport.R] [已核验: project_memory/evidence/verifications/2026-06-02_common_rotation_w_sigma_wind_stability.md]

## 最近进展

最近已经完成逐日净通量图、EA 上升/下沉通量贡献图、CO2 上升/下沉气团浓度异常图，并新增 raw `w` CO2 总输送脚本和可视化脚本。经验倾斜修正分支也已生成，但由于修正量大且依据不足，当前暂不采用，后续分析仍围绕未修正 raw-w 输出展开。 [已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_daily_figures] [已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_raw_w_total_transport\EA_raw_w_CO2_total_transport_all_windows.csv] [来源: 用户当前对话 2026-05-19]

2026-05-20 的新增重点是：raw-w 后续解释应从“结果已经生成”转为“围绕平均垂直运动、上下气团结构和气象归因分析”。当前应优先使用 30 min 结果描述主日变化和站点差异，用 5 min 结果检查日出、日落和短时事件细节。 [来源: 用户当前对话 2026-05-20] [已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_raw_w_total_transport\EA_raw_w_CO2_total_transport_30min.csv] [已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_raw_w_total_transport\EA_raw_w_CO2_total_transport_5min.csv]

最新解释重点是：`F_mean` 已被认为是 `F_total` 的主项，因此当前 raw-w 总输送更像原始坐标下平均垂直运动携带背景 CO2 的诊断量。结合用户确认的站点背景，`MT` 为谷缘高地、`CVT` 为谷底、`FL` 为谷地上方沿切面运动，这一格局符合一个可能的局地环流结构，但仍需排除坐标倾斜、流线倾斜和移动平台运动影响。 [来源: 用户当前对话 2026-05-20] [推断：基于 raw-w 分解结果和站点地形背景整理]

已新增 raw-w 上升/下沉气团空气量细分输出，目录为 `D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_raw_w_up_down_airmass_details`。这一步把 `A_up/T`、`-A_down/T`、`A_net/T`、有界不平衡指数 \(I_A=(A^+-A^-)/(A^++A^-)\)、上升/下沉持续时间不平衡、上升/下沉平均速度不平衡、`c_up-c_down` 与站点差异单独整理出来，目的是把 raw-w 总输送中的“平均垂直运动主导”进一步拆成空气量结构和气团浓度结构。 [已核验: D:\00 博士阶段\博一\05 Project\ecpreproc\plot_ea_raw_w_up_down_airmass_details.R] [已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_raw_w_up_down_airmass_details\EA_raw_w_up_down_airmass_metrics_all_windows.csv]

用户进一步确认了 FL 的位置几何：`0 m` 为 `MT` 所在轨道起点，轨道中点穿过 `CVT` 正上方，`245 m` 为终点；FL 时间与 EC 高频时间同步且同一时区，平台实时调平，因此当前不把 `pitch/roll/yaw` 作为首要修正项。旧项目脚本中可核验到端点坐标和 south-to-north 方位角。 [来源: 用户当前对话 2026-05-20] [已核验: D:\00 博士阶段\博一\05 Project\com_260401\com_0401\diagnostics_0320_0323\w4_mobile_circulation\run_notes.txt]

最新已经新增 raw `w` 局地环流诊断输出。30 min 全日 `w_mean ~ u_mean + v_mean` 回归显示 `FL` 和 `MT` 的 raw `w_mean` 与声学坐标水平风关系很强，`R²` 分别约为 `0.890` 和 `0.750`，`CVT` 约为 `0.296`。扣除线性 `u/v` 解释后，白天 `09:00-15:00` 仍保留 `CVT` 负、`FL/MT` 正的弱化结构。FL 位置分箱显示白天轨道两端上升强、中部上升弱，但 CVT 正上方中段没有转为负 `w`。 [已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_raw_w_local_circulation_diagnostics\w_mean_uv_regression_coefficients.csv] [已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_raw_w_local_circulation_diagnostics\FL_position_binned_raw_w_30min.csv]

已补入 `thread 019e261a-fe4c-7602-b59e-5d4f48e5ddbf` 的三站水平风结果。该 thread 已经完成 `CVT/MT/FL` 高频风 QC、north_offset 坐标统一、`FL` 小车速度矢量修正，以及 `1min/5min/30min` 风向和水平风速分面图。这个结果应作为解释 raw-w 局地环流候选信号的风场背景：它能帮助判断 `MT/FL` 与 `CVT` 是否同步转向或同步增风，但不能单独作为正式平流通量结论。 [来源: thread 019e261a-fe4c-7602-b59e-5d4f48e5ddbf] [已核验: D:\00 博士阶段\博一\05 Project\com_3sites_horizontal\OUTPUT\north_offset_coordinates\validation_summary_30min.csv] [已核验: D:\00 博士阶段\博一\05 Project\com_3sites_horizontal\OUTPUT\fl_motion_correction\fl_motion_correction_summary.csv] [已核验: D:\00 博士阶段\博一\05 Project\com_3sites_horizontal\OUTPUT\wind_direction_faceted_by_window\faceted_wind_direction_figure_manifest.csv] [已核验: D:\00 博士阶段\博一\05 Project\com_3sites_horizontal\OUTPUT\wind_speed_faceted_by_window\faceted_wind_speed_figure_manifest.csv]

2026-05-21 的新增重点是：raw-w 上升/下沉气团分析已经从“空气量是否不平衡”推进到“CO2 浓度结构如何解释”。当前采用的公式口径为 \(F_{\mathrm{total}}=\overline{wc}\)，并分解为 \(F_{\mathrm{air}}=(A^+-A^-)\bar c/T\) 和 \(F_{\mathrm{conc}}=[A^+(c^+-\bar c)-A^-(c^--\bar c)]/T\)。30 min 白天 `midday_09_15` 三站均有 `c_up-c_down < 0`，但 `F_total` 的大数值仍主要来自 `F_air_amount`，因此浓度结构和总输送量级需要分开解释。 [来源: 用户当前对话 2026-05-21] [已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_raw_w_up_down_airmass_details\EA_raw_w_up_down_airmass_period_summary.csv] [已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_raw_w_up_down_airmass_details\EA_raw_w_up_down_airmass_metrics_all_windows.csv]

当前初步解释是：白天上升气团 CO2 偏低、下沉气团 CO2 偏高，更支持地表或植被吸收 CO2 后，低 CO2 空气被湍流或局地环流抬升/通风，而相对高 CO2 空气通过下沉或补偿运动返回近地层的图像。这仍是工作假说；当前验证优先使用标准 EC \(\overline{w'c'}\)、水平风速和风向、`u/v`、`sigma_w/ustar/H` 与 CO2 廓线结构，不把 H2O 作为主线分析项。AP/气压更适合作为密度换算或压力背景诊断的辅助变量。 [来源: 用户当前对话 2026-05-25] [推断：基于当前 CO2 结构结果和微气象过程整理]

最新白天 `09:00-15:00` 统计进一步确认：`CVT` 的 `F_air_amount_window` 为负，`FL/MT` 为正，反映 raw 坐标平均垂直运动或空气量项的站点差异；但三站 `F_concentration_anomaly_window` 与标准 EC `F_EC_cov` 都是小负值，且 `c_up-c_down < 0`。因此当前必须继续把 raw-w 空气量结构与 CO2 浓度异常/湍流交换结构分开解释。 [已核验: project_memory/evidence/verifications/2026-05-24_current_calculated_results.md] [推断：基于当前白天统计和分解公式整理]

2026-05-26 的新增收束是：当前主线聚焦两个现象。第一，09:00 左右 CO2 次高峰基本不再优先按湍流主导解释，而是转向检查日出后固定时段是否有随风向转变输入的高 CO2 气团，并区分“带来后被本地吸收/稀释”和“带来后继续被输送离开”。第二，研究区 raw-w 总输送继续按垂直风或垂直空气量主导理解，`CVT` 日出后明显向下输送可能对应谷底补偿下沉，两侧坡面受热上坡风则可能构成局地次级环流候选图像。`FL` 风向几乎与主塔一致这一点暗示风场可能受更大尺度或跨站一致环流影响。 [来源: 用户当前对话 2026-05-26] [已核验: project_memory/evidence/verifications/2026-05-26_two_main_mechanism_directions.md]

## 下一最小步

下一最小步应围绕 2026-05-26 收束出的两个方向做归因检验：一方面按风向扇区和事件 lead-lag 检查 CO2 次高峰是否由外来高 CO2 气团输入，并比较峰后下降更像生态吸收、垂直混合稀释还是水平通风带走；另一方面按站点和 FL 位置分箱检查日出后 `CVT` 负 `w_mean` 与 `MT/FL` 正 `w_mean` 是否在扣除水平风或按风向分组后仍稳定存在。 [来源: 用户当前对话 2026-05-26] [推断：基于当前归因问题整理]

时间线对齐的第一版已经完成，并且机制图已经改为气象过程主线。当前已新增全天 30 min 对齐表和 `04:00-12:00` 事件窗口对齐表；事件窗口固定 `06:30` 为日出参考线，不做 H2O 分析，也不把 FL 缺失 AP 作为待补缺口。下一最小步应从 `event_key_times_0400_1200_30min.csv`、机制证据矩阵和事件窗口图出发，逐日比较风场增强或转向、`u/v`、湍流/热通量背景、廓线结构切换、CO2 前期低点、次高峰和 FL 切面形态之间的先后顺序。 [来源: 用户当前对话 2026-05-25] [已核验: project_memory/evidence/verifications/2026-05-25_meteorology_focused_mechanism_visualization.md]

后续主线任务已单独记录在 `project_memory/runtime/05_next_mainline_tasks.md`。本轮整理明确：FL 的核心价值是切面空间形态证据，不应直接作为第三个平均通量点解释；`c_up-c_down` 与 `F_conc_anom` 用于解释气团浓度结构，raw `F_total` 仍主要作为原始坐标下平均垂直输送诊断量；未旋转 raw `w` 仍为当前主线口径，经验倾斜修正和 `u/v` 残差只作为敏感性检验。 [来源: 用户当前对话 2026-05-21] [已核验: project_memory/runtime/05_next_mainline_tasks.md]

## 2026-06-01 坐标旋转敏感性进展

当前已新增一个独立的固定站点坐标旋转敏感性分支，目录为 `D:\00 博士阶段\博一\05 Project\com_rotation`。该分支暂不纳入 FL 移动平台，而是先对 `CVT` 与 `MT` 两个固定站点、两个公共时段并行比较 `none/dr/pf/spf` 四种坐标处理后的 `F_EC`。 [已核验: project_memory/evidence/verifications/2026-06-01_common_rotation_sensitivity_analysis.md]

本轮已修复 `CVT` 标量通量全为 `NA` 的问题，重跑后主结果为 `D:\00 博士阶段\博一\05 Project\com_rotation\results\rotation_flux_all_common_periods.csv`，初步统计和图件在 `D:\00 博士阶段\博一\05 Project\com_rotation\results\analysis`。当前初步结论是：`Tau` 对旋转方法高度敏感，`co2_flux/H/LE` 也有明显方法敏感性，`u_star` 相对更稳但不是不变；因此后续复杂地形通量计量必须把坐标旋转敏感性作为方法不确定性单独报告。 [已核验: D:\00 博士阶段\博一\05 Project\com_rotation\results\rotation_flux_all_common_periods.csv] [已核验: D:\00 博士阶段\博一\05 Project\com_rotation\results\analysis]

## 2026-06-02 坐标旋转机制诊断进展

当前已进一步补充四种 rotation 下的 `w_mean` 与 `sigma_w` 诊断，并输出风向扇区、时间轴风向箭矢、稳定度分组和日出窗口的优先级分析。新的核心判断是：rotation 对 `w_mean` 的影响最强，double rotation 会把窗口内 `w_mean` 强制压到接近 `0`；planar fit 与 sector-wise planar fit 则通过长期流面约束减小残余 `w_mean`；no rotation 保留了仪器坐标与局地流线倾斜中的平均垂直分量。相比之下，`sigma_w` 的 rotation 敏感性较低，方法间中位相对 range 约为 `8-10%`，相对 double rotation 的相关性通常高于 `0.98`。这说明当前 rotation 差异主要来自平均流线约束和协方差投影，而不是垂直湍流强度被整体重写。 [已核验: project_memory/evidence/verifications/2026-06-02_common_rotation_w_sigma_wind_stability.md] [推断：基于 `w_mean/sigma_w` 诊断和四方法 rotation 定义整理]

下一步围绕 `com_rotation` 的最小分析重点应是风向依赖的不确定性来源。初步结果显示 `MT` 的 `w_mean` rotation 敏感性在约 `090-150°` 及相邻扇区更集中，`CVT` 相对分散但也存在高敏感扇区；这支持后续把 sector-wise planar fit、风向扇区和地形流线解释放在同一张方法不确定性图景中。`H/LE` 的大离群点不能简单删掉，应同时保留 all-data 诊断、QC-screened 图和 robust/缩放图；正式解释 `H/LE` 时应使用变量特异 QC。日出窗口分析暂时受 `MT` metadata 经纬度可能不准确的限制，如果要正式解释 `MT` 日出窗口结果，需要先修正坐标再重跑。 [已核验: project_memory/evidence/verifications/2026-06-02_common_rotation_w_sigma_wind_stability.md] [推断：基于风向、稳定度、日出窗口和离群点诊断整理]
