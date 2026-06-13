# 2026-06-12 EC/FL 高频时间解析锚点与 com_FLafterPF 修正

## 来源

- 本记录来自用户在当前对话中明确指出的时间轴约束：EC 计算必须先把时间列按字符读入，再显式按 `Asia/Shanghai` 解析；这一点应作为锚点信息，后续不能再犯。[来源: 用户当前对话 2026-06-12]

## 本次确认与修正

- `D:\00 博士阶段\博一\05 Project\com_FLafterPF\scripts\run_fl_pf8bin_ec_covariance_20250320_0323.R` 已修正为在读取 FL TOA5 高频数据时，对原始 `TIMESTAMP` 列按原始列号强制 `colClasses = character`，随后调用 `fl_pf_parse_toa5_time(..., cfg$tz_local)` 按 `Asia/Shanghai` 解析；这避免 `data.table::fread()` 自动推断时间类型后引入时区偏移。[已核验: D:\00 博士阶段\博一\05 Project\com_FLafterPF\scripts\run_fl_pf8bin_ec_covariance_20250320_0323.R]
- 同一脚本读取 `PF_8bin_running_records_selected.csv` 缓存时，如果缓存中已有 `time_num`，则优先使用 `time_num` 作为时间对齐基准，并用 `as.POSIXct(time_num, origin = "1970-01-01", tz = "Asia/Shanghai")` 生成展示用本地时间；不能把缓存中带 `Z` 的 `time_state` 字符串直接当作上海本地时间重解析。[已核验: D:\00 博士阶段\博一\05 Project\com_FLafterPF\scripts\run_fl_pf8bin_ec_covariance_20250320_0323.R] [已核验: E:\Dataset_Level1\Flares\PFparameter\cache\PF_8bin_running_records_selected.csv]
- `D:\00 博士阶段\博一\05 Project\com_FLafterPF\scripts\plot_fl_pf8bin_ec_covariance_20250320_0323.R` 已修正为读取结果 CSV 时对 `block_start` 和 `block_end` 强制按字符读入，然后再按 `Asia/Shanghai` 解析用于绘图，避免绘图阶段再次发生时间轴自动推断偏移。[已核验: D:\00 博士阶段\博一\05 Project\com_FLafterPF\scripts\plot_fl_pf8bin_ec_covariance_20250320_0323.R]

## 锚点含义

- 后续所有 raw-w、EC covariance、FL PF、水平风、profile/AP、气象和可视化对齐脚本，只要涉及 `TIMESTAMP`、`time`、`block_start`、`block_end`、`window_time` 等时间列，都必须先字符读入，再显式指定 `Asia/Shanghai` 解析或使用已核验的 epoch 秒数对齐。不得依赖 `fread()`、`read.csv()`、Excel 读取器或绘图库自动推断时区。[来源: 用户当前对话 2026-06-12] [推断: 基于当前 com_FLafterPF 修正和既有 8 h 相位风险整理]

