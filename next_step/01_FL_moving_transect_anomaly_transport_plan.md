# FL 移动切面 CO2 异常输送诊断算法与第一步可行性验证

## 1. 文件目的

本文档整理下一步针对 `FL` 移动平台数据的计算方案。目标不是把 `FL` 直接作为第三个固定 EC 通量站，而是构建一个移动切面诊断框架，用于判断复杂地形控制体中 CO2 异常输送、空气量闭合、局地环流和平流过程对碳通量计量的影响。

建议算法名称：

> FL 移动切面 CO2 异常输送诊断算法  
> FL moving-transect CO2 anomaly transport diagnostic framework

该算法的第一步不是直接生成最终通量，而是生成一个 `pass` 级可行性诊断表，判断该方案是否有足够的数据量、稳定性和物理解释基础继续推进。

---

## 2. 当前方法边界

1. 当前主线仍在未做坐标旋转、WPL 修正、频率修正和空气密度或摩尔密度换算的口径下解释结果。因此所有结果首先应解释为当前坐标和当前单位下的运动学输送量，不应直接写成标准单位的生态系统 CO2 通量。[依据: project_memory/anchors/02_key_constraints.md]
2. `FL` 搭载实时调平装置，但这不等于 raw `w` 已经是严格地理垂直风。`sonic` 坐标、north offset、流线倾斜、水平风混入和平台运动方向仍需通过风向扇区、`w_mean ~ u_mean + v_mean` 和移动方向分组诊断排查。[依据: project_memory/anchors/02_key_constraints.md]
3. `FL` 轨道位置定义为 `0 m` 靠近 `MT` 方向，轨道中点穿过 `CVT` 正上方，`245 m` 为终点。位置分箱应继续使用 `0-245 m` 有效位置尺度，不应把位置列拉伸到旧脚本端点坐标直线距离。[依据: project_memory/anchors/01_anchor_facts.md]
4. `FL` 的核心角色是移动切面空间形态证据，而不是第三个平均通量点。算法结果应服务于控制体机制判断，而不是单独替代固定塔 EC 或完整 NEE 估计。[依据: project_memory/runtime/05_next_mainline_tasks.md]

---

## 3. 理论上需要主动约束的薄弱点

### 3.1 移动平台不是固定控制面

固定塔 EC 计算的是固定点上的湍流协方差通量：

```math
F_{EC}=\overline{w'c'}
```

`FL` 是移动平台，一个时间段内会经过不同空间位置。因此一段 `FL` 时间序列同时包含：

```text
时间变化 + 空间变化 + 平台运动采样效应
```

因此不能直接把 `FL` 的 1 min 或单程序列当作固定塔 EC 序列解释。必须先按 `pass_id` 和位置分箱组织，再进入事件窗口复合。

### 3.2 `c - c_ref` 估计的是异常输送，不是完整总输送

原始表观输送为：

```math
F_{raw}=\overline{wc}
```

CO2 背景浓度通常为几百 ppm，即使 `w_mean` 很小，也会通过 `w_mean * c_mean` 产生较大数值。为了降低背景 CO2 大数对结果的放大，建议引入参考浓度：

```math
c^*=c-c_{ref}
```

并计算：

```math
F_{anom}=\overline{w(c-c_{ref})}
```

这个量的物理意义是：相对于背景浓度的 CO2 异常随表观垂直风或平均垂直运动的输送。它不是完整 CO2 总输送，也不等同传统生态系统 CO2 通量。

### 3.3 `lambda` 质量守恒修正不能作为主算法核心

已有 `lambda` 思路为：

```math
\lambda=-\frac{\sum w^+}{\sum w^-}
```

其中 `sum w^-` 为负值或以下沉风量的带符号和表示。该修正的核心是强制正负空气量闭合。它适合做空气量闭合诊断和敏感性分析，但不应直接作为主通量算法，因为单个移动单程不一定是闭合控制体，且水平辐合/辐散、平台运动残差、坐标倾斜和流线倾斜都可能真实影响 `A_net`。

### 3.4 1 min 小样本风险

若 `FL` 的 1 min 数据只有约 30 个有效点，则该窗口不适合独立计算 `lambda`、`c_up-c_down` 或 `w'c'`。1 min 应优先作为轨迹定位、事件定位和初步可视化层；主计算单元应转向 `pass-based + position-binned + event-composite`。

---

## 4. 完整算法计算思路

### 4.1 输入变量

每条高频记录至少包括：

