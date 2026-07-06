# 2026-07-01 AP200 QC 脚本与结果位置

## 来源

- 这份记录整理自当前回合直接核验的 4 个 AP200 脚本文件，用于固定 `MT` 和 `CVT` 的 AP200 初步 QC 与 QC 后时序出图入口、阀位映射、主要判据和输出位置。[已核验 E:\Dataset_Level1\MT\AP\QC.R] [已核验 E:\Dataset_Level1\MT\AP\Timeseries_afterQC.R] [已核验 E:\Dataset_Level1\CVT\AP\CVT_QC.R] [已核验 E:\Dataset_Level1\CVT\AP\CVT_timeseries.R]

## 本次新增信息

- `E:\Dataset_Level1\MT\AP\QC.R` 是 `MT` AP200 剖面数据的初步 QC 主脚本。它逐个读取 `E:/Dataset_RAW/MT/MT_AP/20240704-20260131` 下的 `.dat` 文件，先做原始样本级 QC，再把保留样本拼成 profile cycle，最后把汇总结果写到 `E:/Dataset_Level0/MT/AP/qc_summary/20240704-20260131`。[已核验 E:\Dataset_Level1\MT\AP\QC.R]
- `MT` 脚本当前把 `valve_number = 1/2/3/4/5` 映射为 `c8/c13/c17/c20/c29p5`，并把 `1` 号阀位当作轮次起点。原始样本级 QC 规则包括缺测、非目标阀位、重复记录、`CO2_Avg` 范围检查 `250-1000 ppm`、步长/变化率检查、持续平直检查和异常时间间隔检查；轮次级 QC 规则包括 profile 完整性、各层最少样本数、剖面 spread、相邻层突跳和原始 flag 继承。[已核验 E:\Dataset_Level1\MT\AP\QC.R]
- `MT` 脚本的固定输出文件共有 6 类，分别是 `MT_AP_raw_file_qc_summary_20240704_20260131.csv`、`MT_AP_profile_cycle_qc_summary_20240704_20260131.csv`、`MT_AP_profile_day_qc_summary_20240704_20260131.csv`、`MT_AP_profile_missing_dates_20240704_20260131.csv`、`MT_AP_profile_overall_qc_summary_20240704_20260131.csv` 和 `MT_AP_bad_files_20240704_20260131.csv`，都写在 `E:/Dataset_Level0/MT/AP/qc_summary/20240704-20260131`。[已核验 E:\Dataset_Level1\MT\AP\QC.R]
- `E:\Dataset_Level1\MT\AP\Timeseries_afterQC.R` 不是独立读盘脚本，而是直接接在 `cycle_qc_mt` 结果之后使用。它先保留 `qc_keep_cycle == TRUE` 且 5 层都完整的轮次，再基于 `8/13/17/20/29.5 m` 剖面插值到 `zr = 30 m`，计算 `c_zr`、`c_ave` 和 `delta_c = c_zr - c_ave`，最后按天输出 profile 与 `delta_c` 的双面板图，并导出 `MT_AP_profile_cycle_after_qc_20240704_20260131.csv` 到 `E:/Compute_Fcorr/MT_AP_Level1/时序_afterQC`。[已核验 E:\Dataset_Level1\MT\AP\Timeseries_afterQC.R]
- `E:\Dataset_Level1\CVT\AP\CVT_QC.R` 是 `CVT` AP200 剖面数据的初步 QC 主脚本。它读取 `E:/Dataset_Level0/CVT/AP/202411121700-202602020930` 下的 `.dat` 文件，并把结果写到 `E:/Dataset_Level0/CVT/AP/qc_summary/202411121700-202602020930`。当前阀位映射是 `6/7/8 -> c24/c32/c43`，轮次起点是 `6` 号阀位。[已核验 E:\Dataset_Level1\CVT\AP\CVT_QC.R]
- `CVT` 的原始样本级 QC 阈值与 `MT` 基本一致，仍然使用 `250-1000 ppm` 范围、步长/变化率、持续平直和异常时间间隔等检查；但轮次级 `min_obs_per_level` 当前放宽为 `1`，说明 `CVT` profile 汇总允许单层只保留 1 个样本也进入轮次统计。[已核验 E:\Dataset_Level1\CVT\AP\CVT_QC.R]
- `CVT` 脚本同样固定输出 6 类文件，文件名前缀统一为 `CVT_AP_*_202411121700_202602020930.csv`，都写在 `E:/Dataset_Level0/CVT/AP/qc_summary/202411121700-202602020930`。[已核验 E:\Dataset_Level1\CVT\AP\CVT_QC.R]
- `E:\Dataset_Level1\CVT\AP\CVT_timeseries.R` 同样依赖已存在的 `cycle_qc_cvt` 对象，而不是单独从 CSV 回读。它保留 `qc_keep_cycle == TRUE` 且 `c24/c32/c43` 三层完整的轮次，按天输出 3 层 CO2 时序图到 `E:/Compute_Fcorr/CVT_AP_Level1/plot_after_qc`，并导出 `CVT_AP_profile_cycle_after_qc_20241112_20260202.csv`；这个脚本不计算 `delta_c`。[已核验 E:\Dataset_Level1\CVT\AP\CVT_timeseries.R]

## 和现有记忆的关系

- 这批脚本补齐了 W2 晨间 peak 工作流上游 AP200 剖面 QC 的具体入口和结果落点，也把 `MT` 与 `CVT` 的剖面层位定义固定了下来，后续如果要追 AP 剖面异常、profile switch 或日级覆盖，应该先从这些脚本和对应输出目录回溯。[推断: 基于本次核验的 AP200 脚本职责与现有 W2 工作流边界整理]

## 需要长期记住的约束

- `MT` 与 `CVT` 的 AP200 QC 入口并不对称。`MT` 当前脚本直接从 `E:/Dataset_RAW/MT/MT_AP/20240704-20260131` 读原始 `.dat`，而 `CVT` 当前脚本从 `E:/Dataset_Level0/CVT/AP/202411121700-202602020930` 读 `.dat`；后续不要假设两站 AP200 QC 都共用同一层级的源目录。[已核验 E:\Dataset_Level1\MT\AP\QC.R] [已核验 E:\Dataset_Level1\CVT\AP\CVT_QC.R]
- 两个时序脚本都依赖内存中的 `cycle_qc_mt` 或 `cycle_qc_cvt`，说明它们默认运行在 QC 主脚本之后的同一个 R 会话里；如果在干净会话里单独运行，需要先显式生成或读回对应的 cycle 表。[已核验 E:\Dataset_Level1\MT\AP\Timeseries_afterQC.R] [已核验 E:\Dataset_Level1\CVT\AP\CVT_timeseries.R]
