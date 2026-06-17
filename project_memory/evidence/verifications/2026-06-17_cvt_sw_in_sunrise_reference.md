# CVT 短波日出口径核验

## 来源

- 这份记录整理自用户当前对话提供的日出口径说明，并在本轮直接核验 `diagnose_radiation_profile_fadv_0320_0323.R`、`radiation_daily.csv` 和 `04 Lee` 的 `2026-04-24-diagnostics.md`。 [来源: 用户当前对话 2026-06-17] [已核验: D:\00 博士阶段\博一\05 Project\com_260401\com_0401\diagnose_radiation_profile_fadv_0320_0323.R] [已核验: D:\00 博士阶段\博一\05 Project\com_260401\com_0401\diagnostics_0320_0323\radiation_daily.csv] [已核验: D:\00 博士阶段\99 Project\04 Lee\project_memory\evidence\verifications\2026-04-24-diagnostics.md]

## 已确认口径

- 当时用 `CVT` 的 `MET` 数据定义短波日出 proxy 时，参考字段是 `CVT_MET` 中的 `SW_in_Avg`，也就是入射短波辐射。脚本注释明确写着“当前无 PAR，优先用 SW_in_Avg 替代”。 [已核验: D:\00 博士阶段\博一\05 Project\com_260401\com_0401\diagnose_radiation_profile_fadv_0320_0323.R]
- 脚本把 `SW_in_Avg` 聚合到 `30 min` 时间窗，生成 `SW_in = mean(SW_in_Avg, na.rm = TRUE)`；同时也读入并聚合 `SW_out_Avg` 和 `Rn_Avg`，但日出判定不是按 `SW_out` 或 `Rn`。 [已核验: D:\00 博士阶段\博一\05 Project\com_260401\com_0401\diagnose_radiation_profile_fadv_0320_0323.R]
- “见光”阈值是 `SW_in >= 20 W m^-2`。当天所有满足 `is_light == TRUE` 的 `time_30` 中，最早一个窗口被写为 `sunrise_ref_sw`，最晚一个窗口被写为 `sunset_ref_sw`。 [已核验: D:\00 博士阶段\博一\05 Project\com_260401\com_0401\diagnose_radiation_profile_fadv_0320_0323.R]
- 当前核验的四天输出中，`2025-03-20` 到 `2025-03-23` 的 `sunrise_ref_sw` 均为 `06:30:00`，`sunset_ref_sw` 均为 `17:30:00`。 [已核验: D:\00 博士阶段\博一\05 Project\com_260401\com_0401\diagnostics_0320_0323\radiation_daily.csv]
- `04 Lee` 的 `2026-04-24-diagnostics.md` 此前只记录为 `radiation_daily.csv` 给出四天 `06:30` 日出代理和 `17:30` 日落代理，没有细到 `SW_in_Avg` 字段名和 `20 W m^-2` 阈值；本轮补齐了字段和阈值 provenance。 [已核验: D:\00 博士阶段\99 Project\04 Lee\project_memory\evidence\verifications\2026-04-24-diagnostics.md] [推断：基于本轮脚本核验整理]

## 对 W2 的影响

- W2 晨间 peak 的历史日出相对时间口径已经可以明确写成：优先使用 `CVT_MET` 的 `SW_in_Avg`，聚合为 `30 min` 的 `SW_in` 后，以 `SW_in >= 20 W m^-2` 的首个窗口作为 `sunrise_ref_sw`。这比单写 `06:30` 更可复现。 [已核验: D:\00 博士阶段\博一\05 Project\com_260401\com_0401\diagnose_radiation_profile_fadv_0320_0323.R] [推断：基于 W2 批量事件检测需求整理]
- 固定塔自然年批量应用前仍需确认 `E:\Dataset_Level0` 中 `CVT_MET` 是否保留同名 `SW_in_Avg` 字段、时间分辨率是否一致、缺测和异常短波值如何处理，以及是否沿用 `20 W m^-2` 作为冻结规则的一部分。 [来源: 用户当前对话 2026-06-17] [推断：基于历史脚本口径向自然年数据扩展的边界整理]
