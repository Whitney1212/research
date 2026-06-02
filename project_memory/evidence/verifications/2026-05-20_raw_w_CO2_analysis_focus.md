# 2026-05-20 raw `w` CO2 总输送后续分析重点

## 来源

- 这份记录整理自用户在 2026-05-20 当前对话中提出的 raw `w` CO2 总输送后续分析需求。用户明确希望基于 `D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_raw_w_total_transport` 中已经计算的结果，判断后续应重点看哪些部分、做哪些可视化，以及从气象学、微气象学和气团运动物理角度关注哪些时段、过程和因素。 [来源: 用户当前对话 2026-05-20]
- 本回合直接核验了 raw-w 输出目录、`EA_raw_w_CO2_total_transport_5min.csv`、`EA_raw_w_CO2_total_transport_30min.csv`、`EA_raw_w_CO2_site_window_summary.csv`、`EA_raw_w_CO2_period_summary.csv` 和分量数量级图。 [已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_raw_w_total_transport] [已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_raw_w_total_transport\EA_raw_w_CO2_total_transport_5min.csv] [已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_raw_w_total_transport\EA_raw_w_CO2_total_transport_30min.csv] [已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_raw_w_total_transport\EA_raw_w_CO2_figures\EA_raw_w_CO2_site_window_summary.csv] [已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_raw_w_total_transport\EA_raw_w_CO2_figures\EA_raw_w_CO2_period_summary.csv] [已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_raw_w_total_transport\EA_raw_w_CO2_figures\EA_raw_w_CO2_abs_component_magnitude_log.png]

## 本次新增信息

- 用户已经提出三类初步分析方向：比较不同日和不同站点之间的 `F_total` 差异；在各日和各站点内比较 `F_total` 与 `F_turb` 的差异；结合当日风速、风向等气象条件分析成因。 [来源: 用户当前对话 2026-05-20]
- 本地 raw-w 输出已经包含 5 min、30 min 和合并窗口结果，并且可视化目录中已经有 `total_transport`、`total_vs_mean`、`turbulent_component`、`up_down_terms`、站点窗口汇总、时段汇总和分量数量级图。 [已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_raw_w_total_transport]
- 当前汇总结果显示，raw-w `F_total_raw_window` 几乎完全由 `F_mean_window = mean(w) * mean(c)` 控制；`mean_abs_mean_component` 远大于 `mean_abs_turb_component`，`mean_component_abs_fraction` 在 30 min 站点汇总中约为 `0.9980` 到 `0.9993`。这意味着 raw-w 总输送当前主要反映原始坐标下平均垂直运动携带 CO2，而不是湍流协方差项主导的生态交换强度。 [已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_raw_w_total_transport\EA_raw_w_CO2_figures\EA_raw_w_CO2_site_window_summary.csv] [推断：基于当前 raw-w 分解和未做坐标旋转的边界整理]
- 30 min 时段汇总显示，`09:00-15:00` 白天强混合时段的站点差异尤其明显：`CVT` 的 `mean_total` 约为 `-77.51`，`FL` 约为 `+145.10`，`MT` 约为 `+183.50`。这个反差使白天强混合期成为后续解释 raw-w 总输送空间差异的优先时段。 [已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_raw_w_total_transport\EA_raw_w_CO2_figures\EA_raw_w_CO2_period_summary.csv]

## 后续分析路线

- 后续可视化应以 30 min 作为主分析尺度，用 5 min 捕捉事件细节和转换期突变。这样既能保持与常规通量窗口一致，也能在日出、日落和局地环流转换时保留较高时间分辨率。 [推断：基于当前输出窗口设计和微气象解释需求整理]
- 第一组核心图应比较不同日和不同站点的 `F_total_raw_window`，并同时放入 `F_mean_window` 和单独缩放后的 `F_turb_window`。如果 `F_total` 与 `F_mean` 继续高度重合，解释重点应转向平均垂直风和站点几何/地形环流，而不是只解释湍流 CO2 交换。 [推断：基于当前站点窗口汇总和用户分析目标整理]
- 第二组核心图应围绕上升/下沉空气量不平衡展开，重点看 `w_mean_window`、`A_net`、`A_ratio`、`F_up_raw_window` 和 `F_down_raw_window`。这组变量能判断 raw-w 总输送来自净上升/净下沉空气量差异，还是来自上下气团浓度差异。 [推断：基于当前 raw-w 输出字段和总输送分解公式整理]
- 第三组核心图应检查上升/下沉气团浓度结构，重点看 `c_up_flux_weighted`、`c_down_flux_weighted`、`c_mean_valid` 和 `c_up_flux_weighted - c_down_flux_weighted`。这组变量用于解释上升和下沉气团携带的 CO2 特征，而不是只看净输送大小。 [推断：基于当前 raw-w 输出字段和气团运动解释目标整理]
- 气象归因应优先结合水平风速、风向、原始 `w_mean_window`、辐射或太阳高度、温度梯度或稳定度、`u*`、`sigma_w`、降雨或湿度突变，以及是否存在天气系统转换。风向分组尤其重要，因为山谷地形下 raw-w 平均垂直运动可能随谷风、山风、坡面热力环流和站点位置发生系统差异。 [推断：基于用户提出的气象归因目标和微气象过程整理]

## 重点时段

- `00:00-06:00` 应作为夜间稳定层、冷空气下滑、山谷排水流和近地层 CO2 积累的检查时段，重点看间歇性强下沉或强上升，以及 `c_up_flux_weighted` 与 `c_down_flux_weighted` 的差异。 [推断：基于微气象过程和当前 raw-w 分析目标整理]
- `06:00-09:00` 应作为日出转换期检查，重点看稳定层破坏、混合层启动、坡面热力环流启动，以及 `F_total_raw_window` 或 `w_mean_window` 的符号翻转。 [推断：基于微气象过程和当前 raw-w 分析目标整理]
- `09:00-15:00` 应作为白天强混合和站点差异解释的优先时段，因为当前汇总已经显示该时段 `MT`、`FL` 与 `CVT` 的 raw-w 总输送方向和强度差异很明显。 [已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_raw_w_total_transport\EA_raw_w_CO2_figures\EA_raw_w_CO2_period_summary.csv] [推断：基于当前汇总结果整理]
- `15:00-18:00` 与 `18:00-24:00` 应作为傍晚转换和夜间再稳定化时段检查，重点看白天热力环流何时衰减，以及 raw-w 总输送是否从净上升转为净下沉或相反。 [推断：基于微气象过程和当前 raw-w 分析目标整理]

## 和现有记忆的关系

- 这次更新没有改变 `W1` 的计算结果口径；它把当前主线从“raw-w 输出和可视化已经完成”推进到“围绕平均垂直运动、上下气团结构和气象归因解释 raw-w 总输送”。 [推断：基于既有 `W1` 记忆和 2026-05-20 当前讨论整理]
- 当前仍不采用经验倾斜修正结果，后续分析继续基于未修正 raw `w` CO2 总输送结果。 [来源: 用户当前对话 2026-05-19] [来源: 用户当前对话 2026-05-20]

## 仍待确认

- 后续需要明确哪些气象变量文件可与 raw-w 结果按时间对齐，尤其是水平风速、风向、辐射、温度或稳定度、`u*`、`sigma_w`、降雨和湿度变量。 [推断：基于当前气象归因路线整理]
- 后续需要决定风向扇区和质量控制规则，例如是否按风向分箱、是否剔除低 coverage、`edge_hit` 或 despike 异常窗口，以及是否分别报告 5 min 和 30 min 的一致性。 [推断：基于当前 raw-w 输出字段和质量控制边界整理]