```text
t_i        本地时间
x_i        FL 轨道位置，0-245 m
u_i, v_i   水平风分量，建议使用已完成 north_offset 与平台运动修正后的版本进行风向风速解释
w_i        raw 垂直风或当前主线口径下的表观垂直风
c_i        CO2 摩尔分数
Delta_t_i  样本时间间隔
```

所有时间列应按字符读入后显式赋予或解析为 `Asia/Shanghai`。

### 4.2 计算单元

算法不以 1 min 为主通量单元，而采用三层结构：

1. `position bin`：例如每 10 m 或 20 m 一个位置段；
2. `pass`：一次从 `0 m` 到 `245 m` 或从 `245 m` 到 `0 m` 的移动单程；
3. `event composite`：峰前、前期低点、CO2 回升段、次高峰、峰后下降、白天强混合、夜间稳定等事件窗口。

主结果应来自多个 `pass` 或事件窗口复合，而不是单个 1 min。

### 4.3 基础均值与 Reynolds 分解

对每个 `pass_id` 和每个位置 bin `B_k`，定义样本集合 `i in (pass_id, B_k)`：

```math
\bar w_k=\frac{\sum_i w_i\Delta t_i}{\sum_i \Delta t_i}
```

```math
\bar c_k=\frac{\sum_i c_i\Delta t_i}{\sum_i \Delta t_i}
```

```math
w'_i=w_i-\bar w_k
```

```math
c'_i=c_i-\bar c_k
```

### 4.4 raw 表观输送

每个位置 bin 的 raw 表观输送：

```math
F_{raw,k}=\frac{1}{T_k}\sum_{i\in k}w_i c_i \Delta t_i
```

其中：

```math
T_k=\sum_{i\in k}\Delta t_i
```

分解为：

```math
F_{raw,k}=\bar w_k\bar c_k+\overline{w'c'}_k
```

定义：

```math
F_{mean,k}=\bar w_k\bar c_k
```

```math
F_{turb,k}=\overline{w'c'}_k
```

该分解是代数恒等式。解释时必须注意：如果 `F_raw` 主要由 `F_mean` 控制，则它首先是平均表观垂直风携带背景 CO2 的结果，不能直接写成生态系统交换强度。

### 4.5 CO2 异常输送主结果

定义参考浓度：

```math
c^*_i=c_i-c_{ref}
```

主结果：

```math
F_{anom,k}=\frac{1}{T_k}\sum_{i\in k}w_i(c_i-c_{ref})\Delta t_i
```

等价展开为：

```math
F_{anom,k}=\bar w_k(\bar c_k-c_{ref})+\overline{w'c'}_k
```

这说明 `F_anom` 仍然保留平均风或平流相关信息，但只输送 CO2 异常，而不是完整背景浓度。

`c_ref` 建议分三级测试：

1. `pass_mean`：`c_ref = cbar_pass`，用于最小可行性验证；
2. `pre_event_background`：用于解释 CO2 次高峰相对于峰前背景的异常输送；
3. `CVT_MT_mean`：用于把 FL 放入控制体固定塔背景中解释。

第一步可行性验证只使用 `pass_mean`，避免一开始引入过多参考浓度选择。

### 4.6 沿轨道合成

对一个 `pass_id`，位置平均异常输送为：

```math
F_{FL,anom}^{pass}=\frac{\sum_k F_{anom,k}\Delta x_k}{\sum_k \Delta x_k}
```

也可计算沿轨道线积分输送强度：

```math
Q_{FL,anom}^{pass}=\sum_k F_{anom,k}\Delta x_k
```

建议主图优先使用 `F_FL_anom_pass`，补充结果使用 `Q_FL_anom_pass`。

### 4.7 上升/下沉气团结构

对每个 `pass` 或事件窗口：

```math
A^+=\sum_{w_i>0}w_i\Delta t_i
```

```math
A^-=\sum_{w_i<0}|w_i|\Delta t_i
```

```math
A_{net}=A^+-A^-
```

```math
I_A=\frac{A^+-A^-}{A^++A^-}
```

通量权重浓度：

```math
c^+=\frac{\sum_{w_i>0}w_i c_i\Delta t_i}{A^+}
```

```math
c^-=\frac{\sum_{w_i<0}|w_i|c_i\Delta t_i}{A^-}
```

```math
\Delta c_{up-down}=c^+-c^-
```

该部分用于判断异常输送是否有气团浓度结构支撑，而不是作为单独最终通量。

### 4.8 空气量项与浓度异常项拆分

对每个 `pass` 或事件窗口，可继续拆解 raw 上升/下沉输送：

