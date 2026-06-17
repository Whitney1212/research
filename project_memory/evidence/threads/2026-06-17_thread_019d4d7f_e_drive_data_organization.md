# Codex thread 019d4d7f E 盘数据整理确认

## 来源

- 线程链接：`codex://threads/019d4d7f-99f1-7201-87fb-409488ce10a4`。本轮用 Codex thread 工具查询时未在当前线程索引中直接找到该 ID，但已在本机归档会话中定位到原始 JSONL：`C:\Users\admin\.codex\sessions\2026\04\02\rollout-2026-04-02T17-21-41-019d4d7f-99f1-7201-87fb-409488ce10a4.jsonl`。 [来源: 用户当前对话 2026-06-17] [已核验: 本地会话归档]
- 该线程的工作目录为 `D:\00 博士阶段\01 Project`，主要发生在 `2026-04-02` 至 `2026-04-08`，任务是按文件名和目录名整理 E 盘观测数据入口。 [已核验: 本地会话归档]
- 线程中生成过目录说明文档 `D:\00 博士阶段\01 Project\E盘数据说明_按目录索引.md`，本轮已读取；另有旧覆盖图 `D:\00 博士阶段\01 Project\missing_periods_timeline.svg` 和绘图脚本 `D:\00 博士阶段\01 Project\make_missing_periods_svg.py`。 [已核验: D:\00 博士阶段\01 Project\E盘数据说明_按目录索引.md]

## 文件名识别规则

- `57990.RawData` 一类：`AP200` 原始数据。 [已核验: D:\00 博士阶段\01 Project\E盘数据说明_按目录索引.md]
- `53412.IntAvg.dat` 一类：`AP200` 廓线或平均结果数据。 [已核验: D:\00 博士阶段\01 Project\E盘数据说明_按目录索引.md]
- `TOA5_45984.AWS_YYYY_MM_DD_0000.dat` 一类：梯度气象数据；线程后续还补充 `TOA5_40891.AWS_...` 一类属于塔配套 `MET` 数据。 [来源: thread 019d4d7f-99f1-7201-87fb-409488ce10a4] [已核验: D:\00 博士阶段\01 Project\E盘数据说明_按目录索引.md]
- `45984.AWS0.dat` 一类：气象数据。 [已核验: D:\00 博士阶段\01 Project\E盘数据说明_按目录索引.md]
- `24374.Time_Series_63.dat` 一类：通量或 EC 数据。 [已核验: D:\00 博士阶段\01 Project\E盘数据说明_按目录索引.md]
- `Flares` 相关：移动观测平台数据。 [已核验: D:\00 博士阶段\01 Project\E盘数据说明_按目录索引.md]
- 旧线程中用户说明 `AP200`、`AP201`、`AP202` 均按 `AP200` 系列处理，尤其用于移动端覆盖图和缺失时段合并。 [来源: thread 019d4d7f-99f1-7201-87fb-409488ce10a4]

## 目录级归类

- `主塔/Maintower` 的旧 E 盘入口：`MET` 包括 `E:\老师拷贝大量数据（4-30）\MET_TOWER_RAW`、`E:\老师拷贝大量数据（4-30）\EC_ShH_new\MET_TOWER_RAW` 和 `E:\202503-202512MET`；`AP200` 主要为 `E:\老师拷贝大量数据（4-30）\EC_ShH_new\AP200_tower\AP200`；`EC/通量` 包括 `E:\老师拷贝大量数据（4-30）\EC_TOWER_RAW`、`E:\老师拷贝大量数据（4-30）\EC_ShH_new\EC_TOWER_RAW`、`E:\250707上杭towerEC\25-07-07\MAINTOWER_TOP_EC`、`E:\251101数据\主塔塔顶数据` 和 `E:\25-09-08 主塔塔顶\EC—top--0908\EC—top--0908`。 [来源: thread 019d4d7f-99f1-7201-87fb-409488ce10a4]
- `谷底塔体系` 的旧 E 盘入口：`mt` 对应 `E:\20251229\mt_met done`、`E:\20251229\mt_co2 done`、`E:\20251229\mt_ec`；`cvt` 对应 `E:\20251229\cvt_met done`、`E:\20251229\cvt_co2 done`、`E:\20251229\cvt_ec done` 和 `E:\250607上杭数据采集\25-6-7data\CVT_EC`；`evt` 对应 `E:\20251229\evt_met done`、`E:\250607上杭数据采集\25-6-7data\EVT1-MET`、`E:\20251229\evt1_co2 done` 和 `E:\250607上杭数据采集\25-6-7data\EVT1-AP200`；`nvt/svt/wvt` 对应 `E:\20251229\nvt done`、`E:\20251229\svt done`、`E:\20251229\wvt4 done`、`E:\250607上杭数据采集\25-6-7data\SVT3` 和 `E:\250607上杭数据采集\25-6-7data\WVT4`。 [来源: thread 019d4d7f-99f1-7201-87fb-409488ce10a4]
- `Flares/移动平台` 的旧 E 盘入口：`MET` 包括 `E:\老师拷贝大量数据（4-30）\MET_FLARES_RAW` 和 `E:\老师拷贝大量数据（4-30）\EC_ShH_new\MET_FLARES_RAW`；`EC/通量` 包括 `E:\老师拷贝大量数据（4-30）\EC_FLARES_RAW` 和 `E:\老师拷贝大量数据（4-30）\EC_ShH_new\EC_FLARES_RAW`；`AP200` 从目录结构看主要是 `E:\老师拷贝大量数据（4-30）\EC_ShH_new\AP200`。 [来源: thread 019d4d7f-99f1-7201-87fb-409488ce10a4]
- `小车AP200`、`小车气象`、`小车数据` 在旧线程中建议单列成“移动平台/小车”，不直接写死为 `Flares`；`Operation_state` 属于状态和日志；`Process`、`数据结果`、`20250420`、`6m_tower` 更像处理结果或汇总；`network done`、`csat3b done` 先放待核实或配套。 [来源: thread 019d4d7f-99f1-7201-87fb-409488ce10a4]

