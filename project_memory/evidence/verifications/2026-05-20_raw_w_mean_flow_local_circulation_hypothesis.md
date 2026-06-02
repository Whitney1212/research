# 2026-05-20 raw `w` 平均流主导与局地环流假说

## 来源

- 这份记录整理自 2026-05-20 当前对话中关于 `F_mean` 主导 `F_total`、站点地形背景、局地环流物理图像和下一步计算路线的讨论。用户明确说明：`MT` 是谷缘高地，`CVT` 是谷底，`FL` 在谷地上方沿切面均匀运动。 [来源: 用户当前对话 2026-05-20]
- 本回合此前已经生成并核验 raw-w 分解相关输出，包括 `F_total`/`F_mean`/`F_turb` 分解图、湍流占比热图和分解汇总表。 [已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_raw_w_total_transport\EA_raw_w_CO2_figures\EA_raw_w_CO2_decomposition_components_30min.png] [已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_raw_w_total_transport\EA_raw_w_CO2_figures\EA_raw_w_CO2_turbulent_share_heatmap_30min.png] [已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_raw_w_total_transport\EA_raw_w_CO2_figures\EA_raw_w_CO2_decomposition_date_site_period_summary.csv]

## 本次新增信息

- 当前 raw-w 总输送的核心解释是：`F_total = F_mean + F_turb`，而 `F_mean = mean(w) * mean(CO2)` 几乎控制了 `F_total`。这意味着当前 raw-w 总输送主要记录的是原始坐标下平均垂直运动携带背景 CO2，而不是常规 EC 口径下的湍流交换强度。 [已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_raw_w_total_transport\EA_raw_w_CO2_figures\EA_raw_w_CO2_decomposition_date_site_period_summary.csv] [推断：基于当前分解结果和公式解释整理]
- 这个现象与常规 EC 结论差异明显但不必然矛盾。常规 EC 主要解释 \(\overline{w'c'}\)，而 raw-w 总输送保留了 \(\bar w\bar c\)。因为背景 CO2 浓度很大，只要 raw \(\bar w\) 有小的系统偏正或偏负，`F_mean` 就会远大于 `F_turb`。 [推断：基于公式 \(F_{total}=\bar w\bar c+\overline{w'c'}\) 和当前分解结果整理]
- 在当前地形背景下，白天 `MT` 和 `FL` 多为强正、`CVT` 多为负的格局，符合一个可能的局地环流物理图像：谷缘高地和谷地上方切面可能处在热力环流或上坡流的上升支，谷底可能处在补偿下沉、谷底通道流或局地流线下沉区。 [来源: 用户当前对话 2026-05-20] [推断：基于站点地形位置和 raw-w 时段格局整理]
- 这个局地环流解释目前仍是工作假说，不是最终归因。raw `w` 尚未做坐标旋转，仍可能混入仪器坐标倾斜、流线倾斜、塔架安装角度、地形导流和移动平台运动影响。 [来源: 用户当前对话 2026-05-20] [推断：基于当前处理边界和未采用经验修正分支整理]

## 下一步关键判断

- 第一，先围绕 `w_mean_window` 复现 `F_total` 的主要图组，包括日变化、日期-站点-时段热图和站点差值图。因为 `F_mean = mean(w) * mean(CO2)`，而 `mean(CO2)` 相对稳定，`w_mean_window` 应是当前 `F_total` 空间差异的直接主控变量。 [推断：基于当前分解公式和 raw-w 输出字段整理]
- 第二，做风向和水平风诊断。应计算 `w_mean_window` 与 `u_mean`、`v_mean`、水平风速和风向的关系，并按风向扇区统计 `w_mean_window`、`F_total_raw_window` 和 `F_mean_window`。如果 `w_mean_window` 随特定风向或水平风分量稳定变化，坐标倾斜或流线倾斜风险较高。 [推断：基于当前局地环流假说和坐标倾斜风险整理]
- 第三，做一个诊断性回归或对照：\(\bar w = a + b\bar u + c\bar v + \epsilon\)。如果扣除由水平风解释的部分后，残差 \(\epsilon\) 仍保留白天 `MT/FL` 正、`CVT` 负的结构，则更支持真实局地环流；如果结构大幅消失，则说明 raw `w` 中的 apparent vertical motion 很可能主要来自坐标或流线倾斜。 [推断：基于当前方法讨论整理]
- 第四，FL 不应只作为一个整体站点汇总。因为 FL 在谷地上方沿切面均匀运动，后续应按切面位置分箱，构建 `w_mean(x,t)`、`F_total(x,t)`、`c_mean(x,t)` 或异常浓度的切面-时间图。若切面上出现稳定的一侧上升、另一侧下沉，或谷缘上方上升、谷底上方下沉，将更直接支持横向局地环流结构。 [来源: 用户当前对话 2026-05-20] [推断：基于 FL 观测方式和局地环流验证目标整理]
- 第五，为了避免背景浓度支配解释，可增加一个异常平均输送诊断：\(F_{mean,anom}=\bar w(\bar c-c_{ref})\)。这个量不能替代 raw 总输送，但可用于判断平均垂直运动搬运的是 CO2 富集空气还是贫 CO2 空气。 [推断：基于当前 `F_mean` 被背景 CO2 控制的解释整理]

## 需要补充或确认的数据

- 最高优先级数据包括：每个窗口的 `u_mean`、`v_mean`、水平风速、风向，FL 的位置、移动轨迹和时间同步信息，三站的坐标、海拔、相对谷地切面位置，以及仪器安装高度、朝向和可能的 pitch/roll/tilt 信息。 [推断：基于当前下一步诊断路线整理]
- 第二优先级数据包括：短波或净辐射、气温、湿度、气压、降雨、稳定度指标或可计算稳定度的数据、`u*`、`sigma_w` 和湍流强度。它们用于判断 `w_mean` 与日出、白天加热、傍晚转换和夜间稳定层之间的相位关系。 [推断：基于当前气象归因需求整理]
- 第三优先级数据包括：地形剖面、坡向、坡度、谷轴方向，以及 FL 平台姿态和运动修正信息。它们用于把站点差异和切面运动解释到具体地形环流结构中。 [推断：基于当前地形环流假说整理]

## 和现有记忆的关系

- 这次更新把 `W1` 的解释重点从“raw-w 总输送由平均流主导”推进到“判断平均流主导是否对应真实局地环流结构”。它不改变当前主线仍基于未修正 raw `w` 结果，也不恢复经验倾斜修正分支。 [来源: 用户当前对话 2026-05-20] [推断：基于既有 `W1` 状态整理]
