# 2026-07-09 固定塔 rotation 方法机制诊断（w_mean / w'c' / gapfill 时段与风向）

## 本次目标

在不再重跑原始通量的前提下，补做双塔公共四方法 `no_rotation / dr / global_pf / sector_pf` 的机制诊断，回答两类问题：

1. 四方法的 `w_mean` 与 `w'c'` 日变化、风向分组差异主要出现在哪里。
2. 四方法进入 strict gapfill 的时间段是否集中在特定时段或风向。

## 输入与口径

- `w_mean` / `w'c'` 部分复用既有 rotation 诊断表，因为当前 standardized full-flux 产品本身不含 `w_mean`：
  - `D:\00 博士阶段\博一\05 Project\com_rotation\results\analysis\tables\13_w_sigma_flux_joined.csv`
  - `D:\00 博士阶段\博一\05 Project\com_rotation\results\analysis\tables\19_state_reference_wind_stability_sunrise.csv`
  - `D:\00 博士阶段\博一\05 Project\com_rotation\results\analysis\tables\20_method_range_by_timestamp_with_state.csv`
- gapfill 部分直接复用 standardized strict rerun 的 `2025` per-method `30min gapfilled` 明细表，并按 `ts_key` 回连 standardized 输入中的风向角。
- gapfill 口径仍为 `qc_co2 <= 1 + flag9_co2 <= 3 + 夜间 u*`，且只保留双塔公共四方法，不再纳入 `MT season_sector_pf`。

## 新增脚本

- `D:\00 博士阶段\99 Project\06 EA\scripts\analyze_fixed_tower_rotation_wmean_wc_gapfill_2025.R`

## 主要输出

输出目录：

- `E:\Dataset_Level1\FixedTower\EC\rotation_sensitivity_standardized_2025\mechanism_diagnostics`

表格：

- `rotation_wmean_wc_diurnal_summary.csv`
- `rotation_wmean_wc_wind_sector_summary.csv`
- `rotation_wmean_wc_method_range_by_sector.csv`
- `rotation_gapfill_fraction_by_hour_strict.csv`
- `rotation_gapfill_fraction_by_wind_sector_strict.csv`
- `rotation_gapfill_fraction_time_wind_sector_strict.csv`
- `rotation_gapfill_missing_wind_summary_strict.csv`

图件：

- `figures\rotation_wmean_diurnal_comparison_2025.png`
- `figures\rotation_wprime_diurnal_comparison_2025.png`
- `figures\rotation_sigma_w_diurnal_comparison_2025.png`
- `figures\rotation_sigma_co2_diurnal_common_periods.png`
- `figures\rotation_wc_diurnal_comparison_2025.png`
- `figures\rotation_wmean_wind_sector_comparison_2025.png`
- `figures\rotation_wc_wind_sector_comparison_2025.png`
- `figures\rotation_gapfill_fraction_by_hour_strict.png`
- `figures\rotation_gapfill_fraction_by_wind_sector_strict.png`
- `figures\rotation_gapfill_fraction_time_wind_sector_strict.png`

## 核心结果

### 1. `w_mean` 差异不是均匀分布，而是集中在白天和特定来流扇区

- `dr` 的 `w_mean` 中位数在多数时段和扇区都最接近 `0`，符合双旋转把平均垂直风压到近零的预期。
- `no_rotation` 的 `w_mean` 偏移最大，且 `MT` 明显强于 `CVT`。
- `MT` 的 `w_mean` 方法分歧峰值出现在白天中午后，按小时最大约 `0.35 m s^-1`，按风向主要集中在 `120-150 / 150-180 / 180-210` 扇区。
- `CVT` 的 `w_mean` 方法分歧整体更小，按小时最大约 `0.16 m s^-1`，按风向主要集中在 `060-090 / 150-180 / 090-120` 扇区。

### 2. `w'c'` 差异也主要集中在白天活跃交换时段

- 两塔的四方法 `w'c'` 日变化分歧都在白天放大，而不是夜间均匀扩散。
- `MT` 的 `w'c'` 方法分歧更强，小时尺度最大出现在约 `11:00`，四方法中位数跨度约 `2.36 umol m^-2 s^-1`；风向上最大集中在 `180-210` 和 `150-180`。
- `CVT` 的 `w'c'` 分歧较弱但仍集中在上午到中午，小时尺度最大约 `1.41 umol m^-2 s^-1`；风向上主要在 `150-180 / 120-150 / 240-270`。
- 说明 rotation 影响并非只是常数平移，而是在强交换时段和敏感来流方向上改变协方差量级。