```math
F_{total}=\frac{A^+c^+-A^-c^-}{T}
```

```math
F_{air}=\frac{(A^+-A^-)\bar c}{T}
```

```math
F_{conc}=\frac{A^+(c^+-\bar c)-A^-(c^--\bar c)}{T}
```

其中：

```math
F_{total}=F_{air}+F_{conc}
```

解释：

- `F_air` 反映空气量不平衡或表观平均垂直运动主导程度；
- `F_conc` 反映上升/下沉气团 CO2 浓度异常造成的输送；
- 若 `F_air` 远大于 `F_conc`，则不能把 `F_total` 直接写成生态 CO2 交换。

### 4.9 lambda 与闭合敏感性

继续输出传统 `lambda`：

```math
\lambda=-\frac{\sum w^+}{\sum w^-}
```

但只作为敏感性和 QC，不作为主修正结论。

更稳的后续方案是最小修正质量闭合：在位置 bin 层面对 `wbar_k` 做最小调整，使：

```math
\sum_k \tilde w_k \Delta x_k=0
```

并最小化：

```math
\min_{\delta_k}\sum_k \frac{\delta_k^2}{\sigma_{w,k}^2}
```

其中：

```math
\tilde w_k=\bar w_k+\delta_k
```

然后计算闭合约束下的异常输送：

```math
F_{closure,anom}=\frac{\sum_k \tilde w_k(\bar c_k-c_{ref})\Delta x_k}{\sum_k\Delta x_k}+\frac{\sum_k \overline{w'c'}_k\Delta x_k}{\sum_k\Delta x_k}
```

该结果只进入敏感性分析。

---

## 5. 第一阶段最小可行性验证

### 5.1 第一阶段目标

第一步只判断算法是否值得继续推进，不做完整控制体解释。需要生成一个 `pass` 级表：

```text
FL_pass_anomaly_transport_feasibility.csv
```

每一行是一个 `FL` 移动单程 `pass_id`。

### 5.2 第一阶段只使用的参考浓度

第一步统一使用：

```math
c_{ref}=\bar c_{pass}
```

即 `pass` 平均 CO2。该选择最简单，能直接检查去掉背景 CO2 后 `F_anom` 是否明显降低 raw `wc` 的大数敏感性。

### 5.3 每个 pass 需要计算的最小字段

#### 基础信息

```text
pass_id
date
start_time
end_time
duration_min
moving_direction
position_min
position_max
position_range
position_coverage
```

#### 样本量与 QC

```text
n_total
n_valid
n_up
n_down
coverage
flag_low_n
flag_low_updown
flag_low_position_coverage
flag_single_sign
```

建议第一版阈值：

```text
n_total < 100                    -> flag_low_n = TRUE
n_up < 30 或 n_down < 30          -> flag_low_updown = TRUE
position_coverage < 0.6           -> flag_low_position_coverage = TRUE
n_up == 0 或 n_down == 0          -> flag_single_sign = TRUE
```

如果多数 pass 的 `n_total` 低于 100，或大量出现 `n_up/n_down` 不足，则不能把单个 pass 作为主计算单元，应转向多 pass composite。

#### raw 输送与分解

```text
w_mean
co2_mean
F_raw
F_mean
F_turb
F_mean_fraction
```

计算：

```math
F_{raw}=\overline{wc}
```

```math
F_{mean}=\bar w\bar c
```

```math
F_{turb}=\overline{w'c'}
```

```math
F_{mean\_fraction}=\frac{|F_{mean}|}{|F_{mean}|+|F_{turb}|}
```

#### CO2 异常输送

```text
c_ref_pass
F_anom_pass_ref
F_anom_to_raw_ratio
```

计算：

```math
F_{anom,pass}=\overline{w(c-c_{ref,pass})}
```

```math
F_{anom\_to\_raw\_ratio}=\frac{|F_{anom,pass}|}{|F_{raw}|}
```

该指标回答：`c-c_ref` 是否降低了 raw `wc` 的极端量级和背景浓度敏感性。

#### 空气量闭合

```text
A_up
A_down
A_net
I_A
lambda
flag_lambda_extreme
```

计算：

```math
A^+=\sum_{w_i>0}w_i\Delta t_i
```

```math
A^-=\sum_{w_i<0}|w_i|\Delta t_i
```

```math
A_{net}=A^+-A^-
```

```math
I_A=\frac{A^+-A^-}{A^++A^-}
```

```math
\lambda=\frac{A^+}{A^-}
```

