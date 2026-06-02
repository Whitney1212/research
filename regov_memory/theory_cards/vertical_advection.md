# 理论卡：平均垂直输送与 vertical advection

## 定义

平均垂直输送关注平均垂直风携带平均浓度结构造成的 CO2 输送。它与 EC 的湍流协方差项不同。

在 Lee (1998) 的单塔近似框架中，常见写法是：

\[
F_{vad} = \bar w(z_r)\left[\bar c(z_r) - \langle \bar c \rangle_{0,z_r}\right]
\]

其中 \(\langle \bar c \rangle_{0,z_r}\) 是参考高度以下空气柱平均浓度。这个项只有在 \(\bar w\)、浓度垂直梯度和坐标口径都足够可信时，才可能作为通量预算项讨论。

## 适用前提

- 平均垂直速度 \(\bar w\) 必须有清楚坐标口径，最好经过合理坐标旋转或已有足够理由说明 raw `w` 的物理含义。
- 需要参考高度和下方廓线浓度，才能区分“平均风携带背景浓度”和“垂直浓度梯度产生的输送”。
- 当前用户明确补充，两套廓线系统的最高层分别等于对应 EC 观测高度，因此 Lee 式 \(\bar w(z_r)[\bar c(z_r)-\langle \bar c\rangle]\) 在垂直浓度结构输入上具备站点内可计算条件；主要不确定性将更多转向 \(\bar w\) 的坐标口径、旋转敏感性、单位换算和局地代表性。 [来源: 用户当前对话 2026-05-29] [推断：基于 Lee 式 vertical advection 公式整理]
- 单塔 vertical advection 近似不能自动代表完整三维平流；复杂地形下水平平流、流线收敛/发散和通量散度可能同样重要。

## 核心公式或变量

- raw 总输送：\(\overline{wc} = \bar w\bar c + \overline{w'c'}\)。
- 平均流项：\(\bar w\bar c\)，在当前 raw-w 结果里对应 `F_mean_window` 的主导含义。
- Lee 式垂直平流近似：\(\bar w(z_r)[\bar c(z_r)-\langle \bar c\rangle]\)。
- 需要分清：`F_mean_window`、`F_turb_window`、`w_mean_window`、`F_conc_anom`。

## 当前项目可用证据

- 当前 raw `w` CO2 总输送结果几乎完全由 `F_mean_window` 控制，平均流项在平均绝对分量中占比约 `0.9980` 到 `0.9995`。这说明 raw-w 总输送首先是平均垂直风信号，而不是生态 CO2 交换强度。 [已核验: `regov_memory/00_shared_research_context.md`]
- 当前 `w_mean ~ u_mean + v_mean` 诊断显示 `FL` 和 `MT` 的 raw `w_mean` 与 sonic 坐标水平风关系很强，必须保留“真实局地环流”和“坐标/流线倾斜或水平风投影”两种可能。 [已核验: `regov_memory/00_shared_research_context.md`]
- FL 平台实时调平降低了姿态误差的优先级，但不等于 raw `w` 已经是地理垂直风。 [已核验: `regov_memory/00_shared_research_context.md`]

## 不能说明什么

- raw \(\overline{wc}\) 不能直接写成 Lee 式 vertical advection。
- `F_mean_window` 很大，不等于地形垂直平流已经被证明。
- 单塔或单轨道上的垂直项不能自动代表完整水平平流和三维环流预算。
- 经验 `w_mean ~ u+v` 残差不是正式坐标旋转，也不是物理垂直平流的最终估计。

## 与最终通量方案的关系

vertical advection 是当前研究区最可能影响通量计量解释的关键项之一，但它的证据门槛高于 raw `w` 诊断。更稳的路线是先把 raw `w` 作为局地环流和坐标问题的诊断，再判断是否能升级为 Lee 式或更完整平流预算的一部分。

## 下一步验证

- 对同一批窗口同时输出 raw \(\overline{wc}\)、\(\bar w\bar c\)、\(\overline{w'c'}\) 和 Lee 式 \(\bar w(c_r-\langle c\rangle)\) 的可计算版本。
- 对比使用 raw 坐标、经验 `w_mean ~ u+v` 残差和正式旋转后的 \(\bar w\) 时，Lee 式 vertical advection 和 `F_EC` 结论是否稳定；如果 `F_EC` 或 \(\bar w\) 对旋转方法高度敏感，后续应输出旋转敏感性范围而不是单一修正通量。 [来源: 用户当前对话 2026-05-29] [推断：基于当前用户判断整理]
- 检查强 `w_mean` 时段是否与风向、FL 位置、站点地形和 CO2 廓线结构同步。

## 来源

- 本地共享背景：`C:\Users\admin\Documents\New project\regov_memory\00_shared_research_context.md`。
- Lee (1998) 单塔 NEE 预算和 mass-flow 项入口：<https://environment.yale.edu/bibcite/reference/1910>。
- Baldocchi et al. 对 Lee 方法、复杂地形和 vertical/horizontal advection 边界的讨论入口：<https://www.fsl.orst.edu/rna/Documents/publications/On%20measuring%20net%20ecosystem%20carbon%20exchange%20over%20tall%20vegetation%20on%20complex%20terrain.pdf>。
- ScienceDirect 上对 Lee (1998) 的评论摘要指出 vertical advection 不能在一般复杂流场中自动代表总平流：<https://www.sciencedirect.com/science/article/abs/pii/S0168192399000490>。
