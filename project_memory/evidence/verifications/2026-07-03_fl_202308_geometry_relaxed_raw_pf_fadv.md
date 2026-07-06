# 2026-07-03 FL 202308 geometry-relaxed raw/PF F_adv 计算与日变化图

## 背景

本轮针对 `E:\FL_MASSBALANCE\202308` 中用户提供的几何放宽完整单程，按同一套质量守恒算法分别计算 raw 风和 PF 后风的 `F_adv`。该批单程来自 `2023-03-15` 至 `2023-12-26` 的运行记录，完整单程筛选轨道口径放宽为 `15-255 m`，导出 `1823` 个 `geometry_complete == TRUE` 单程。 [已核验: E:\FL_MASSBALANCE\202308\fl_complete_passes_geometry_relaxed_track15_255_20230315_20231226_summary.txt]

为避免把该诊断量误读为固定塔 EC 通量，当前输出统一用 `F_adv` 命名；它仍是质量守恒闭合后的移动切面垂直输送诊断量，而不是最终生态系统 CO2 通量。 [推断：基于当前质量守恒算法用途和用户命名要求整理]

## 脚本与入口修正

- 已修改 `E:\FL_MASSBALANCE\run_fl_mass_balance_8bin_2ensemble.R`，增加环境变量入口 `FL_MB_PASSES_CSV`、`FL_MB_PF_PARAMS_CSV`、`FL_MB_RAW_FILES_CSV`、`FL_MB_RUNNING_CACHE_CSV`、`FL_MB_TRACK_SOUTH_M` 和 `FL_MB_TRACK_NORTH_M`，以便在不改主流程的情况下复用几何放宽 pass 表和 `15-255 m` 轨道范围。 [已核验: E:\FL_MASSBALANCE\run_fl_mass_balance_8bin_2ensemble.R]
- 同一脚本中修复了 raw 分支：`collapse_minutes()` 不再用标量 `fifelse()` 选择 raw/PF 风列，并拆开 `data.table :=` 赋值顺序，确保 `w_raw_1min` / `w_pf_1min` 先生成后再派生 `w_balance_1min`。 [已核验: E:\FL_MASSBALANCE\run_fl_mass_balance_8bin_2ensemble.R]
- 新增兼容 pass 表脚本 `E:\FL_MASSBALANCE\202308\prepare_geometry_relaxed_passes_for_raw_fadv.R`，输出 `E:\FL_MASSBALANCE\202308\raw_fadv_geometry_relaxed_track15_255\fl_complete_passes_geometry_relaxed_track15_255_for_raw_fadv.csv`，把 `candidate_id` 映射为 `pass_id` 并补齐主脚本需要的字段。 [已核验: E:\FL_MASSBALANCE\202308\raw_fadv_geometry_relaxed_track15_255\prepare_geometry_relaxed_passes_for_raw_fadv_summary.txt]

注意：主脚本自动生成的 `manifest.txt` 仍可能保留一行旧文字 `positions from 5 to 240 m`；本轮 postprocess summary 已正确记录实际计算轨道为 `15-255 m`。 [已核验: E:\FL_MASSBALANCE\202308\raw_fadv_geometry_relaxed_track15_255\FL_raw_F_adv_geometry_relaxed_track15_255_summary.txt] [已核验: E:\FL_MASSBALANCE\202308\pf_fadv_geometry_relaxed_track15_255\FL_pf_F_adv_geometry_relaxed_track15_255_summary.txt]

## raw F_adv 结果

raw 版本输出根目录为 `E:\FL_MASSBALANCE\202308\raw_fadv_geometry_relaxed_track15_255`。主结果包括：

- `results\FL_raw_F_adv_geometry_relaxed_track15_255_by_pass.csv`
- `results\FL_raw_F_adv_geometry_relaxed_track15_255_daily_summary.csv`
- `results\FL_raw_F_adv_geometry_relaxed_track15_255_direction_summary.csv`
- `results\FL_mass_balance_raw_w_1min.csv`
- `qc\FL_mass_balance_raw_w_file_qc.csv`
- `qc\FL_mass_balance_raw_w_flag_summary.csv`
- `FL_raw_F_adv_geometry_relaxed_track15_255_summary.txt`

