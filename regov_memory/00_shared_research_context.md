# 共享研究背景上下文

## 作用

这份文件是 REgov 的“必读背景包”。它把当前项目与 `04 Lee` 的 anchor 层中长期有效、跨分析角度反复使用、容易被新工作线遗漏的内容集中到一个共享上下文中。后续新增 workstream、开新分析角度、写代码或做机制讨论时，应先读取这里，再按需读取具体项目的 `project_memory`。 [来源: 用户当前对话 2026-05-28] [推断：基于两个项目 anchor 层整合]

## 来源文件

- 当前项目 anchor 层：`D:\00 博士阶段\99 Project\06 EA\project_memory\anchors`。 [已核验: D:\00 博士阶段\99 Project\06 EA\project_memory\anchors]
- `04 Lee` anchor 层：`D:\00 博士阶段\99 Project\04 Lee\project_memory\anchors`。 [已核验: D:\00 博士阶段\99 Project\04 Lee\project_memory\anchors]
- 这份文件是整合层，不替代两个项目原始 anchor 文件；当需要精确追证、更新旧判断或处理冲突时，仍应回到原始 anchor 和 evidence。 [推断：基于 REgov 分层读取规则]

## 总研究目标与资源入口

- 总框架是复杂地形下的通量计量，最终目标是形成一个合理的通量计量方案或结果。CO2 储存释放、平流输送、局地环流、冠层交换、数据质量控制、坐标旋转、频率修正、WPL 修正等问题都可以纳入，但它们的角色应服从“是否改善通量计量解释和结果可信度”。 [来源: 用户当前对话 2026-05-28]
- 2026-06-06 后，REgov 的仓库级主线进一步收束为“复杂地形 EC 通量偏差的状态依赖性、机制来源与可观测修正框架”。后续优先议题固定为：EC 何时可信、storage 如何修正、平流/通风/局地环流如何造成解耦、FL 如何提供空间约束，以及是否能形成可迁移的状态分类。 [来源: 用户当前对话 2026-06-06] [已核验: project_memory/evidence/verifications/2026-06-06_regov_mainline_reset.md]
- 2026-06-17 后，当前项目调整为双主线并行：第一条主线继续理清复杂地形下长期碳收支与通量计量修正问题，第二条主线将晨间 CO2 peak 独立为长期稳定事件机制工作流，重点研究边界层转换、空间传播与局地再分配机制。该调整不是删除 2026-06-06 的通量修正框架，而是把原先作为支撑案例的晨间 peak 重新提升为并行主线。 [来源: 用户当前对话 2026-06-17] [已核验: project_memory/evidence/discussions/2026-06-17_morning_peak_dual_mainline_plan.md]
- 2026-06-17 后，当前项目后续批量数据整理的统一数据根入口为 `E:\Dataset_Level0`，当前处理记录和覆盖登记表为 `E:\Dataset_Level0\数据存入-处理记录.xlsx`；`E:\Dataset_RAW` 作为仪器直接输出数据入口和 provenance 追溯入口使用，不再作为本轮覆盖登记主索引。 [来源: 用户当前对话 2026-06-17] [已核验: project_memory/evidence/verifications/2026-06-17_fixed_tower_level0_coverage.md]
- Codex thread `019d4d7f-99f1-7201-87fb-409488ce10a4` 保留了旧 E 盘目录整理地图，可用于追溯 `MET_TOWER_RAW`、`EC_TOWER_RAW`、`AP200_tower`、`EC_FLARES_RAW`、`MET_FLARES_RAW`、`Operation_state` 等历史入口；但其中小写 `mt/cvt/evt/nvt/svt` 属于硬盘整理口径，不能覆盖当前 `MT=谷缘高地`、`CVT=谷底` 的科学站点定义。 [来源: 用户当前对话 2026-06-17] [已核验: project_memory/evidence/threads/2026-06-17_thread_019d4d7f_e_drive_data_organization.md]
- 晨间 peak 工作流复用历史日出相对时间口径时，已核验的短波日出 proxy 是 `CVT_MET` 的 `SW_in_Avg`，聚合为 `30 min` 的 `SW_in` 后，以 `SW_in >= 20 W m^-2` 的首个窗口作为 `sunrise_ref_sw`。该口径不使用 `SW_out_Avg` 或 `Rn_Avg` 判定日出；固定塔自然年批量应用前仍需核查 `E:\Dataset_Level0` 中该字段的覆盖和异常值处理。 [已核验: project_memory/evidence/verifications/2026-06-17_cvt_sw_in_sunrise_reference.md]
- 旧 RAW 目录中的登记表和甘特图只作为历史覆盖线索保留；当前固定塔自然年和三站事件日批量整理应以 Level0 处理记录重新计算覆盖，必要时再回到 `E:\Dataset_RAW` 查原始仪器输出。 [来源: 用户当前对话 2026-06-17] [已核验: project_memory/evidence/verifications/2026-06-17_fixed_tower_level0_coverage.md] [已核验: E:\Dataset_RAW\20260428数据甘特图.png]
- 用户已确认当前检测到的固定塔数据就是全部可用数据，W2 第一版不再等待两个完整自然年，而是按一个自然年推进，优先以 `2025` 年为主分析年；仪器维修造成的断口作为不可避免缺测处理。 [来源: 用户当前对话 2026-06-17] [已核验: project_memory/evidence/verifications/2026-06-17_fixed_tower_level0_coverage.md]
- `D:\00 博士阶段\博一\05 Project\ecpreproc` 是用户自写、按 EddyPro 逻辑复现的通量预处理和计算包，已经过每个阶段精度验证，可作为更灵活通量计算的优先调用工具。 [来源: 用户当前对话 2026-05-28] [已核验: D:\00 博士阶段\博一\05 Project\ecpreproc]
- 详细研究问题分层、数据资产和方法菜单分别由 `regov_memory/06_research_question_map.md`、`regov_memory/07_data_inventory.md` 和 `regov_memory/08_method_menu.md` 维护；共享背景文件只保留长期有效的入口信息，避免不断膨胀。 [推断：基于 REgov 分层存取结构]

