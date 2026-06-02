# 2026-06-02 PF 旋转后 raw-w CO2 总输送 30 min 对比

## 本次记录对象

- 按用户要求，在旧 EA raw-w 总输送流程上做最小改动，只补充 `planar fit` 坐标旋转，并只计算 `30min` CO2 的 `F_total`、`F_mean` 和 `F_turb`。结果全部输出到 `D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_with_rotation`。 [来源: 用户当前对话 2026-06-02]
- 本次只处理已有 PF 拟合文件的固定站点 `MT` 和 `CVT`；`FL` 仍未纳入，因为当前 `com_rotation` 分支明确排除了 FL，且没有可直接复用的 FL PF 拟合文件。 [已核验: `D:\00 博士阶段\博一\05 Project\com_rotation\README.md`] [已核验: `D:\00 博士阶段\博一\05 Project\com_rotation\results\fit_details`]

## 脚本和输出

- 新增脚本为 `D:\00 博士阶段\博一\05 Project\ecpreproc\run_ea_raw_w_total_transport_pf_30min.R`。该脚本沿用旧 raw-w 流程的读取、诊断码过滤、合理范围过滤、`w/co2` despike、缺测过滤和 metadata 约束 lag；随后调用 `rotate_coordinates(method = "pf")` 生成 `w_rot`，再用 `w_rot` 计算 30 min 的 `F_total_pf_window`、`F_mean_pf_window` 和 `F_turb_pf_window`。 [已核验: `D:\00 博士阶段\博一\05 Project\ecpreproc\run_ea_raw_w_total_transport_pf_30min.R`]
- 主 PF 输出为 `D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_with_rotation\EA_pf_raw_w_CO2_total_transport_30min.csv`，共 `384` 行，其中 `MT = 192`、`CVT = 192`。 [已核验: 本轮运行输出与 CSV 行数]
- raw 对比输出为 `D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_with_rotation\EA_pf_vs_raw_w_CO2_total_transport_30min.csv`，共 `384` 行，已与旧 raw 30 min 文件按 `site + source_file + block_start` 完成配对。 [已核验: `D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_with_rotation\EA_pf_vs_raw_w_CO2_total_transport_30min.csv`]
- 站点汇总输出为 `D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_with_rotation\EA_pf_vs_raw_w_CO2_site_summary_30min.csv`；manifest 为 `EA_pf_raw_w_CO2_30min_manifest.txt`。 [已核验: `D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_with_rotation`]

## 核验结果

- 8 个输入文件运行状态均为 `ok`；PF 分解误差 `max_abs_pf_decomp_error` 约为 `2.84e-14`，处于浮点误差量级。 [已核验: `D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_with_rotation\EA_pf_raw_w_CO2_run_log_30min.csv`] [已核验: `EA_pf_raw_w_CO2_30min_manifest.txt`]
- `CVT` 的 30 min 平均 `F_total_raw_mean` 约为 `-24.34`，PF 后 `F_total_pf_mean` 约为 `-5.94`，平均差值约为 `+18.40`；对应 `F_mean` 的平均差值约为 `+18.40`，`F_turb` 的平均差值约为 `+0.00087`。 [已核验: `EA_pf_vs_raw_w_CO2_site_summary_30min.csv`]
- `MT` 的 30 min 平均 `F_total_raw_mean` 约为 `+74.11`，PF 后 `F_total_pf_mean` 约为 `-13.58`，平均差值约为 `-87.69`；对应 `F_mean` 的平均差值约为 `-87.69`，`F_turb` 的平均差值约为 `-0.00360`。 [已核验: `EA_pf_vs_raw_w_CO2_site_summary_30min.csv`]

## 可视化输出

- 按 REgov 固定图形规范新增并运行 `D:\00 博士阶段\博一\05 Project\ecpreproc\plot_ea_pf_rotation_raw_w_30min.R`，图件输出到 `D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_with_rotation\figures`。本次沿用 `CVT = #F8766D`、`FL = #00BA38`、`MT = #619CFF`，使用白底 `theme_bw`、图例置顶、浅灰分面标题和有符号变量零线。 [已核验: `D:\00 博士阶段\博一\05 Project\ecpreproc\plot_ea_pf_rotation_raw_w_30min.R`]
- 当前图件包括 `EA_pf_vs_raw_Ftotal_time_series_30min.png`、`EA_pf_minus_raw_component_differences_30min.png`、`EA_pf_vs_raw_site_mean_components_30min.png`、`EA_pf_CO2_decomposition_components_30min.png` 和 `EA_pf_vs_raw_component_scatter_30min.png`，并生成 manifest `EA_pf_rotation_raw_w_30min_visualization_manifest.csv`。 [已核验: `D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_with_rotation\figures`]
- 已人工打开检查 `EA_pf_vs_raw_Ftotal_time_series_30min.png` 与 `EA_pf_minus_raw_component_differences_30min.png`，图像正常渲染，站点配色、raw/PF 线型和三分量差异分面均可读；`F_turb` 差异图使用独立 y 轴以避免被 `F_total/F_mean` 的大数值压扁。 [已核验: 本轮本地图片查看]

## 解释边界

- 本次结果说明：PF 对 raw-w 总输送的影响主要通过平均垂直风或空气量项进入，`F_turb` 改变量相对很小。 [推断：基于 `F_total/F_mean/F_turb` 差异汇总]
- 这仍是方法敏感性分支，不等同于最终生态系统 CO2 通量；当前还没有加入 WPL、频率修正、空气摩尔密度换算，也没有对 FL 建立 PF 拟合。 [推断：基于当前项目方法边界]

## 2026-06-02 update: air molar density conversion and requested component figures

