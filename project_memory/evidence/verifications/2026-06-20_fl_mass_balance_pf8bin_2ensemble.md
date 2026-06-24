# 2026-06-20 FL PF_8bin_2ensemble 质量守恒全量计算

## 来源与用户决策

- 用户明确指定本轮质量守恒计算使用 `PF_8bin_2ensemble` 平面参数，计算脚本和全部输出统一放到 `E:\FL_MASSBALANCE`，并要求使用 R 完成计算。该决定把原本标记为独立诊断分支的两单程集合 PF 参数提升为本轮质量守恒计算的指定参数，但不自动替代其他 FL EC 产品中的正式 four-pass `PF_8bin`。 [来源: 用户当前对话 2026-06-20]

## 输入与方法

- 本轮参数文件为 `E:\Dataset_Level1\Flares\PFparameter_2ensemble\PF_8bin_2ensemble_parameters_for_flux.csv`。8 个位置 bin 均 `fit_ok = TRUE`，参数方法名为 `PF_8bin_2ensemble`；该参数由相邻正反向两单程集合的 bin 均值拟合。 [已核验: E:\Dataset_Level1\Flares\PFparameter_2ensemble\PF_8bin_2ensemble_parameters_for_flux.csv] [已核验: E:\Dataset_Level1\Flares\PFparameter_2ensemble\manifest.txt]
- 严格完整单程输入为 `E:\Dataset_Level0\Flares\260611_clasified\30min\fl_complete_passes_strict.csv`，共 `1529` 个单程、`73` 天；目标 TOA5 清单共 `78` 个文件。全部目标文件表头和单位一致，`CO2` 为 `umolCO2 mol-1`、`PA` 为 `kPa`、`TA_1_1_1` 为摄氏度。 [已核验: E:\Dataset_Level0\Flares\260611_clasified\30min\fl_complete_passes_strict.csv] [已核验: E:\Dataset_Level1\Flares\PFparameter\cache\PF_8bin_raw_files_used.csv]
- R 主脚本为 `E:\FL_MASSBALANCE\run_fl_mass_balance_8bin_2ensemble.R`。脚本按严格单程时间匹配 10 Hz 点，使用运行记录 `time_num` 做逐点位置和实际有符号速度插值，完成水平移动速度修正后按 `5-240 m` 的 8 个位置 bin 应用 `w_pf = Uz - (a + b U_east_corr + c U_north_corr)`，再聚合为 1 min 均值并使用原 Fadv 负向样本缩放规则计算 `lambda`。 [已核验: E:\FL_MASSBALANCE\run_fl_mass_balance_8bin_2ensemble.R]
- 主计算要求每个 1 min 行至少有 `50%` 的10 Hz风和标量有效覆盖。mixed-sign 单程使用 `lambda = -sum(w[w>0])/sum(w[w<0])`；single-sign 保留原方法 `lambda=1` 输出，但标为未实现质量平衡。主通量使用原始1 min CO2，去趋势CO2通量和密度加权 `lambda_density` 只作为敏感性字段。 [已核验: E:\FL_MASSBALANCE\manifest.txt] [已核验: E:\FL_MASSBALANCE\run_fl_mass_balance_8bin_2ensemble.R]

## 输出与核验结果

- pass 主结果为 `E:\FL_MASSBALANCE\results\FL_mass_balance_PF8bin_2ensemble_by_pass.csv`，1 min 明细为 `E:\FL_MASSBALANCE\results\FL_mass_balance_PF8bin_2ensemble_1min.csv`；另有逐日、方向、文件QC、标记汇总和数据可用性表。独立验证脚本为 `E:\FL_MASSBALANCE\verify_fl_mass_balance_8bin_2ensemble.R`，验证摘要为 `E:\FL_MASSBALANCE\qc\verification_summary.txt`。 [已核验: E:\FL_MASSBALANCE]
- pass 主表完整保留全部 `1529` 个严格单程且 `pass_id` 无遗漏、无重复。实际成功计算 `1023` 个单程；其中 `976` 个 `ok`、`20` 个 `extreme_lambda`、`19` 个 `single_sign_up`、`8` 个 `single_sign_down`。mixed-sign且成功执行平衡的单程共 `996` 个，最大 `abs(corrected_sum_w)` 为 `1.915135e-15`。 [已核验: E:\FL_MASSBALANCE\qc\verification_summary.txt]
- 另有 `506` 个单程不能形成主通量：`415` 个对应原始 TOA5 文件整日没有有效风值，`18` 个对应 `2025-04-04` 无原始EC文件，`32` 个没有PF保留分钟，`41` 个有分钟片段但未达到50%分钟风与标量覆盖。它们均保留在pass主表，并通过 `data_status` 明确标记，不能与1023个已计算单程混写。 [已核验: E:\FL_MASSBALANCE\results\FL_mass_balance_PF8bin_2ensemble_by_pass.csv] [已核验: E:\FL_MASSBALANCE\qc\FL_mass_balance_PF8bin_2ensemble_data_availability.csv]

## 方法边界与不确定性

- 原始 Fadv 代码不做PF旋转；本轮是在用户指定下先应用 `PF_8bin_2ensemble`，再忠实使用其1 min `lambda`规则，因此是“PF后原质量守恒公式”，不是原脚本逐字复现。 [来源: 用户当前对话 2026-06-20] [已核验: E:\老师拷贝大量数据（4-30）\R\EC_process\Fc_adv_2025.R] [已核验: E:\FL_MASSBALANCE\run_fl_mass_balance_8bin_2ensemble.R]
- 原阈值 `lambda < 0.01` 或 `lambda > 100` 只标出 `20` 个极端段，但 `996` 个mixed-sign单程中有 `146` 个位于更窄的 `0.1-10` 之外、`350` 个位于 `0.25-4` 之外，说明后续解释不能只依赖原极端阈值，需保留lambda分层敏感性。 [已核验: E:\FL_MASSBALANCE\results\FL_mass_balance_PF8bin_2ensemble_by_pass.csv] [推断：基于lambda分布整理]
- mixed-sign结果中，主结果与CO2线性去趋势敏感性结果的绝对差中位数约 `0.3023`、q95约 `5.1947 umol m-2 s-1`，最大约 `59.0731 umol m-2 s-1`；因此去趋势不能静默替代主结果，应作为稳定性检查。 [已核验: E:\FL_MASSBALANCE\results\FL_mass_balance_PF8bin_2ensemble_by_pass.csv] [推断：基于主结果和去趋势敏感性列整理]
- single-sign共 `27` 个，其主公式绝对值可达到数千到 `17009.48 umol m-2 s-1`，应解释为单表面持续穿流候选量，不能与996个成功平衡的交换型结果直接合并解释。 [已核验: E:\FL_MASSBALANCE\results\FL_mass_balance_PF8bin_2ensemble_by_pass.csv] [推断：基于single-sign物理边界与结果量级整理]
