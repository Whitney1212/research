# 2026-06-03 FL moving-transect anomaly transport feasibility

## 来源

- 用户要求根据 `next_step/01_FL_moving_transect_anomaly_transport_plan.md` 的思路，调用 REgov 和项目记忆检查信息是否足够，并在 `D:\00 博士阶段\博一\05 Project\com_mass_balance` 中完成第一步可行性计算和核心结构图。 [来源: 用户当前对话 2026-06-03]
- 用户补充可复用的小车位置匹配代码入口：`D:\00 博士阶段\99 Project\04 Lee\diagnose_w4_mobile_ec_circulation.R`，以及 `D:\00 博士阶段\博一\05 Project\com_260401\com_0401` 中的小车位置匹配代码和结果。 [来源: 用户当前对话 2026-06-03]
- 本轮已核验输出脚本、CSV 表和图件均已生成到 `D:\00 博士阶段\博一\05 Project\com_mass_balance`。 [已核验: D:\00 博士阶段\博一\05 Project\com_mass_balance]

## 第一阶段可行性计算

- 新增并运行 `D:\00 博士阶段\博一\05 Project\com_mass_balance\run_fl_pass_anomaly_transport_feasibility.R`。该脚本读取 FL 高频 TOA5 与小车运行位置表，按移动单程构建 `pass_id`，并计算每个 pass 的 `F_raw`、`F_mean`、`F_turb`、`F_anom_pass_ref`、`A_up`、`A_down`、`I_A`、`lambda`、`c_up`、`c_down` 和质量标记。 [已核验: D:\00 博士阶段\博一\05 Project\com_mass_balance\run_fl_pass_anomaly_transport_feasibility.R]
- 主输出 `FL_pass_anomaly_transport_feasibility.csv` 共 `193` 个 pass，覆盖 `2025-03-20` 到 `2025-03-23`。按日 pass 数分别为 `50`、`48`、`48` 和 `47`。匹配到的高频点轻量表为 `FL_pass_matched_points_light.csv`，共 `3,381,493` 行。 [已核验: D:\00 博士阶段\博一\05 Project\com_mass_balance\FL_pass_anomaly_transport_feasibility.csv] [已核验: D:\00 博士阶段\博一\05 Project\com_mass_balance\FL_pass_matched_points_light.csv]
- 质量标记显示：`low_n`、`low_updown` 和 `single_sign` 均为 `0`；`low_position_coverage` 为 `4`；`lambda_extreme` 为 `76`；`air_imbalance` 为 `174`。`flag_anom_stable_candidate` 共 `113` 个 pass。 [已核验: D:\00 博士阶段\博一\05 Project\com_mass_balance\FL_pass_anomaly_transport_flag_summary.csv]
- `F_anom_to_raw_ratio` 的日尺度中位数约为 `0.00027-0.00042`，说明用 pass mean CO2 做异常参考后，`w * (co2 - c_ref_pass)` 明显削弱了 raw `w * co2` 中由背景浓度和平均垂直运动共同造成的大数值。 [已核验: D:\00 博士阶段\博一\05 Project\com_mass_balance\FL_pass_anomaly_transport_daily_summary.csv] [推断：基于 pass-level 输出与公式关系整理]

## position-time 核心图

- 新增并运行 `D:\00 博士阶段\博一\05 Project\com_mass_balance\run_fl_position_time_core_plots.R`。该脚本复用第一阶段 `FL_pass_matched_points_light.csv`，重新插值小车位置，按 `10 m` position bin 计算 pass-position-bin 级 `F_anom`、`F_raw`、`w_mean` 和 `co2_mean`，并输出三张核心图。 [已核验: D:\00 博士阶段\博一\05 Project\com_mass_balance\run_fl_position_time_core_plots.R]
- 分箱诊断表 `FL_position_time_pass_bin_diagnostics.csv` 共 `4751` 行，覆盖 `193` 个 pass、`4` 天和 `25` 个位置 bin。三组 profile 汇总表 `FL_position_profile_group_summary.csv` 共 `75` 行。 [已核验: D:\00 博士阶段\博一\05 Project\com_mass_balance\FL_position_time_pass_bin_diagnostics.csv] [已核验: D:\00 博士阶段\博一\05 Project\com_mass_balance\FL_position_profile_group_summary.csv]
- 三张核心图已经输出为：`fig04_position_time_F_anom_heatmap.png`、`fig05_position_time_w_mean_heatmap.png` 和 `fig06_F_anom_position_group_comparison.png`。 [已核验: D:\00 博士阶段\博一\05 Project\com_mass_balance\figures\fig04_position_time_F_anom_heatmap.png] [已核验: D:\00 博士阶段\博一\05 Project\com_mass_balance\figures\fig05_position_time_w_mean_heatmap.png] [已核验: D:\00 博士阶段\博一\05 Project\com_mass_balance\figures\fig06_F_anom_position_group_comparison.png]
- `fig04` 和 `fig05` 最初看起来 `2025-03-20` 面板近似空白。核验表明 `2025-03-20` 实际有 `1176` 个分箱行、`50` 个 pass 和 `25` 个位置 bin；问题来自 `geom_tile()` 自动使用全局最小 `hour_mid` 间隔推断 tile 高度，而 `2025-03-20` 有两个 pass 的 `hour_mid` 间隔仅 `0.00042 h`，约 `1.5 s`，导致 tile 被压得极薄。脚本已改为固定 `geom_tile(width = 10, height = 0.35)` 并重新输出热图。 [已核验: D:\00 博士阶段\博一\05 Project\com_mass_balance\run_fl_position_time_core_plots.R] [已核验: D:\00 博士阶段\博一\05 Project\com_mass_balance\FL_position_time_pass_bin_diagnostics.csv]

## 结构稳定性判断

- `FL_position_profile_stability_summary.csv` 显示 `all_pass` 与 `non_lambda_extreme` 的 median `F_anom(x)` profile 相关系数为 `0.8209436`，共同位置 bin 为 `25`。这说明排除 `lambda_extreme` 后，主空间形态基本保留。 [已核验: D:\00 博士阶段\博一\05 Project\com_mass_balance\FL_position_profile_stability_summary.csv] [推断：基于 profile 相关性整理]
- `all_pass` 与 `non_air_imbalance` 的 median `F_anom(x)` profile 相关系数为 `0.2275509`，共同位置 bin 为 `25`。该组每个位置 bin 只有约 `16-19` 个 pass，因此当前不适合作为主结构结论依据。 [已核验: D:\00 博士阶段\博一\05 Project\com_mass_balance\FL_position_profile_stability_summary.csv] [推断：基于 profile 相关性和样本量整理]
- 当前结论是：第一步数据和位置匹配足以支持 FL moving-transect anomaly transport 的可行性诊断；但它仍是原始坐标、原始单位、以 pass mean CO2 为异常参考的结构诊断，不应直接写成最终生态系统 CO2 通量。下一步若继续推进，应优先使用 `non_lambda_extreme` 作为稳健性筛选，并把 `non_air_imbalance` 作为敏感性或警示组，而不是主分析组。 [推断：基于本轮计算结果和既有 raw-w 方法边界整理]
