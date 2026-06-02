# FL pass 级异常输送算法第一步可行性验证结果

## 1. 结果性质

本文档记录 `FL moving-transect CO2 anomaly transport diagnostic framework` 的第一步可行性验证结果。该步骤的目标不是生成最终 CO2 通量，而是判断 `FL` 移动平台数据是否具备继续进入位置分箱、事件 composite 和控制体机制诊断的基础。

本阶段使用的核心检验是：

```math
F_{raw}=\overline{wc}
```

```math
F_{anom}=\overline{w(c-c_{ref})}
```

其中第一步采用：

```math
c_{ref}=\bar c_{pass}
```

即每个移动 pass 内的平均 CO2 浓度。

---

## 2. 第一阶段主要结果

### 2.1 数据量足够

共识别 `193` 个移动 pass，匹配高频点约 `338万` 行。

该结果说明：`FL` 数据在 pass 层级具备足够样本量，第一阶段不需要退回到更粗糙的全天或纯事件窗口聚合。

### 2.2 位置覆盖度良好

四天大多数 pass 的位置覆盖接近完整轨道，日中位 `position_coverage` 约 `0.999`。

该结果说明：大多数 pass 可以代表较完整的 `0-245 m` 移动轨道，因此后续进入位置分箱和空间形态分类是可行的。

### 2.3 样本 QC 通过

没有出现以下主要问题：

```text
low_n
low_updown
single_sign
```

这说明每个 pass 的总样本量、上升/下沉样本量以及正负 `w` 结构均满足第一阶段最低计算条件。

### 2.4 CO2 异常输送计算有效降低 raw `wc` 的量级敏感性

使用 `c_ref = pass_mean CO2` 后，`F_anom` 相比 raw `wc` 被大幅压低。

四天 `F_anom_to_raw_ratio` 日中位约为：

```text
0.00027 - 0.00042
```

这说明 `c-c_ref` 处理有效移除了背景 CO2 大数与 `w_mean` 相乘造成的主要量级放大。

该结果支持继续使用：

```math
F_{anom}=\overline{w(c-c_{ref})}
```

作为后续移动切面 CO2 异常输送诊断的主线候选量。

### 2.5 主要风险来自空气量不平衡

第一阶段结果显示：

```text
lambda_extreme = 76 / 193
air_imbalance = 174 / 193
```

这说明虽然 `F_anom` 已经降低背景浓度敏感性，但 pass 内正负垂直空气量仍普遍不平衡。

因此后续不能只报告 `F_anom` 的总体均值，必须按空气量闭合状态分组解释。

### 2.6 raw 背景项仍然主导 raw `wc`

第一阶段结果显示：

```text
raw_dominated = 192 / 193
```

这说明 raw `wc` 仍然主要由：

```math
\bar w \bar c
```

控制。

因此 raw `wc` 只能作为背景项主导的表观输送诊断量，不应被写成传统生态系统 CO2 通量。

### 2.7 浓度结构主导的 pass 很少

第一阶段结果显示：

```text
concentration_driven = 3 / 193
```

这说明在 pass 层级，绝大多数结果并不是由单纯上升/下沉气团 CO2 浓度差主导，而是仍受到空气量不平衡或平均垂直运动结构控制。

---

## 3. 第一阶段判断

第一步可行性验证通过。

理由如下：

1. pass 数量足够；
2. 高频样本量足够；
3. 位置覆盖度接近完整轨道；
4. 基础样本 QC 通过；
5. `F_anom` 明显压低 raw `wc` 的背景浓度大数敏感性；
6. 主要风险已经被识别为 `lambda_extreme` 和 `air_imbalance`，可以在后续分组中处理。

但该阶段结果不能直接解释为最终 CO2 通量。

更准确的解释是：

> `FL` pass 级数据具备进入移动切面 CO2 异常输送诊断的基础；`F_anom` 是比 raw `wc` 更稳健的候选诊断量，但后续必须按空气量不平衡、lambda 极端值、位置覆盖和事件窗口进行分组解释。

---

## 4. 对后续计算的限制条件

后续进入位置分箱和事件 composite 时，必须保留以下分组：

```text
lambda_extreme / non_lambda_extreme
air_imbalance / near_air_balance
raw_dominated / non_raw_dominated
concentration_driven / non_concentration_driven
moving_direction
position_coverage class
event_window
wind_sector
```

其中最重要的是：

```text
lambda_extreme
air_imbalance
```

因为当前主要风险不是样本量不足，而是正负空气量不闭合。

---

## 5. 第二步建议

下一步可以进入：

> position-binned FL anomaly transport and event-composite analysis

即按位置分箱和事件窗口计算 `F_anom(x)`、`w_mean(x)`、`CO2_anom(x)` 和空间形态标签。

第二步最小输出建议包括：

```text
FL_position_binned_anomaly_transport.csv
FL_event_composite_anomaly_transport.csv
FL_event_spatial_pattern_labels.csv
```

优先图件包括：

1. `position × time` 的 `F_anom` 热图；
2. `position × time` 的 `w_mean` 热图；
3. `position × time` 的 `CO2_anom` 热图；
4. `F_anom` 按 `lambda_extreme` 与 `air_imbalance` 分组的对比图；
5. `F_anom` 与 CO2 次高峰、CVT/MT 廓线切换、风向转变之间的 lead-lag 图。

---

## 6. 进入第二步时的核心判读边界

第二步中，`F_anom` 仍应被解释为：

> 相对于 pass 或事件背景浓度的 CO2 异常输送。

不应写成：

> 最终生态系统 CO2 通量。

若某一事件窗口中 `F_anom` 空间形态稳定，并且与 `CVT/MT` 的 CO2 次高峰、廓线结构切换、风向转变或标准 EC `F_EC_cov` 具有明确先后关系，则该结果可以用于机制归因。

若 `F_anom` 主要集中在 `lambda_extreme` 或强 `air_imbalance` pass 中，则应降级为敏感性结果，不能作为主结论。