## 共享研究区与观测系统

- 当前大课题围绕复杂山地峡谷场地展开，核心问题是复杂地形条件下的局地环流、垂直/水平输送、CO2 结构变化，以及通量计算或通量校正。这个背景决定了后续判断不能简单套用平坦下垫面直觉。 [已核验: D:\00 博士阶段\99 Project\04 Lee\project_memory\anchors\01_anchor_facts.md]
- 谷底中心存在一座 `45 m` 高塔，配置 `CPEC310` 通量系统、MET 梯度气象系统和 `AP200` 五层 CO2 廓线系统；谷底塔附近冠层高度约 `20 m`，因此“冠层以上”在当前项目里有明确层位边界。 [已核验: D:\00 博士阶段\99 Project\04 Lee\project_memory\anchors\01_anchor_facts.md]
- 在 `04 Lee` 的 W4 解释中，`CVT` 应按“轨道和谷轴交叉位置、谷底中央”理解，`MT` 应按“谷缘坡顶”理解；这个映射直接影响对谷轴输送、切面输送、塔位 footprint 和两塔同步性的解释。 [来源: 用户在 2026-05-01 当前回合的场地说明] [已核验: D:\00 博士阶段\99 Project\04 Lee\project_memory\anchors\01_anchor_facts.md]
- 当前项目中，`MT` 被明确为谷缘高地，`CVT` 被明确为谷底，`FL` 被明确为在谷地上方沿切面均匀运动的观测。这个站点背景会直接约束 raw `w` 平均垂直运动和局地环流结构解释。 [来源: 用户当前对话 2026-05-20] [已核验: D:\00 博士阶段\99 Project\06 EA\project_memory\anchors\01_anchor_facts.md]
- 研究区存在一条接近主切面的 ridge-to-ridge 轨道，讨论中一直把它视为判断峡谷切面输送和局地环流结构的重要观测线。轨道上的移动系统包括 `CPEC310` 通量系统、MET 梯度气象系统和 `AP200` CO2 廓线系统，因此它不仅提供风场信息，也可能为切面结构判断提供浓度证据。 [已核验: D:\00 博士阶段\99 Project\04 Lee\project_memory\anchors\01_anchor_facts.md]
- 近地层排泄流观测不只依赖单塔，旧记忆中还保留了“谷底中心塔加坡面五塔”的描述。这意味着场地本身具有多尺度结构，后续整理时不要把所有过程压缩成单塔现象。 [已核验: D:\00 博士阶段\99 Project\04 Lee\project_memory\anchors\01_anchor_facts.md]

## FL 与移动平台几何

- 当前项目中，FL 轨道位置定义为：`0 m` 为靠南起点并对应 `MT` 位置，轨道中点穿过 `CVT` 正上方，`245 m` 为轨道终点；FL 时间与 EC 高频时间同一时区且同步，平台搭载实时调平装置，当前诊断暂不把 `pitch/roll/yaw` 姿态修正作为首要误差源。 [来源: 用户当前对话 2026-05-20] [已核验: D:\00 博士阶段\99 Project\06 EA\project_memory\anchors\01_anchor_facts.md]
- 旧项目脚本记录的 FL 轨道端点坐标为 south/start `E=447574.2334, N=2768410.8877, z=659.8350` 和 north/end `E=447787.0474, N=2768235.1387, z=661.0430`；south 指向 north 的坐标方位角约 `129.551°`，端点坐标直线距离约 `276.003 m`。当前位置分箱仍应使用有效位置尺度 `0-245 m`，不把位置列重新拉伸到端点坐标距离。 [已核验: D:\00 博士阶段\博一\05 Project\com_260401\com_0401\diagnose_w4_mobile_ec_circulation.R] [已核验: D:\00 博士阶段\博一\05 Project\com_260401\com_0401\diagnostics_0320_0323\w4_mobile_circulation\run_notes.txt]
- 对移动平台轨道位置而言，`04 Lee` 中当前有效位置尺度也以小车位置列 `0-245 m` 为准，其中 `0 m` 为 `south`，`245 m` 为 `north`。轨道端点坐标用于确定 south-to-north 地理方位角和后续平台运动修正方向，不用于把小车位置列拉伸到端点坐标水平距离。 [来源: 用户在 2026-04-30 当前回合的明确决定] [已核验: D:\00 博士阶段\99 Project\04 Lee\project_memory\anchors\03_active_decisions.md]
- 小车运动状态的时间仍有不确定性；如果后续要把移动平台数据用于更多日期或更强归因，需要先整理并匹配小车运行状态、CPEC310 高频数据和 EC 时间口径。否则，小车 `south/center/north` 空间形态只能作为弱线索，不能直接作为已确认机制证据。 [来源: 用户在 2026-05-01 当前回合的判断] [已核验: D:\00 博士阶段\99 Project\04 Lee\project_memory\anchors\02_key_constraints.md]
- 如果后续把小车风场或 REA 式诊断纳入与固定塔比较，还需要先确认是否扣除小车自身速度；在平台运动修正未明确之前，不应把小车风向、垂直风或 REA 条件分组直接并入强归因。 [来源: 用户在 2026-05-08 当前回合提供的讨论记录] [已核验: D:\00 博士阶段\99 Project\04 Lee\project_memory\anchors\02_key_constraints.md]

## FL PF_8bin 正式参数口径

