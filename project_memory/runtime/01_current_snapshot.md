# 当前项目快照

## 2026-06-26 最新同步

FL 运行记录当前基础交付已在 `230417_260622` 全量记录上补入 `2025-08-17` 至 `2025-10-01` 的特殊轨道增量：该段按 `5-230 m` 轨道端点重新做完整单程筛选和 EC key-complete 可用性筛选，增量严格单程 `1065` 个，合并后严格单程总数 `2933` 个。`records` 基础文件仍为 `E:\Dataset_Level0\Flares\running_time\records\fl_records_230417_260622.csv`，因为该文件已经包含三份 2025-08 至 2025-10 原始记录；`passes` 目录已更新为增量后的覆盖表、覆盖图和 manifest。 [已核验: project_memory/evidence/verifications/2026-06-26_fl_running_records_20250817_5_230_increment.md]

当前 FL 运行记录覆盖流程固定为：全局默认完整单程轨道范围 `5-240 m`；仅 `2025-08-17` 至 `2025-10-01` 这段位置编码特殊数据在 pass 层使用 `5-230 m`。这只修复完整单程覆盖，不自动说明该段已适用于既有 `PF_8bin`、FL 高频通量或质量守恒结果。 [已核验: E:\Dataset_Level0\Flares\running_time\passes\fl_complete_passes_incremental_manifest.txt] [推断: 基于本次增量与既有 PF_8bin 方法边界整理]

## 2026-06-25 最新同步

FL 运行记录已经按新的固定输出结构完成一次全量重建。运行记录基础文件位于 `E:\Dataset_Level0\Flares\running_time\records\fl_records_230417_260622.csv`，对应来源摘要为 `fl_records_230417_260622_source_summary.csv`；完整单程覆盖交付位于 `E:\Dataset_Level0\Flares\running_time\passes`。本轮统一运行记录为 `6,706,308` 行，严格完整且 EC key-complete 可用单程为 `1868` 个，覆盖图日期范围为 `2023-06-22` 至 `2026-06-04`。 [已核验: project_memory/evidence/verifications/2026-06-25_fl_full_records_rebuild_records_passes_delivery.md]

当前 FL 运行记录覆盖流程的固定边界是：只在完整单程覆盖阶段确认几何完整和 EC key-complete 数据量，不提前做风速范围、诊断码或标量物理范围 QC。`2025-08-17` 至 `2025-10-01` 的 `0-230 m` 修复仍作为历史特例保留，但当前全量默认完整单程轨道口径为 `5-240 m`；如果后续要把特殊轨道段纳入 PF 或质量守恒重算，仍需要建立分时段轨道口径或重建对应 PF 参数。 [已核验: E:\FL_pre\scripts\README_FL_records_pipeline.md] [推断: 基于全量重建结果与既有 PF_8bin 方法边界整理]

## 2026-06-17 最新同步

当前项目已经调整为双主线并行。第一条主线继续围绕复杂地形下长期碳收支问题，重点处理 EC、storage、平流、通风、局地环流和坐标旋转等方法不确定性；第二条主线把晨间 CO2 peak 独立为 `W2_morning_peak_workflow.md`，专门研究长期稳定晨间 CO2 事件的边界层转换、空间传播与局地再分配机制。 [来源: 用户当前对话 2026-06-17] [已核验: project_memory/workstreams/W2_morning_peak_workflow.md]

这次同步不是删除 2026-06-06 的复杂地形通量修正框架，而是把原先降为支撑案例的晨间 peak 重新提升为并行工作流。已有的 8 个事件、`profile switch`、`pre-min`、三站风场、FL 切面和 raw-w 诊断都作为 W2 的前期证据继续保留；后续新增事件气候学、三站事件日机制验证和谷中央上空固定观测，应优先写入 W2。 [来源: 用户当前对话 2026-06-17] [已核验: project_memory/evidence/discussions/2026-06-17_morning_peak_dual_mainline_plan.md] [推断：基于项目记忆分层规则整理]

## 2026-06-15 最新同步

FL PF 方法对比的拟合平面可视化已经补齐到 `E:\FL_pf\00_compare_all_methods`。A1/B1/B2/B3 已有轨道位置 × 横风分量 × `w_plane` 的 tilt 着色示意图；本轮新增 C1、C2、D1、D2 四张图，其中 C1/C2 用于检查 `fw/bw` 方向差异，D1/D2 用于检查 `wind_from` 风向扇区依赖。D 系列按 8 个 `45 deg` 的 `wind_from` 扇区分组，分类基于 PF 输入统计点的平均风向，不是 10 Hz 瞬时风向逐点分类。 [已核验: project_memory/evidence/verifications/2026-06-15_fl_pf_fitted_plane_visualizations.md]

