# 2026-06-01 FL 老师 1 min 方法复现版质量守恒 lambda

## 本次运行

- 新增并运行脚本 `D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\run_fl_mass_balance_lambda_teacher_1min.R`，用于复现 `E:\老师拷贝大量数据（4-30）\R\EC_process\Fc_adv_2025.R` 的方法意图。脚本先把 `D:\00EDDYPRO\com_260401\Flares` 下四天 TOA5 高频数据按 `floor(TIMESTAMP, 1 min)` 聚合为 1 min 均值，再按 `D:\00 博士阶段\博一\05 Project\com_260326\小车运行.csv` 中每个移动单程的起止时间四舍五入到分钟，生成闭区间 `1 min` 序列并计算 `lambda`。 [已核验: `D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\run_fl_mass_balance_lambda_teacher_1min.R`] [已核验: `D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\FL_mass_balance_lambda_teacher_1min\FL_teacher_1min_lambda_manifest.txt`]
- 本版保留老师方法的核心设定：`1 min` 均值作为 `w.line`，移动单程超过 `35` 个 1 min 点则跳过，输出时间 `output_time` 四舍五入到邻近半小时。与原 `Fc_adv_2025.R` 不同的是，本脚本修复了 2025 版中 `index <- which(as.POSIXct(data.ec$TimeInterval)==time.line[1])` 被注释导致的潜在索引错误，改为按每个单程的完整 1 min 时间序列精确匹配。 [已核验: `E:\老师拷贝大量数据（4-30）\R\EC_process\Fc_adv_2025.R`] [已核验: `D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\run_fl_mass_balance_lambda_teacher_1min.R`]
- 输出目录为 `D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\FL_mass_balance_lambda_teacher_1min`，主要输出包括 `FL_teacher_1min_means.csv`、`FL_teacher_1min_lambda_by_run.csv`、`FL_teacher_1min_daily_summary.csv`、`FL_teacher_1min_direction_summary.csv`、`FL_teacher_1min_skipped_runs.csv` 和 `FL_teacher_1min_compare_10hz.csv`。 [已核验: `D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\FL_mass_balance_lambda_teacher_1min`]

## 核心结果

- 四天 TOA5 数据共读取 `3,455,999` 行高频记录，聚合为 `5,760` 行 1 min 均值。目标范围内共有 `188` 个移动单程，未出现超过 `35` 个 1 min 点的单程；有 `2` 个单程因缺少完整 1 min 数据被跳过，最终计算 `186` 个单程。 [已核验: `D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\FL_mass_balance_lambda_teacher_1min\FL_teacher_1min_lambda_manifest.txt`] [已核验: `D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\FL_mass_balance_lambda_teacher_1min\FL_teacher_1min_skipped_runs.csv`]
- 按输出日期汇总的单程数为：`2025-03-20 = 42`、`2025-03-21 = 48`、`2025-03-22 = 48`、`2025-03-23 = 48`。`single_sign` 段共 `18` 个，`extreme_lambda` 段共 `21` 个；其中 `single_sign` 段按老师规则 `lambda = 1`，不会强制平衡正负风量。 [已核验: `D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\FL_mass_balance_lambda_teacher_1min\FL_teacher_1min_lambda_by_run.csv`] [已核验: `D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\FL_mass_balance_lambda_teacher_1min\FL_teacher_1min_daily_summary.csv`]
- 非 `single_sign` 段修正后 `corrected_sum_w` 最大绝对残差约为 `4.11e-15`，说明 1 min 复现版中 `lambda = -sum(w[w > 0]) / sum(w[w < 0])` 的质量守恒修正数值上成立。所有段一起统计时，最大残差为 `15.18`，该值来自 `single_sign` 段，因为这些段按规则不做正负风量平衡。 [已核验: `D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\FL_mass_balance_lambda_teacher_1min\FL_teacher_1min_lambda_by_run.csv`]
- 与前一版 10 Hz 原始点计算相比，1 min 老师复现版可比较单程数为 `186`；两者 `lambda` 中位数相近，1 min 版约为 `1.696`，10 Hz 版约为 `1.716`，但逐段差异较大，`lambda_teacher_1min / lambda_10hz` 的中位数约为 `1.466`，平均绝对差约为 `35.67`。 [已核验: `D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\FL_mass_balance_lambda_teacher_1min\FL_teacher_1min_compare_10hz.csv`]

## 可视化输出

- 新增并运行脚本 `D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\plot_fl_mass_balance_1min_lambda_flux.R`，对 1 min 质量守恒结果绘制 `lambda` 和质量守恒修正后的 `co2_transport_lambda` 图件。图件输出到中性目录 `D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\FL_mass_balance_lambda_1min\figures`。 [已核验: `D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\plot_fl_mass_balance_1min_lambda_flux.R`] [已核验: `D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\FL_mass_balance_lambda_1min\figures\FL_mass_balance_1min_lambda_flux_visualization_manifest.csv`]
- 当前图件包括 `mass_balance_1min_lambda_time_series.png`、`mass_balance_1min_lambda_daily_distribution.png`、`mass_balance_1min_corrected_flux_time_series.png`、`mass_balance_1min_flux_before_after.png`、`mass_balance_1min_corrected_flux_daily_distribution.png`、`mass_balance_1min_lambda_vs_corrected_flux.png`、`mass_balance_1min_lambda_heatmap.png` 和 `mass_balance_1min_corrected_flux_heatmap.png`。主图检查显示图像正常渲染，非 `ok` 的 `lambda` 段已在 `lambda` 图和通量热图中单独标记；新绘图脚本和新出图目录中已不再保留 `teacher-style` 或 `teacher_1min` 命名。 [已核验: `D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\FL_mass_balance_lambda_1min\figures`]
- 按用户要求额外新增并运行 OK-only 可视化脚本 `D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\plot_fl_mass_balance_1min_ok_only.R`，只保留 `lambda_class == ok`，排除 `extreme` 和 `single_sign` 段后重新绘制 `lambda` 和 `co2_transport_lambda`。图件输出到 `D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\FL_mass_balance_lambda_1min\figures_ok_only`，共 `8` 张 PNG，并生成 `FL_mass_balance_1min_ok_only_summary.csv`。 [已核验: `D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\plot_fl_mass_balance_1min_ok_only.R`] [已核验: `D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\FL_mass_balance_lambda_1min\figures_ok_only\FL_mass_balance_1min_ok_only_summary.csv`]
- OK-only 过滤后四天分别保留 `37`、`38`、`35` 和 `37` 个移动单程；修正后 `co2_transport_lambda` 的最大绝对值降到约 `58.50`，不再出现 `single_sign` 导致的数千量级。 [已核验: `D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\FL_mass_balance_lambda_1min\figures_ok_only\FL_mass_balance_1min_ok_only_summary.csv`]

## 方法边界

- 该结果是老师方法意图的 1 min 复现版，不是直接复制 `Fc_adv_2025.R` 的潜在索引错误运行结果。若要复现“原文件逐字运行”的错误状态，需要单独运行带注释索引的版本，但其科学含义不稳定。 [推断: 基于 `Fc_adv_2025.R` 与本次脚本差异整理]
- 本版与 10 Hz 版都按移动单程窗口计算 `lambda`，区别在采样层级：老师复现版使用每分钟均值 `Uz`，10 Hz 版使用单程内所有高频 `Uz` 样本。因此两版可以用于敏感性比较，不能直接混写为同一口径。 [推断: 基于本次两个脚本的输入和窗口定义整理]
