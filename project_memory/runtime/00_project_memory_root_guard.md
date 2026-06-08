# Project memory write root guard

记录日期：2026-06-08

当前项目根目录：
`D:\00 博士阶段\99 Project\06 EA`

当前 project memory 根目录：
`D:\00 博士阶段\99 Project\06 EA\project_memory`

写入规则：
- 后续所有 project memory 更新必须显式写入 `D:\00 博士阶段\99 Project\06 EA\project_memory`。
- 不再依赖会话当前工作目录推断 `./project_memory`。
- 旧路径 `C:\Users\admin\Documents\New project` 当前是指向 `D:\00 博士阶段\99 Project\06 EA` 的 Junction 别名。
- 不通过旧 C 路径写入、删除或汇报 project memory；所有路径展示和记录统一使用 D 盘规范路径。

误写原因与处理：
- 2026-06-08 上一轮会话的工作目录仍是 `C:\Users\admin\Documents\New project`。
- `project-progress-memory` 的默认规则会将 project memory 写入当前工作目录下的 `./project_memory`。
- 因未显式覆盖为迁移后的 D 盘项目根目录，导致 `07_step3_peakH1H2_log.md` 的写入/汇报路径显示为旧 C 路径。
- 2026-06-08 已核验旧 C 路径为 Junction：`Attributes = Directory, ReparsePoint`，`LinkType = Junction`，`Target = D:\00 博士阶段\99 Project\06 EA`。
- 曾尝试删除旧 C 路径下的重复 `07_step3_peakH1H2_log.md`，实际等价于删除 D 盘目标文件；已立即在 D 盘规范路径恢复该记录。
- 后续不得对 `C:\Users\admin\Documents\New project` 下的项目文件执行清理动作，除非先确认要操作的是 Junction 本身而非 D 盘目标内容。