这些图件的角色是解释和诊断不同 PF 旋转策略的几何含义：A/B 更适合看沿轨道空间变化，C 更适合看往返方向偏差，D 更适合看来流风向依赖。当前正式后续高频通量参数仍以 `E:\Dataset_Level1\Flares\PFparameter\PF_8bin_parameters_for_flux.csv` 为主，D 系列和 C2 等高分组图优先作为诊断依据，不直接替代 `PF_8bin` 主参数。 [已核验: project_memory/evidence/verifications/2026-06-15_fl_pf_fitted_plane_visualizations.md] [推断：基于 2026-06-12 `PF_8bin` 决策和本轮 PF 图件用途整理]

## 2026-06-12 最新同步

FL 移动平台的正式 planar fit 参数口径已经固定为 `PF_8bin`，输出目录为 `E:\Dataset_Level1\Flares\PFparameter`。该版本保留原 B2 的 8-bin bin-wise PF 思路，但已把预处理升级为“统一运行记录逐点位置插值 + 实际有符号速度矢量水平风修正”。8 个 bin 全部拟合成功，PF 输入点共 `1852` 个，每个 bin 为 `231-232` 个输入点；倾角范围为 `8.4200-11.8022 deg`，倾角中位数约 `9.5073 deg`。后续高频通量计算应调用 `E:\Dataset_Level1\Flares\PFparameter\PF_8bin_parameters_for_flux.csv`，并沿用同一套逐点运行记录预处理口径。 [已核验: project_memory/evidence/verifications/2026-06-12_fl_pf8bin_record_position_actual_speed.md]

## 当前重点

当前重点是双主线组织。`W1` 继续承担 EC/EA、raw-w、FL PF、rotation 敏感性和复杂地形碳收支解释的技术与方法主线；`W2` 单独承担晨间 CO2 peak 的事件气候学和机制归因主线。 [来源: 用户当前对话 2026-06-17] [已核验: project_memory/workstreams/W1_EA_EC_flux.md] [已核验: project_memory/workstreams/W2_morning_peak_workflow.md]

