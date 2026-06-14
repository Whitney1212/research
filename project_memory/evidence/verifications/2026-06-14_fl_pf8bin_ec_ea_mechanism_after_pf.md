# 2026-06-14 FL PF_8bin 后 EC 与 EA 机制诊断记录

## 来源

- 这份记录整理自 2026-06-12 至 2026-06-14 当前对话中完成并核验的 FL `PF_8bin` 后高频通量计算、coverage 筛选规则修正、分拆可视化和 EA 机制诊断输出。[来源: 用户当前对话 2026-06-12 至 2026-06-14]
- 本次记录只使用 D 盘项目记忆路径 `D:\00 博士阶段\99 Project\06 EA\project_memory`，没有通过 `C:\Users\admin\Documents\New project` legacy alias 写入。[已核验 D:\00 博士阶段\99 Project\06 EA\project_memory]

## 本次新增信息

- `D:\00 博士阶段\博一\05 Project\com_FLafterPF` 已成为 FL `PF_8bin` 后 EC 与 EA 机制诊断的当前输出根目录。主要计算脚本为 `scripts\run_fl_pf8bin_ec_covariance_20250320_0323.R`，可视化脚本为 `scripts\plot_fl_pf8bin_ec_covariance_20250320_0323.R`，EA 机制诊断脚本为 `scripts\output_fl_pf8bin_ea_mechanism_diagnostics_20250320_0323.R`。[已核验 D:\00 博士阶段\博一\05 Project\com_FLafterPF\scripts\run_fl_pf8bin_ec_covariance_20250320_0323.R] [已核验 D:\00 博士阶段\博一\05 Project\com_FLafterPF\scripts\plot_fl_pf8bin_ec_covariance_20250320_0323.R] [已核验 D:\00 博士阶段\博一\05 Project\com_FLafterPF\scripts\output_fl_pf8bin_ea_mechanism_diagnostics_20250320_0323.R]
- 当前 EC 计算对 `2025-03-20` 至 `2025-03-23` 的 FL 高频数据逐点应用 `PF_8bin` 参数后，再用协方差方法计算 `F_EC_cov_valid = mean(w_pf' * scalar')`。CO2 另用窗口空气摩尔密度换算为 `umol m-2 s-1`。[已核验 D:\00 博士阶段\博一\05 Project\com_FLafterPF\results\flux_30min\FL_PF8bin_EC_covariance_30min.csv]
- 当前窗口 QC 已从“固定 30 min 窗口必须达到 `coverage_frac >= 0.90`”改为 `valid_samples_by_bin`：窗口至少有 `120 s` 有效样本，每个参与 bin 至少有 `10 s` 有效样本，且至少有 `1` 个有效 bin。`coverage_frac` 继续输出，但只作为诊断量，不再作为硬筛选条件。[已核验 D:\00 博士阶段\博一\05 Project\com_FLafterPF\scripts\run_fl_pf8bin_ec_covariance_20250320_0323.R]
- 重新计算后的主通量表共有 `378` 行，其中 CO2 和 H2O 各 `189` 行。按日期统计，`2025-03-20` 的 CO2/H2O 各有 `45` 个窗口，`2025-03-21`、`2025-03-22` 和 `2025-03-23` 每天各有 `48` 个窗口。[已核验 D:\00 博士阶段\博一\05 Project\com_FLafterPF\results\flux_30min\FL_PF8bin_EC_covariance_30min.csv]
- `2025-03-20` 在新规则下新增保留了 `13:30`、`14:00`、`15:30` 和 `16:30` 这四个 partial windows；`13:00`、`14:30` 和 `15:00` 仍无输出，因为对应固定 30 min 窗口内没有可用于 EC 的有效高频段。[已核验 D:\00 博士阶段\博一\05 Project\com_FLafterPF\results\flux_30min\FL_PF8bin_EC_covariance_30min.csv]
- 可视化已经改为按量级合理拆分，不再把通量、`wmean`、coverage、位置等不同量级变量混在一个 y 轴解释。核心图件包括 CO2 EC flux、`w_pf_mean` vs `w_raw_mean`、`sigma_w`、coverage 和 position mean，图件输出在 `results\figures`。[已核验 D:\00 博士阶段\博一\05 Project\com_FLafterPF\results\figures\FL_PF8bin_CO2_EC_flux_by_day_rows.png] [已核验 D:\00 博士阶段\博一\05 Project\com_FLafterPF\results\figures\FL_PF8bin_coverage_by_day_rows.png]
- EA 机制诊断已经基于现有 PF_8bin EC 结果派生，不重读原始高频文件。诊断表 `FL_PF8bin_EA_mechanism_diagnostics_30min.csv` 共有 `378` 行，CO2/H2O 各 `189` 行；summary 中 CO2 的最大上下贡献闭合误差约 `3.297e-13`，H2O 约 `1.309e-14`，均为浮点误差量级。[已核验 D:\00 博士阶段\博一\05 Project\com_FLafterPF\results\ea_mechanism\FL_PF8bin_EA_mechanism_diagnostics_30min.csv] [已核验 D:\00 博士阶段\博一\05 Project\com_FLafterPF\results\ea_mechanism\FL_PF8bin_EA_mechanism_summary_by_scalar.csv]
- EA 机制诊断输出的主要变量包括 `F_up_cov_valid`、`F_down_cov_valid`、`F_net_from_components`、`scalar_up_anomaly`、`scalar_down_anomaly`、`scalar_contrast_up_minus_down`、`A_up_rate`、`A_down_rate`、`transport_balance` 和 `F_up_abs_share`。CO2 同时输出 `*_umol_m2_s` 换算字段。[已核验 D:\00 博士阶段\博一\05 Project\com_FLafterPF\results\ea_mechanism\FL_PF8bin_EA_mechanism_diagnostics_30min.csv]
- EA 机制图件已经分成 CO2 上下贡献、CO2 条件浓度差、输送强度、CO2 上输送绝对贡献占比和 H2O 上下贡献五组，输出在 `results\ea_mechanism\figures`。[已核验 D:\00 博士阶段\博一\05 Project\com_FLafterPF\results\ea_mechanism\figures]

