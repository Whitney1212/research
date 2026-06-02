# 2026-05-19 raw-w 主线回退到未修正结果

## 来源

这份记录整理自当前对话中用户对经验修正结果的判断：修正缺少足够依据，暂时不使用刚刚的修正结果，分析主线回到未修正的 raw `w` CO2 总输送。 [来源: 用户当前对话 2026-05-19]

## 本次新增决策

- 当前分析主线继续使用未修正的 raw `w` CO2 总输送结果，即 `D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_raw_w_total_transport\EA_raw_w_CO2_total_transport_all_windows.csv` 及其 5 min/30 min 分文件。 [来源: 用户当前对话 2026-05-19] [已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_raw_w_total_transport\EA_raw_w_CO2_total_transport_all_windows.csv]
- 经验倾斜修正分支已经生成并保留，但因为修正量大且依据不足，暂时不作为当前解释和下一步分析的依据。 [来源: 用户当前对话 2026-05-19] [已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_raw_w_total_transport_tilt_corrected]
- 后续记录项目进度时，应把经验修正视为“已尝试但暂停使用的诊断分支”，不要把它和当前 raw `w` 主线混为一谈。 [推断：基于当前用户决策和既有输出文件状态整理]

## 对现有记忆的影响

- `W1` 的当前主线应回到未修正 raw `w` 总输送的计算、可视化和解释边界。经验修正的脚本与输出仍保留在构件索引和证据层，用于后续追溯，但不提升为当前分析依据。 [推断：基于当前用户决策与项目记忆分层规则整理]
