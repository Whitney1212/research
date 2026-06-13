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
- 事件检测与复合分析：日出/日落窗口、`09:00-11:00` 次高峰、结构切换时刻、强弱事件分组、多日 composite。
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