如果使用带符号下沉和，则与前述 `-sum(w+)/sum(w-)` 等价。第一版可用 `lambda < 0.2` 或 `lambda > 5` 标记为 `flag_lambda_extreme`，具体阈值后续可按实际分布调整。

#### 上升/下沉 CO2 结构

```text
c_up
c_down
c_up_minus_c_down
```

计算：

```math
c^+=\frac{\sum_{w_i>0}w_i c_i\Delta t_i}{A^+}
```

```math
c^-=\frac{\sum_{w_i<0}|w_i|c_i\Delta t_i}{A^-}
```

```math
c_{up}-c_{down}=c^+-c^-
```

#### 综合 flag

```text
flag_raw_dominated
flag_anom_stable_candidate
flag_concentration_driven
flag_air_imbalance
```

建议初版定义：

```text
flag_raw_dominated = F_mean_fraction > 0.95
flag_anom_stable_candidate = FALSE 仅在低样本、低位置覆盖、single_sign、lambda_extreme 全部为 FALSE 且 F_anom_to_raw_ratio 明显小于 1 时置 TRUE
flag_concentration_driven = abs(I_A) < 0.2 且 abs(c_up_minus_c_down) 较大
flag_air_imbalance = abs(I_A) >= 0.2
```

`c_up_minus_c_down` 的“大”应先依据四天数据分布确定，例如使用 `abs(c_up_minus_c_down)` 的 75% 或 90% 分位数作为阈值。

### 5.4 第一阶段建议输出图

只画三张图，不扩展太多。

1. `F_raw` vs `F_anom_pass_ref`  
   目的：判断 anomaly 方法是否降低 raw `wc` 的背景浓度敏感性。

2. `F_anom_pass_ref` vs `n_total / n_up / n_down`  
   目的：判断极端值是否由小样本造成。

3. `F_anom_pass_ref` vs `c_up_minus_c_down`，点颜色用 `I_A` 或 `moving_direction`  
   目的：判断异常输送是否有气团浓度结构支撑。

### 5.5 第一阶段通过标准

若满足以下条件，则算法可以进入第二步位置分箱和事件窗口分析：

1. 大多数 pass 的样本量和位置覆盖达到最低阈值；
2. `F_anom_pass_ref` 相比 `F_raw` 明显降低极端量级；
3. `F_anom_pass_ref` 的正负和大小能够与 `c_up_minus_c_down`、`I_A`、时段或移动方向建立可解释关系；
4. 极端值主要集中在低样本、低覆盖、single-sign 或 extreme-lambda 的 flagged pass 中。

如果不满足，则先不要做完整移动切面通量解释，应优先调整：

1. 从单 pass 改为多 pass composite；
2. 放宽或重定义 pass；
3. 增大事件窗口；
4. 先只保留 FL 空间形态热图，不输出通量型主结果。

---

## 6. 第一阶段之后的第二步

第一阶段通过后，第二步再做：

1. 位置分箱 `F_anom(x)`、`w_mean(x)`、`co2_anom(x)` 热图；
2. 事件窗口 composite；
3. FL 空间形态分类：`sync_all_track`、`two_ends_strong_middle_weak`、`cvt_above_enhanced`、`south_side_enhanced`、`north_side_enhanced`、`gradient_south_to_north`、`dipole_structure`、`unclear`；
4. 与 `CVT/MT` 的 CO2 次峰、廓线切换、风向转变和标准 EC `F_EC_cov` 做 lead-lag 比较；
5. `lambda` 和最小修正闭合结果作为敏感性，不进入主结论。

---

## 7. 推荐的输出目录

建议后续本地计算输出到：

```text
D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\FL_moving_transect_anomaly_transport
```

内部可分为：

```text
01_pass_feasibility
02_position_binned
03_event_composite
04_figures
05_sensitivity_lambda_closure
```

GitHub 项目记忆中对应更新位置建议为：

```text
next_step/01_FL_moving_transect_anomaly_transport_plan.md
project_memory/workstreams/W_FL_moving_transect_anomaly_transport.md   # 后续若进入正式 workstream 再新增
```

---

## 8. 最终写法边界

正式表述建议：

> 本算法不直接估计传统生态系统 CO2 通量，而是估计 FL 移动切面上相对于背景浓度的 CO2 异常输送，用于诊断复杂地形控制体内平流、储存释放和局地环流对碳通量计量的影响。

英文表述：

> This framework does not directly estimate conventional ecosystem CO2 exchange. Instead, it quantifies apparent CO2 anomaly transport along the FL moving transect and uses it as a diagnostic constraint on advection, storage release, and terrain-driven circulation within the control-volume carbon budget.