因此，现有未修正 raw `w`、CO2 次高峰对齐、FL anomaly transport 和 rotation 分支都保留，但需要按双主线分流解释：`EA_flux_results.csv` 仍是 \(w'\) 协方差型基准，storage/rotation/raw-w/FL 继续服务长期碳收支主线；晨间 peak 的发生率、日出相对时序、lead-lag、profile transition、三站事件日和固定上空观测则进入 W2。 [来源: 用户当前对话 2026-06-17] [推断：基于本轮双主线调整和既有结果边界整理]

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

下一最小步分成两条。长期碳收支主线仍应整理一版**复杂地形通量状态框架草表**，把 `EC 可信型`、`储存主导型`、`外来输入型`、`通风带走型`、`横谷再分配型` 和 `方法高不确定型` 写成判别信号、所需数据、推荐修正策略和证据缺口。 [来源: 用户当前对话 2026-06-06] [已核验: project_memory/runtime/05_next_mainline_tasks.md]

晨间 peak 主线的下一最小步，是按当前已检测到的 Level0 数据先做一个自然年，优先以 `2025` 年为主分析年，生成按日覆盖清单、维修断口标记和冻结前事件识别草案；随后再筛查 `20-30` 个三站事件日的气象状态分布。 [来源: 用户当前对话 2026-06-17] [已核验: project_memory/workstreams/W2_morning_peak_workflow.md]

## 2026-06-01 坐标旋转敏感性进展

当前已新增一个独立的固定站点坐标旋转敏感性分支，目录为 `D:\00 博士阶段\博一\05 Project\com_rotation`。该分支暂不纳入 FL 移动平台，而是先对 `CVT` 与 `MT` 两个固定站点、两个公共时段并行比较 `none/dr/pf/spf` 四种坐标处理后的 `F_EC`。 [已核验: project_memory/evidence/verifications/2026-06-01_common_rotation_sensitivity_analysis.md]

本轮已修复 `CVT` 标量通量全为 `NA` 的问题，重跑后主结果为 `D:\00 博士阶段\博一\05 Project\com_rotation\results\rotation_flux_all_common_periods.csv`，初步统计和图件在 `D:\00 博士阶段\博一\05 Project\com_rotation\results\analysis`。当前初步结论是：`Tau` 对旋转方法高度敏感，`co2_flux/H/LE` 也有明显方法敏感性，`u_star` 相对更稳但不是不变；因此后续复杂地形通量计量必须把坐标旋转敏感性作为方法不确定性单独报告。 [已核验: D:\00 博士阶段\博一\05 Project\com_rotation\results\rotation_flux_all_common_periods.csv] [已核验: D:\00 博士阶段\博一\05 Project\com_rotation\results\analysis]

## 2026-06-02 坐标旋转机制诊断进展

当前已进一步补充四种 rotation 下的 `w_mean` 与 `sigma_w` 诊断，并输出风向扇区、时间轴风向箭矢、稳定度分组和日出窗口的优先级分析。新的核心判断是：rotation 对 `w_mean` 的影响最强，double rotation 会把窗口内 `w_mean` 强制压到接近 `0`；planar fit 与 sector-wise planar fit 则通过长期流面约束减小残余 `w_mean`；no rotation 保留了仪器坐标与局地流线倾斜中的平均垂直分量。相比之下，`sigma_w` 的 rotation 敏感性较低，方法间中位相对 range 约为 `8-10%`，相对 double rotation 的相关性通常高于 `0.98`。这说明当前 rotation 差异主要来自平均流线约束和协方差投影，而不是垂直湍流强度被整体重写。 [已核验: project_memory/evidence/verifications/2026-06-02_common_rotation_w_sigma_wind_stability.md] [推断：基于 `w_mean/sigma_w` 诊断和四方法 rotation 定义整理]

下一步围绕 `com_rotation` 的最小分析重点应是风向依赖的不确定性来源。初步结果显示 `MT` 的 `w_mean` rotation 敏感性在约 `090-150°` 及相邻扇区更集中，`CVT` 相对分散但也存在高敏感扇区；这支持后续把 sector-wise planar fit、风向扇区和地形流线解释放在同一张方法不确定性图景中。`H/LE` 的大离群点不能简单删掉，应同时保留 all-data 诊断、QC-screened 图和 robust/缩放图；正式解释 `H/LE` 时应使用变量特异 QC。日出窗口分析暂时受 `MT` metadata 经纬度可能不准确的限制，如果要正式解释 `MT` 日出窗口结果，需要先修正坐标再重跑。 [已核验: project_memory/evidence/verifications/2026-06-02_common_rotation_w_sigma_wind_stability.md] [推断：基于风向、稳定度、日出窗口和离群点诊断整理]

## 2026-06-03 FL moving-transect anomaly transport 进展

当前已在 `D:\00 博士阶段\博一\05 Project\com_mass_balance` 完成 FL moving-transect anomaly transport 第一阶段可行性计算和三张核心结构图。pass-level 主表共有 `193` 个移动单程，轻量高频匹配表共有 `3,381,493` 行；`low_n`、`low_updown` 和 `single_sign` 均为 `0`，说明样本量和正负 `w` 基本满足第一步诊断需要，但 `lambda_extreme` 为 `76`、`air_imbalance` 为 `174`，说明空气量平衡仍是后续解释的主要质量约束。 [已核验: project_memory/evidence/verifications/2026-06-03_fl_moving_transect_anomaly_transport_feasibility.md]

position-time 分箱诊断共 `4751` 行，覆盖 `193` 个 pass 和 `25` 个 `10 m` 位置 bin。`F_anom(x)` profile 稳定性显示，`all_pass` 与 `non_lambda_extreme` 的 median profile 相关系数为 `0.8209436`，而 `all_pass` 与 `non_air_imbalance` 的相关系数为 `0.2275509`。因此当前更适合把 `non_lambda_extreme` 作为稳健性筛选组，`non_air_imbalance` 由于样本少且形态变化大，应作为敏感性或警示组，而不是主结论依据。 [已核验: project_memory/evidence/verifications/2026-06-03_fl_moving_transect_anomaly_transport_feasibility.md] [推断：基于三组 profile 对比和样本量整理]

本轮还修复了 `2025-03-20` 在 `position × time` 热图中看似空白的问题。核验表明该日并非缺数据，而是 `geom_tile()` 自动高度被 `1.5 s` 的最小 pass 间隔压得极薄；脚本已固定 `width = 10 m` 和 `height = 0.35 h` 后重新输出 `F_anom` 与 `w_mean` 热图。当前这些图用于检查切面结构稳定性，仍属于原始坐标、原始单位和 pass mean CO2 异常参考下的诊断结果，不能直接解释为最终生态系统 CO2 通量。 [已核验: project_memory/evidence/verifications/2026-06-03_fl_moving_transect_anomaly_transport_feasibility.md]
## 2026-06-14 最新同步

FL `PF_8bin` 参数已经被带入 `2025-03-20` 至 `2025-03-23` 的高频数据并完成 EC covariance 重算。当前可用结果在 `D:\00 博士阶段\博一\05 Project\com_FLafterPF`，主通量表为 `results\flux_30min\FL_PF8bin_EC_covariance_30min.csv`，共 `378` 行，CO2/H2O 各 `189` 行；`2025-03-20` 在新 QC 下恢复到 CO2/H2O 各 `45` 个窗口。[已核验 D:\00 博士阶段\99 Project\06 EA\project_memory\evidence\verifications\2026-06-14_fl_pf8bin_ec_ea_mechanism_after_pf.md]

当前 FL after-PF 的窗口筛选规则已经明确为 `valid_samples_by_bin`，不再要求固定 30 min 窗口完整覆盖单程 pass 或达到 `coverage_frac >= 0.90`。`coverage_frac` 只作为诊断量；EC covariance 是主通量口径，EA 上下输送拆分用于机制诊断，包括 `F_up_cov_valid`、`F_down_cov_valid`、`c_up-c_down`、`A_up_rate/A_down_rate` 和 `F_up_abs_share` 等指标。[来源: 用户当前对话 2026-06-12 至 2026-06-14] [已核验 D:\00 博士阶段\99 Project\06 EA\project_memory\evidence\verifications\2026-06-14_fl_pf8bin_ec_ea_mechanism_after_pf.md]