- Supersedes the earlier "no density conversion" boundary for this PF/raw-w branch. The 30 min PF script now keeps `ta` and `pa`, calculates per-window mean air molar density as `mean(PA_kPa * 1000 / (R * (TA_C + 273.15)))`, and writes CO2 component columns in `umol m-2 s-1`: `F_total_pf_umol_m2_s`, `F_mean_pf_umol_m2_s`, `F_turb_pf_umol_m2_s`, plus paired raw columns and PF-minus-raw difference columns in `EA_pf_vs_raw_w_CO2_total_transport_30min.csv`. [verified: `D:\00 博士阶段\博一\05 Project\ecpreproc\run_ea_raw_w_total_transport_pf_30min.R`]
- Rerun verification: PF rows `384`, raw/PF paired comparison rows `384`; required molar-density/unit columns are present; `air_molar_density_mol_m3` range is `37.916` to `40.848`; max PF decomposition error after conversion is `1.136868e-12 umol m-2 s-1`. [verified: `D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_with_rotation\EA_pf_raw_w_CO2_total_transport_30min.csv`; `EA_pf_vs_raw_w_CO2_total_transport_30min.csv`; `EA_pf_raw_w_CO2_30min_manifest.txt`]
- Site means after unit conversion: CVT raw mean `-959.4831`, PF mean `-233.5007`, PF-minus-raw mean `+725.9824 umol m-2 s-1`; MT raw mean `+2877.2433`, PF mean `-529.6634`, PF-minus-raw mean `-3406.9067 umol m-2 s-1`. Mean-component differences still dominate the total difference; turbulent-component mean differences are `+0.0336` for CVT and `-0.1407 umol m-2 s-1` for MT. [verified: `EA_pf_vs_raw_w_CO2_site_summary_30min.csv`]
- Visualization script now uses the converted `*_umol_m2_s` columns and defines the plotted site color table as CVT/MT only, so FL is not shown in the legend for this PF-only output set. Existing five PNGs were regenerated, and two requested component-by-date facet figures were added: `EA_pf_components_by_component_date_30min.png` and `EA_pf_components_with_raw_overlay_30min.png`. The overlay figure draws raw as dashed lines with `alpha = 0.7`, PF as solid lines. [verified: `D:\00 博士阶段\博一\05 Project\ecpreproc\plot_ea_pf_rotation_raw_w_30min.R`; `D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_with_rotation\figures\EA_pf_rotation_raw_w_30min_visualization_manifest.csv`]

## 2026-06-02 update: PF F_turb versus existing EC covariance figure

- Added one REgov-style comparison figure for PF-rotated turbulent CO2 transport and the existing covariance EC flux: `EA_pf_Fturb_vs_EC_cov_30min.png`. The script pairs `EA_pf_raw_w_CO2_total_transport_30min.csv` with `EA_flux_results.csv` CO2 `F_EC_cov` by `site + source_file + block_start`, then converts `F_EC_cov` to `umol m-2 s-1` using the matched PF-window `air_molar_density_mol_m3`. [verified: `D:\00 博士阶段\博一\05 Project\ecpreproc\plot_ea_pf_rotation_raw_w_30min.R`]
- Pairing result: `376` windows total (`CVT = 188`, `MT = 188`). Site means: CVT PF `F_turb` mean `-1.5819`, EC covariance mean `-1.6159`, mean difference `+0.0340 umol m-2 s-1`; MT PF `F_turb` mean `-2.1917`, EC covariance mean `-2.0512`, mean difference `-0.1405 umol m-2 s-1`. [verified: `D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_with_rotation\EA_pf_Fturb_vs_EC_cov_30min.csv`; `EA_pf_Fturb_vs_EC_cov_site_summary_30min.csv`]
- The figure was visually inspected after generation. It uses date columns, site rows, station colors only for CVT/MT, PF as solid lines and EC covariance as dashed lines; FL is not shown. [verified: `D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_with_rotation\figures\EA_pf_Fturb_vs_EC_cov_30min.png`]

## 2026-06-02 correction: PF-basis EC covariance replaces raw-coordinate EC in F_turb comparison

- Corrected the previous `PF F_turb versus EC covariance` comparison: the earlier figure had used `EA_flux_results.csv` `F_EC_cov`, which was computed in the original/non-PF coordinate basis. The PF calculation script now calls the existing ecpreproc `calculate_ea_block()` on PF-rotated `w_rot` by temporarily using `w_rot` as the EC vertical wind variable on the same valid samples. [verified: `D:\00 博士阶段\博一\05 Project\ecpreproc\run_ea_raw_w_total_transport_pf_30min.R`]
- New PF output columns include `F_EC_cov_pf_valid`, `F_EC_cov_pf_window`, `F_EC_cov_pf_valid_umol_m2_s`, `F_EC_cov_pf_window_umol_m2_s`, and PF turbulent-minus-EC difference columns. Rerun result remains `384` PF rows and `384` paired raw/PF rows. The max absolute window-scaled PF `F_turb` minus PF EC covariance difference is `0 umol m-2 s-1`. [verified: `D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_with_rotation\EA_pf_raw_w_CO2_total_transport_30min.csv`; `EA_pf_raw_w_CO2_30min_manifest.txt`]
- Redrew `EA_pf_Fturb_vs_EC_cov_30min.png` without reading `EA_flux_results.csv`. The figure now uses PF `F_turb_pf_umol_m2_s` and PF-basis `F_EC_cov_pf_window_umol_m2_s`; paired windows are `384` total (`CVT = 192`, `MT = 192`). The two curves overlap exactly because both are the same PF covariance term under the same denominator and density conversion. [verified: `D:\00 博士阶段\博一\05 Project\ecpreproc\plot_ea_pf_rotation_raw_w_30min.R`; `D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_with_rotation\figures\EA_pf_Fturb_vs_EC_cov_30min.png`]
