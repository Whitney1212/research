# REgov 数据资产索引

## 定位

这份文件记录可以被 REgov 调用或优先检查的数据资产入口。它只做索引和口径说明，不替代原始数据文件。 [来源: 用户当前对话 2026-05-28]

## 原始数据覆盖索引

- 主索引表：`E:\Dataset_RAW\数据存入-处理记录.xlsx`。 [来源: 用户当前对话 2026-05-28] [已核验: 本地存在]
- 覆盖图示：`E:\Dataset_RAW\20260428数据甘特图.png`，图像尺寸 `1522 x 655`，RGB。 [来源: 用户当前对话 2026-05-28] [已核验: 本地存在]
- 同目录另有 `E:\Dataset_RAW\现有数据.xlsx`，本轮只识别为同目录数据表，是否作为正式索引仍待确认。 [本轮自动发现 2026-05-28]

## 主索引表工作表

`E:\Dataset_RAW\数据存入-处理记录.xlsx` 当前可读工作表如下。行列数只是工作簿结构核验，不代表有效观测时段已经完成科学筛选。 [已核验: 2026-05-28 本地读取]

- `MT_EC`：19 行，6 列。
- `MT_AP`：3 行，6 列。
- `MT_MET`：22 行，7 列。
- `CVT_MET`：2 行，6 列。
- `CVT_EC`：17 行，12 列。
- `CVT_AP`：2 行，6 列。
- `Flares_EC`：11 行，6 列。
- `Flares_AP`：3 行，6 列。
- `Flares_MET`：1 行，7 列。

## 已进入分析的关键数据入口

- 三站 EC 高频数据：`MT`、`CVT`、`FL` 当前已在 EA/raw-w 分支中处理。 [已核验: regov_memory/00_shared_research_context.md]
- EA 主结果：`D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_flux_results.csv`。 [已核验: regov_memory/00_shared_research_context.md]
- raw `w` CO2 总输送结果：`D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_raw_w_total_transport\EA_raw_w_CO2_total_transport_all_windows.csv`。 [已核验: regov_memory/00_shared_research_context.md]
- raw-w 局地环流诊断结果：`D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_raw_w_local_circulation_diagnostics`。 [已核验: regov_memory/00_shared_research_context.md]
- 三站水平风结果：`D:\00 博士阶段\博一\05 Project\com_3sites_horizontal\OUTPUT`。 [已核验: regov_memory/00_shared_research_context.md]
- FL `PF_8bin` 参数与诊断输出：`E:\Dataset_Level1\Flares\PFparameter`。后续高频 FL 通量计算应优先调用 `PF_8bin_parameters_for_flux.csv`，并用同目录的 `run_PF_8bin.R`、`PF_8bin_method_notes.md`、`pf_fit_summary.csv`、`PF_8bin_preprocessing_ab_summary.csv` 和 `figures` 追溯参数来源、预处理 A/B 对比和关键验证图。 [已核验: E:\Dataset_Level1\Flares\PFparameter] [已核验: D:\00 博士阶段\99 Project\06 EA\project_memory\evidence\verifications\2026-06-12_fl_pf8bin_record_position_actual_speed.md]
- 两套 AP/profile 廓线系统的最高层分别等于对应 EC 系统观测高度，因此它们可作为 `CVT` 与 `MT` 局地柱 storage tendency 的优先数据入口。该条只说明层位覆盖满足局地 storage 计算，不说明两套系统之间的绝对浓度差已经可直接用于水平梯度或控制体平均 storage。 [来源: 用户当前对话 2026-05-29] [已核验: regov_memory/00_shared_research_context.md]

## 晨间 peak 工作流计划数据

- 两年双固定塔连续数据将作为晨间 peak 事件气候学的统计主线。计划采用“第一年建立规则、第二年独立验证”的设计，固定使用日出相对时间识别 peak，并统计发生率、峰值时间、幅度、持续时间、峰后下降率、有无 peak 日对照和两塔 lead-lag。 [来源: 用户当前对话 2026-06-17]
- `20-30` 个三站独立事件日将作为机制验证样本。进入正式统计前，需要先核查事件日是否覆盖弱风晴空晨间转换、峰前风向转变或增风、较强通风且 peak 较弱或快速消散三类状态；统计独立样本应是事件日，而不是 `1 min` 或 `30 min` 数据点。 [来源: 用户当前对话 2026-06-17]
- 谷中央上空固定观测计划用于补足两个地面固定塔无法区分的垂直过程。推荐实际安排 `16-20` 个固定观测早晨，争取得到 `12-15` 个有效事件；若三站联合观测总量只有 `20-30` 天，建议 `12-15` 天固定谷中央上空，`8-10` 天保留移动切面。 [来源: 用户当前对话 2026-06-17]
- 移动切面继续用于横谷空间结构约束，回答事件期间结构是同步、单侧增强、谷底增强还是偶极结构；它不替代谷中央上空固定观测的时间连续性。 [来源: 用户当前对话 2026-06-17] [推断：基于 FL 既有角色边界整理]
- AP 廓线在 W2 中优先作为 profile switch、梯度符号、标准化幅度和柱异常变化代理的数据入口，而不是正式 storage flux 闭合数据。 [来源: 用户当前对话 2026-06-17]

## 可调用处理工具

- `D:\00 博士阶段\博一\05 Project\ecpreproc`：用户自写、按 EddyPro 逻辑复现的通量预处理和计算包，已经过每个阶段精度验证。后续需要灵活计算 EC、lag、QC、坐标旋转、谱修正、WPL 或分支通量时，应优先检查和调用这里的已有函数。 [来源: 用户当前对话 2026-05-28] [已核验: 本地存在]

## 使用规则

- 任何新 workstream 使用原始数据前，先回到主索引表和覆盖图确认数据是否存在，再进入具体读取脚本。
- 工作簿覆盖记录只说明“可能有数据”，不自动等于“可用于通量计算”。仍需检查缺测、质量控制、时间口径、仪器状态和跨平台同步。
- 原始数据处理应继续遵守 `regov_memory/00_shared_research_context.md` 中的 `Asia/Shanghai`、start/end label、lag 和质量控制约束。
