# 2026-06-17 Level0 数据入口与 04_lee 项目记忆查询

## 来源与范围

- 本记录整理自用户在当前对话中补充的要求：后续所有数据入口统一注意 `E:\Dataset_Level0`，并查询 `D:\00 博士阶段\99 Project\research\projects\04_lee\project_memory` 是否有可调用信息；如有，需要更新到当前 REgov 和 project memory。 [来源: 用户当前对话 2026-06-17]
- 本轮只做本地路径和项目记忆核对，不运行任何数据处理、事件检测或批量统计脚本。 [来源: 用户当前对话 2026-06-17]

## 本轮核验结果

- `E:\Dataset_Level0` 在本机存在，当前应作为后续批量整理固定塔自然年数据和三站事件日时优先进入的数据根目录。 [已核验: E:\Dataset_Level0] [来源: 用户当前对话 2026-06-17]
- 用户指定的 `04_lee` 项目记忆路径存在：`D:\00 博士阶段\99 Project\research\projects\04_lee\project_memory`。该路径下包含 `anchors/`、`runtime/`、`workstreams/`、`evidence/` 和旧版 `00-08` 兼容文件，可作为当前 W2 晨间 peak 工作流的历史方法与事件口径来源。 [已核验: D:\00 博士阶段\99 Project\research\projects\04_lee\project_memory]

## 04_lee 中可调用的信息

- `04_lee` 已记录 `com_260507` 多日事件普查目录结构：`D:\00 博士阶段\博一\05 Project\com_260507` 下有 `COMPUTE`、`DATA` 和 `OUTPUT`，其中 `DATA` 包含 `CVT_AP`、`CVT_EC`、`CVT_MET`、`MT_AP` 和 `MT_EC` 五类输入；每类有 `20` 个 `.dat` 文件，覆盖 `2025-03-06` 到 `2025-03-25`。 [已核验: D:\00 博士阶段\99 Project\research\projects\04_lee\project_memory\evidence\verifications\2026-05-08-com260507-data-structure.md]
- `04_lee` 中已有四天窗口的辐射日出 proxy：`radiation_daily.csv` 给出 `2025-03-20` 到 `2025-03-23` 四天一致的 `06:30` 短波日出 proxy 和 `17:30` 日落 proxy；这可以作为当前 W2 查找“CVT 辐射日出口径”的直接线索。 [已核验: D:\00 博士阶段\99 Project\research\projects\04_lee\project_memory\workstreams\W4_diurnal_vertical_advection_and_circulation.md]
- `04_lee` 中已有次高峰事件指标脚本口径：用 `06:30` 单点作为日出基准，在 `06:30-09:00` 找前期低值，在 `09:00-11:00` 找次高峰，并输出 `morning_decline`、`secondary_peak_amp`、`recovery_ratio`、`secondary_peak_time` 和 `event_flag`。 [已核验: D:\00 博士阶段\99 Project\research\projects\04_lee\project_memory\evidence\discussions\2026-05-01-secondary-peak-status.md]
- `04_lee` 已确认 `co2_mean` 与 `upper_co2` 的次高峰峰值时间在八个塔日中一致，幅度总体接近；因此 AP 均值可以作为晨间 peak 主 CO2 指标，但后续仍应保留上层 CO2 或层间结构作为机制辅助。 [已核验: D:\00 博士阶段\99 Project\research\projects\04_lee\project_memory\evidence\discussions\2026-05-01-secondary-peak-status.md]
- `04_lee` 中已有移动平台四天晨起窗口结果：当前移动平台输出覆盖 `2025-03-20` 到 `2025-03-23`，共有 `776778` 个高频点和 `48` 个小车运行段，并输出 `mobile_run_summary_w4.csv`、`mobile_zone_summary_w4.csv` 和 `mobile_run_summary_join_ec_w4.csv` 等结果。 [已核验: D:\00 博士阶段\99 Project\research\projects\04_lee\project_memory\workstreams\W4_diurnal_vertical_advection_and_circulation.md]
- `04_lee` 同时保留小车运动状态时间不确定性的提醒：若后续把移动平台数据扩展到更多日期或更强归因，需要先整理小车运行状态、CPEC310 高频数据和 EC 时间口径之间的匹配关系。 [已核验: D:\00 博士阶段\99 Project\research\projects\04_lee\project_memory\workstreams\W4_diurnal_vertical_advection_and_circulation.md]

## 对当前 W2 的影响

- 当前 W2 的批量整理入口应从“先找分散文件路径”调整为“先从 `E:\Dataset_Level0` 建立数据清单，再按 `CVT/MT/FL`、`AP/EC/MET`、自然年和事件日拆分可用性”。 [来源: 用户当前对话 2026-06-17] [推断：基于本轮数据入口确认整理]
- `04_lee` 的 `com_260507` 结构可以作为 W2 第一版事件普查脚本组织方式的先例：脚本放在 `COMPUTE`、输入读 `DATA`、输出写 `OUTPUT`。这只是可复用组织口径，不代表当前 W2 必须继续使用旧 `com_260507` 目录作为长期批量根目录。 [已核验: D:\00 博士阶段\99 Project\research\projects\04_lee\project_memory\evidence\verifications\2026-05-08-com260507-data-structure.md] [推断：基于当前用户指定 `E:\Dataset_Level0` 整理]
- 日出计算标准应优先追溯 `04_lee` 中 `diagnose_radiation_profile_fadv_0320_0323.R` 和 `radiation_daily.csv` 的短波辐射 proxy 口径。当前已知四天例子中 proxy 为 `06:30`，但用于固定塔自然年批量时仍需确认具体阈值、平滑和字段名。 [已核验: D:\00 博士阶段\99 Project\research\projects\04_lee\project_memory\workstreams\W4_diurnal_vertical_advection_and_circulation.md] [推断：基于当前批量扩展需求整理]
