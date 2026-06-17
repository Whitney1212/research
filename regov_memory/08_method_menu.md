# REgov 研究手段菜单

## 定位

这份文件不是固定清单，而是一个可扩展菜单。后续只要某个方法能够服务“复杂地形下通量计量方案/结果”，就可以加入；每个方法都要说明它解决什么问题、调用什么数据、输出什么量，以及它的解释边界。 [来源: 用户当前对话 2026-05-28]

## 方法选择原则

- 先明确目标：当前是在算正式通量、做修正、做诊断，还是做机制解释。
- 先用已有数据和已有工具做最小可验证版本，再决定是否引入复杂方法。
- 方法之间可以组合，但不要把诊断量直接写成正式物理通量。
- 每个新方法至少要记录输入数据、核心公式或算法、输出变量、适用前提、不能说明什么。

## 菜单 v1

- 数据覆盖与质量控制：原始数据覆盖检查、缺测统计、诊断码过滤、合理范围过滤、Vickers-Mahrt 式 despiking、覆盖率阈值、异常日/异常层位标记。
- 时间与同步：`Asia/Shanghai` 时间解析、start-label/end-label 区分、EC/AP/MET/FL 对齐、lag 搜索、移动平台运行状态匹配。
- 常规 EC 计算：协方差通量、block 分割、lag 校正、去趋势、坐标旋转、质量标记、最终通量汇总。优先检查 `ecpreproc` 已有实现。根据用户既往处理经验和研究区背景，`F_EC` 较为依赖坐标旋转方法，因此后续正式 EC 基线应优先做 no rotation、double rotation、planar fit 或 sector-wise planar fit 的并行对照，并把旋转敏感性作为最终结果不确定性来源。 [来源: 用户当前对话 2026-05-29]
- EddyPro 复现与对照：用 `ecpreproc` 复现 EddyPro 关键阶段，并在需要时与 EddyPro 输出逐阶段核对，识别差异来自预处理、修正还是单位口径。
- 坐标和平台修正：sonic 坐标解释、north offset、二维水平风统一、三维坐标旋转、经验 `w_mean ~ u + v` 诊断、FL 平台运动修正。
- FL `PF_8bin` 移动平台 planar fit：使用 `5-240 m` 有效轨道、8 个位置 bin、four-pass ensemble-bin mean、统一运行记录逐点位置插值和实际有符号速度矢量修正，拟合 `w = a + b * U_east_corr + c * U_north_corr`。当前正式参数表为 `E:\Dataset_Level1\Flares\PFparameter\PF_8bin_parameters_for_flux.csv`，适合作为后续 FL 高频通量计算的主坐标旋转口径；若更换运行记录、速度字段、bin 划分或有效轨道范围，必须重新生成参数。 [已核验: E:\Dataset_Level1\Flares\PFparameter\PF_8bin_method_notes.md] [已核验: E:\Dataset_Level1\Flares\PFparameter\PF_8bin_parameters_for_flux.csv]
- WPL、密度和单位换算：干/湿空气密度、摩尔密度、WPL 修正、单位从运动学量到常规通量单位的换算。当前主线未默认启用，但属于后续正式通量方案候选步骤。
- 频率响应和谱修正：高通/低通谱修正、谱质量检查、传感器响应和管路衰减诊断。后续如进入正式 EC 方案，应纳入候选步骤。
- raw `w` 总输送诊断：\(\overline{wc}\)、`F_mean`、`F_turb`、`w_mean`、`A_net`、`A_ratio`、上升/下沉气团拆分。当前主要用于平均垂直运动和局地环流线索，不直接作为生态通量。
- EA/REA 式条件分组：基于 \(w'\) 或条件事件拆分上升/下沉气团，比较 \(c^+\)、\(c^-\)、`D_cond` 和 centered contribution。当前可用于机制诊断，正式 REA 通量需另行定义。
- CO2 储存与释放：AP200/MET 廓线、冠层以上/以下浓度变化、夜间积累、日出后释放、storage flux 估算和次高峰阶段分析。当前两套廓线系统最高层分别等于对应 EC 观测高度，因此可优先计算 `CVT` 与 `MT` 各自到 \(z_r\) 的局地柱 storage tendency；但在跨系统校准和控制体几何未完成前，不应直接升级为完整峡谷控制体 storage 或水平梯度通量。 [来源: 用户当前对话 2026-05-29]
- 平流与局地环流：水平风扇区、垂直平流、水平平流、FL 切面输送、谷底/谷缘相位差、局地环流事件分类。
- 冠层交换解释：冠层源汇、湍流交换、稳定层结、冠层高度边界和通量塔观测层位之间的关系。
- 事件检测与复合分析：日出/日落窗口、`09:00-11:00` 次高峰、结构切换时刻、强弱事件分组、多日 composite。2026-06-17 后，晨间 CO2 peak 不再只是通量修正框架的案例分支，而应作为独立 W2 工作流维护；当前固定塔数据条件下先做一个自然年，优先以 `2025` 年建立事件气候学和冻结前检测规则，维修断口按缺测处理。 [来源: 用户当前对话 2026-06-17] [已核验: D:\00 博士阶段\99 Project\06 EA\project_memory\evidence\verifications\2026-06-17_fixed_tower_level0_coverage.md]
- 晨间 peak 事件机制判据：固定使用日出相对时间，事件级统计 peak 发生率、峰值时间、幅度、持续时间、峰后下降率、三站 lead-lag、表观传播速度、profile transition、风向变化和 peak 后同步下降；独立样本按事件日计。历史短波日出 proxy 的可复现口径是 `CVT_MET` 的 `SW_in_Avg` 聚合为 30 min `SW_in` 后，以 `SW_in >= 20 W m^-2` 的首个窗口作为 `sunrise_ref_sw`。 [来源: 用户当前对话 2026-06-17] [已核验: D:\00 博士阶段\99 Project\06 EA\project_memory\evidence\verifications\2026-06-17_cvt_sw_in_sunrise_reference.md]
- AP 廓线代理量：可使用廓线梯度指数、柱浓度异常代理量和柱异常变化率代理来比较 profile switch、梯度符号、标准化变化幅度、变化速率和相对 peak 的相位；不能称为正式 `storage flux`，也不能直接进入 `F_EC + F_storage` 闭合。 [来源: 用户当前对话 2026-06-17]
- 统计与不确定性：敏感性分析、bootstrap、事件分组检验、回归/混合模型、聚类或状态分类。使用前先确认样本量和独立性。
- 可视化：数据覆盖甘特图、workstream dashboard、逐日时间序列、站点对比、剖面图、切面位置图、机制判据图和论文图件草图。
- 文献与理论校验：针对 EC 假设、复杂地形平流、storage correction、Lee 方法、REA/EA、谱修正等问题建立理论卡，避免只凭模型记忆判断。

## 新方法加入模板

```markdown
### 方法名

- 目标：
- 输入数据：
- 核心计算/判据：
- 输出变量：
- 适用前提：
- 不能说明：
- 优先验证：
- 关联 workstream：
```

### FL PF_8bin 移动平台 planar fit 旋转参数

- 目标：为 FL 移动平台高频通量计算提供当前主推荐的坐标旋转参数，而不是继续使用旧的线性位置和固定小车速度试算口径。 [已核验: E:\Dataset_Level1\Flares\PFparameter\PF_8bin_method_notes.md]
- 输入数据：完整单程表、FL 高频 EC 数据和统一运行记录，其中运行记录提供逐点位置和实际有符号速度。 [已核验: E:\Dataset_Level1\Flares\PFparameter\manifest.txt]
- 核心计算：先把 sonic 水平风转换到地理 east/north，再用实际小车速度矢量做水平运动修正，按 `5-240 m` 的 8 个 bin 构造 four-pass ensemble-bin mean，并逐 bin 拟合 PF 参数。 [已核验: E:\Dataset_Level1\Flares\PFparameter\PF_8bin_method_notes.md]
- 输出变量：`a`、`b`、`c`、`tilt_deg`、bin 边界、样本量和拟合诊断；后续高频应用时按当前点所在 bin 调用参数并计算 `w_pf`。 [已核验: E:\Dataset_Level1\Flares\PFparameter\PF_8bin_parameters_for_flux.csv]
- 适用前提：后续通量脚本必须沿用同一套位置插值、速度修正、north offset、轨道方位角、有效轨道范围和 bin 定义。 [推断：基于 PF 参数与预处理一致性要求整理]
- 不能说明：该方法未修正轨道坡度导致的垂直平台速度，也不能单独替代 WPL、频率响应、密度换算或完整通量质量控制。 [已核验: E:\Dataset_Level1\Flares\PFparameter\PF_8bin_method_notes.md]
- 优先验证：在带入高频通量前，检查每个 10 Hz 点是否成功匹配 bin 和 PF 参数，并对比旋转前后 `w_mean`、`F_EC`、残差分布、方向差异和 bin 边界附近样本。 [推断：基于 PF 参数应用风险整理]
- 关联 workstream：当前项目 `W1_EA_EC_flux`，服务复杂地形 EC 通量偏差和 FL 空间约束分支。 [已核验: D:\00 博士阶段\99 Project\06 EA\project_memory\workstreams\W1_EA_EC_flux.md]

### FL PF 拟合平面可视化诊断

- 目标：把不同 FL PF 旋转策略拟合出的平均流线面可视化，用于解释全轨道、bin-wise、方向分开和风向扇区 PF 的几何差异。 [已核验: D:\00 博士阶段\99 Project\06 EA\project_memory\evidence\verifications\2026-06-15_fl_pf_fitted_plane_visualizations.md]
- 输入数据：`E:\FL_pf` 下各方法的 `pf_fit_summary.csv`、`pf_input_points.csv` 和 `pf_points_with_residual.csv`，以及统一轨道方位角和 bin/sector 定义。 [已核验: E:\FL_pf\00_compare_all_methods] [已核验: D:\00 博士阶段\99 Project\06 EA\project_memory\evidence\verifications\2026-06-15_fl_pf_fitted_plane_visualizations.md]
- 核心计算/判据：A/B/C 图把 PF 平面投影到 `track position × u_perp × w_plane`；D1 使用 `u_parallel × u_perp × w_plane` 热图面板；D2 使用 `bin × wind_from sector` 的 `tilt_deg` 矩阵。 [已核验: E:\FL_pf\00_compare_all_methods\plot_CD_pf_plane_visualizations.R]
- 输出变量：`w_plane`、`tilt_deg`、方向分组、bin 分组、`wind_from` 扇区和拟合是否成功。 [已核验: D:\00 博士阶段\99 Project\06 EA\project_memory\evidence\verifications\2026-06-15_fl_pf_fitted_plane_visualizations.md]
- 适用前提：这些图用于方法解释和诊断，正式高频通量仍应调用已经固定的 `PF_8bin_parameters_for_flux.csv`，不能因为某张诊断图局部差异明显就直接更换旋转参数。 [已核验: E:\Dataset_Level1\Flares\PFparameter\PF_8bin_parameters_for_flux.csv] [推断：基于 PF 参数应用边界整理]
- 不能说明：平面图不能直接给出最终生态系统通量，也不能替代 WPL、频率响应、密度换算、窗口 QC 或轨道坡度导致的垂直平台速度修正。 [已核验: E:\Dataset_Level1\Flares\PFparameter\PF_8bin_method_notes.md] [推断：基于 PF 图件用途整理]
- 优先验证：报告中应优先把 A/B/C/D 图与 `tilt_deg`、RMSE 降幅、残差分布、`fw/bw` 差异和 sector 样本量一起解释。 [已核验: D:\00 博士阶段\99 Project\06 EA\project_memory\evidence\verifications\2026-06-15_fl_pf_fitted_plane_visualizations.md]
- 关联 workstream：当前项目 `W1_EA_EC_flux` 的 FL 坐标旋转和复杂地形通量方法不确定性分支。 [已核验: D:\00 博士阶段\99 Project\06 EA\project_memory\workstreams\W1_EA_EC_flux.md]
