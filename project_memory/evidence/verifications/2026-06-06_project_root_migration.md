# 2026-06-06 项目根目录迁移记录

## 目的

根据用户当前对话要求，将本地项目根目录从 `C:\Users\admin\Documents\New project` 迁移到 `D:\00 博士阶段\99 Project\06 EA`，并尽量同步修改仓库内所有直接写死的旧根路径，避免后续索引或引用错误。 [来源: 用户当前对话 2026-06-06]

## 已完成动作

- 已将仓库内所有直接写死的项目根路径从 `C:\Users\admin\Documents\New project` 机械替换为 `D:\00 博士阶段\99 Project\06 EA`。 [已核验: 本仓库本次路径检索]
- 已补改 `regov_memory/04_project_memory_network.md`，使 Current 节点的记忆路径和当前主线描述与新项目根目录及 2026-06-06 主线重设保持一致。 [已核验: regov_memory/04_project_memory_network.md]
- 已将当前仓库完整复制到 `D:\00 博士阶段\99 Project\06 EA`。复制前，目标位置原有内容已备份到 `D:\00 博士阶段\99 Project\06 EA_preexisting_backup_20260606_113616`。 [已核验: D:\00 博士阶段\99 Project\06 EA] [已核验: D:\00 博士阶段\99 Project\06 EA_preexisting_backup_20260606_113616]

## 当前状态

- 新根目录 `D:\00 博士阶段\99 Project\06 EA` 已可作为后续主项目目录使用。 [已核验: D:\00 博士阶段\99 Project\06 EA]
- 当前 Codex 会话仍占用旧目录，因此本轮**未能**把 `C:\Users\admin\Documents\New project` 整体改名后再创建指向新目录的 junction。Windows 返回“目录被其他进程占用”的错误。 [已核验: 本轮 PowerShell 迁移命令输出]
- 因此本轮结束时的实际状态是：**新目录已建成并可用；旧目录仍保留一份工作副本**。 [推断：基于本轮迁移执行结果整理]

## 对后续使用的含义

- 从现在开始，REgov 仓库内部的绝对路径应统一视为 `D:\00 博士阶段\99 Project\06 EA`。 [已核验: 本仓库本次路径检索]
- 若后续在关闭当前会话后还需要把旧路径替换成 junction 或彻底删除旧副本，应在没有程序占用 `C:\Users\admin\Documents\New project` 时再执行。 [推断：基于本轮 Windows 文件占用错误整理]
