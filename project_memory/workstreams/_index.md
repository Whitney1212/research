# 工作流索引

- `W3_fixed_tower_annual_nee_estimation.md` 已新增为两固定塔 `MT/CVT` 2025 自然年 `EC-only annual NEE estimate / proxy` 工作流。该工作流单独维护覆盖审计、gapfilling、长缺口、筛选口径敏感性和对外表述边界，避免继续挤在 `W1/W2` 中。 [来源: 用户当前对话 2026-07-05 至 2026-07-06] [已核验: D:\00 博士阶段\99 Project\06 EA\project_memory\workstreams\W3_fixed_tower_annual_nee_estimation.md]

- `W2_morning_peak_workflow.md` 已新增为独立晨间 CO2 peak 事件机制工作流。该工作流与长期复杂地形碳收支主线并行；当前固定塔事件气候学先做一个自然年，优先以 `2025` 年为主分析年，再结合 `20-30` 个三站独立事件日、谷中央上空固定观测、移动切面和 AP 廓线代理量，解释长期稳定晨间 CO2 事件的边界层转换、空间传播与局地再分配机制。 [来源: 用户当前对话 2026-06-17] [已核验: project_memory/evidence/verifications/2026-06-17_fixed_tower_level0_coverage.md]

- `W1_EA_EC_flux.md` 已补入 2026-06-12 的 FL `PF_8bin` 参数进展：正式参数输出位于 `E:\Dataset_Level1\Flares\PFparameter`，后续高频通量计算应调用 `PF_8bin_parameters_for_flux.csv`，并沿用逐点运行记录位置插值和实际速度矢量水平风修正。 [已核验: project_memory/evidence/verifications/2026-06-12_fl_pf8bin_record_position_actual_speed.md]

- 当前下一步主线任务已单独记录在 `project_memory/runtime/05_next_mainline_tasks.md`：基于已完成的全天表、事件窗口表和气象过程机制图，围绕 09:00 CO2 次高峰检验夜间储存释放、沿谷向平流、横谷向局地环流和湍流/生态过程的相对贡献。[来源: 用户当前对话 2026-05-25]

- `W1_EA_EC_flux.md` 记录 EC 高频数据按 EA 思路计算 30 min \(w'\) 协方差型通量、逐日可视化、上升/下沉拆分、CO2 气团浓度解释，以及新增的 raw `w` CO2 总输送分支。当前状态是旧协方差型结果和未修正 raw-w 5 min/30 min 输出都已生成；经验倾斜修正分支已尝试但暂不作为当前依据。机制对齐图已从 `F_air/F_conc` 分解主线改为气象过程主线，2026-05-26 后进一步收束为两个归因方向：次高峰是否由风向转变输入高 CO2 气团并在峰后被吸收/稀释或平流带走，以及日出后 `CVT` 下沉和 `MT/FL` 上升是否支持谷底补偿下沉与坡面热力环流候选图像。 [已核验: project_memory/evidence/verifications/2026-05-26_two_main_mechanism_directions.md]
- `W1_EA_EC_flux.md` 已补充 2026-06-14 的 FL `PF_8bin` 后四天高频 EC 与 EA 机制诊断进展。当前 `com_FLafterPF` 结果使用 `valid_samples_by_bin` 作为窗口 QC，主 EC 表为 `FL_PF8bin_EC_covariance_30min.csv`，EA 机制诊断输出为 `FL_PF8bin_EA_mechanism_diagnostics_30min.csv`。[已核验 D:\00 博士阶段\99 Project\06 EA\project_memory\evidence\verifications\2026-06-14_fl_pf8bin_ec_ea_mechanism_after_pf.md]