raw 版本请求 `1823` 个单程，实际计算 `1777` 个；其中 mixed-sign `1628` 个，`broad_closed=398`，`numerically_closed=890`，`extreme_forced=340`，`single_sign_up=28`，`single_sign_down=121`。未计算原因包括 `no_raw_file_for_pass_date=43` 和分钟/标量覆盖失败 `3` 个；mixed-sign 的最大 `abs(corrected_sum_w)` 为 `2.324e-15`。 [已核验: E:\FL_MASSBALANCE\202308\raw_fadv_geometry_relaxed_track15_255\FL_raw_F_adv_geometry_relaxed_track15_255_summary.txt]

raw mixed-sign 日变化图位于 `E:\FL_MASSBALANCE\202308\raw_fadv_geometry_relaxed_track15_255\figures\FL_raw_mixed_sign_F_adv_diurnal_mean.png`，对应 CSV 和 summary 同目录。该图按 mixed-sign 样本合并，不再区分 lambda 分组；样本为 `1628` 个 mixed-sign 单程、`74` 个观测日期、`1798` 个 date-half-hour 行，纵轴设为 `-25` 至 `15`。最负的半小时均值为 `12:30=-14.95`、`13:00=-14.87`、`12:00=-13.97`、`13:30=-13.44`、`14:00=-12.18`。 [已核验: E:\FL_MASSBALANCE\202308\raw_fadv_geometry_relaxed_track15_255\figures\FL_raw_mixed_sign_F_adv_diurnal_mean_summary.txt]

## raw 早晨爬升诊断

对 raw 版本早晨 `08:00-09:00` 的诊断输出位于：

- `E:\FL_MASSBALANCE\202308\raw_fadv_geometry_relaxed_track15_255\diagnose_morning_diurnal_rise.R`
- `E:\FL_MASSBALANCE\202308\raw_fadv_geometry_relaxed_track15_255\figures\FL_raw_mixed_sign_morning_class_summary.csv`
- `E:\FL_MASSBALANCE\202308\raw_fadv_geometry_relaxed_track15_255\figures\FL_raw_mixed_sign_morning_date_contributors.csv`

当前解释是：raw 08:30 的正向爬升不是多数日期都稳定出现的结构，而是少数日期的正向 date-half-hour 值抬高均值。08:30 的 class 加权均值显示 `broad_closed=6.69`、`numerically_closed=3.75`、`extreme_forced=-0.07`，因此该正峰不主要由 `extreme_forced` 组直接造成。主要正贡献日期包括 `2023-08-25=60.76`、`2023-09-28=50.41`、`2023-09-27=38.02`、`2023-10-01=37.07` 和 `2023-09-30=25.84`；09:00 最大正贡献为 `2023-09-27=102.64`。 [已核验: E:\FL_MASSBALANCE\202308\raw_fadv_geometry_relaxed_track15_255\figures\FL_raw_mixed_sign_morning_class_summary.csv] [已核验: E:\FL_MASSBALANCE\202308\raw_fadv_geometry_relaxed_track15_255\figures\FL_raw_mixed_sign_morning_date_contributors.csv]

因此，这批数据在九点前后的 raw 形态与此前全量均值不一致，主要可归因于：几何放宽后 2023 年样本组成不同、恢复了 8-9 月若干完整日期、mixed-sign 合并口径、raw `Uz` 对少数日期的均值敏感，以及少数高正值日期对均值的影响。当前证据不支持把该早晨正峰简单解释为 lambda 强制闭合导致。 [推断：基于 raw 早晨 class 和日期贡献表整理]

## PF F_adv 结果

PF 版本输出根目录为 `E:\FL_MASSBALANCE\202308\pf_fadv_geometry_relaxed_track15_255`。主结果包括：

- `results\FL_pf_F_adv_geometry_relaxed_track15_255_by_pass.csv`
- `results\FL_pf_F_adv_geometry_relaxed_track15_255_daily_summary.csv`
- `results\FL_pf_F_adv_geometry_relaxed_track15_255_direction_summary.csv`
- `results\FL_mass_balance_PF8bin_2ensemble_1min.csv`
- `qc\FL_mass_balance_PF8bin_2ensemble_file_qc.csv`
- `qc\FL_mass_balance_PF8bin_2ensemble_flag_summary.csv`
- `FL_pf_F_adv_geometry_relaxed_track15_255_summary.txt`

