# CO2 事件竞争假设与计算完成状态整理

记录日期：2026-06-04  
记录目的：把当前项目中关于 CO2 次高峰、峰后下降、FL 移动切面、raw-w、EA/EC、三站水平风和廓线证据的竞争假设整理成可执行的下一步分析表。

---

## 1. 当前解释边界

本记录只整理“已经完成或部分完成计算、可以进入整合分析”的证据，以及“尚未完成、不能直接下结论”的缺口。

当前必须保持三类量的边界：

1. **\(w'\) 协方差型 EA/EC 通量**：用于常规湍流交换参照。
2. **raw \(wc\) 总输送**：用于当前坐标下平均垂直运动或空气量结构诊断。
3. **\(w(c-c_{ref})\)、`F_conc_anom` 或 FL anomaly transport**：用于 CO2 异常输送、上升/下沉气团结构和移动切面空间形态诊断。

FL 不作为独立“第三平均通量站点”，而作为移动切面空间结构证据。其主作用是判断固定塔 CO2 事件在空间上更像整区同步、单侧输入、谷底增强，还是横谷向再分配。

---

## 2. 竞争假设状态表

| 编号 | 竞争假设 | 机制含义 | 当前计算状态 | 已完成或部分完成的计算 | 当前能否整合分析 | 尚未完成的关键缺口 |
|---|---|---|---|---|---|---|
| H1 | 夜间储存层释放 + 日出后廓线/边界层转换 | 夜间 CO2 在谷底或冠层内积累，日出后廓线结构切换、混合增强或储存层再分配，形成 CO2 次高峰。 | 部分完成 | 已完成事件时间线和机制证据矩阵。当前最稳链条是 `profile switch` 和 `pre-min` 均稳定早于 CO2 次高峰，记录为 `8/8 before_peak`。AP/profile 系统层位也已确认可作为局地柱 storage tendency 的优先入口。 | 可以整合为“基础候选机制”。 | 尚未完成定量 storage flux 或局地柱 CO2 storage tendency 的逐事件计算；还不能把“廓线切换”直接等同为储存释放通量。 |
| H2 | 风向转变或增风输入外来高 CO2 气团 | 次高峰由外部或上游高 CO2 气团输入触发，而非本地储存单独造成。 | 部分完成 | 三站水平风已完成 QC、north_offset 坐标统一、FL 小车速度矢量修正，并生成 1 min、5 min、30 min 风向和风速结果。事件对齐图已包含风速、u/v、风向、raw `w_mean`、EC、湍流和热通量变量。 | 可以初步整合，但只能作为风场背景和候选输入证据。 | 尚未完成“峰前输入—峰值—峰后去向”的风向扇区标签；尚未逐事件判断风向转变是否稳定早于 CO2 回升；也未完成三站 CO2 传播顺序或同步性标签。 |
| H3 | 横谷向局地次级环流再分配 | 坡面受热、谷底补偿下沉或横谷向环流把 CO2 在谷缘、谷底和 FL 切面之间重新分配。 | 部分完成 | raw-w 诊断已显示白天 CVT 空气量项偏负、FL/MT 偏正。FL pass-level anomaly transport 与位置分箱已完成：193 个 pass，position-time 诊断 4751 行，25 个 10 m 位置 bin。`non_lambda_extreme` 与 `all_pass` 的 median profile 相关系数较高，可作为较稳健筛选组。 | 可以整合为空间形态证据，但不能直接定性为闭合环流。 | 尚未完成事件窗口内 FL 形态分类，例如 `sync_all_track`、`two_ends_strong_middle_weak`、`cvt_above_enhanced`、`dipole_structure`；尚未按风向扇区、移动方向、u/v 残差检验空间形态稳定性。 |
| H4 | 次高峰后下降由生态吸收 + 垂直混合稀释主导 | 峰后 CO2 下降主要来自负 EC 通量、低 CO2 上升气团、湍流混合和混合层发展。 | 部分完成 | EA/EC 和 CO2 气团结构已完成。白天 09:00-15:00 全站平均表现为 `c_up < c_mean < c_down`，`c_up-c_down` 为负，净 CO2 通量为负。30 min 白天三站 `c_up-c_down < 0`，标准 EC 和 `F_conc_anom` 均为小负值。 | 可以整合为“峰后下降候选机制”。 | 尚未逐事件建立“峰后 EC 负通量增强、`c_up-c_down` 增强、`sigma_w/ustar/H` 增强、CO2 下降速率”之间的对应表。 |
| H5 | 次高峰后下降由通风或水平平流带走主导 | 高 CO2 气团形成后被稳定风向或增风带离控制体，三站 CO2 同步下降。 | 部分完成偏少 | 风速、风向、三站水平风和事件对齐基础已完成。项目下一步任务已明确要求增加风向扇区和峰后去向检验。 | 目前只能作为待检验强候选。 | 尚未完成峰后三站同步下降判据、稳定风向判据、增风判据和 FL 全轨道异常减弱判据；尚不能与 H4 定量区分。 |
| H6 | 湍流或热力过程直接触发次高峰 | 次高峰由湍流强度、u*、sigma_w、H 或 EC 交换增强直接触发。 | 已计算，但当前证据偏弱 | 机制证据矩阵已重跑。结果显示 wind max、raw w max、sigma_w max、u* max、H abs max 和 EC flux max 多不稳定地领先次高峰，其中不少变量更接近峰后或近峰。 | 可以整合为“背景或伴随过程”，不宜作为当前主控机制。 | 不需要优先扩展同类计算；若保留，应改为检验其是否调节峰后下降或混合稀释，而不是解释峰前触发。 |
| H7 | raw-w 垂直结构主要来自坐标/流线投影，而非真实环流 | CVT 负、MT/FL 正的 raw `w_mean` 结构可能来自 sonic 坐标、地形流线倾斜、水平风投影或移动平台影响。 | 部分完成，且应作为方法约束 | 固定站点四方法 rotation 敏感性已完成，包含 `none/dr/pf/spf`。结果显示 rotation 对 `w_mean` 影响最大，double rotation 会把窗口内 `w_mean` 压到接近 0，而 `sigma_w` 相对稳定。 | 可以整合为所有 raw-w 与局地环流解释的敏感性约束。 | 尚未把 rotation 敏感性、`w_mean ~ u_mean + v_mean` 残差、风向扇区和 FL 位置形态统一到同一个事件级判据表。 |
| H8 | 组合机制 | 实际事件由夜间储存、晨间廓线切换、平流/环流再分配、峰后吸收/稀释或通风共同造成。 | 尚未完成最终整合 | 前置计算大多已经具备：EA/EC、raw-w、CO2 气团结构、事件对齐、三站水平风、rotation 敏感性、FL anomaly transport 均已有阶段性结果。 | 尚不能直接给最终排序，但已经具备整合分析基础。 | 需要建立逐事件机制打分表：时间顺序、空间形态、风向扇区、固定塔相位、FL 形态、EC/气团结构、方法风险各给标签。 |

---

## 3. 按当前可推进程度分组

| 类别 | 假设 | 当前处理方式 |
|---|---|---|
| 已有较完整计算，可立即纳入整合分析 | H6 湍流/热力直接触发；H7 坐标/流线投影方法风险 | H6 当前应降级为背景或伴随过程；H7 应作为 raw-w 和 FL 解释的必要敏感性约束。 |
| 已有部分计算，可进入事件级整合 | H1 储存释放 + 廓线转换；H2 外来高 CO2 输入；H3 横谷向局地环流；H4 峰后吸收/混合稀释 | 需要把已有表格和图件转写为逐事件标签，不一定需要先新增大量计算。 |
| 目前仍缺关键判据，不能直接判断 | H5 峰后通风/平流带走；H8 组合机制最终排序 | H5 需要补峰后去向判据；H8 需要等 H1-H5 的逐事件标签完成后再综合。 |

---

## 4. 当前最合理的整合顺序

| 顺序 | 整合对象 | 目的 | 最小输出 |
|---:|---|---|---|
| 1 | H1 vs H2：廓线切换/储存转换 与 外来高 CO2 输入 | 判断 CO2 次高峰“从哪里来”。 | 每个事件标记：`profile_switch_before_peak`、`pre_min_before_peak`、`wind_shift_before_rise`、`high_CO2_input_signal`。 |
| 2 | H4 vs H5：峰后吸收/混合稀释 与 通风/平流带走 | 判断次高峰“之后去了哪里”。 | 每个事件标记：`EC_more_negative_after_peak`、`c_up_minus_c_down_more_negative`、`wind_speed_increase_after_peak`、`three_station_sync_decline`。 |
| 3 | H3 + H7：横谷向局地环流 与 坐标/流线投影风险 | 判断 raw-w 和 FL 空间形态能否升级为物理机制。 | 每个事件标记：`FL_shape_class`、`wind_sector_dependence`、`moving_direction_dependence`、`uv_projection_risk`、`rotation_sensitivity_risk`。 |
| 4 | H8：组合机制排序 | 给每个事件主控、参与、背景和方法风险标签。 | `main_mechanism`、`secondary_mechanism`、`background_process`、`method_risk`。 |

---

## 5. 建议建立的逐事件机制判据矩阵

建议新建一个事件级表，例如：

`next_step/co2_event_mechanism_scoring_template.csv`

字段建议：

| 字段 | 含义 |
|---|---|
| `event_id` | 事件编号，例如 `2025-03-21_CVT_secondary_peak` |
| `date` | 日期 |
| `site_focus` | 重点站点，例如 CVT、MT、FL 或 all |
| `peak_time` | CO2 次高峰时刻 |
| `pre_min_time` | 次峰前 CO2 低点时刻 |
| `profile_switch_time` | 廓线结构切换时刻 |
| `profile_switch_before_peak` | TRUE/FALSE |
| `pre_min_before_peak` | TRUE/FALSE |
| `wind_shift_before_rise` | TRUE/FALSE/unclear |
| `wind_speed_increase_after_peak` | TRUE/FALSE/unclear |
| `three_station_sync_rise` | TRUE/FALSE/unclear |
| `three_station_sync_decline` | TRUE/FALSE/unclear |
| `EC_more_negative_after_peak` | TRUE/FALSE/unclear |
| `c_up_minus_c_down_more_negative` | TRUE/FALSE/unclear |
| `FL_shape_class` | `sync_all_track`、`two_ends_strong_middle_weak`、`cvt_above_enhanced`、`dipole_structure`、`unclear` 等 |
| `FL_quality_group` | `all_pass`、`non_lambda_extreme`、`non_air_imbalance` 等 |
| `wind_sector_dependence` | TRUE/FALSE/unclear |
| `moving_direction_dependence` | TRUE/FALSE/unclear |
| `uv_projection_risk` | low/medium/high |
| `rotation_sensitivity_risk` | low/medium/high |
| `support_H1_storage_transition` | 0-3 分 |
| `support_H2_external_input` | 0-3 分 |
| `support_H3_local_secondary_circulation` | 0-3 分 |
| `support_H4_ecosystem_mixing_decline` | 0-3 分 |
| `support_H5_ventilation_advection_decline` | 0-3 分 |
| `support_H6_turbulence_direct_trigger` | 0-3 分 |
| `support_H7_method_projection_risk` | 0-3 分 |
| `main_mechanism` | 主控机制 |
| `secondary_mechanism` | 参与机制 |
| `background_process` | 背景过程 |
| `method_risk` | 方法风险说明 |
| `notes` | 简短解释 |

---

## 6. 当前结论

当前项目不是缺少基础计算，而是缺少**逐事件机制标签表**。下一步最小工作不应优先重算 EA、raw-w 或重复生成 FL 热图，而应把已有结果压缩成每个事件的竞争假设判据矩阵。

优先级最高的是：

1. 把 `profile switch`、`pre-min`、CO2 次高峰、风向转变、增风、峰后下降放到同一张逐事件时间顺序表；
2. 给 FL anomaly transport 增加事件窗口内的空间形态标签；
3. 把 H4 峰后吸收/混合稀释与 H5 通风/水平平流带走拆开竞争；
4. 把 H7 方法风险作为所有 raw-w 和 FL 机制解释的强制检查项；
5. 最后再形成 H8 组合机制排序。
