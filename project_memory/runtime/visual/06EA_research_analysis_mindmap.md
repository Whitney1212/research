---
aliases:
  - 06EA 研究路径与计算角度导图
type: visualization
view: mindmap
mindmap-plugin: basic
updated: 2026-07-20
tags:
  - 06EA
  - visualization/mindmap
---

# 总计算思维导图

## W1 EC/FL 与通量修正
- [[runtime/research_paths/W1-P01_complex_terrain_flux_state|W1-P01 复杂地形通量状态框架]]
    - EC 交换参照条件
    - storage 与平流风险标记
    - 状态—信号—数据—修正表
    - 证据缺口清单
- [[runtime/research_paths/W1-P02_fl_ec_delivery|W1-P02 FL 全量 BPF 与 EC 产品]]
    - no rotation / DR / BPF 对照
    - 三组 source group 一致性
    - valid_samples_by_bin QC
    - manifest 与正式入口复用
    - pooled 日变化结构
- [[runtime/research_paths/W1-P03_fl_spatial_constraint|W1-P03 FL 空间结构约束]]
    - 去程与返程差异
    - 轨道位置分箱结构
    - closure class 分层
    - 事件日形态重复性
    - 固定塔相位与风向对照
- [[runtime/research_paths/W1-P04_storage_correction|W1-P04 局地柱 storage 修正]]
    - 积分高度选择
    - 单位与时间对齐
    - 廓线缺测处理
    - storage 修正前后对照
    - 夜间与晨间贡献

## W2 晨间 CO2 peak
- [[runtime/research_paths/W2-P01_morning_peak_climatology|W2-P01 2025 晨间 peak 事件气候学]]
    - 事件发生率
    - 峰值时间与振幅
    - 持续时间与季节分布
    - 天气状态分层
    - 单塔、双塔与缺测集合
    - amp > 5 ppm 人工复核
- [[runtime/research_paths/W2-P02_morning_peak_mechanism|W2-P02 晨间 peak 机制分类]]
    - MT/CVT 空间同步性
    - 三站 lead-lag
    - 沿谷水平传播
    - 局地垂直再分配
    - 下降—谷值—回升—消散阶段
    - 三类气象状态覆盖
- [[runtime/research_paths/W2-P03_supplementary_observation|W2-P03 谷中央上空补充观测]]
    - 固定观测高度
    - 最低变量集
    - 事件触发条件
    - 固定观测与移动切面同步
    - 12–15 个有效观测早晨

## W3 固定塔年度 NEE
- [[runtime/research_paths/W3-P01_annual_nee_delivery|W3-P01 标准化年度 NEE 交付]]
    - 公共四方法绝对年值
    - observed valid 覆盖
    - MT/CVT 同方法差异
    - per-method 30 min 明细
    - EC-only proxy 表述边界
- [[runtime/research_paths/W3-P02_rotation_qc_gapfill|W3-P02 rotation—QC—gapfill 影响机制]]
    - u'c' / v'c' / w'c' 投影分解
    - no_rotation 下塔间差异
    - 同方法下塔间差异
    - 单塔 rotation 敏感性
    - rotation × 塔交互
    - 多方法稳健塔间差异
    - strict / no-qc 筛选贡献
    - observed / gapfilled 贡献
    - 时段、风向与气象分解
