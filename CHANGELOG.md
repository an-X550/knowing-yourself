---
created: 2026-07-05
last_updated: 2026-07-08
---

# CHANGELOG — 改动记录

> 倒序时间线。更早历史见 [docs/archive/changelog-archive.md](docs/archive/changelog-archive.md)。

## [2026-07-08 15:45] [修复] 日反馈链路升级为验证闭环入口 (v1.5.1 → v1.5.2)

- **受影响文件**: `.claude/agents/daily-analyzer.md`, `.claude/commands/daily-review.md`, `.claude/skills/log.md`, `.claude/shared/paths.md`, `.claude/shared/prompt-rules.md`, `.claude/agents/weekly-synthesis.md`, `.claude/agents/monthly-synthesis.md`, `docs/first-principles.md`, `docs/superpowers/specs/2026-07-08-verification-loop-design.md`, `docs/superpowers/plans/2026-07-08-verification-loop.md`, `README.md`, `PROJECT_STATUS.md`, `CHANGELOG.md`, `VERSION`
- **改动摘要**: 将现有日反馈入口从“生成建议”升级为“检查上一条行动并沉淀验证结果”的最短闭环：`daily-analyzer` 提取上一条 `💊` 与行动预测，`/daily-review` 和 `log` skill 保存反馈后写回 `verified-patterns.md`；周/月综合报告优先消费已验证、已证伪、待验证和连续没做的行动，减少只生产新建议但不追踪行为改变的问题。

## [2026-07-08 15:20] [功能] 周/月复盘新增方向锚点与缺席项校准协议 (v1.5.0 → v1.5.1)

- **受影响文件**: `.claude/agents/weekly-synthesis.md`, `.claude/agents/monthly-synthesis.md`, `docs/methodology-review.md`, `docs/superpowers/specs/2026-07-08-direction-anchor-calibration-design.md`, `docs/superpowers/plans/2026-07-08-direction-anchor-calibration.md`, `README.md`, `PROJECT_STATUS.md`, `CHANGELOG.md`, `VERSION`
- **改动摘要**: 在周/月综合 agent 中新增方向锚点读取与五类缺席项检查，要求复盘同时检查“发生了什么”和“重要但缺席了什么”；方法论文档新增回应复盘的方向校准模板，防止考公、行测等长期主线因本周期材料缺席而从后续规划中自然消失。

## [2026-07-08 14:45] [功能] 增强人生设计盲点触发与第三方提醒机制 (v1.4.0 → v1.5.0)

- **受影响文件**: `.claude/agents/review-readiness-checker.md`, `.claude/commands/review.md`, `.claude/commands/journal-coach.md`, `.claude/agents/monthly-synthesis.md`, `.claude/agents/yearly-synthesis.md`, `README.md`, `PROJECT_STATUS.md`, `CHANGELOG.md`, `VERSION`
- **改动摘要**: 将 `/life-design` 触发从“主动调用 + 月/年复盘提醒”升级为“主动调用 + 周期升级提醒 + 盲点探测提醒”；增强 `/review` 无参数智能检测和 `/journal-coach` 近 7 天方向信号提醒，并要求月报 / 年报输出基于证据的 `/life-design --quick` 升级提示。

## [2026-07-08 14:30] [功能] 新增人生设计专项命令与低频方向校准链路 (v1.3.27 → v1.4.0)

- **受影响文件**: `.claude/commands/life-design.md`, `.claude/agents/life-design-synthesis.md`, `.claude/shared/paths.md`, `.claude/commands/review.md`, `.claude/agents/monthly-synthesis.md`, `.claude/agents/yearly-synthesis.md`, `docs/superpowers/plans/2026-07-08-life-design-command.md`, `README.md`, `PROJECT_STATUS.md`, `CHANGELOG.md`, `VERSION`, `人生设计skill.md`
- **改动摘要**: 新增 `/life-design` 专项命令与 `life-design-synthesis` agent，将原始人生设计 prompt 改造为证据优先、低频调用、可验证原型实验的方向校准链路；同步 `/review` 路由、月报 / 年报升级提醒和人生设计报告输出路径，并清理根目录临时来源文件。

## [2026-07-08 14:10] [功能] 新增项目复盘完整链路并并入统一六问协议 (v1.3.26 → v1.3.27)

