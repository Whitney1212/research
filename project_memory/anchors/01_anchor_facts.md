# 锚点事实

## 数据入口

- 2026-06-17 后，当前项目后续批量整理固定塔自然年数据和三站独立事件日时，统一以 `E:\Dataset_Level0` 作为 Level0 数据根入口，并以 `E:\Dataset_Level0\数据存入-处理记录.xlsx` 作为当前处理记录和覆盖登记表；`E:\Dataset_RAW` 是仪器直接输出数据入口，不应再把 RAW 下的旧登记表当成本轮主索引。 [来源: 用户当前对话 2026-06-17] [已核验: E:\Dataset_Level0] [已核验: project_memory/evidence/verifications/2026-06-17_fixed_tower_level0_coverage.md]
- Codex thread `019d4d7f-99f1-7201-87fb-409488ce10a4` 中曾整理旧 E 盘数据入口，可作为历史“按图索骥”地图：主塔/Maintower 的旧入口包括 `MET_TOWER_RAW`、`EC_TOWER_RAW`、`AP200_tower\AP200` 等；Flares/移动平台旧入口包括 `EC_FLARES_RAW`、`MET_FLARES_RAW` 和 `EC_ShH_new\AP200`；`Operation_state\20250313_20250419.xlsx` 是 2025-03-13 至 2025-04-19 运行状态线索。当前批量处理仍以 `E:\Dataset_Level0` 为准。 [来源: 用户当前对话 2026-06-17] [已核验: project_memory/evidence/threads/2026-06-17_thread_019d4d7f_e_drive_data_organization.md]
- 旧 E 盘整理线程中的小写 `mt/cvt/evt/nvt/svt` 是历史原始目录口径；当前项目科学解释中的 `MT=谷缘高地`、`CVT=谷底` 站点定义优先。后续从旧目录追溯数据时，必须用 `E:\Dataset_Level0` 或当前 metadata 重新确认站点身份，不能只凭旧文件夹名完成映射。 [来源: 用户当前对话 2026-06-17] [已核验: project_memory/evidence/threads/2026-06-17_thread_019d4d7f_e_drive_data_organization.md]

## EA/EC 当前分析对象

- 当前工作线处理的是三个 EC 观测点的高频数据：`MT` 来自 `E:\260402计算\谷缘塔EC`，`CVT` 来自 `E:\260402计算\谷底塔EC`，`FL` 来自 `E:\260402计算\Flares_EC`。 [来源: 用户当前对话 2026-05-18]
- 当前地形解释中，`MT` 被用户明确为谷缘高地，`CVT` 被用户明确为谷底，`FL` 被用户明确为在谷地上方沿切面均匀运动的观测。这个站点背景会直接约束后续对 raw `w` 平均垂直运动和局地环流结构的解释。 [来源: 用户当前对话 2026-05-20]
- FL 轨道位置的当前定义是：`0 m` 为靠南的起点且对应 `MT` 位置，轨道中点穿过 `CVT` 正上方，`245 m` 为轨道终点；FL 时间与 EC 高频时间同一时区且同步，平台搭载实时调平装置，当前诊断暂不考虑 `pitch/roll/yaw` 姿态修正。 [来源: 用户当前对话 2026-05-20]
- 旧项目脚本中记录的 FL 轨道端点坐标为 south/start `E=447574.2334, N=2768410.8877, z=659.8350` 和 north/end `E=447787.0474, N=2768235.1387, z=661.0430`；由 south 指向 north 的坐标方位角约为 `129.551°`，端点坐标直线距离约为 `276.003 m`。当前位置分箱仍应使用有效位置尺度 `0-245 m`，不把位置列重新拉伸到端点坐标距离。 [已核验: D:\00 博士阶段\博一\05 Project\com_260401\com_0401\diagnose_w4_mobile_ec_circulation.R] [已核验: D:\00 博士阶段\博一\05 Project\com_260401\com_0401\diagnostics_0320_0323\w4_mobile_circulation\run_notes.txt]
- 当前 EA 主结果文件是 `D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_flux_results.csv`，该文件已被读取并用于后续逐日可视化、上升/下沉拆分和 CO2 气团浓度分析。 [已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_flux_results.csv]
- 当前结果是一行一个站点、一个 30 min 时段、一个标量，因此当前 EA 通量是由高频 EC 数据计算得到的 30 min 通量，而不是高频逐点通量。 [已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_flux_results.csv]
- 当前结果覆盖 `2025-03-20` 到 `2025-03-23`，站点为 `MT`、`CVT`、`FL`，标量为 `co2` 和 `h2o`。主结果共有 1152 行，即 3 个站点、4 天、48 个半小时、2 个标量。 [已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_flux_results.csv]