## 和现有记忆的关系

- 本次更新承接 `2026-06-12_fl_pf8bin_record_position_actual_speed.md` 中固定的 `PF_8bin` 参数路径，并把它推进到四天 FL 高频 EC 通量和 EA 机制诊断产品。后续讨论 FL after-PF 通量时，应优先引用 `D:\00 博士阶段\博一\05 Project\com_FLafterPF` 下的新结果，而不是旧 raw-w 分支或未应用 PF 的 FL 诊断结果。[已核验 D:\00 博士阶段\99 Project\06 EA\project_memory\evidence\verifications\2026-06-12_fl_pf8bin_record_position_actual_speed.md] [已核验 D:\00 博士阶段\博一\05 Project\com_FLafterPF\results\flux_30min\FL_PF8bin_EC_covariance_30min.csv]
- 本次方法边界是：EC covariance 仍作为主通量口径，EA/up-down decomposition 用作机制诊断和质量解释；两者不应混写成两个互相替代的主通量产品。[来源: 用户当前对话 2026-06-14] [推断: 基于本次 EC 与 EA 输出定义整理]
- 时间解析锚点仍然有效：EC 高频时间必须按字符读入，再显式按 `Asia/Shanghai` 解析；本次绘图脚本也修复了混合时间格式解析，避免 00:00 被写成纯日期后导致整列时间截成 0 点。[来源: 用户当前对话 2026-06-12] [已核验 D:\00 博士阶段\博一\05 Project\com_FLafterPF\scripts\plot_fl_pf8bin_ec_covariance_20250320_0323.R] [已核验 D:\00 博士阶段\99 Project\06 EA\project_memory\evidence\verifications\2026-06-12_ec_time_parsing_anchor_and_com_FLafterPF_fix.md]

## 仍待确认

- 当前 `valid_samples_by_bin` 阈值为 `120 s` 窗口有效样本和 `10 s` 单 bin 有效样本，是本轮用于恢复 partial windows 的工作阈值。若后续要进入论文统计，应进一步确认这些阈值是否需要按湍流统计稳定性、航段方向或 bin 覆盖结构做敏感性分析。[推断: 基于本次 QC 规则和 partial window 恢复结果整理]
- 当前 EA 机制诊断是从 30 min 结果派生的机制量，适合解释上下输送贡献、浓度差和输送强度；若要研究 pass-level 或 pass-centered 机制，则需要另建产品，不能直接把当前 fixed-window 结果改名为 pass-level 结果。[推断: 基于本次 fixed 30 min EC 窗口定义整理]