- **受影响文件**: `.claude/commands/project-review.md`, `.claude/workflows/project-review.js`, `.claude/agents/project-synthesis.md`, `.claude/shared/paths.md`, `.claude/workflows/shared.js`, `.claude/commands/review.md`, `docs/methodology-review.md`, `docs/superpowers/specs/2026-07-08-project-review-unification-design.md`, `docs/superpowers/plans/2026-07-08-project-review-unification.md`, `README.md`, `PROJECT_STATUS.md`, `CHANGELOG.md`, `VERSION`
- **改动摘要**: 新增 `/project-review` 命令、`project-review.js` workflow、`project-synthesis` 综合 agent 与 `output.project_report` 路径契约，让项目复盘正式并入“六问一级标题 + 内层综合分析”统一协议；同时补齐项目复盘专用模板与命令骨架说明，更新 README、项目状态与版本记录，完成周 / 月 / 项目三类复盘的同构化。

## [2026-07-08 12:13] [重构] 统一周/月复盘输出骨架为六问一级标题，保留内层综合分析 (v1.3.25 → v1.3.26)

- **受影响文件**: `.claude/agents/monthly-synthesis.md`, `.claude/agents/weekly-synthesis.md`, `docs/methodology-review.md`, `README.md`, `PROJECT_STATUS.md`, `CHANGELOG.md`, `VERSION`
- **改动摘要**: 将运行时周/月复盘综合模板从主题章节式骨架收紧为“复盘六问”显式一级标题协议，同时保留主题归并、多视角证据、假说追踪和数据边界等优化能力作为六问内部的二级结构；同步补写方法论文档中的统一输出协议，并在 README、PROJECT_STATUS 与版本记录中对齐“六问外壳 + 内层综合分析”的新约定。

## [2026-07-08 11:32] [文档] 重写未来优化路线图，突出阶段判断与升级门槛 (v1.3.24 → v1.3.25)

- **受影响文件**: `docs/specs/evolution-roadmap.md`, `docs/superpowers/specs/2026-07-08-evolution-roadmap-design.md`, `docs/superpowers/plans/2026-07-08-evolution-roadmap-rewrite.md`, `README.md`, `PROJECT_STATUS.md`, `CHANGELOG.md`, `VERSION`
- **改动摘要**: 将未来优化方向文档从“三路径平铺”改为“战略摘要 → 当前判断 → 升级门槛 → 近 12 周动作 → A/B/C 附录展开”的双层结构，修正过期版本与阶段表述，强化“先验证闭环，再扩形态”的路线判断；同时补写本轮设计文档与实施计划，并同步 README 徽章、项目状态与版本号至 v1.3.25。

## [2026-07-08 11:10] [文档] 清理 CHANGELOG 历史格式并复审低优先级待办 (v1.3.23 → v1.3.24)

- **受影响文件**: `CHANGELOG.md`, `PROJECT_STATUS.md`, `README.md`, `VERSION`
- **改动摘要**: 清理 CHANGELOG 头部格式与旧记录粘连问题，复审 PROJECT_STATUS 的中低优先级待办，将样本与年度回归保留为中优先级验证任务，将自动化测试、CSV 导出和国际化标记为等待真实需求的暂缓项；同步版本号至 v1.3.24。

## [2026-07-08 10:30] [文档] 收紧项目规范与维护文档职责，降低重复与维护成本 (v1.3.22 → v1.3.23)

- **受影响文件**: `AGENTS.md`, `CLAUDE.md`, `PROJECT_STATUS.md`, `README.md`, `CHANGELOG.md`, `VERSION`
- **改动摘要**: 将镜像规范收紧为同一份更短的规则文本，保留维护边界、版本追踪、同步验证与工作流控制等高价值规则，删除过细的重复展开；将 `README.md` 收回到“项目说明与使用入口”，将 `PROJECT_STATUS.md` 收回到“事实状态面板”，减少它们与规范文件之间的重复叙述；同步版本号至 `v1.3.23`。

## [2026-07-08 01:20] [文档] 对齐月度复盘命令表述：先生成视角证据包，再做主题综合 (v1.3.21 → v1.3.22)

- **受影响文件**: `.claude/commands/monthly-review.md`, `PROJECT_STATUS.md`, `README.md`, `CHANGELOG.md`, `VERSION`
- **改动摘要**: 补齐 `/monthly-review` 命令层文案，使其与已完成的月度综合链路优化保持一致：命令入口不再把并行视角输出描述成直接产出的“月报内容”，而是明确为“先生成视角证据包 / 综合材料，再由 `monthly-synthesis` 做主题归并并输出最终月报”；同步更新版本号与状态记录，作为月度链路优化的命令层收口。
