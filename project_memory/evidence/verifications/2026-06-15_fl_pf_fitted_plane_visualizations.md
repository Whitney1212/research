# 2026-06-15 FL PF 拟合平面可视化补充

## 来源

- 这份记录整理自当前对话中关于 FL planar fit 拟合平面表达方式的连续讨论，以及本轮对本地脚本和输出图件的直接核验。 [来源: 用户当前对话 2026-06-15] [已核验: E:\FL_pf\00_compare_all_methods]

## 本次新增信息

- 已新增并运行 C/D 方法拟合平面可视化脚本 `E:\FL_pf\00_compare_all_methods\plot_CD_pf_plane_visualizations.R`，运行命令为 `Rscript "E:\FL_pf\00_compare_all_methods\plot_CD_pf_plane_visualizations.R"`，脚本完成后生成 4 张 PNG 图件。 [已核验: E:\FL_pf\00_compare_all_methods\plot_CD_pf_plane_visualizations.R]
- 已生成 C1 方向分开全轨道 PF 平面图 `fig_CD_pf_plane_C1_direction_track_surfaces.png`，该图把 `fw` 与 `bw` 分成两个面板，用 `track position × u_perp × w_plane` 的轨道剖面方式展示方向分开后的拟合平面。 [已核验: E:\FL_pf\00_compare_all_methods\fig_CD_pf_plane_C1_direction_track_surfaces.png]
- 已生成 C2 方向 × bin PF 平面图 `fig_CD_pf_plane_C2_direction_binwise_surfaces.png`，该图按 `fw/bw` 分面，并把各 bin 的拟合平面沿轨道位置拼接，用颜色深浅表达各 bin 的 `tilt_deg`。 [已核验: E:\FL_pf\00_compare_all_methods\fig_CD_pf_plane_C2_direction_binwise_surfaces.png]
- 已生成 D1 风向扇区全轨道 PF 图 `fig_CD_pf_plane_D1_track_sector_heatmap_facets.png`，该图每个小面板对应一个 `wind_from` 扇区，横轴为 `u_parallel`，纵轴为 `u_perp`，底色为拟合平面预测的 `w_plane`，蓝点为参与该扇区 PF 拟合的输入统计点。 [已核验: E:\FL_pf\00_compare_all_methods\fig_CD_pf_plane_D1_track_sector_heatmap_facets.png]
- 已生成 D2 bin × sector 倾角矩阵图 `fig_CD_pf_plane_D2_bin_sector_tilt_matrix.png`，每个格子代表一个 `bin × wind_from sector` PF 单元，颜色表示 `tilt_deg`，灰色且标注 `fail` 的格子表示样本不足或拟合失败。 [已核验: E:\FL_pf\00_compare_all_methods\fig_CD_pf_plane_D2_bin_sector_tilt_matrix.png]

## D 系列风向扇区口径

- D 系列使用 `wind_from` 而不是 `wind_to` 分风向；实现先由运动修正后的 `u_mean/v_mean` 计算 `wind_to = atan2(u_east, v_north)`，再加 `180 deg` 得到 `wind_from`。 [已核验: E:\FL_pf\R\fl_pf_common.R]
- 当前扇区数为 `sector_n = 8`，因此每个扇区宽 `45 deg`：`sector 01 = 0-45 deg`，`sector 02 = 45-90 deg`，依次到 `sector 08 = 315-360 deg`。 [已核验: E:\FL_pf\R\fl_pf_common.R]
- D1 的风向分类基于整条轨道 four-pass ensemble mean 输入点；D2 的风向分类基于 8-bin four-pass ensemble-bin mean 输入点。也就是说，D 系列反映的是 PF 输入统计点的平均来流方向分类，不是 10 Hz 瞬时风向逐点分类。 [已核验: E:\FL_pf\06_track_sector_pf\run_track_sector_pf.R] [已核验: E:\FL_pf\07_binwise_sector_pf_optional\run_binwise_sector_pf_optional.R]

## 和既有 A/B 图件的关系

- A1/B1/B2/B3 已生成对应的轨道位置 × 横风分量 × `w_plane` 拟合平面示意图，并统一使用颜色深浅表示 `tilt_deg`。A1 为全轨道统一 PF，B1/B2/B3 分别为 6-bin、8-bin 和 10-bin PF。 [已核验: E:\FL_pf\00_compare_all_methods\fig_A1_global_track_pf_track_position_crosswind_surface_tilt_colored.png] [已核验: E:\FL_pf\00_compare_all_methods\fig_B1_6bin_pf_track_position_crosswind_surface_tilt_colored.png] [已核验: E:\FL_pf\00_compare_all_methods\fig_B2_8bin_pf_track_position_crosswind_surface_tilt_colored.png] [已核验: E:\FL_pf\00_compare_all_methods\fig_B3_10bin_pf_track_position_crosswind_surface_tilt_colored.png]
- 推断：A/B 图件适合展示沿轨道位置的拟合平面空间变化，C 图件适合检查 `fw/bw` 方向差异，D 图件适合检查拟合平面是否随来流风向改变。D2 因为拆分到 `bin × sector`，最容易出现样本不足或拟合失败，因此更适合作为诊断图，而不是最终旋转参数。 [推断：基于本次图件结构和各方法分组方式整理]

## REgov 作图规范同步点

- 本次 PF 平面图件继续采用白底论文图取向，避免过多留白，减少无关装饰，并以浅灰网格、顶部或低干扰图例、明确标题和分面标签辅助阅读。 [来源: 用户当前对话 2026-06-15] [已核验: D:\00 博士阶段\99 Project\06 EA\regov_memory\03_visualization.md]
- 后续若继续补充 PF 平面图，默认应保留统一短标签：`A1 = 01 Global track`，`B1 = 02 6-bin`，`B2 = 03 8-bin`，`B3 = 04 10-bin`，`C1 = 05A Direction track`，`C2 = 05B Direction x bin`，`D1 = 06 Track sector`，`D2 = 07 Bin x sector`。 [来源: 用户当前对话 2026-06-15]

## 解释边界

- PF 拟合平面图展示的是 `w = a + b u + c v` 所定义的平均流线平面或其诊断投影；它可以帮助比较不同旋转策略下平面倾角、方向差异、风向依赖和沿轨道空间变化，但不能直接替代后续高频通量计算。 [推断：基于 PF 方法定义和当前输出用途整理]
- 颜色深浅表示 `tilt_deg` 或 `w_plane` 时必须在图题或说明中明确，因为绿色平面本身只是方法组或平面片的视觉载体，不能默认等同于倾角大小。 [来源: 用户当前对话 2026-06-15] [推断：基于本次图件迭代中对“绿色是否代表倾角”的澄清整理]