## 2025-03-13 至 2025-03-25 相关入口

- 旧线程第一轮只按目录名、文件名和时间戳锁定 `2025-03-13` 至 `2025-03-25` 的可能相关目录，没有逐个审阅大文件。命中主要集中在 `E:\老师拷贝大量数据（4-30）\EC_ShH_new`、`E:\老师拷贝大量数据（4-30）\EC_FLARES_RAW`、`E:\老师拷贝大量数据（4-30）\EC_TOWER_RAW` 和 `E:\老师拷贝大量数据（4-30）\Operation_state`。 [来源: thread 019d4d7f-99f1-7201-87fb-409488ce10a4]
- 固定塔 EC 相关重点目录包括 `E:\老师拷贝大量数据（4-30）\EC_TOWER_RAW\RawData\20240313-20250325`、`E:\老师拷贝大量数据（4-30）\EC_TOWER_RAW\CSformat\20240313-20250325`、`E:\老师拷贝大量数据（4-30）\EC_TOWER_RAW\Converted\Rawdata\20240313-20250325`、`E:\老师拷贝大量数据（4-30）\EC_TOWER_RAW\Converted\CSformat\20240313-20250325`，以及至少含 `2025-03-25` 尾部数据的 `20250325-` 目录。 [来源: thread 019d4d7f-99f1-7201-87fb-409488ce10a4]
- Flares EC 相关重点目录包括 `E:\老师拷贝大量数据（4-30）\EC_FLARES_RAW\Converted\RawData\20241129-`、`E:\老师拷贝大量数据（4-30）\EC_FLARES_RAW\Converted\CSformat\20241129-`、`E:\老师拷贝大量数据（4-30）\EC_FLARES_RAW\Converted\RawData\moving\correct\eddypro_binned_cospectra` 和 `E:\老师拷贝大量数据（4-30）\EC_FLARES_RAW\Converted\RawData\moving\correct\eddypro_full_cospectra`。 [来源: thread 019d4d7f-99f1-7201-87fb-409488ce10a4]
- `E:\老师拷贝大量数据（4-30）\Operation_state\20250313_20250419.xlsx` 是旧线程中锁定的运行状态汇总入口，可能与后续三站事件日、FL 运行状态和完整单程核查有关。 [来源: thread 019d4d7f-99f1-7201-87fb-409488ce10a4]

## 覆盖时段结果的使用边界

- 旧线程曾基于 `E:\数据整理\现有数据.xlsx` 计算缺失时段并生成 `D:\00 博士阶段\01 Project\missing_periods_timeline.svg`，统计起点为 `2023-06-21`，截止到当时日期 `2026-04-08`。 [来源: thread 019d4d7f-99f1-7201-87fb-409488ce10a4] [已核验: D:\00 博士阶段\01 Project\missing_periods_timeline.svg]
- 本轮核查发现 `E:\数据整理\现有数据.xlsx` 当前不存在；当前可见的是 `E:\Dataset_RAW\现有数据.xlsx` 和 `E:\Dataset_RAW\数据存入-处理记录.xlsx`。因此旧线程的缺失时段图只能作为历史覆盖口径，不应替代当前正式批量整理。 [已核验: E:\Dataset_RAW]
- 当前 W2 批量整理仍应优先使用 `E:\Dataset_Level0` 作为数据根入口，并用 `E:\Dataset_Level0\数据存入-处理记录.xlsx` 作为当前处理记录和覆盖登记表；`E:\Dataset_RAW` 用于追溯仪器直接输出，不再作为本轮覆盖登记主表。 [来源: 用户当前对话 2026-06-17] [已核验: project_memory/evidence/verifications/2026-06-17_fixed_tower_level0_coverage.md]

## 对当前项目的影响

- 旧线程提供的是原始 E 盘“按图索骥”入口，可用于追溯旧原始目录和判断某类数据可能在哪里，但不能覆盖当前 `E:\Dataset_Level0` 的统一数据根入口。 [推断：基于本轮核查整理]
- 旧线程中的小写目录名 `mt/cvt/evt/nvt/svt` 属于历史硬盘整理口径；当前项目和 W2 中科学解释使用的 `MT=谷缘高地`、`CVT=谷底` 站点定义仍然优先。凡是从旧 E 盘目录迁移或追溯数据时，必须用 `E:\Dataset_Level0` 的站点元数据或字段名重新确认，不应直接把小写 `mt` 文件夹等同于当前大写 `MT` 科学站点。 [推断：基于旧线程与当前 anchor 定义的冲突整理]
- 对 `20-30` 个三站独立事件日而言，旧线程最有价值的信息是 `Operation_state\20250313_20250419.xlsx`、Flares EC 目录和移动平台 AP/MET/EC 的目录级入口；正式事件筛选仍要回到 W1 中关于 FL 完整单程的统计和当前 Level0/Level1 输出。 [推断：基于 W2 事件日需求整理]
