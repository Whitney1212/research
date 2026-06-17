# REgov 数据资产索引

## 定位

这份文件记录可以被 REgov 调用或优先检查的数据资产入口。它只做索引和口径说明，不替代原始数据文件。 [来源: 用户当前对话 2026-05-28]

## 数据覆盖索引

- 统一数据根入口：`E:\Dataset_Level0`。2026-06-17 后，当前项目批量整理固定塔自然年数据和三站事件日时，应优先从该根目录建立站点、变量、自然年和事件日数据清单。 [来源: 用户当前对话 2026-06-17] [已核验: E:\Dataset_Level0]
- 当前处理记录和覆盖登记表：`E:\Dataset_Level0\数据存入-处理记录.xlsx`。Level0 文件夹是按日切割后的数据，RAW 文件夹是仪器直接输出数据。 [来源: 用户当前对话 2026-06-17] [已核验: E:\Dataset_Level0\数据存入-处理记录.xlsx]
- 历史覆盖图示：`E:\Dataset_RAW\20260428数据甘特图.png`，图像尺寸 `1522 x 655`，RGB。该图可以作为旧 RAW 覆盖线索，但不替代当前 Level0 处理记录。 [来源: 用户当前对话 2026-05-28] [来源: 用户当前对话 2026-06-17] [已核验: E:\Dataset_RAW\20260428数据甘特图.png]
- RAW 同目录另有 `E:\Dataset_RAW\现有数据.xlsx` 和旧 `E:\Dataset_RAW\数据存入-处理记录.xlsx`；它们当前只作为历史线索或原始数据追溯入口，不作为 W2 覆盖登记主表。 [来源: 用户当前对话 2026-06-17] [已核验: E:\Dataset_RAW]

## 旧 E 盘目录整理线程

- Codex thread `019d4d7f-99f1-7201-87fb-409488ce10a4` 可作为历史 E 盘目录地图。对应本地会话归档为 `C:\Users\admin\.codex\sessions\2026\04\02\rollout-2026-04-02T17-21-41-019d4d7f-99f1-7201-87fb-409488ce10a4.jsonl`，线程中生成的说明文档为 `D:\00 博士阶段\01 Project\E盘数据说明_按目录索引.md`。 [来源: 用户当前对话 2026-06-17] [已核验: D:\00 博士阶段\99 Project\06 EA\project_memory\evidence\threads\2026-06-17_thread_019d4d7f_e_drive_data_organization.md]
- 旧线程确认的文件名规则：`57990.RawData` 为 `AP200` 原始数据，`53412.IntAvg.dat` 为 `AP200` 廓线或平均结果，`TOA5_45984.AWS_*` 与 `TOA5_40891.AWS_*` 属于气象或梯度气象，`45984.AWS0.dat` 属于气象，`24374.Time_Series_*` 属于 EC/通量，`Flares` 代表移动观测平台；移动端 `AP200/AP201/AP202` 按 `AP200` 系列合并。 [已核验: D:\00 博士阶段\99 Project\06 EA\project_memory\evidence\threads\2026-06-17_thread_019d4d7f_e_drive_data_organization.md]
- 旧线程的主塔/Maintower 历史入口包括 `E:\老师拷贝大量数据（4-30）\MET_TOWER_RAW`、`E:\老师拷贝大量数据（4-30）\EC_TOWER_RAW`、`E:\老师拷贝大量数据（4-30）\EC_ShH_new\AP200_tower\AP200`、`E:\202503-202512MET`、`E:\250707上杭towerEC\25-07-07\MAINTOWER_TOP_EC`、`E:\251101数据\主塔塔顶数据` 和 `E:\25-09-08 主塔塔顶\EC—top--0908\EC—top--0908`。 [已核验: D:\00 博士阶段\99 Project\06 EA\project_memory\evidence\threads\2026-06-17_thread_019d4d7f_e_drive_data_organization.md]
- 旧线程的 Flares/移动平台历史入口包括 `E:\老师拷贝大量数据（4-30）\EC_FLARES_RAW`、`E:\老师拷贝大量数据（4-30）\MET_FLARES_RAW`、`E:\老师拷贝大量数据（4-30）\EC_ShH_new\EC_FLARES_RAW`、`E:\老师拷贝大量数据（4-30）\EC_ShH_new\MET_FLARES_RAW` 和 `E:\老师拷贝大量数据（4-30）\EC_ShH_new\AP200`；`E:\251101数据\小车AP200`、`E:\251101数据\小车气象`、`E:\251101数据\小车数据` 建议单列为“移动平台/小车”，不直接写死为 Flares。 [已核验: D:\00 博士阶段\99 Project\06 EA\project_memory\evidence\threads\2026-06-17_thread_019d4d7f_e_drive_data_organization.md]
- 旧线程锁定的 `2025-03-13` 至 `2025-03-25` 相关目录包括固定塔 `EC_TOWER_RAW` 的 `20240313-20250325` 与 `20250325-` 批次、Flares `EC_FLARES_RAW\Converted` 下的 `20241129-` 批次和 `moving\correct\eddypro_*_cospectra`，以及 `Operation_state\20250313_20250419.xlsx`。这些可作为旧原始目录追溯线索，但当前事件筛选仍要以 `E:\Dataset_Level0\数据存入-处理记录.xlsx` 和 W1 FL 完整单程统计为准。 [已核验: D:\00 博士阶段\99 Project\06 EA\project_memory\evidence\threads\2026-06-17_thread_019d4d7f_e_drive_data_organization.md] [已核验: D:\00 博士阶段\99 Project\06 EA\project_memory\evidence\verifications\2026-06-17_fixed_tower_level0_coverage.md]
- 使用边界：旧线程中的小写 `mt/cvt/evt/nvt/svt` 是硬盘目录整理口径，当前项目科学解释中的 `MT=谷缘高地`、`CVT=谷底` 定义优先；旧缺失时段图基于 `E:\数据整理\现有数据.xlsx` 并截止 `2026-04-08`，当前只作为历史覆盖结果，不替代 `Dataset_RAW` 和 `Dataset_Level0` 的正式批量核查。 [已核验: D:\00 博士阶段\99 Project\06 EA\project_memory\evidence\threads\2026-06-17_thread_019d4d7f_e_drive_data_organization.md]