- `PF_8bin` 是当前 FL 移动平台 planar fit 的正式参数口径，输出根目录为 `E:\Dataset_Level1\Flares\PFparameter`，后续高频通量计算应调用 `PF_8bin_parameters_for_flux.csv`，并保留 `run_PF_8bin.R`、`PF_8bin_method_notes.md` 和 `figures` 作为可复现脚本、方法说明和诊断图入口。 [已核验: E:\Dataset_Level1\Flares\PFparameter] [已核验: D:\00 博士阶段\99 Project\06 EA\project_memory\evidence\verifications\2026-06-12_fl_pf8bin_record_position_actual_speed.md]
- 该口径保留原 B2 的 `8-bin bin-wise planar fit` 思路，但预处理已从“单程起止位置线性插值 + 固定 `0.137 m/s`”升级为“统一运行记录逐点位置插值 + 实际有符号速度矢量水平风修正”。有效轨道范围为 `5-240 m`，8 个等宽 bin，PF 输入为 four-pass ensemble-bin mean。 [已核验: E:\Dataset_Level1\Flares\PFparameter\PF_8bin_method_notes.md] [已核验: D:\00 博士阶段\99 Project\06 EA\project_memory\evidence\verifications\2026-06-12_fl_pf8bin_record_position_actual_speed.md]
- `PF_8bin` 的水平运动修正使用 `cart_speed_m_s = speed_cm_s_record / 100`，再按轨道方位角 `129.551°` 分解为 east/north 速度并加到地理东/北向水平风上；PF 方程为 `w = a + b * U_east_corr + c * U_north_corr`，后续高频应用时计算 `w_pf = Uz - (a + b * U_east_corr + c * U_north_corr)`。 [已核验: E:\Dataset_Level1\Flares\PFparameter\PF_8bin_method_notes.md]
- 本次正式运行中，严格通过完整单程 `1529` 个、覆盖 `73` 天，构造有效 four-pass ensemble `334` 个；`PF_8bin` 输入点总数 `1852`，8 个 bin 全部拟合成功，倾角范围 `8.4200-11.8022 deg`，输入点层面中位 RMSE 降幅约 `38.1%`。这说明该口径已经具备作为后续 FL 高频通量旋转参数的样本量和可复现基础。 [已核验: E:\Dataset_Level1\Flares\PFparameter\manifest.txt] [已核验: E:\Dataset_Level1\Flares\PFparameter\pf_fit_summary.csv] [推断：基于 PF 样本量、fit_ok 和 RMSE 诊断整理]
- A/B 对比显示，新旧预处理的平均绝对位置差约 `0.0747 m`，10 Hz 样本 bin 重分配比例约 `0.245%`，实际速度相对固定速度的平均绝对差约 `0.00267 m/s`。因此这次升级主要是把位置和速度处理正式化，对 8-bin 分箱和整体 PF 判断没有造成大范围重排；但当前参数不能与旧线性位置/固定速度的 B2 预处理混用。 [已核验: E:\Dataset_Level1\Flares\PFparameter\PF_8bin_preprocessing_ab_summary.csv] [推断：基于 A/B 汇总数值整理]
- `PF_8bin` 本轮仍未修正轨道坡度导致的垂直平台速度。因此它解决的是 sonic 方位、水平小车运动和长期平均流线倾斜下的 FL 坐标旋转参数问题，不应被解释为已经完成全部平台三维运动修正。 [已核验: E:\Dataset_Level1\Flares\PFparameter\PF_8bin_method_notes.md] [推断：基于方法边界整理]

## 当前项目 EA/EC 与 raw-w 计算对象