### 2b. `w'` 日变化图已补出，但当前只能用 `sigma_w` 作为可观测代理

- 本轮新增 `rotation_wprime_diurnal_comparison_2025.png`，其中 `w'` 以 `sigma_w` 的 `30 min` 统计量表示。
- 该图与 `w_mean` 图采用相同的 `REgov` 白底报告风格，并按用户要求把线宽进一步压细、纵轴刻度加密。
- 随后已按最小路径补出 `rotation_sigma_co2_common_periods.csv` 与 `rotation_sigma_co2_paired_common_periods.csv`：它们直接复用同一批 common-period Level0 高频 `CO2` 序列，按半小时窗口计算 `sigma_co2 = sd(co2)`，不重跑 `year audit / gapfill / annual NEE`。
- 其中 `rotation_sigma_co2_common_periods.csv` 共 `5700` 行，覆盖 `CVT A=1578 / CVT B=1272 / MT A=1578 / MT B=1272`；`rotation_sigma_co2_paired_common_periods.csv` 共 `5123` 行，与现有 `13_w_sigma_flux_joined.csv` 的 paired 时间键一一对齐。
- 当前 `MT` 原始 `sigma_co2` 仍可见少量极大尖峰，因此后续如果直接画 `c'` 日变化，应继续沿用中位数 + 四分位带，而不宜直接用均值。
- 随后已补出两张 `sigma` 日变化图：`rotation_sigma_w_diurnal_comparison_2025.png` 复用四方法 `sigma_w` 半小时汇总表，按方法着色；`rotation_sigma_co2_diurnal_common_periods.png` 复用 paired `sigma_co2` 表，按站点分面并用中位数 + 四分位带压制 `MT` 尖峰的影响。

### 3. strict gapfill 明显集中在特定时段，但方法差异只在少数窗口被放大

- `CVT` 四方法的 gapfill 高值主要集中在白天，尤其上午晚些到下午早些时段；各方法最高半小时窗口通常在 `08:30-15:30`，峰值约 `0.83-0.89`。
- `MT` 四方法的 gapfill 高值更偏夜间末段和下午，最高窗口常见于 `01:30-03:00` 与 `14:30-15:30`，峰值约 `0.80-0.86`。
- 方法间 gapfill 差异最大的并不是各自 gapfill 最高的时段，而是 `CVT` 的傍晚到前半夜（约 `19:00-21:00`）以及 `MT` 的傍晚过渡时段（约 `17:00-18:00`），说明这里更容易被不同 rotation 的 QC/flag 组合放大。

### 4. strict gapfill 也有风向集中性，但其方法差异弱于时段差异

- `CVT` 的高 gapfill 风向主要集中在 `180-210 / 210-240 / 150-180`，且 `000-030 / 330-360 / 300-330` 扇区的方法间差异更明显，`no_rotation` 往往更高。
- `MT` 的高 gapfill 风向主要集中在 `120-150 / 150-180 / 180-210 / 210-240`，而方法间差异最大的扇区是 `060-090` 与 `030-060`，其中 `sector_pf` 在部分扇区 gapfill 比例更高。
- 总体上，gapfill 的“是否集中”答案是肯定的，但其主控轴首先是时段，其次才是风向；方法间差异更多表现为对这些高风险时段/扇区的放大或缓解程度不同。

## 解释边界

- 这里的 `w_mean` / `w'c'` 机制图不是直接从本轮 standardized rerun 输入表里提取的，而是复用既有四方法 rotation 诊断库；因此它们用于解释方法差异的方向与集中区，而不是替代 strict annual NEE 主结果。
- gapfill 时段/风向诊断则直接基于本轮 `2025` strict rerun 的 per-method 明细表，可与当前 NEE 结果一一对应。
- `sigma_co2` 补表同样不是从 standardized rerun `30 min` 成品反推出来的，而是回到 common-period Level0 高频 `CO2` 序列直接汇总得到；因此它适合用于 `c'` 波动可视化，不应与当前 annual NEE 主结果混写成同一层级产品。