## 主处理记录工作表

`E:\Dataset_Level0\数据存入-处理记录.xlsx` 当前可读工作表如下。行列数只是工作簿结构核验，不代表有效观测时段已经完成科学筛选。 [已核验: D:\00 博士阶段\99 Project\06 EA\project_memory\evidence\verifications\2026-06-17_fixed_tower_level0_coverage.md]

- `MT_EC`：20 行，6 列。
- `MT_AP`：4 行，6 列。
- `MT_MET`：23 行，7 列。
- `CVT_MET`：3 行，6 列。
- `CVT_EC`：18 行，12 列。
- `CVT_AP`：3 行，6 列。
- `Flares_EC`：11 行，6 列。
- `Flares_AP`：3 行，6 列。
- `Flares_MET`：1 行，7 列。

## 两固定塔 Level0 覆盖核验

- 按 `E:\Dataset_Level0\数据存入-处理记录.xlsx` 合并登记窗口，`MT/CVT AP` 共同覆盖为 `2024-11-12 14:30` 至 `2026-02-02 09:30`，以及 `2026-02-02 10:00` 至 `2026-05-10 15:00`。这条窗口最接近 W2 的主 CO2 指标入口，因为晨间 peak 主 CO2 指标已确定为 AP 均值。 [来源: 用户当前对话 2026-06-17] [已核验: D:\00 博士阶段\99 Project\06 EA\project_memory\evidence\verifications\2026-06-17_fixed_tower_level0_coverage.md]
- 按同一处理记录，`MT/CVT EC` 共同覆盖被分成多个批次窗口，整体从 `2024-10-22 04:00` 延伸到 `2026-05-10 15:00`，但中间存在 `2024-11-29` 至 `2024-12-02`、`2024-12-24` 至 `2025-01-22`、`2025-02-24` 至 `2025-03-05`、`2025-07-06` 至 `2025-07-07` 等断口。 [已核验: D:\00 博士阶段\99 Project\06 EA\project_memory\evidence\verifications\2026-06-17_fixed_tower_level0_coverage.md]
- 按同一处理记录，`MT/CVT MET` 共同覆盖为 `2024-11-12 14:30` 至 `2025-12-28 23:59`，以及 `2026-02-22 00:00` 至 `2026-03-15 23:59`。因此 2026 年机制协变量不能默认全年连续，需要按日检查。 [已核验: D:\00 博士阶段\99 Project\06 EA\project_memory\evidence\verifications\2026-06-17_fixed_tower_level0_coverage.md] [推断：基于共同覆盖窗口整理]
- 同时具有 `MT/CVT` 两塔 `EC/AP/MET` 登记覆盖的窗口包括 `2024-11-12` 至 `2025-12-28` 之间的多段，以及 `2026-02-22 00:00` 至 `2026-03-15 23:59`。完整分段见固定塔覆盖核验证据记录。 [已核验: D:\00 博士阶段\99 Project\06 EA\project_memory\evidence\verifications\2026-06-17_fixed_tower_level0_coverage.md]
- 用户已确认当前检测到的固定塔数据就是全部可用数据；如果只有这些数据，就做一个自然年。推断：W2 第一版固定塔事件气候学优先以 `2025` 年为主分析年，`2024-11` 至 `2024-12` 和 `2026-01` 至 `2026-05` 作为补充或敏感性窗口，不再强行构造成第二个完整自然年。 [来源: 用户当前对话 2026-06-17] [已核验: D:\00 博士阶段\99 Project\06 EA\project_memory\evidence\verifications\2026-06-17_fixed_tower_level0_coverage.md]
- 当前 EC/MET/AP 覆盖中的断口有一部分来自中途仪器维修，属于无法避免的数据缺测。后续日历清单应把这类断口标记为维修或不可避免缺测窗口，不能当作无 peak 对照日。 [来源: 用户当前对话 2026-06-17] [推断：基于事件日筛选边界整理]
- Level0 文件夹当前已确认 `CVT` 与 `MT` 均有 `AP/EC/MET` 子目录；但处理记录与文件夹命名之间仍存在若干摆放或命名待核查点，包括 `MT_AP` 2026 年 1 月底至 4 月下旬、`MT_EC` 2026 年 1 月至 4 月下旬、`CVT_MET` 2026 年 2 月至 5 月、以及 `MT_MET` 2026 年登记覆盖在 Level0 文件夹中的具体位置。由于用户说明“有文件夹的均有数据覆盖，只是可能有误存”，这些暂记为文件摆放待核查，不直接判为无数据。 [来源: 用户当前对话 2026-06-17] [已核验: D:\00 博士阶段\99 Project\06 EA\project_memory\evidence\verifications\2026-06-17_fixed_tower_level0_coverage.md]