- 当前工作线处理三个 EC 观测点的高频数据：`MT` 来自 `E:\260402计算\谷缘塔EC`，`CVT` 来自 `E:\260402计算\谷底塔EC`，`FL` 来自 `E:\260402计算\Flares_EC`。 [来源: 用户当前对话 2026-05-18] [已核验: D:\00 博士阶段\99 Project\06 EA\project_memory\anchors\01_anchor_facts.md]
- 当前 EA 主结果文件为 `D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_flux_results.csv`，覆盖 `2025-03-20` 到 `2025-03-23`，站点为 `MT`、`CVT`、`FL`，标量为 `co2` 和 `h2o`。主结果共有 1152 行，即 3 个站点、4 天、48 个半小时、2 个标量。 [已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_flux_results.csv] [已核验: D:\00 博士阶段\99 Project\06 EA\project_memory\anchors\01_anchor_facts.md]
- 当前结果是一行一个站点、一个 30 min 时段、一个标量，因此当前 EA 通量是由高频 EC 数据计算得到的 30 min 通量，不是高频逐点通量。 [已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_flux_results.csv]
- 当前 EA 计算先在每个 30 min block 内对垂直风去均值，使用 \(w'_i=w_i-\bar w\)，再以 \(w'_i>0\) 和 \(w'_i<0\) 划分上升与下沉事件。 [已核验: D:\00 博士阶段\博一\05 Project\ecpreproc\run_ea_preprocess.R]
- 当前 EA 通量采用 \(F_{EA}=(A^+c^+-A^-c^-)/T\)，其中 \(A^+=\sum_{w'>0}w'\Delta t\)，\(A^-=\sum_{w'<0}(-w')\Delta t\)，\(c^+\) 和 \(c^-\) 是按 \(w'\) 体积权重得到的上升/下沉气团浓度。 [已核验: D:\00 博士阶段\博一\05 Project\ecpreproc\run_ea_preprocess.R]
- 因为当前计算使用去均值后的 \(w'\)，并且 `A_up` 与 `A_down` 在离散意义上平衡，所以 `F_EA_general` 和 `F_EC_cov` 在数值上几乎相等；当前 EA 实现等价于 EC 协方差通量的条件积分写法。 [已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_flux_results.csv]
- 理论讨论中曾指出 EA 原始总输送可包含湍流和平均垂直输送项，但当前代码中的 EA 使用 \(w'\) 并去除了 30 min 平均垂直风，因此当前 `F_EA_general` 不包含 \(\bar w\bar c\) 形式的平均垂直输送。这个差异不是矛盾，而是“理论总输送形式”和“当前实现的湍流条件积分形式”之间的定义差异。 [来源: 用户当前对话 2026-05-18] [已核验: D:\00 博士阶段\博一\05 Project\ecpreproc\run_ea_preprocess.R]

## 方法边界与硬约束

- 当前处理明确不做坐标旋转、WPL 修正、频率修正和空气密度或摩尔密度换算，因此结果应解释为当前坐标和当前单位下的运动学通量，而不是已经换算到常规 \(\mu mol\,m^{-2}\,s^{-1}\) 的 CO2 通量。 [来源: 用户当前对话 2026-05-18] [已核验: D:\00 博士阶段\博一\05 Project\ecpreproc\run_ea_preprocess.R]
- 当前气体测量量被视为摩尔分数，且用户明确说“不需要密度修正”。如果后续要与常规 EC 碳通量单位比较，需要另行加入空气摩尔密度或干空气摩尔密度换算。 [来源: 用户当前对话 2026-05-18]
- 因为不做坐标旋转，`w'` 是仪器坐标下去除 30 min 平均后的垂直风脉动，不应直接解释为严格地形法向风或完整平均垂直平流。这个边界会影响对山谷站上升/下沉事件的物理解释。 [来源: 用户当前对话 2026-05-18]
- 当前 raw `w` CO2 总输送作为独立分支计算，使用 `D:\00 博士阶段\博一\05 Project\ecpreproc\run_ea_raw_w_total_transport.R`，只计算 CO2，输出 5 min 和 30 min 两个窗口，并不覆盖旧的 \(w'\) 协方差型 EA/EC 结果。 [已核验: D:\00 博士阶段\博一\05 Project\ecpreproc\run_ea_raw_w_total_transport.R] [已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_raw_w_total_transport\EA_raw_w_CO2_total_transport_all_windows.csv]
- 当前 raw-w 后续分析以 30 min 结果作为主解释尺度，5 min 结果用于日出、日落和短时事件细节；优先分析 `F_total_raw_window`、`F_mean_window`、`F_turb_window`、`w_mean_window`、`A_net`、`A_ratio`、`F_up_raw_window`、`F_down_raw_window` 和 `c_up_flux_weighted-c_down_flux_weighted`，再结合风速、风向和稳定度等气象条件做归因。 [来源: 用户当前对话 2026-05-20] [已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_raw_w_total_transport_30min.csv] [已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_raw_w_total_transport_5min.csv]
- 当前 raw `w` CO2 总输送结果几乎完全由 `F_mean_window` 控制，平均流项在平均绝对分量中占比约 `0.9980` 到 `0.9995`。因此 raw-w 总输送应解释为原始仪器坐标下平均垂直风携带 CO2 的结果，而不是直接等同于生态系统 CO2 交换强度。 [已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_raw_w_total_transport\EA_raw_w_CO2_figures\EA_raw_w_CO2_site_window_summary.csv] [推断：基于当前未做坐标旋转的处理边界整理]
- 根据用户基于既往数据处理经验和研究区背景的判断，`F_EC` 对坐标旋转方法较为敏感。后续复杂地形通量计量不应把单一旋转版本的 `F_EC` 当作无条件最终值，而应把 no rotation、double rotation、planar fit 或 sector-wise planar fit 等口径作为方法敏感性轴，输出通量范围、稳定性判断和旋转依赖标记。若某个 CO2 通量结论只在单一旋转口径下成立，应标记为旋转敏感结果，而不是提升为稳健机制结论。 [来源: 用户当前对话 2026-05-29] [推断：基于复杂地形通量计量方法边界整理]
- 当前对 raw-w 结果的解释边界是：`F_mean` 主导 `F_total` 可作为局地平均垂直运动的诊断线索，但不能直接写成生态 CO2 交换强度或最终局地环流证明。后续主线应先检验 `w_mean_window` 与水平风、风向、站点地形位置和 FL 切面位置的关系。 [来源: 用户当前对话 2026-05-20] [推断：基于当前分解结果和未做坐标旋转的处理边界整理]
- 当前 raw-w 上升/下沉气团细分采用 \(F_{\mathrm{total}}=\overline{wc}\) 的总输送口径，按原始 `w` 符号分组并使用通量权重计算 \(c^+\) 与 \(c^-\)。解释时必须区分 `F_air_amount` 和 `F_conc_anom`：前者主要反映 raw `w` 空气量/平均垂直运动，后者才更接近 CO2 浓度异常结构。 [来源: 用户当前对话 2026-05-21] [已核验: D:\00 博士阶段\博一\05 Project\ecpreproc\plot_ea_raw_w_up_down_airmass_details.R] [已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_raw_w_up_down_airmass_details\EA_raw_w_up_down_airmass_metrics_all_windows.csv]
- 当前主线暂不使用 `EA_raw_w_total_transport_tilt_corrected` 中的经验修正结果；后续分析继续基于未修正 raw `w` CO2 总输送结果推进。 [来源: 用户当前对话 2026-05-19]
- 当前经验倾斜修正不是实测安装几何修正，而是用 30 min 风场块拟合 `w_mean ~ u_mean + v_mean` 后扣除线性偏差。它能显著降低站点长期平均 raw-w 总输送，但可能同时移除真实地形平均垂直运动，因此只能作为诊断分支使用。 [已核验: D:\00 博士阶段\博一\05 Project\ecpreproc\run_ea_raw_w_total_transport_tilt_corrected.R] [推断：基于 metadata 缺少 pitch/roll 字段和当前经验模型整理]
- FL 平台实时调平使 `pitch/roll/yaw` 姿态修正暂不作为当前首要误差源，但这不等于 raw `w` 已经是地理垂直风；sonic 坐标、north offset、流线倾斜、水平风混入和平台运动方向仍需要通过风向扇区、`w_mean ~ u_mean + v_mean` 和移动方向分组诊断排查。 [来源: 用户当前对话 2026-05-20] [推断：基于当前 raw-w 处理边界整理]

## 时间、质量控制与数据读取

- 本项目所有需要按本地时间对齐的数据表，时间列读取时应优先按字符读入，再显式按 `Asia/Shanghai` 解析或赋予时区。不要让 `data.table::fread()`、`read.csv()` 或类似函数自动把 `block_start`、`block_end`、`TIMESTAMP` 等列推断成 UTC/POSIX 时间，否则可能造成 `8 h` 错位。这个约束适用于后续 raw-w、风场、FL 位置、气象和廓线数据的合并。 [来源: 用户当前对话 2026-05-20] [已核验: D:\00 博士阶段\博一\05 Project\ecpreproc\diagnose_ea_raw_w_local_circulation.R]
- 当前合并后的 EC 时间口径已经核清：`diagnostic_30min_with_ec.csv` 中所有可用记录都满足 `eddy_time_end - time_30 = 30 min`，与 EC 合并脚本里 `time_30 := eddy_time_end - minutes(30)` 的处理一致。因此后续把 `time_30`、`eddy_time_end` 和其他事件时刻放在一起比较时，必须明确自己是在 start-label 还是 end-label 口径下解释；简单时间标签重写不应被当作 `W4` 时序差异的通用修复手段。 [已核验: D:\00 博士阶段\博一\05 Project\com_260401\com_0401\diagnose_ec_controls_0320_0323.R] [已核验: D:\00 博士阶段\博一\05 Project\com_260401\com_0401\diagnostics_0320_0323\diagnostic_30min_with_ec.csv]
- 当前三站水平风图件的 `window_time` 使用窗口起点；解释日出、风向切换或风速增强相位时，`30min` 图上 `06:30` 点应理解为 `06:30-07:00` 窗口，而不是瞬时 `06:30`。 [已核验: D:\00 博士阶段\博一\05 Project\com_3sites_horizontal\COMPUTE\01_basic_highfreq_wind_qc_3sites.R] [已核验: D:\00 博士阶段\博一\05 Project\com_3sites_horizontal\OUTPUT\wind_speed_faceted_by_window\run_notes.txt]
- 当前 metadata 约束下的 time lag 搜索范围是实际管长推导后的窄范围：`MT` 和 `FL` 为 10 Hz、±2 个样本，`CVT` 为 20 Hz、±4 个样本，均对应约 ±0.2 s。 [已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_lag_config.csv]
- 当前 lag 结果中仍有 `edge_hit`，但它已经是在 metadata 约束的 ±0.2 s 窗口边界上触发，不再代表早期宽 lag 窗口下的多秒级异常。后续若解释 lag，应把它看作“协方差峰在物理允许窗口边界”的质量标记，而不是直接等同于真实管路延迟很长。 [已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_lag_stats.csv] [已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_lag_config.csv]
- 后续凡是调用 EC 外部数据，都必须先与仪器内部粗算结果核对时相，并结合 `Quality flag` 剔除明显异常值；在这一步完成之前，不应直接把新导入的 EC 结果写进结构切换、REA 或空间格局解释。 [来源: 用户在 2026-05-08 当前回合提供的讨论记录] [已核验: D:\00 博士阶段\99 Project\04 Lee\project_memory\anchors\02_key_constraints.md]
- `CVT 2025-03-23` AP 廓线的第七层即 `valve_number = 7/c32` 在 `2025-03-23 17:53:30` 之后必须筛除。当前上游脚本已将该时刻之后的 `CVT c32` 置为缺测并按 complete-case 排除不完整廓线轮次；因此全天图中 `CVT 2025-03-23 18:00` 之后不应再解释 AP/profile CO2 结构。 [来源: 用户当前对话 2026-05-25] [已核验: D:\00 博士阶段\99 Project\06 EA\project_memory\evidence\verifications\2026-05-25_cvt0323_c32_profile_qc.md]
- 用户明确补充，两套廓线系统的最高层分别就是对应 EC 系统的观测高度。因此 `CVT` 和 `MT` 的 AP/profile 数据在层位覆盖上足以分别计算到各自 \(z_r\) 的局地柱 CO2 storage tendency，不需要对顶部到 EC 高度之间再做外推。这个条件只支持站点内局地柱 storage 计算；在未完成跨系统绝对浓度校准、空间代表性假设和控制体几何定义之前，仍不应把两套系统的绝对浓度差直接用于完整峡谷控制体 storage 或水平浓度梯度通量。 [来源: 用户当前对话 2026-05-29] [推断：基于 storage 公式和当前两套廓线系统边界整理]
- `04 Lee` 中 `2025-03-23` 的一个谷底廓线原始或半原始文件已被手动截断到前 `4299` 行，最后时间戳停在 `2025-03-23 17:53:30`。所有和该日黄昏阶段有关的比较，都必须把“数据不完整”作为硬约束写明。 [已核验: D:\00 博士阶段\99 Project\04 Lee\project_memory\05_action_log.md] [已核验: D:\00 博士阶段\99 Project\04 Lee\project_memory\04_open_questions.md]
- `TIME_SERIES` 目录此前的回退是近似恢复，不是精确回到某个历史时刻的快照。因此凡是依赖该目录脚本状态做 provenance 判断时，都要保留“近似回退”的提醒。 [已核验: D:\00 博士阶段\99 Project\04 Lee\project_memory\05_action_log.md]

## 水平风、坐标与切面解释

- 三站水平风比较不能直接使用原始 `Ux/Uy` 分量互比；当前已采用 north_offset 做水平坐标统一，并对 `FL` 按轨道方向做小车速度矢量修正。该处理适合比较水平风速、风向和同步性，但它不是完整三维坐标旋转，也不能单独替代正式 EA/TEA、垂直平流或水平平流计算。 [来源: thread 019e261a-fe4c-7602-b59e-5d4f48e5ddbf] [已核验: D:\00 博士阶段\博一\05 Project\com_3sites_horizontal\OUTPUT\north_offset_coordinates\validation_summary_30min.csv] [已核验: D:\00 博士阶段\博一\05 Project\com_3sites_horizontal\OUTPUT\fl_motion_correction\fl_motion_correction_summary.csv]
- 当前局地环流诊断中的窗口内 `u_mean_valid` 和 `v_mean_valid` 是在同一窗口内用同时具有有限 `u`、`v` 的样本平均得到；`w_mean_window` 是 `sum(w * dt_sec) / window_sec`，不是只除以有效样本持续时间。因此在覆盖率高时它与普通 `mean(w)` 接近，有缺测时则保留完整窗口分母的约束。 [已核验: D:\00 博士阶段\博一\05 Project\ecpreproc\diagnose_ea_raw_w_local_circulation.R]
- 当前 `w_mean ~ u_mean + v_mean` 诊断按 `site + window_label` 单独拟合，形式为 `w_mean_window.wind = a + b * u_mean_valid + c * v_mean_valid + residual`。`w_resid_uv` 是从 raw `w_mean_window` 中扣除线性 `u/v` 拟合值后的残差，不是正式坐标旋转或严格 tilt correction。 [已核验: D:\00 博士阶段\博一\05 Project\ecpreproc\diagnose_ea_raw_w_local_circulation.R] [推断：基于当前方法边界整理]
- 当前 30 min 结果显示 `F_total` 几乎完全由 `F_mean` 控制，而 `F_mean` 又几乎完全由 `w_mean` 控制；因此 raw-w CO2 总输送图首先应解释为 raw 坐标平均垂直风信号，而不是生态系统 CO2 源汇。 [已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_raw_w_local_circulation_diagnostics\raw_w_transport_with_wind_context_all_windows.csv] [推断：基于当前本地核算整理]
- 当前 30 min 回归显示 `FL` 和 `MT` 的 raw `w_mean` 与 sonic 坐标水平风关系很强，`R2` 分别约 `0.890` 和 `0.750`，`CVT` 约 `0.296`。因此后续解释必须保留“真实局地环流”和“坐标/流线倾斜或水平风投影”两种可能，不应直接把 raw `w_mean` 写成地理垂直速度。 [已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_raw_w_local_circulation_diagnostics\w_mean_uv_regression_coefficients.csv] [推断：基于当前未做坐标旋转的处理边界整理]
- FL 位置诊断使用 `0 m = MT 起点`、约 `122.5 m = CVT 正上方`、`245 m = 轨道终点` 的几何约束。当前 30 min 白天结果显示 FL 轨道高度整体偏上升，两端强、中部弱，但 CVT 正上方中段没有转为负 `w`。 [来源: 用户当前对话 2026-05-20] [已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_raw_w_local_circulation_diagnostics\FL_position_binned_raw_w_30min.csv]
- `04 Lee` 的高频风对齐中，`wind_angle_sonic` 是 `Ux/Uy` 声学坐标角度，不是地理风向或来向风向。后续如果要把该支线推进到“谷轴向 vs 切面向”归因，仍需要补充坐标旋转、仪器方位角或沿谷/切面方向定义。 [已核验: D:\00 博士阶段\99 Project\04 Lee\project_memory\evidence\verifications\2026-05-07-mt0323-highfreq-wind-alignment.md]

## 当前生效分析决策

- 后续所有代表三个观测站点的点线图固定使用同一套站点颜色：`CVT = #F8766D` 红色、`FL = #00BA38` 绿色、`MT = #619CFF` 蓝色。EA/raw-w/FL 诊断图默认采用 `regov_memory/03_visualization.md` 中固定的白底 `theme_bw` 报告型风格；该规范来自 `EA_raw_w_CO2_decomposition_components_30min.png` 对应代码，后续不随变量、窗口或分析分支改变。 [来源: 用户当前对话 2026-05-21] [来源: 用户当前对话 2026-06-02] [已核验: D:\00 博士阶段\99 Project\06 EA\regov_memory\03_visualization.md] [已核验: D:\00 博士阶段\博一\05 Project\ecpreproc\plot_ea_raw_w_total_transport.R]
- 当前 EA 计算采用 `D:\00 博士阶段\博一\05 Project\ecpreproc\run_ea_preprocess.R`，并复用 `ecpreproc` 中已有预处理思路，但只保留 EA 需要的预处理部分。 [已核验: D:\00 博士阶段\博一\05 Project\ecpreproc\run_ea_preprocess.R]
- 当前预处理保留读取 TOA5、时间排序与重复时间去除、30 min 分块、诊断码过滤、合理范围过滤、Vickers-Mahrt 式 despiking、缺测覆盖率过滤和 metadata 约束 lag 协方差法。 [已核验: D:\00 博士阶段\博一\05 Project\ecpreproc\run_ea_preprocess.R]
- 当前逐日可视化使用 `D:\00 博士阶段\博一\05 Project\ecpreproc\plot_ea_daily.R`，上升/下沉通量贡献拆分使用 `D:\00 博士阶段\博一\05 Project\ecpreproc\plot_ea_up_down_daily.R`，CO2 气团浓度细化分析使用 `D:\00 博士阶段\博一\05 Project\ecpreproc\plot_ea_co2_airmasses.R`。 [已核验: D:\00 博士阶段\博一\05 Project\ecpreproc\plot_ea_daily.R] [已核验: D:\00 博士阶段\博一\05 Project\ecpreproc\plot_ea_up_down_daily.R] [已核验: D:\00 博士阶段\博一\05 Project\ecpreproc\plot_ea_co2_airmasses.R]
- 后续解释上升/下沉贡献时，优先使用 `centered` 拆分，即 \(A^+(c^+-\bar c)/T\) 和 \(-A^-(c^--\bar c)/T\)，因为 `raw` 拆分包含大量背景浓度项，主要表现为大数抵消。 [已核验: D:\00 博士阶段\博一\05 Project\ecpreproc\plot_ea_up_down_daily.R] [推断：基于当前对话对 EA 公式解释整理]
- 当前 Lee 方法比较仍以冠层以上层位为主要工作边界。如果没有新的明确来源，不要自行扩展成整套下层到上层完整比较。 [已核验: D:\00 博士阶段\99 Project\04 Lee\project_memory\anchors\03_active_decisions.md]
- 对目标谷底廓线文件而言，`valve_number = 1:8` 被视为有效值，不应因为早期代码中曾出现 `1:5` 假设就把它们误判成异常。 [已核验: D:\00 博士阶段\99 Project\04 Lee\project_memory\anchors\03_active_decisions.md]
- `04 Lee` 的 W4 下一轮计算已经从四天个例窗口转向多日事件普查。新的计算目录为 `D:\00 博士阶段\博一\05 Project\com_260507`，后续更多天数据导入、半小时事件表和强弱事件过程对照应优先在该目录下进行；`2025-03-20` 到 `2025-03-23` 仍作为已核验基准窗口和代表日解释材料保留，但不再限制下一步只能围绕四天推进。 [来源: 用户在 2026-05-08 当前回合的明确说明] [已核验: D:\00 博士阶段\99 Project\04 Lee\project_memory\evidence\verifications\2026-05-08-com260507-data-structure.md]
- REA 思路在 `04 Lee` 中暂作为 `W4` 的条件分组诊断子工作流，而不是独立 `W5`。它的用途是用 `D_cond = C_up - C_down` 识别次高峰形成阶段的上升或下沉气团富 CO2 特征，不应被写成正式 REA 通量观测结果；若后续扩展到多日普查并形成稳定分类规则，再考虑提升为独立工作流。 [来源: 用户在 2026-05-08 当前回合对 REA 借鉴价值的追问] [已核验: D:\00 博士阶段\99 Project\04 Lee\project_memory\evidence\verifications\2026-05-08-rea-conditional-diagnostic.md]
- 对 `04 Lee` W4 当前阶段而言，问题表述应优先聚焦在 `09:00-11:00` 冠层上部 CO2 稳定或二次高峰的来源，而不是泛泛表述为“是否存在环流”。后续归因应围绕该二次高峰与结构切换、`F_adv`、EC 背景和移动平台空间形态之间的关系展开。 [来源: 用户在 2026-04-30 当前回合的问题重述]
- 2026-06-17 之后，这条 `09:00-11:00` / 晨间 CO2 peak 事件归因线在当前项目中重新提升为并行主线，单独维护为 `W2_morning_peak_workflow.md`。它仍然可以为复杂地形通量修正框架提供案例证据，但不应再默认只作为复现与支撑案例处理。 [来源: 用户当前对话 2026-06-17] [已核验: project_memory/workstreams/W2_morning_peak_workflow.md]
- 对 `04 Lee` W4 当前解释而言，夜间 CO2 积累量不应被直接写成次高峰强度的充分解释。更稳口径是：夜间积累提供 CO2 库，但上午输送、释放窗口、通风清除能力、垂直结构变化和塔位地形路径共同决定该 CO2 库是否表现为明显次高峰。 [来源: 用户在 2026-05-01 当前回合的判断] [已核验: D:\00 博士阶段\99 Project\04 Lee\project_memory\evidence\discussions\2026-05-01-secondary-peak-status.md]
- 当前短期主线优先放在 CO2 空间格局、垂直风、风向切变时点和结构切换的关系上；通量准确度和更完整的 Lee/REA 方法边界仍然重要，但暂不作为最近一轮分析的主阻塞项。 [来源: 用户在 2026-05-08 当前回合提供的讨论记录]

## 解释风险与长期冲突

- 当前两处观测的整体偏差仍然较大，因此现阶段暂不把 `14:00` 时段仪器偏差修正作为 `W4` 前置步骤；但后续所有计算和解释都必须把“不能直接比较两处绝对浓度”写成硬约束。可以比较结构、时序、切换、相对变化和站点内演变，但不应把两处绝对浓度大小直接解释成可比的仪器差异或真实空间差异。 [来源: 用户在 2026-04-29 当前回合的明确决定]
- 当前四天不支持“夜间积累越大，上午次高峰越强”的简单解释。特别是 `2025-03-23` 是夜间积累较大、日出后下降明显但 `09:00-11:00` 次高峰偏弱的对照日，因此后续分析必须把夜间积累、上午输送/释放和下午清除/滞留分开看。 [来源: 用户在 2026-05-01 当前回合的判断] [已核验: D:\00 博士阶段\博一\05 Project\com_260401\com_0401\diagnostics_0320_0323\secondary_peak_events\secondary_peak_events_0630_co2_mean.csv]
- 对 `MT 2025-03-23` 夜间结构异常的归因，半小时风速只能作为背景证据，不能单独证明高频触发顺序。当前结果继续支持高层 `c29p5` 相对底层 `c8` 增强，但滞后相关偏弱，因此暂不应强写成风速、风向或垂直风变化触发了高层增强。 [已核验: D:\00 博士阶段\99 Project\04 Lee\project_memory\evidence\verifications\2026-05-07-mt0323-highfreq-wind-alignment.md]
- 移动 `AP200` 的向下廓线深度在不同来源里分别出现过 `10 m` 和 `30 m` 两种说法。在该冲突没有被更强来源消解之前，任何引用该系统观测深度的总结都应明确写出“仍有冲突”。 [已核验: D:\00 博士阶段\99 Project\04 Lee\project_memory\anchors\04_conflicts_to_keep.md]
- 移动系统速度曾被写成 `13 cm/s` 和 `13.7 cm/s` 两种数值。如果后续要做时空对应或移动采样解释，不应把它当成已经自动统一。 [已核验: D:\00 博士阶段\99 Project\04 Lee\project_memory\anchors\04_conflicts_to_keep.md]
- 固定塔数量与命名仍不完全清楚。早期记忆里有“两侧 ridge-top 固定塔”的表述，后续 Lee 方法讨论里又更像“单个 valley-edge 固定塔”；当前 `W4` 虽然已经补充 `CVT` 与 `MT` 的核心塔位映射，但旧记忆里关于 ridge-top、valley-edge、ridge-side tower 和固定塔数量的表述仍没有完全统一。 [来源: 用户在 2026-05-01 当前回合的场地说明] [已核验: D:\00 博士阶段\99 Project\04 Lee\project_memory\anchors\04_conflicts_to_keep.md]
- 结构切换判据存在尚未定稿的边界：到底坚持“日出后首次由负转非负”，还是允许把日出前已开始的切换算进去。这个问题会影响 `MT 2025-03-21` 等个例判定，后续摘要需保留冲突。 [已核验: D:\00 博士阶段\99 Project\04 Lee\project_memory\anchors\04_conflicts_to_keep.md]

## 编码与输出风格

- 后续凡是涉及数据读取、数据写出、字段口径、时间标签、已有文件结构或目录组织的脚本工作，都不应凭猜测自行编造实现方式，而应优先复用 `D:\00 博士阶段\博一\05 Project\com_260401\com_0401` 中已经存在的相关代码、处理口径和目录习惯。 [来源: 用户在 2026-05-08 当前回合的明确编码要求] [已核验: D:\00 博士阶段\99 Project\04 Lee\project_memory\anchors\05_coding_requirements.md]
- 如果需要扩展或修改现有读写流程，默认做法应是先核对 `D:\00 博士阶段\博一\05 Project\com_260401\com_0401` 中已有脚本的实现，再在此基础上做局部改动，而不是重新凭印象写一套平行逻辑。 [来源: 用户在 2026-05-08 当前回合的明确编码要求]
- 后续编写代码应保持简明、易懂；关键步骤需要中文注释说明，但注释应帮助理解处理逻辑、输入输出关系和判断依据，不要重复每一行显而易见的语句。 [来源: 用户在 2026-05-08 当前回合的明确编码要求]
- 每个脚本开头都应有一段简短中文总结，说明脚本实现什么功能、处理哪类输入、产出什么结果。所有注释默认使用中文，不混用英文注释。 [来源: 用户在 2026-05-08 当前回合的明确编码要求]
- REgov 的科研讨论、研究笔记、项目记忆总结、方法设计、证据边界整理和阶段性研究计划，默认可调用 `my-writing-style` 的 `Research Thinking Notes Mode`；正式论文 abstract、introduction、discussion、reviewer response 仍走 `Academic paper mode`，且在论文样本未校准前应声明该模式仍是 provisional。 [已核验: C:\Users\admin\.codex\skills\my-writing-style\SKILL.md] [已核验: C:\Users\admin\.codex\skills\my-writing-style\references\research-thinking-notes.md]

## 新工作线继承规则

新开任何分析角度时，工作流文件开头应写明：

```markdown
## 继承背景

本工作线继承 `regov_memory/00_shared_research_context.md` 中的研究区背景、站点定义、FL 几何、时间口径、方法边界、编码要求和长期解释风险。具体证据仍按本工作线自己的 `evidence/` 与对应项目 `project_memory` 追溯。
```

这样做的目的，是避免每开一个新 `project_memory` 或新 workstream 就遗漏用户已经输入过的关键场地背景和方法边界。 [来源: 用户当前对话 2026-05-28] [推断：基于 REgov 共享背景层设计]

## FL 质量守恒修正输入入口

- 后续围绕 FL/Flares 做移动段质量守恒修正或垂直平流近似时，移动位置数据优先使用 `D:\00 博士阶段\博一\05 Project\com_260326\20250313_20250419.xlsx`。该文件中位置数值越接近 `0` 越靠近 `MT` 南端；`Flares = FL = 移动平台`。 [来源: 用户当前对话 2026-06-01] [已核验: D:\00 博士阶段\99 Project\06 EA\project_memory\evidence\verifications\2026-06-01_fl_mass_balance_inputs.md]
- 可复用代码和数据入口优先级为：先检查 `D:\00 博士阶段\博一\05 Project\com_260326\compute\com_260326` 中的移动平台轨迹/筛选脚本，再检查 `D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com` 中的既有 EA/raw-w 结果；四个典型天的关键数据和信息整体位于 `D:\00 博士阶段\博一\05 Project\com_260507`。 [来源: 用户当前对话 2026-06-01] [已核验: D:\00 博士阶段\99 Project\06 EA\project_memory\evidence\verifications\2026-06-01_fl_mass_balance_inputs.md]
