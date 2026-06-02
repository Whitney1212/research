# 2026-05-20 FL 轨道几何与 raw `w` 诊断约束

## 来源

- 用户在当前回合补充：FL Excel 中 `位置` 的零点是 `MT` 所在的轨道起点；轨道随后经过 `CVT` 正上方的中点，到达 `245` 位置的轨道终点。 [来源: 用户当前对话 2026-05-20]
- 用户在当前回合补充：FL 时间与 EC 高频时间完全同步且同一时区。 [来源: 用户当前对话 2026-05-20]
- 用户在当前回合补充：FL 平台搭载实时调平装置，后续该分支暂不考虑 `pitch`、`roll`、`yaw` 姿态修正。 [来源: 用户当前对话 2026-05-20]
- 本回合读取了旧项目记忆和已核验脚本，确认旧 `W4` 中也保留了移动平台轨道位置尺度和端点坐标。 [已核验: D:\00 博士阶段\99 Project\04 Lee\project_memory\workstreams\W4_diurnal_vertical_advection_and_circulation.md] [已核验: D:\00 博士阶段\博一\05 Project\com_260401\com_0401\diagnose_w4_mobile_ec_circulation.R] [已核验: D:\00 博士阶段\博一\05 Project\com_260401\com_0401\diagnostics_0320_0323\w4_mobile_circulation\run_notes.txt]

## 轨道定义

- 当前 raw-w 诊断中，FL 的有效位置尺度应按 `0-245 m` 使用，而不是按端点坐标的水平直线距离重新拉伸。`0 m` 是靠南的起点，也就是 `MT` 位置；`245 m` 是轨道终点；`CVT` 位于轨道中点正下方、谷底中央。 [来源: 用户当前对话 2026-05-20] [已核验: D:\00 博士阶段\博一\05 Project\com_260401\com_0401\diagnostics_0320_0323\w4_mobile_circulation\run_notes.txt]
- 旧脚本中记录的轨道端点坐标为：south/start `easting = 447574.2334`、`northing = 2768410.8877`、`elevation = 659.8350`；north/end `easting = 447787.0474`、`northing = 2768235.1387`、`elevation = 661.0430`。由 south 指向 north 的坐标方位角为 `129.551°`，端点坐标直线距离为 `276.003 m`。 [已核验: D:\00 博士阶段\博一\05 Project\com_260401\com_0401\diagnose_w4_mobile_ec_circulation.R] [已核验: D:\00 博士阶段\博一\05 Project\com_260401\com_0401\diagnostics_0320_0323\w4_mobile_circulation\run_notes.txt]

## 对下一步诊断的影响

- FL 现在可以从“整体站点”推进为“沿轨道位置的移动切面观测”。下一步应把 FL 高频 EC 与 `20250313_20250419.xlsx` 的 `时间-位置` 表对齐，按 `position_m` 分箱，计算 `w_mean(x,t)`、`F_total(x,t)` 和 `c_mean(x,t)`。 [推断：基于用户补充的轨道定义和当前 raw-w 诊断目标整理]
- 因为 `0 m = MT`、中点在 `CVT` 正上方，FL 位置分箱可以直接用于检验“谷缘上升、谷底下沉、轨道另一端是否补偿”的切面结构。若 `w_mean` 或异常平均输送在 `0 m` 附近、`CVT` 上方中点和终点附近呈现稳定空间差异，就比把 FL 汇总成一个站点更能支持或否定横向局地环流解释。 [推断：基于轨道几何与当前局地环流工作假说整理]
- 平台实时调平降低了 `pitch/roll/yaw` 姿态误差作为首要解释的优先级，但不消除 sonic 坐标、north offset、流线倾斜、水平风混入和移动速度对 raw `w` 的影响。因此仍需做 `w_mean ~ u_mean + v_mean`、风向扇区和平台运动方向分组诊断。 [来源: 用户当前对话 2026-05-20] [推断：基于当前未做坐标旋转的处理边界整理]