## 已进入分析的关键数据入口

- 三站 EC 高频数据：`MT`、`CVT`、`FL` 当前已在 EA/raw-w 分支中处理。 [已核验: regov_memory/00_shared_research_context.md]
- EA 主结果：`D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_flux_results.csv`。 [已核验: regov_memory/00_shared_research_context.md]
- raw `w` CO2 总输送结果：`D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_raw_w_total_transport\EA_raw_w_CO2_total_transport_all_windows.csv`。 [已核验: regov_memory/00_shared_research_context.md]
- raw-w 局地环流诊断结果：`D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_raw_w_local_circulation_diagnostics`。 [已核验: regov_memory/00_shared_research_context.md]
- 三站水平风结果：`D:\00 博士阶段\博一\05 Project\com_3sites_horizontal\OUTPUT`。 [已核验: regov_memory/00_shared_research_context.md]
- FL `PF_8bin` 参数与诊断输出：`E:\Dataset_Level1\Flares\PFparameter`。后续高频 FL 通量计算应优先调用 `PF_8bin_parameters_for_flux.csv`，并用同目录的 `run_PF_8bin.R`、`PF_8bin_method_notes.md`、`pf_fit_summary.csv`、`PF_8bin_preprocessing_ab_summary.csv` 和 `figures` 追溯参数来源、预处理 A/B 对比和关键验证图。 [已核验: E:\Dataset_Level1\Flares\PFparameter] [已核验: D:\00 博士阶段\99 Project\06 EA\project_memory\evidence\verifications\2026-06-12_fl_pf8bin_record_position_actual_speed.md]
- 两套 AP/profile 廓线系统的最高层分别等于对应 EC 系统观测高度，因此它们可作为 `CVT` 与 `MT` 局地柱 storage tendency 的优先数据入口。该条只说明层位覆盖满足局地 storage 计算，不说明两套系统之间的绝对浓度差已经可直接用于水平梯度或控制体平均 storage。 [来源: 用户当前对话 2026-05-29] [已核验: regov_memory/00_shared_research_context.md]

## 晨间 peak 工作流计划数据

