# 2026-07-10 FL 公共时段原始 sigma_co2

## 目的

给 `FL` 补一版与 rotation 方法解耦的 `raw sigma_co2`：

- 不使用各方法 `30 min` 结果表中的 `scalar_sd`
- 回到原始 `CO2` 高频序列
- 只保留每个 `source_group` 下 `no_rotation / dr / PF_8bin_2ensemble` 三方法共同存在的半小时 `timestamp`
- 再按固定塔同类产品的思路，计算这些公共时段的 `30 min sigma_co2`

## 脚本

- 主脚本：`D:\00 博士阶段\99 Project\06 EA\scripts\build_fl_full_ec_sigma_co2_common_periods.R`
- 合并脚本：`D:\00 博士阶段\99 Project\06 EA\scripts\combine_fl_full_ec_sigma_co2_common_periods.R`

## 输入

- `FL` 全量多旋转 `30 min` 结果根目录：`E:\Dataset_Level1\Flares\EC_ecpreproc`
- `bundle index`：`E:\FL_MASSBALANCE\202308\downstream_multicaliber\bundle_index.csv`
- 原始高频根目录：`E:\Dataset_Level0\Flares\EC`

## 输出

正式总表与图：

- `E:\Dataset_Level1\Flares\EC_ecpreproc\FL_sigma_co2_raw_common_periods.csv`
- `E:\Dataset_Level1\Flares\EC_ecpreproc\FL_sigma_co2_raw_common_periods_diurnal_plot_data.csv`
- `E:\Dataset_Level1\Flares\EC_ecpreproc\figures_diurnal\FL_sigma_co2_raw_common_periods_diurnal.png`
- `E:\Dataset_Level1\Flares\EC_ecpreproc\FL_sigma_co2_raw_common_periods_summary.txt`

分组中间表与图：

- `E:\Dataset_Level1\Flares\EC_ecpreproc\FL_sigma_co2_raw_common_periods_oldcode_0_245.csv`
- `E:\Dataset_Level1\Flares\EC_ecpreproc\FL_sigma_co2_raw_common_periods_batch_b_complete.csv`
- `E:\Dataset_Level1\Flares\EC_ecpreproc\FL_sigma_co2_raw_common_periods_main_complete.csv`
- 以及对应的 `*_diurnal_plot_data_*.csv` 和 `figures_diurnal\FL_sigma_co2_raw_common_periods_diurnal_*.png`

## 口径

- 公共窗口定义：在每个 `source_group` 内，取 `no_rotation / dr / PF_8bin_2ensemble` 三方法结果表 `timestamp` 的交集
- 原始 `CO2` 提取：直接从 `TOA5 Time_Series` 原始文件读取 `TIMESTAMP + CO2`
- 时间处理：显式按 `Asia/Shanghai` 解析
- 裁切边界：沿用 `FL` 全量 `EC` runner 的 `pass-window clipping`
- 统计量：对每个公共半小时窗口内、且落在 pass 窗口内的原始 `CO2` 点计算 `sigma_co2 = sd(CO2)`

## 验证

- 最终总表共 `4685` 行，覆盖 `3` 个 `source_group`
- 三个 `source_group` 都覆盖完整 `48` 个 half-hour bin
- 分组结果规模：
  - `oldcode_0_245 = 1822` 行
  - `batch_b_complete = 1063` 行
  - `main_complete = 1800` 行
- 总图已成功输出为 pooled `diurnal` 图，中心线为中位数，色带为 `25-75%` 四分位范围

## 解释边界

这份 `FL raw sigma_co2` 产品与此前 `FL_full_ec_sigma_diurnal.png` 中的 `scalar_sd` 不同：

- 旧图里的 `scalar_sd` 是各 rotation 方法各自 `lag + valid_samples_by_bin QC` 后的样本标准差
- 这次的新表和新图则是不分方法、只按公共 `timestamp` 回到原始 `CO2` 序列计算得到

因此这份新产品更适合拿来与固定塔“公共时段原始 `sigma_co2`”做口径对齐比较。