## 当前 EA 计算定义

- 当前 EA 计算先在每个 30 min block 内对垂直风去均值，使用 \(w'_i=w_i-\bar w\)，再以 \(w'_i>0\) 和 \(w'_i<0\) 划分上升与下沉事件。 [已核验: D:\00 博士阶段\博一\05 Project\ecpreproc\run_ea_preprocess.R]
- 当前 EA 通量采用 \(F_{EA}=(A^+c^+-A^-c^-)/T\)，其中 \(A^+=\sum_{w'>0}w'\Delta t\)，\(A^-=\sum_{w'<0}(-w')\Delta t\)，\(c^+\) 和 \(c^-\) 是按 \(w'\) 体积权重得到的上升/下沉气团浓度。 [已核验: D:\00 博士阶段\博一\05 Project\ecpreproc\run_ea_preprocess.R]
- 因为当前计算使用去均值后的 \(w'\)，并且 `A_up` 与 `A_down` 在离散意义上平衡，所以 `F_EA_general` 和 `F_EC_cov` 在数值上几乎相等；这说明当前 EA 实现等价于 EC 协方差通量的条件积分写法。 [已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_flux_results.csv]

## FL 质量守恒修正输入入口

- Flares 的移动位置数据文件为 `D:\00 博士阶段\博一\05 Project\com_260326\20250313_20250419.xlsx`；位置数值越接近 `0`，表示越靠近 `MT` 方向，也就是轨道南端。后续对 `D:\00EDDYPRO\com_260401\Flares` 四天数据做移动段或空间段质量守恒修正时，应优先用该文件确定 FL 的位置和运行方向。 [来源: 用户当前对话 2026-06-01] [已核验: project_memory/evidence/verifications/2026-06-01_fl_mass_balance_inputs.md]
- 与 FL 移动位置、轨迹转换或既有结果复用相关的优先入口包括 `D:\00 博士阶段\博一\05 Project\com_260326\compute\com_260326`、`D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com` 和 `D:\00 博士阶段\博一\05 Project\com_260507`。其中 `com_260326\compute\com_260326` 保存移动平台相关旧脚本，`com_260507` 保存四个典型天的关键数据和信息。 [来源: 用户当前对话 2026-06-01] [已核验: project_memory/evidence/verifications/2026-06-01_fl_mass_balance_inputs.md]

## 坐标旋转敏感性分支

- 当前已有独立的固定站点四方法坐标旋转敏感性分支，路径为 `D:\00 博士阶段\博一\05 Project\com_rotation`。该分支针对 `CVT/MT` 两个固定站点、两个公共时段，比较 `none`、`double rotation`、`planar fit` 和 `sector-wise planar fit` 后的 EC 结果。 [来源: 用户当前对话 2026-06-01] [已核验: project_memory/evidence/verifications/2026-06-01_common_rotation_sensitivity_analysis.md]
- 当前四方法合并主结果为 `D:\00 博士阶段\博一\05 Project\com_rotation\results\rotation_flux_all_common_periods.csv`，初步统计和图件为 `D:\00 博士阶段\博一\05 Project\com_rotation\results\analysis`。 [已核验: D:\00 博士阶段\博一\05 Project\com_rotation\results\rotation_flux_all_common_periods.csv] [已核验: D:\00 博士阶段\博一\05 Project\com_rotation\results\analysis]
- `CVT` 标量通量全为 `NA` 的旧问题已经修复；刷新后的 `CVT/MT` 四方法结果中 `co2_flux/H/LE/Tau/rho_air` 均已有有限值。 [已核验: D:\00 博士阶段\博一\05 Project\com_rotation\results\rotation_flux_all_common_periods.csv]