- `04_lee` 可复用历史记忆入口为 `D:\00 博士阶段\99 Project\research\projects\04_lee\project_memory`。本轮已确认其中包含 W4 晨间次高峰工作线、`com_260507` 多日数据结构、四天辐射日出 proxy、次高峰事件口径和移动平台运行段信息，可作为当前 W2 的方法先例和历史证据入口。 [来源: 用户当前对话 2026-06-17] [已核验: project_memory/evidence/verifications/2026-06-17_level0_and_04lee_memory_query.md]
- 历史短波日出 proxy 的具体字段和阈值已经核验：`D:\00 博士阶段\博一\05 Project\com_260401\com_0401\diagnose_radiation_profile_fadv_0320_0323.R` 读取 `E:\260402计算\CVT_MET` 中的 `SW_in_Avg`，聚合为 30 min `SW_in`，以 `SW_in >= 20 W m^-2` 的首个窗口作为 `sunrise_ref_sw`；`radiation_daily.csv` 中 `2025-03-20` 至 `2025-03-23` 四天均为 `06:30`。 [已核验: D:\00 博士阶段\99 Project\06 EA\project_memory\evidence\verifications\2026-06-17_cvt_sw_in_sunrise_reference.md]
- 固定塔自然年连续数据将作为晨间 peak 事件气候学的统计主线。当前执行口径是优先以 `2025` 年为主分析年，固定使用日出相对时间识别 peak，并统计发生率、峰值时间、幅度、持续时间、峰后下降率、有无 peak 日对照和两塔 lead-lag；维修断口应作为缺测窗口排除。 [来源: 用户当前对话 2026-06-17] [已核验: D:\00 博士阶段\99 Project\06 EA\project_memory\evidence\verifications\2026-06-17_fixed_tower_level0_coverage.md]
- `20-30` 个三站独立事件日将作为机制验证样本。进入正式统计前，需要先核查事件日是否覆盖弱风晴空晨间转换、峰前风向转变或增风、较强通风且 peak 较弱或快速消散三类状态；统计独立样本应是事件日，而不是 `1 min` 或 `30 min` 数据点。 [来源: 用户当前对话 2026-06-17]
- 谷中央上空固定观测计划用于补足两个地面固定塔无法区分的垂直过程。推荐实际安排 `16-20` 个固定观测早晨，争取得到 `12-15` 个有效事件；若三站联合观测总量只有 `20-30` 天，建议 `12-15` 天固定谷中央上空，`8-10` 天保留移动切面。 [来源: 用户当前对话 2026-06-17]
- 移动切面继续用于横谷空间结构约束，回答事件期间结构是同步、单侧增强、谷底增强还是偶极结构；它不替代谷中央上空固定观测的时间连续性。 [来源: 用户当前对话 2026-06-17] [推断：基于 FL 既有角色边界整理]
- AP 廓线在 W2 中优先作为 profile switch、梯度符号、标准化幅度和柱异常变化代理的数据入口，而不是正式 storage flux 闭合数据。 [来源: 用户当前对话 2026-06-17]

## 可调用处理工具

- `D:\00 博士阶段\博一\05 Project\ecpreproc`：用户自写、按 EddyPro 逻辑复现的通量预处理和计算包，已经过每个阶段精度验证。后续需要灵活计算 EC、lag、QC、坐标旋转、谱修正、WPL 或分支通量时，应优先检查和调用这里的已有函数。 [来源: 用户当前对话 2026-05-28] [已核验: 本地存在]

## 使用规则

- 任何新 workstream 使用 Level0 或原始数据前，先回到 `E:\Dataset_Level0\数据存入-处理记录.xlsx` 确认登记覆盖，再进入具体读取脚本；需要追溯仪器直接输出时再回到 `E:\Dataset_RAW`。 [来源: 用户当前对话 2026-06-17] [已核验: D:\00 博士阶段\99 Project\06 EA\project_memory\evidence\verifications\2026-06-17_fixed_tower_level0_coverage.md]
- 工作簿覆盖记录只说明“可能有数据”，不自动等于“可用于通量计算”。仍需检查缺测、质量控制、时间口径、仪器状态和跨平台同步。 [推断：基于数据覆盖登记与科学 QC 的边界整理]
- 原始数据处理应继续遵守 `regov_memory/00_shared_research_context.md` 中的 `Asia/Shanghai`、start/end label、lag 和质量控制约束。 [已核验: regov_memory/00_shared_research_context.md]
