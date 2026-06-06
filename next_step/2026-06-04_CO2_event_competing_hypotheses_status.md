# CO2 事件竞争假设与计算完成状态整理

记录日期：2026-06-04  
更新说明：根据当前分析边界，事件假设整合阶段**不要求先将 CVT/MT 固定塔 raw `w` 总输送重算为 `F_anom`**。CVT/MT raw-w 结果只作为可选背景或方法风险检查；主整合优先使用 EA/EC、CO2 上升/下沉气团结构、CO2 廓线、三站水平风和 FL moving-transect anomaly transport。

2026-06-06 补充定位：本文件继续保留，但其角色已调整为**复杂地形通量计量修正主线下的复现与支撑分支**。也就是说，这里的事件竞争假设用于说明储存、平流、通风和局地环流何时干扰 EC 解释，而不再单独承担整个 REgov 项目的主线叙事。 [来源: 用户当前对话 2026-06-06] [已核验: project_memory/evidence/verifications/2026-06-06_regov_mainline_reset.md]

---

## 1. 当前解释边界

本记录只整理“已经完成或部分完成计算、可以进入整合分析”的证据，以及“尚未完成、不能直接下结论”的缺口。

当前必须保持三类量的边界：

1. **\(w'\) 协方差型 EA/EC 通量**：用于常规湍流交换参照。
2. **raw \(wc\) 总输送**：用于当前坐标下平均垂直运动或空气量结构诊断；在本轮 CO2 事件假设整合中，CVT/MT 的 raw-w 结果不作为必须先转换的主证据。
3. **\(w(c-c_{ref})\)、`F_conc_anom` 或 FL anomaly transport**：用于 CO2 异常输送、上升/下沉气团结构和移动切面空间形态诊断。

FL 不作为独立“第三平均通量站点”，而作为移动切面空间结构证据。其主作用是判断固定塔 CO2 事件在空间上更像整区同步、单侧输入、谷底增强，还是横谷向再分配。

### 1.1 CVT/MT raw-w 与 `F_anom` 的当前决策

当前**不需要**先把 CVT/MT 的 raw `w` 总输送调整成 `F_anom` 计算，理由如下：

1. CVT/MT 是固定塔，已经有 \(w'c'\) 口径的 EA/EC 结果，可作为湍流交换参照。
2. CVT/MT 已有上升/下沉 CO2 气团结构和 `F_conc_anom` 类型结果，可用于判断浓度异常结构。
3. raw \(wc\) 总输送在固定塔上主要受平均空气量项控制，若直接转为主证据，容易把事件机制分析重新拉回 raw-w 空气量主线。
4. FL 的 `F_anom` 更重要，因为 FL 是移动切面，必须用异常输送和空间形态来避免背景 CO2 大数主导，并服务于空间结构判断。

因此，当前事件整合的主证据顺序为：

\[
\text{CO2 廓线/事件时序}
\rightarrow
\text{EA/EC 与气团浓度结构}
\rightarrow
\text{三站水平风}
\rightarrow
\text{FL anomaly transport 空间形态}
\rightarrow
\text{CVT/MT raw-w 或 rotation 作为方法风险/敏感性}
\]

只有在后续需要把固定塔与 FL 放入同一个“异常输送口径”中比较时，才另开敏感性分支，计算 CVT/MT 的 fixed-tower `F_anom`：

\[
F_{anom}^{tower}=\overline{w(c-c_{ref})}
\]

其中 `c_ref` 必须与 FL 使用的参考浓度方案一致，例如事件前背景、pass/event 背景或同一时间窗背景。该分支不作为当前整合的前置条件。

---

## 2. 竞争假设状态表

| 编号 | 竞争假设 | 机制含义 | 当前计算状态 | 已完成或部分完成的计算 | 当前能否整合分析 | 尚未完成的关键缺口 |
|---|---|---|---|---|---|---|
| H1 | 夜间储存层释放 + 日出后廓线/边界层转换 | 夜间 CO2 在谷底或冠层内积累，日出后廓线结构切换、混合增强或储存层再分配，形成 CO2 次高峰。 | 部分完成 | 已完成事件时间线和机制证据矩阵。当前最稳链条是 `profile switch` 和 `pre-min` 均稳定早于 CO2 次高峰，记录为 `8/8 before_peak`。AP/profile 系统层位也已确认可作为局地柱 storage tendency 的优先入口。 | 可以整合为“基础候选机制”。 | 尚未完成定量 storage flux 或局地柱 CO2 storage tendency 的逐事件计算；还不能把“廓线切换”直接等同为储存释放通量。 |
| H2 | 风向转变或增风输入外来高 CO2 气团 | 次高峰由外部或上游高 CO2 气团输入触发，而非本地储存单独造成。 | 部分完成 | 三站水平风已完成 QC、north_offset 坐标统一、FL 小车速度矢量修正，并生成 1 min、5 min、30 min 风向和风速结果。事件对齐图已包含风速、u/v、风向、EC、湍流和热通量变量；raw `w_mean` 若使用，仅作为背景或方法风险，不作为当前主证据。 | 可以初步整合，但只能作为风场背景和候选输入证据。 | 尚未完成“峰前输入—峰值—峰后去向”的风向扇区标签；尚未逐事件判断风向转变是否稳定早于 CO2 回升；也未完成三站 CO2 传播顺序或同步性标签。 |
| H3 | 横谷向局地次级环流再分配 | 坡面受热、谷底补偿下沉或横谷向环流把 CO2 在谷缘、谷底和 FL 切面之间重新分配。 | 部分完成 | FL pass-level anomaly transport 与位置分箱已完成：193 个 pass，position-time 诊断 4751 行，25 个 10 m 位置 bin。`non_lambda_extreme` 与 `all_pass` 的 median profile 相关系数较高，可作为较稳健筛选组。既有 CVT/MT raw-w 结构可作为背景线索，但当前不要求先重算为固定塔 `F_anom`。 | 可以整合为空间形态证据，但不能直接定性为闭合环流。 | 尚未完成事件窗口内 FL 形态分类，例如 `sync_all_track`、`two_ends_strong_middle_weak`、`cvt_above_enhanced`、`dipole_structure`；尚未按风向扇区、移动方向检验 FL 空间形态稳定性。 |
| H4 | 次高峰后下降由生态吸收 + 垂直混合稀释主导 | 峰后 CO2 下降主要来自负 EC 通量、低 CO2 上升气团、湍流混合和混合层发展。 | 部分完成 | EA/EC 和 CO2 气团结构已完成。白天 09:00-15:00 全站平均表现为 `c_up < c_mean < c_down`，`c_up-c_down` 为负，净 CO2 通量为负。30 min 白天三站 `c_up-c_down < 0`，标准 EC 和 `F_conc_anom` 均为小负值。 | 可以整合为“峰后下降候选机制”。 | 尚未逐事件建立“峰后 EC 负通量增强、`c_up-c_down` 增强、`sigma_w/ustar/H` 增强、CO2 下降速率”之间的对应表。 |
| H5 | 次高峰后下降由通风或水平平流带走主导 | 高 CO2 气团形成后被稳定风向或增风带离控制体，三站 CO2 同步下降。 | 部分完成偏少 | 风速、风向、三站水平风和事件对齐基础已完成。项目下一步任务已明确要求增加风向扇区和峰后去向检验。 | 目前只能作为待检验强候选。 | 尚未完成峰后三站同步下降判据、稳定风向判据、增风判据和 FL 全轨道异常减弱判据；尚不能与 H4 定量区分。 |
| H6 | 湍流或热力过程直接触发次高峰 | 次高峰由湍流强度、u*、sigma_w、H 或 EC 交换增强直接触发。 | 已计算，但当前证据偏弱 | 机制证据矩阵已重跑。结果显示 wind max、raw w max、sigma_w max、u* max、H abs max 和 EC flux max 多不稳定地领先次高峰，其中不少变量更接近峰后或近峰。 | 可以整合为“背景或伴随过程”，不宜作为当前主控机制。 | 不需要优先扩展同类计算；若保留，应改为检验其是否调节峰后下降或混合稀释，而不是解释峰前触发。 |
| H7 | raw-w 垂直结构主要来自坐标/流线投影，而非真实环流 | raw `w_mean` 结构可能来自 sonic 坐标、地形流线倾斜、水平风投影或移动平台影响。 | 部分完成，且应作为方法约束 | 固定站点四方法 rotation 敏感性已完成，包含 `none/dr/pf/spf`。结果显示 rotation 对 `w_mean` 影响最大，double rotation 会把窗口内 `w_mean` 压到接近 0，而 `sigma_w` 相对稳定。 | 可以作为 raw-w 或 FL 垂直运动解释的敏感性约束；但当前事件整合不以 CVT/MT raw-w 为前置主证据。 | 若后续要把 raw-w 结构写成局地环流证据，仍需把 rotation 敏感性、风向扇区、移动方向和 FL 位置形态统一到事件级判据表。 |
| H8 | 组合机制 | 实际事件由夜间储存、晨间廓线切换、平流/环流再分配、峰后吸收/稀释或通风共同造成。 | 尚未完成最终整合 | 前置计算大多已经具备：EA/EC、CO2 气团结构、事件对齐、三站水平风、FL anomaly transport 和 rotation 敏感性均已有阶段性结果。 | 尚不能直接给最终排序，但已经具备整合分析基础。 | 需要建立逐事件机制打分表：时间顺序、空间形态、风向扇区、固定塔相位、FL 形态、EC/气团结构、方法风险各给标签。 |

---

## 3. 按当前可推进程度分组

| 类别 | 假设 | 当前处理方式 |
|---|---|---|
| 已有较完整计算，可立即纳入整合分析 | H6 湍流/热力直接触发；H7 坐标/流线投影方法风险 | H6 当前应降级为背景或伴随过程；H7 只在解释 raw-w 或 FL 垂直运动时作为敏感性约束。 |
| 已有部分计算，可进入事件级整合 | H1 储存释放 + 廓线转换；H2 外来高 CO2 输入；H3 横谷向局地环流；H4 峰后吸收/混合稀释 | 需要把已有表格和图件转写为逐事件标签，不一定需要先新增大量计算，也不要求先补 CVT/MT fixed-tower `F_anom`。 |
| 目前仍缺关键判据，不能直接判断 | H5 峰后通风/平流带走；H8 组合机制最终排序 | H5 需要补峰后去向判据；H8 需要等 H1-H5 的逐事件标签完成后再综合。 |

---

## 4. 当前最合理的整合顺序

| 顺序 | 整合对象 | 目的 | 最小输出 |
|---:|---|---|---|
| 1 | H1 vs H2：廓线切换/储存转换 与 外来高 CO2 输入 | 判断 CO2 次高峰“从哪里来”。 | 每个事件标记：`profile_switch_before_peak`、`pre_min_before_peak`、`wind_shift_before_rise`、`high_CO2_input_signal`。 |
| 2 | H4 vs H5：峰后吸收/混合稀释 与 通风/平流带走 | 判断次高峰“之后去了哪里”。 | 每个事件标记：`EC_more_negative_after_peak`、`c_up_minus_c_down_more_negative`、`wind_speed_increase_after_peak`、`three_station_sync_decline`。 |
| 3 | H3 + FL 空间形态：横谷向局地再分配 | 判断 FL 空间形态是否支持横谷向再分配。 | 每个事件标记：`FL_shape_class`、`wind_sector_dependence`、`moving_direction_dependence`、`FL_quality_group`。 |
| 4 | H7 方法风险检查 | 只在需要把 raw-w 或 FL 垂直运动写成环流证据时使用。 | `uv_projection_risk`、`rotation_sensitivity_risk`、`raw_w_not_primary_evidence`。 |
| 5 | H8：组合机制排序 | 给每个事件主控、参与、背景和方法风险标签。 | `main_mechanism`、`secondary_mechanism`、`background_process`、`method_risk`。 |

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
| `uv_projection_risk` | low/medium/high；仅在解释 raw-w 或 FL 垂直运动时必填 |
| `rotation_sensitivity_risk` | low/medium/high；仅在解释 raw-w 或 FL 垂直运动时必填 |
| `fixed_tower_F_anom_needed` | 默认 FALSE；只有需要 CVT/MT 与 FL anomaly 同口径对比时才改 TRUE |
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

当前项目不是缺少基础计算，而是缺少**逐事件机制标签表**。下一步最小工作不应优先重算 EA、raw-w 或重复生成 FL 热图，也不应把 CVT/MT raw `w` 先改成固定塔 `F_anom` 作为前置条件。

优先级最高的是：

1. 把 `profile switch`、`pre-min`、CO2 次高峰、风向转变、增风、峰后下降放到同一张逐事件时间顺序表；
2. 给 FL anomaly transport 增加事件窗口内的空间形态标签；
3. 把 H4 峰后吸收/混合稀释与 H5 通风/水平平流带走拆开竞争；
4. 把 H7 方法风险作为 raw-w 或 FL 垂直运动解释时的强制检查项，而不是当前主线的前置计算；
5. 只有在需要固定塔与 FL 进行同一异常输送口径比较时，才补算 CVT/MT fixed-tower `F_anom`；
6. 最后再形成 H8 组合机制排序。

---

## 7. 机制假设详细讨论

本节用于把上面的状态表扩展为可直接指导事件分析的竞争性假设框架。后续每个事件不应只给一个单一解释，而应围绕候选机制建立证据排序。每个假设都需要同时回答四个问题：

1. CO2 次高峰从哪里来；
2. FL 应该看到什么空间结构；
3. CVT/MT 固定塔应该看到什么时间顺序；
4. 哪些证据支持、削弱或否定该假设。

事件分析不应只看峰值时刻，而应切成以下过程链：

\[
\text{峰前背景}
\rightarrow
\text{廓线结构切换}
\rightarrow
\text{CO2 前期低点}
\rightarrow
\text{CO2 回升/次高峰}
\rightarrow
\text{峰后下降}
\]

当前最稳的已知链条是：`profile switch` 和 `pre-min` 均稳定早于 CO2 次高峰；风速、`u/v`、raw `w_mean`、`sigma_w`、`ustar` 和 `H` 更像背景或伴随过程，尚不能单独作为稳定峰前触发因子。因此，下面的假设讨论以“时间顺序 + 空间结构 + 方法风险”三层证据为核心。

### 7.1 H1：夜间储存层释放 + 日出后廓线/边界层转换

#### 机制逻辑

H1 假设认为，夜间谷底、近地层或冠层内积累高 CO2。日出后，稳定层被削弱，廓线结构先发生切换，CO2 随混合或通风先下降到前期低点；随后一部分夜间储存 CO2 被重新卷入观测高度，或由局地柱内储存层释放和再分配，形成 09:00 左右 CO2 次高峰。

该假设的核心不是“外部气团输入”，而是：

> 本地或近地层储存 CO2 在晨间转换中被重新分配。

因此，H1 的关键证据不是某一瞬间 CO2 升高，而是 `profile switch -> pre-min -> secondary peak` 的稳定先后顺序。

#### FL 应该看到什么

如果 H1 成立，FL 空间形态可能出现两类结果。

第一类是 `cvt_above_enhanced` 或谷底附近增强。这表示储存层或谷底高 CO2 空气在晨间转换后被重新抬升、混合或带到 FL 轨道中部附近。此时 `co2_anom(x)` 应在 CVT 上方或中部更强，`F_anom(x)` 可能与局地垂直运动配合增强。

第二类是 `sync_all_track`。如果储存层或晨间混合过程的空间尺度大于 FL 横切面，FL 会表现为整条轨迹同步升高或同步降低，而不是单侧输入。此时 FL 的作用是说明事件具有整区背景变化特征，而不是定位单一输入侧。

H1 不要求 FL 一定出现强单侧结构。如果 FL 仅表现为整条轨迹同步变化，并且廓线切换稳定早于次峰，H1 仍可以成立。

#### 固定塔应该看到什么

支持 H1 的固定塔时序包括：

- `profile_switch_time` 早于 CO2 次高峰；
- `pre_min_time` 早于 CO2 次高峰；
- CVT/MT 廓线差值发生明显变化；
- 次峰前不一定存在稳定风向突变；
- `sigma_w`、`ustar`、`H` 和标准 EC 极值可以接近峰值或出现在峰后，而不必稳定领先。

如果每个事件均表现为廓线先切换、CO2 先达到前期低点、随后回升成次峰，则 H1 应作为基础候选机制保留。

#### 支持证据

H1 的强支持证据包括：

1. `profile_switch_before_peak = TRUE` 且跨事件稳定；
2. `pre_min_before_peak = TRUE` 且跨事件稳定；
3. 次峰前风向转变不稳定或不领先；
4. FL 为 `sync_all_track` 或 `cvt_above_enhanced`，且 CO2 anomaly 在次峰前后增强；
5. 峰后 CO2 下降可由混合增强、EC 负通量或通风进一步解释。

#### 削弱或否定证据

H1 会被以下证据削弱：

- FL 在次峰前某一侧轨道先出现高 CO2 anomaly，随后固定塔响应；
- 该单侧增强与 corrected wind sector 一致；
- 风向转变或增风稳定早于 CO2 回升；
- 三站 CO2 回升呈明显传播顺序，而不是廓线转换后的本地响应。

若上述证据成立，H1 可能仍作为背景过程存在，但主控机制应转向 H2 或 H3。

#### 当前判定地位

H1 当前应作为基础假设。它不必单独解释全部事件，但它提供了晨间事件的初始条件：夜间储存、日出后结构切换和 CO2 前期低点。

---

### 7.2 H2：风向转变或增风输入外来高 CO2 气团

#### 机制逻辑

H2 假设认为，日出后某一固定时段发生风向转变、风速增强或背景流场重组，将外部或上游高 CO2 气团带入研究区。CO2 次高峰不是由本地储存层单独造成，而是外来输入或沿谷/侧向平流造成。

该假设的核心过程为：

\[
\text{风向/风速变化}
\rightarrow
\text{FL 单侧或全轨道 CO2 异常}
\rightarrow
\text{CVT/MT CO2 回升}
\]

因此，H2 的关键检验是风场变化是否领先 CO2 回升，以及 FL 空间形态是否能显示输入方向或整区同步输入。

#### FL 应该看到什么

H2 有两个子类型。

##### H2a：沿谷向或背景风输入

如果输入尺度大于 FL 横切面，FL 应表现为：

- `sync_all_track`；
- 整条轨道 CO2 anomaly 同步升高；
- `F_anom(x)` 空间差异不强；
- 三站 CO2 近同步回升；
- 峰后若继续增风，三站 CO2 可能同步下降。

这种情况下，FL 的作用不是定位横向结构，而是证明 CO2 异常具有大尺度背景变化特征。

##### H2b：侧向输入

如果高 CO2 气团从某一侧进入，FL 应表现为：

- `mt_side_enhanced` 或 `far_side_enhanced`；
- 一侧 CO2 anomaly 先增强；
- 异常随后向中部或另一侧扩展；
- 输入侧与 corrected wind sector 一致；
- 固定塔响应可能存在时间滞后。

这种情形下，FL 的价值最大，因为固定塔很难单独判断输入方向。

#### 固定塔应该看到什么

支持 H2 的固定塔和风场证据包括：

- `wind_shift_before_rise = TRUE`；
- `wind_speed_increase_before_rise = TRUE` 或接近 CO2 回升；
- CVT/MT/FL CO2 回升同步，或存在与风向一致的传播顺序；
- 次峰前廓线切换虽然可以存在，但不足以单独解释回升；
- 峰后如果保持增风和稳定风向，CO2 下降更偏向 H5 通风带走。

#### 支持证据

H2 的强支持证据包括：

1. 风向转变稳定早于 CO2 回升；
2. FL 出现单侧增强并与风向扇区匹配；
3. 三站 CO2 上升存在同步性或传播顺序；
4. 峰后 CO2 下降伴随增风或稳定风向；
5. 标准 EC 负通量不能解释 CO2 回升幅度。

#### 削弱或否定证据

H2 会被以下证据削弱：

- 风向转变发生在 CO2 次峰之后；
- FL 没有单侧输入或整区同步升高；
- 廓线切换和前期低点稳定早于所有风场变化；
- CO2 回升主要局限在某一固定塔，而非与风场传播一致。

#### 当前判定地位

H2 是强竞争假设。它尤其需要 FL 空间形态和 corrected wind sector 接入后才能判定。若 FL 是 `sync_all_track`，H2 更偏背景风或沿谷向输入；若 FL 是单侧增强，H2 更偏侧向输入。

---

### 7.3 H3：横谷向局地次级环流再分配

#### 机制逻辑

H3 假设认为，日出后坡面受热、地形热力差异和谷地几何共同形成横谷向局地次级环流。谷缘或坡面附近可能处于上升支，谷底或谷轴可能出现补偿下沉。CO2 次高峰不是单纯由外部输入造成，而是夜间储存 CO2、低 CO2 上升气团和背景风在横谷切面内被重新分配。

H3 的核心不是“有风场变化”，而是：

> FL 切面上存在可重复的横向空间结构，并且该结构与 CVT/MT 固定塔相位一致。

#### FL 应该看到什么

H3 最依赖 FL。强支持形态包括：

- `two_ends_strong_middle_weak`：两端增强，中部较弱；
- `dipole_structure`：一侧正、一侧负；
- `cvt_above_enhanced`：谷底上方出现局地增强；
- `mt_side_enhanced` 与坡面上升支一致；
- `F_anom(x)`、`w_mean(x)` 和 `co2_anom(x)` 具有相互解释关系；
- `non_lambda_extreme` 筛选后形态仍存在；
- 相同事件阶段、相似风向扇区或相似日出窗口中重复出现。

如果 FL 在峰前、峰中、峰后只表现为 `sync_all_track`，则 H3 不能作为强机制，只能作为弱背景候选。

#### 固定塔应该看到什么

支持 H3 的固定塔证据包括：

- CVT 日出后 raw `w_mean` 偏负；
- MT 或 FL raw `w_mean` 偏正；
- 标准 EC `F_EC_cov` 仍为小负值或生态吸收型结构，说明湍流浓度交换与 raw-w 空气量结构解耦；
- `c_up-c_down < 0` 支持低 CO2 上升气团存在；
- FL 切面形态与 CVT/MT 的时序相位一致。

这里必须注意：raw `w_mean` 不能单独证明真实环流。只有当 FL 空间形态、固定塔相位、风向扇区和方法风险检验共同支持时，H3 才能升级为强候选机制。

#### 支持证据

H3 的强支持证据包括：

1. FL 在多个 pass 或多个事件中重复出现横向结构；
2. `non_lambda_extreme` 筛选后 `F_anom(x)` profile 仍稳定；
3. 形态不依赖单一移动方向；
4. 形态不是某个强水平风扇区的投影结果；
5. CVT/MT 相位与 FL 空间结构一致；
6. CO2 anomaly、`w_mean` 和 `c_up-c_down` 能形成一致物理图像。

#### 削弱或否定证据

H3 会被以下证据削弱：

- FL 空间形态总是 `sync_all_track`；
- 横向结构只在某一移动方向出现；
- 横向结构只在特定强风向扇区出现，且可由水平风投影解释；
- `non_air_imbalance` 或严格 QC 后形态完全改变；
- CVT/MT 固定塔时序与 FL 横向结构不一致。

#### 当前判定地位

H3 是 FL 最能贡献增量证据的假设，但不能先验成立。下一步必须通过事件窗口内的 FL 形态标签、风向扇区、移动方向和质量组筛选来判断其强弱。

---

### 7.4 H4：峰后下降由生态吸收 + 垂直混合稀释主导

#### 机制逻辑

H4 不主要解释次高峰如何形成，而是解释次高峰之后 CO2 为什么下降。该假设认为，峰后 CO2 下降主要来自：

1. 植被或地表生态系统吸收增强；
2. 低 CO2 空气通过湍流、混合层发展或局地环流向上输送；
3. 混合层发展导致近地层 CO2 被稀释。

核心过程为：

\[
\text{负 EC 通量增强}
+
\text{低 CO2 上升气团增强}
+
\text{混合增强}
\rightarrow
\text{CO2 下降}
\]

#### FL 应该看到什么

如果 H4 成立，FL 可能显示：

- `co2_anom(x)` 整体减弱；
- `F_anom(x)` 指向低 CO2 anomaly 的上输或通风；
- 峰后空间梯度减弱；
- 不一定有单侧输入；
- 可能从峰中局地增强转为全轨道低 CO2 或弱异常。

H4 不要求 FL 出现强横向环流。它可以和 H1、H2 或 H3 同时存在，专门解释峰后下降阶段。

#### 固定塔应该看到什么

支持 H4 的证据包括：

- 峰后标准 EC `F_EC_cov` 更负；
- `c_up-c_down` 变得更负；
- `sigma_w`、`ustar` 或 `H` 增强；
- CO2 下降不一定与强风向转变同步；
- 三站 CO2 下降可以不同步，因为生态吸收和局地混合有空间差异。

#### 支持证据

H4 的强支持证据包括：

1. 峰后 EC 负通量增强；
2. 峰后 `c_up-c_down` 更负；
3. 峰后混合指标增强；
4. FL CO2 anomaly 减弱但无明显单侧输出；
5. 风速或风向不足以解释同步下降。

#### 削弱或否定证据

H4 会被以下证据削弱：

- 峰后风速明显增强且风向稳定；
- 三站 CO2 几乎同步下降；
- 标准 EC 负通量没有增强；
- `c_up-c_down` 没有增强；
- FL 全轨道 anomaly 同步减弱且更像大尺度通风。

#### 当前判定地位

H4 是峰后下降阶段的强候选机制，但不应被用来解释次高峰的形成。它应与 H5 做竞争判断。

---

### 7.5 H5：峰后下降由通风或水平平流带走主导

#### 机制逻辑

H5 认为，CO2 次高峰形成后，高 CO2 气团被稳定风向或增强风速带离观测控制体。CO2 下降主要是输送离开，而不是本地生态吸收或垂直混合单独造成。

核心过程为：

\[
\text{增风/稳定风向}
\rightarrow
\text{三站同步 CO2 下降}
\rightarrow
\text{FL 全轨道 anomaly 减弱}
\]

#### FL 应该看到什么

如果 H5 成立，FL 应更可能出现：

- `sync_all_track`；
- CO2 anomaly 沿整条轨道同步降低；
- 空间梯度减弱；
- `F_anom(x)` 整体趋近背景；
- 不需要两端强中部弱或单侧输入结构。

如果 FL 在峰后显示整条轨迹同步减弱，而风向稳定、风速增强，则 H5 会明显增强。

#### 固定塔应该看到什么

支持 H5 的固定塔证据包括：

- 峰后风速增强；
- 风向保持稳定；
- 三站 CO2 同步下降；
- 标准 EC 负通量不是唯一解释；
- `c_up-c_down` 可能仍为负，但不能单独解释下降速率。

#### 支持证据

H5 的强支持证据包括：

1. `wind_speed_increase_after_peak = TRUE`；
2. `wind_direction_stable_after_peak = TRUE`；
3. `three_station_sync_decline = TRUE`；
4. FL 为 `sync_all_track` 且 anomaly 同步减弱；
5. 峰后 EC 负通量未明显增强，或不足以解释下降速率。

#### 削弱或否定证据

H5 会被以下证据削弱：

- 峰后弱风或风向不稳定；
- 三站 CO2 下降不同步；
- EC 负通量和低 CO2 上升气团明显增强；
- FL 空间结构显示局地吸收/混合主导，而非整区通风。

#### 当前判定地位

H5 是峰后去向检验的必要假设。当前缺口是尚未建立三站同步下降、稳定风向、增风和 FL 全轨道 anomaly 减弱的逐事件判据。

---

### 7.6 H6：湍流或热力过程直接触发次高峰

#### 机制逻辑

H6 假设认为，CO2 次高峰由湍流强度、`ustar`、`sigma_w`、热通量 `H` 或 EC 交换增强直接触发。也就是说，次高峰的主控不是储存释放或平流输入，而是湍流/热力过程本身。

#### 应看到什么

如果 H6 成立，应满足：

- `sigma_w`、`ustar` 或 `H` 的极值稳定早于 CO2 回升；
- EC 通量变化稳定早于次峰；
- FL 空间形态不是关键，或仅反映混合增强；
- 风向转变和廓线切换不是主要领先信号。

#### 当前证据判断

目前 H6 证据偏弱。已有机制矩阵显示，湍流和热力指标并没有稳定峰前领先，很多极值出现在近峰或峰后。因此，H6 不宜作为当前主控机制，而应降级为：

> 背景或调节过程，主要影响峰后混合、稀释或下降速率。

#### 何时重新提升 H6

只有当逐事件表显示 `sigma_w/ustar/H` 稳定先于 CO2 回升，且比风向、廓线和 FL 空间形态更能解释峰值时序时，H6 才能重新作为强候选。

---

### 7.7 H7：raw-w 垂直结构主要来自坐标/流线投影，而非真实环流

#### 机制逻辑

H7 是方法风险假设，不直接解释 CO2 次高峰来源。它限制我们如何解释 raw `w_mean` 和 FL 垂直结构。

该假设认为，`CVT` 负、`MT/FL` 正的 raw `w_mean` 结构可能来自：

- sonic 坐标倾斜；
- 地形流线倾斜；
- 水平风投影进入 raw `w`；
- FL 平台运动残余；
- 特定风向扇区导致的系统性投影。

#### FL 应该看到什么

如果 H7 风险高，FL 可能表现为：

- `w_mean(x)` 与 corrected wind sector 强绑定；
- 某种空间形态只在特定风向出现；
- 移动方向不同，形态明显不同；
- `F_anom(x)` 与 `w_mean(x)` 强相关，但与 CO2 anomaly 或廓线结构不一致；
- `non_lambda_extreme` 与更严格质量筛选组差异很大。

#### 固定塔应该看到什么

支持 H7 的固定塔证据包括：

- `w_mean ~ u_mean + v_mean` 解释度高；
- rotation 方法显著改变 `w_mean`；
- double rotation 后窗口平均 `w_mean` 接近 0；
- `sigma_w` 相对稳定，说明差异主要来自平均流线或坐标处理，而不是湍流强度被整体重写。

#### 支持证据

H7 的强支持证据包括：

1. raw `w_mean` 结构可被水平风解释；
2. 风向扇区决定 FL 形态；
3. 移动方向决定 FL 形态；
4. rotation 后固定塔 `w_mean` 结构显著改变；
5. CO2 anomaly 与 `w_mean` 结构不一致。

#### 削弱或否定证据

H7 会被以下证据削弱：

- `CVT` 负、`MT/FL` 正结构跨风向稳定；
- FL 空间形态在两个移动方向下都稳定；
- FL 空间形态与 CO2 anomaly、廓线结构和固定塔相位一致；
- rotation 敏感性不能解释事件时序。

#### 当前判定地位

H7 是强制方法检查。任何关于“补偿下沉”“上升支”“横谷环流”的表述，都必须同时报告 H7 风险等级。

---

### 7.8 H8：组合机制

#### 机制逻辑

实际事件很可能不是单一机制。更合理的组合是：

\[
\text{夜间储存}
+
\text{日出廓线转换}
+
\text{局地或背景风再分配}
+
\text{峰后吸收/稀释或通风}
\]

可能过程为：

1. 夜间 CO2 在谷地、冠层或近地层积累；
2. 日出后廓线结构先切换；
3. CO2 下降到前期低点；
4. 某一风向、背景流或局地环流过程把高 CO2 气团重新带入、抬升或再分配；
5. 形成 CO2 次高峰；
6. 峰后由生态吸收、垂直混合和水平通风共同降低 CO2。

#### 组合机制的判读方式

H8 不是简单地说“都有贡献”，而是要给每个事件一个机制排序：

| 排名 | 机制角色 | 判据 |
|---|---|---|
| 1 | 主控机制 | 时间顺序、空间结构和固定塔证据三者一致 |
| 2 | 参与机制 | 两类证据支持，但缺少一个关键约束 |
| 3 | 背景过程 | 与事件同步，但不能解释触发 |
| 4 | 不支持机制 | 时间顺序或空间结构矛盾 |
| 5 | 方法风险 | 可能由坐标、风向扇区、移动方向或质量标记造成 |

#### 推荐输出文本格式

每个事件最终应输出一句结构化判断，例如：

> `2025-03-21_CVT`: `profile switch` 和 `pre-min` 早于次峰，FL 在峰前表现为 `sync_all_track`，风向转变接近 CO2 回升，峰后三站同步下降；因此主控候选为 `storage_transition + background_advection`，横谷向环流证据较弱，生态吸收主要解释峰后下降的一部分。

#### 当前判定地位

H8 是最终解释框架，但不能先于 H1-H5 的逐事件标签完成。现在需要先完成事件级打分表，再形成组合机制排序。

---

## 8. 事件接入后的判读规则

### 8.1 判断 CO2 次高峰“从哪里来”

| 证据组合 | 机制倾向 |
|---|---|
| `profile_switch` 和 `pre_min` 稳定早于 peak；风向变化不稳定 | H1 储存/廓线转换为基础机制 |
| 风向转变或增风稳定早于 CO2 回升；FL 单侧增强 | H2 外来高 CO2 输入，偏侧向输入 |
| 风向转变或增风稳定早于 CO2 回升；FL 全轨道同步增强 | H2 外来高 CO2 输入，偏背景风或沿谷向平流 |
| FL 两端强中部弱或 dipole，且与 CVT/MT 相位一致 | H3 横谷向局地再分配增强 |
| 湍流/热力极值稳定早于 CO2 回升 | H6 湍流/热力直接触发增强；但当前证据偏弱 |

### 8.2 判断 CO2 次高峰“之后去了哪里”

| 证据组合 | 机制倾向 |
|---|---|
| 峰后 EC 更负、`c_up-c_down` 更负、混合增强 | H4 生态吸收 + 垂直混合稀释 |
| 峰后增风、风向稳定、三站同步下降、FL 全轨道 anomaly 减弱 | H5 通风或水平平流带走 |
| 峰后空间形态仍有明显侧向梯度 | H2/H3 仍参与后续再分配 |
| 峰后下降与 EC、风场均不同步 | 机制不清，需保留为 ambiguous |

### 8.3 判断 FL 空间证据强弱

| FL 结果 | 解释级别 |
|---|---|
| `sync_all_track` | 支持背景风、沿谷向平流或整区混合；不支持强横谷结构 |
| `mt_side_enhanced` / `far_side_enhanced` | 支持侧向输入或地形导流，需与风向扇区匹配 |
| `cvt_above_enhanced` | 支持谷底储存释放、谷底局地输送或 CVT 上方再分配 |
| `two_ends_strong_middle_weak` | 支持横谷向次级环流候选，但需重复性和风向/移动方向检验 |
| `dipole_structure` | 支持横向输送或局地环流，但方法风险也较高 |
| `unclear` | 只能作辅助背景，不进入强机制证据 |

### 8.4 判断方法风险

| 风险证据 | 处理方式 |
|---|---|
| `w_mean` 与 `u/v` 高相关 | raw-w 结构降级为坐标/流线敏感诊断 |
| rotation 后 `w_mean` 强烈改变 | 不把 raw-w 直接写成真实垂直环流 |
| FL 形态只在单一移动方向出现 | 降级为空间采样风险 |
| FL 形态只在特定强风向出现 | 优先讨论地形导流或水平风投影 |
| `lambda_extreme` 或 air imbalance 过多 | 使用 `non_lambda_extreme` 主筛选，严格空气量组仅作敏感性 |

---

## 9. 下一步最小执行项

为把机制假设真正接入事件分析，下一步只需要补三类表，不需要重新扩展通量算法。

### 9.1 `FL_event_spatial_pattern_labels.csv`

每个事件窗口输出：

- `date`
- `event_phase`
- `window_start`
- `window_end`
- `n_pass`
- `FL_quality_group`
- `F_anom_profile_type`
- `w_mean_profile_type`
- `co2_anom_profile_type`
- `FL_shape_class`
- `dominant_position_bin`
- `moving_direction_dependence`
- `wind_sector_dependence`
- `notes`

### 9.2 `CO2_event_lead_lag_table.csv`

每个事件输出：

- `profile_switch_time`
- `pre_min_time`
- `secondary_peak_time`
- `wind_shift_time`
- `wind_speed_change_time`
- `FL_anom_first_time`
- `EC_flux_min_time`
- `sigma_w_max_time`
- `ustar_max_time`
- `H_abs_max_time`
- 与 `secondary_peak_time` 的所有时间差

### 9.3 `CO2_event_mechanism_ranking.csv`

每个事件输出：

- `support_H1_storage_transition`
- `support_H2_external_input`
- `support_H3_local_secondary_circulation`
- `support_H4_ecosystem_mixing_decline`
- `support_H5_ventilation_advection_decline`
- `support_H6_turbulence_direct_trigger`
- `support_H7_method_projection_risk`
- `main_mechanism`
- `secondary_mechanism`
- `background_process`
- `method_risk`
- `one_sentence_interpretation`

---

## 10. 最终写作边界

后续写作时，FL 接入事件分析后不应写成：

> FL 独立计算了控制体 CO2 通量。

更稳妥的写法是：

> FL moving-transect anomaly transport was used as a cross-sectional diagnostic to evaluate whether fixed-tower CO2 events were spatially organized as whole-transect changes, one-sided inputs, valley-bottom enhancement, or cross-valley redistribution.

中文表述为：

> FL 移动切面 CO2 异常输送用于判断固定塔 CO2 事件在空间上表现为整区同步、单侧输入、谷底增强还是横谷向再分配；它不直接给出最终生态系统 CO2 通量，而是作为复杂地形控制体机制归因的空间证据层。
