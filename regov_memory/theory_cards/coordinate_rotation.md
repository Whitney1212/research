# 理论卡：坐标旋转与 raw `w`

## 定义

坐标旋转用于把 sonic anemometer 的仪器坐标转换到更接近平均流线或地表法向的坐标系，从而减少水平风分量投影到垂直风中的误差。它改变的是 \(u,v,w\) 的坐标口径，也会改变 \(\bar w\)、\(w'\) 和 \(\overline{w'c'}\) 的解释。

## 适用前提

- 必须知道 sonic 原始坐标、仪器安装方向、north offset 或可由长期风场估计流线平面。
- double rotation、triple rotation、planar fit 和 sector-wise planar fit 解决的问题不同。
- 复杂地形下，强行把每个 30 min 窗口的平均 \(w\) 旋到零，可能会移除真实局地平均垂直运动。
- planar fit 需要足够长、覆盖足够风向范围的数据，不能只用很短事件窗口直接拟合。

## 核心方法

- Double rotation：每个 averaging period 内旋转，使平均横风和平均垂直风为零。适合常规 EC 处理，但会把该窗口内的平均垂直运动归零。
- Triple rotation：在 double rotation 基础上进一步处理横向应力项。
- Planar fit：用较长时期的平均风数据拟合局地平均流线平面，再把垂直轴定义为该平面的法向。
- 经验 `w_mean ~ u_mean + v_mean`：当前项目中的诊断分支，用于检查 raw `w_mean` 是否主要受水平风投影或流线倾斜控制；它不是正式坐标旋转。

## 当前项目可用证据

- 当前主线明确暂不做正式坐标旋转，因此 raw `w` 和 \(w'\) 都应保留“仪器坐标”解释。 [已核验: `regov_memory/00_shared_research_context.md`]
- 三站水平风比较已采用 north_offset 统一水平坐标，并对 FL 按轨道方向做小车速度矢量修正；这适合比较水平风速、风向和同步性，但不是完整三维坐标旋转。 [已核验: `regov_memory/00_shared_research_context.md`]
- 当前 `w_mean ~ u_mean + v_mean` 诊断显示 `FL` 和 `MT` 的 raw `w_mean` 与 sonic 坐标水平风关系很强，说明坐标/流线问题必须保留在解释边界中。 [已核验: `regov_memory/00_shared_research_context.md`]
- 根据用户基于既往数据处理经验和研究区背景的判断，`F_EC` 本身也较为依赖坐标旋转方法。因此后续不能只把旋转敏感性看作 raw `w_mean` 或 raw \(wc\) 的问题，也要把标准 EC 协方差通量的旋转依赖纳入最终通量计量不确定性。 [来源: 用户当前对话 2026-05-29]
- `D:\00 博士阶段\博一\05 Project\ecpreproc` 中已有 `pre_rotate.R` 等相关文件，后续可优先检查本地实现。 [已核验: 本地目录读取 2026-05-28]

## FL PF_8bin 当前口径

- `PF_8bin` 是当前 FL 移动平台 planar fit 的正式参数口径。它使用统一运行记录逐点插值得到位置和实际有符号速度，再用实际速度矢量修正地理 east/north 水平风，最后按 `5-240 m` 轨道范围的 8 个 bin 独立拟合 `w = a + b * U_east_corr + c * U_north_corr`。 [已核验: E:\Dataset_Level1\Flares\PFparameter\PF_8bin_method_notes.md]
- 当前参数表为 `E:\Dataset_Level1\Flares\PFparameter\PF_8bin_parameters_for_flux.csv`。后续高频通量应用时，应按每个 10 Hz 点的运行记录位置分配 bin，然后调用对应 bin 的 `a,b,c` 计算 `w_pf = Uz - (a + b * U_east_corr + c * U_north_corr)`。 [已核验: E:\Dataset_Level1\Flares\PFparameter\PF_8bin_parameters_for_flux.csv]
- 本次拟合 8 个 bin 全部成功，倾角范围为 `8.4200-11.8022 deg`，输入点层面中位 RMSE 降幅约 `38.1%`，说明该口径在当前样本下具备进入后续 FL 高频通量计算的基础。 [已核验: E:\Dataset_Level1\Flares\PFparameter\pf_fit_summary.csv] [已核验: D:\00 博士阶段\99 Project\06 EA\project_memory\evidence\verifications\2026-06-12_fl_pf8bin_record_position_actual_speed.md] [推断：基于 fit_ok、tilt 和 RMSE 诊断整理]
- 当前参数不能与旧 B2 的“单程线性位置 + 固定 `0.137 m/s`”预处理混用。若后续更换运行记录、插值规则、速度字段、有效轨道范围或 bin 定义，应重新生成 PF 参数，而不是直接复用现有 `PF_8bin_parameters_for_flux.csv`。 [已核验: E:\Dataset_Level1\Flares\PFparameter\PF_8bin_preprocessing_ab_summary.csv] [推断：基于 PF 参数与预处理一致性要求整理]
- `PF_8bin` 仍未修正轨道坡度引起的垂直平台速度，因此它应被描述为“水平平台运动修正 + bin-wise planar fit 坐标旋转参数”，不能被描述为完整平台三维运动修正。 [已核验: E:\Dataset_Level1\Flares\PFparameter\PF_8bin_method_notes.md]

## 不能说明什么

- raw `w_mean` 的正负不能直接当成地理垂直运动正负。
- double rotation 后的 \(\bar w=0\) 不等于真实平均垂直运动不存在。
- 经验 `w_mean ~ u+v` 残差不能直接命名为真实垂直风。
- north_offset 和 FL 速度修正只处理水平风口径，不能替代三维 tilt correction。

## 与最终通量方案的关系

坐标旋转是最终通量方案中的关键分叉点。若目标是常规 EC 基线，至少需要明确采用哪一种旋转方案；若目标是保留复杂地形平均垂直运动，则不能无条件用每窗口 double rotation 把 \(\bar w\) 消去。鉴于用户已判断 `F_EC` 对旋转方法较敏感，当前更稳做法是并行保留 raw 坐标诊断、常规旋转 EC、planar-fit 或 sector-wise planar-fit 候选版本，并把不同旋转口径下的 `F_EC` 差异作为结果不确定性和方法边界，而不是在前期强行选出唯一真值。 [来源: 用户当前对话 2026-05-29] [推断：基于复杂地形通量计量目标整理]

## 下一步验证

- 检查 `ecpreproc` 中 `pre_rotate.R` 的已有旋转方法和测试覆盖。
- 在已核验四天窗口上做小规模对照：raw 坐标、double rotation、planar fit 或 sector-wise planar fit。
- 对比不同旋转方案下 `F_EC`、`w_mean`、raw-w 总输送和站点差异是否改变主结论。
- 对每个通量结论增加旋转稳定性标签：跨旋转方法稳定、仅符号稳定、仅相位稳定、或高度旋转敏感。 [来源: 用户当前对话 2026-05-29] [推断：基于当前用户判断整理]

## 来源

- 本地共享背景：`D:\00 博士阶段\99 Project\06 EA\regov_memory\00_shared_research_context.md`。
- NCAR/EOL 对 planar fit sonic tilt correction 的说明：<https://www.eol.ucar.edu/content/sonic-tilt-corrections>。
- LI-COR EddyPro 对 double rotation、triple rotation 和 planar fit 的说明：<https://www.licor.com/support/EddyPro/topics/anemometer-tilt-correction.html>。
- Wilczak, Oncley and Stage (2001), "Sonic Anemometer Tilt Correction Algorithms", Boundary-Layer Meteorology, 99, 127-150。 [文献入口见 NCAR/EOL 与 LI-COR 页面]
