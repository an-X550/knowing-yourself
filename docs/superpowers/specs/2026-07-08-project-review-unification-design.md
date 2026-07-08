---
created: 2026-07-08
last_updated: 2026-07-08
status: 已确认
type: 复盘链路设计
---

# project-review 统一化设计

## 背景

当前周复盘与月复盘已经统一到“六问一级标题 + 内层综合分析”协议，但项目复盘仍缺少正式命令、workflow、agent 与输出路径契约，导致三类复盘尚未真正统一。

## 目标

新增一整套项目复盘链路，并与周复盘、月复盘共享同一外层协议：

1. 新增 `/project-review` 命令
2. 新增 `project-review.js` workflow
3. 新增 `project-synthesis.md` agent
4. 在 `.claude/shared/paths.md` 增加项目复盘输出路径
5. 让项目复盘正文固定为六问一级标题
6. 同步 `README.md`、`PROJECT_STATUS.md`、`docs/methodology-review.md`、`CHANGELOG.md`、`VERSION`

## 非目标

1. 本轮不新增“项目专用多视角 processor”链路
2. 本轮不引入新的项目分析打分体系
3. 本轮不改变周复盘与月复盘既有输出目录

## 方案选择

采用“完整对齐”方案：

1. 命令层新增 `/project-review`
2. workflow 层新增 `project-review.js`
3. 综合层新增 `project-synthesis.md`
4. 共享层扩展 `paths.md` 与 `shared.js`

不采用“仅文档补模板”方案，因为那样无法形成真正可执行的三类复盘统一链路。

## 结构设计

### 1. 输出协议

项目复盘沿用统一六问一级标题：

1. `## 一、回顾目标`
2. `## 二、评估结果`
3. `## 三、分析原因（正向）`
4. `## 四、分析原因（负向）`
5. `## 五、重来演练`
6. `## 六、后续规划`

### 2. 项目复盘的专用内层槽位

六问不变，但项目复盘内部更强调：

- 里程碑与验收目标
- 实际交付与偏差
- 决策、协作、流程、机制
- 可复用经验与后续机制调整

### 3. workflow 形态

项目复盘不走多视角并行，而是走轻量两阶段：

1. `Gather`：整理项目名、输出路径、执行模式
2. `Synthesize`：调用 `project-synthesis` 直接产出最终报告

这样既能对齐现有 `yearly-review.js` 的单综合模式，又避免在没有真实需求前过度扩展项目复盘上游链路。

### 4. 路径约定

新增命名路径键：

- `output.project_report` → `复盘/项目复盘/{date}-project-{project}.md`

该命名同时满足：

1. 与周复盘、月复盘目录天然区分
2. 文件名显式带 `project`
3. 可在同一天生成多个不同项目复盘

## 影响文件

1. `.claude/commands/project-review.md`
2. `.claude/workflows/project-review.js`
3. `.claude/agents/project-synthesis.md`
4. `.claude/shared/paths.md`
5. `.claude/workflows/shared.js`
6. `.claude/commands/review.md`
7. `docs/methodology-review.md`
8. `README.md`
9. `PROJECT_STATUS.md`
10. `CHANGELOG.md`
11. `VERSION`

## 自检结论

1. 方案与用户确认的“完整对齐”一致
2. 保留现有周/月优化成果，不回退为旧模板
3. 新链路复用共享 helper，不额外复制一套规则
