# 时间解析硬约束

- 所有 EC/FL 高频计算、窗口汇总和可视化对齐中，时间列必须先按字符读入，再显式按 `Asia/Shanghai` 解析；不得依赖 `data.table::fread()`、`read.csv()`、Excel 读取器或绘图库自动推断 `TIMESTAMP`、`time`、`block_start`、`block_end`、`window_time` 等列的时区。该约束适用于 raw-w、EC covariance、FL PF、水平风、profile/AP、气象和所有后续合并绘图脚本。[来源: 用户当前对话 2026-06-12]

- 若缓存文件中同时保存了带 `Z` 的时间字符串和已核验的 `time_num` epoch 秒数，应以 `time_num` 作为时间对齐基准，再转换为 `Asia/Shanghai` 本地展示时间；不能把带 `Z` 的字符串误当上海本地时间重解析。[已核验: project_memory/evidence/verifications/2026-06-12_ec_time_parsing_anchor_and_com_FLafterPF_fix.md]

- `com_FLafterPF` 的 PF_8bin EC 计算脚本已经按此约束修正：FL TOA5 高频 `TIMESTAMP` 按字符读入后用 `fl_pf_parse_toa5_time(..., "Asia/Shanghai")` 解析；结果 CSV 的 `block_start` 和 `block_end` 在绘图脚本中也按字符读入后再解析。[已核验: D:\00 博士阶段\博一\05 Project\com_FLafterPF\scripts\run_fl_pf8bin_ec_covariance_20250320_0323.R] [已核验: D:\00 博士阶段\博一\05 Project\com_FLafterPF\scripts\plot_fl_pf8bin_ec_covariance_20250320_0323.R]