PF 版本请求 `1823` 个单程，实际计算 `1777` 个；其中 mixed-sign `1734` 个，`broad_closed=653`，`numerically_closed=984`，`extreme_forced=97`，`single_sign_up=43`，`single_sign_down=0`。未计算原因同 raw 版本，为 `no_raw_file_for_pass_date=43` 和分钟/标量覆盖失败 `3` 个；mixed-sign 最大 `abs(corrected_sum_w)` 为 `1.894e-15`。 [已核验: E:\FL_MASSBALANCE\202308\pf_fadv_geometry_relaxed_track15_255\FL_pf_F_adv_geometry_relaxed_track15_255_summary.txt]

PF mixed-sign 日变化图位于 `E:\FL_MASSBALANCE\202308\pf_fadv_geometry_relaxed_track15_255\figures\FL_pf_mixed_sign_F_adv_diurnal_mean.png`。样本为 `1734` 个 mixed-sign 单程、`74` 个观测日期、`1836` 个 date-half-hour 行，纵轴设为 `-25` 至 `10`。最负的半小时均值为 `12:30=-14.67`、`08:30=-14.53`、`12:00=-12.38`、`13:00=-12.23`、`09:00=-11.44`。 [已核验: E:\FL_MASSBALANCE\202308\pf_fadv_geometry_relaxed_track15_255\figures\FL_pf_mixed_sign_F_adv_diurnal_mean_summary.txt]

## raw 与 PF 的当前对比解释

PF 后同一批单程仍保留午间负向 trough，但把 raw 08:30 的正向爬升改为明显负谷值。质量分层上，PF 使 `extreme_forced` 从 raw 的 `340` 降到 `97`，`single_sign_down` 从 raw 的 `121` 降到 `0`，同时 `broad_closed` 从 `398` 增至 `653`。这说明 PF 后平均垂直风场更接近混合符号和可闭合状态，降低了 raw `Uz` 造成的高风险闭合类别比例。 [已核验: E:\FL_MASSBALANCE\202308\raw_fadv_geometry_relaxed_track15_255\FL_raw_F_adv_geometry_relaxed_track15_255_summary.txt] [已核验: E:\FL_MASSBALANCE\202308\pf_fadv_geometry_relaxed_track15_255\FL_pf_F_adv_geometry_relaxed_track15_255_summary.txt] [推断：基于 raw/PF summary 的类别数量对比整理]

当前最稳妥的写法是：`202308` 几何放宽批次显示 `F_adv` 日变化对风处理口径敏感，尤其早晨 08:30-09:00；PF 后质量闭合类别更集中于 `broad_closed/numerically_closed`，但这不自动证明 PF 后曲线是真实通量，只说明在当前质量守恒诊断框架下，PF 版本比 raw 版本更少受单符号下沉和极端闭合类别支配。 [推断：基于当前算法边界和 raw/PF 对比整理]

## 仍需注意

- 本批 `15-255 m` 几何放宽口径与正式 `PF_8bin` 参数原始建模口径 `5-240 m` 并不完全相同；当前 PF 版本是复用既有 PF 参数到放宽轨道单程上，适合做敏感性和样本恢复诊断，不应直接替代正式全量主口径。 [推断：基于 `PF_8bin` 方法边界和本轮轨道口径整理]
- raw/PF 输出虽然命名为 `F_adv`，但仍来自 `F_lambda_pf_umol_m2_s` 别名，是质量守恒闭合后的移动切面垂直输送诊断量。后续和 `MT/CVT` EC 通量并列时，应继续强调它不是第三个固定塔 EC 通量。 [已核验: E:\FL_MASSBALANCE\202308\raw_fadv_geometry_relaxed_track15_255\FL_raw_F_adv_geometry_relaxed_track15_255_summary.txt] [已核验: E:\FL_MASSBALANCE\202308\pf_fadv_geometry_relaxed_track15_255\FL_pf_F_adv_geometry_relaxed_track15_255_summary.txt]
