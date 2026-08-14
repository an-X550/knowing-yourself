# 桌面端契约对齐任务书（下一对话 Agent 指令）

> 创建日期：2026-08-14
>
> 用途：在新对话中交给 AI Agent 执行桌面端与 Skill 系统的契约对齐工作。直接把第 2 节的指令块复制给 Agent，或让 Agent 完整阅读本文。
>
> 背景文档：
> - 差异真相：`docs/archive/2026-08-14-desktop-vs-skill-system-contract-audit.md`（下称"契约审计"，R1-R6 是唯一任务来源）
> - 实施约束：`apps/zhiji-desktop/docs/architecture.md`（下称"架构文档"）
> - 执行边界：`docs/desktop-skill-runtime-handoff.md`（下称"交接文档"）
> - 架构设计原文：`docs/superpowers/specs/2026-08-14-skill-runtime-agent-architecture-design.md`

## 1. 为什么这样设计（第一性原理说明，给发起者读）

- **真实问题**：桌面端与 Skill 契约的偏离集中在契约审计 R1-R6；其中 R3/R6 是产品决策（不是技术任务），R2/R4 需要先有证据（不是现在编码），真正可立即执行的只有 R1/R5 和决策本身。
- **失败模式防护**：最初的偏离正是"AI 无约束自由发挥"造成的。因此本任务书禁止开放式"优化产品/重构架构"，角色只服务于封闭任务清单。
- **顺序硬约束**：先决策后实现。未经用户对 R3/R6 拍板，禁止动周期复盘相关代码。

## 1.1 已锁定的决策（2026-08-14，用户拍板）

- **R3/R6 选择选项 A**：桌面端周期复盘补齐六问一级标题结构、硬质量门与方向锚点缺席检查，与 Skill 侧 `review-synthesis.md` 同构。跳过提案阶段，直接实施第 2 节指令（指令已按选项 A 定制）。

## 2. 可直接复制给 Agent 的指令

```text
你在为"知己"项目执行桌面端与 Skill 系统的契约对齐工作。以第一性原理和高性价比为最高决策方法：每项先定义真实问题、证据、不可突破约束与最小验证；优先复用既有架构，禁止为"未来可能需要"引入复杂度。用户已拍板 R3/R6 选项 A（桌面周期复盘补齐与 Skill 同构），按下方清单直接实施，禁止开放式重构或清单外的功能新增。

第一步，按顺序完整阅读以下文档：
1. AGENTS.md（项目规范与必要性闸门）
2. docs/2026-08-14-desktop-alignment-task-brief.md（本任务书，含已锁定决策）
3. docs/archive/2026-08-14-desktop-vs-skill-system-contract-audit.md（契约审计：任务唯一来源 R1-R6，重点 4.3 节周期复盘差异表）
4. apps/zhiji-desktop/docs/architecture.md（架构与实施约束，重点第 12-14 节）
5. docs/desktop-skill-runtime-handoff.md（执行边界；其中"可直接复制给执行 Agent 的约束 Prompt"一节对你同样生效）
6. apps/zhiji-desktop/docs/skill-compatibility-matrix.md（桌面端自证快照）
7. docs/superpowers/specs/2026-08-14-skill-runtime-agent-architecture-design.md（架构设计原文）
8. .claude/shared/contracts/review-synthesis.md（Skill 侧周期复盘契约原文，选项 A 的对齐目标）

对 .claude/ 的授权例外：本任务只读。允许读取 .claude/shared/contracts/ 下契约用于对照；禁止修改、复制、迁移其中内容到产品代码，禁止桌面端运行时依赖 .claude/。

第二步，以技术开发身份实施工作项（每项独立过必要性闸门、TDD、最小改动，开工前先报告：工作项编号、闸门证据、将改动的精确文件、验证方式）：

工作项 1（主线，R3/R6 选项 A）——桌面周期复盘与 Skill 同构：
目标状态（以契约审计 4.3 节的差异行为准，实施前先逐项核对 review-synthesis.md 原文）：
 a. 输出结构补齐：复盘六问一级标题（回顾目标/评估结果/分析原因正向/负向与重来演练/后续规划）、聊天摘要、YAML frontmatter；当前实现缺"回顾目标"且六问压缩为六字段，需扩展 PeriodicReviewOutputSchema 与 renderPeriodicReview。
 b. 硬质量门补齐：证据不足必须降级标注、关键判断需反例或限制说明；方向锚点缺席五态检查（方向锚点定义与五态以 review-synthesis.md 原文为准）。
 c. 类型级深度差异：周报（3Why、下周规划三要素）与月报（主主题归并、life-design 升级提醒）的差异化深度要求，是否本轮补齐由你在开工报告中给出成本评估后由用户拍板，默认只做周报。
实施边界：
 - 当前版本常量 periodic-review-v2（prompts/periodic-review-v1.ts），结构变化必须递增为 periodic-review-v3；同步更新 skill-runtime/compatibility/periodic-review-v1.ts 兼容快照与 skill-compatibility-matrix.md。
 - 800 字硬上限、下游沉淀优先材料组装、A-D 证据分级、预览-digest 确认门、D 级不调模型均保持不变；不得顺手重做材料组装与证据分级。
 - 旧 Review 文件必须可被现有解析读回（向后兼容是硬要求）。
 - 先写失败测试再实现：输出 schema、渲染快照（含金样本）、质量门降级路径各至少一组测试。
工作项 2（R5，低风险）：日反馈提示词补"常规 260 字上限"一句，递增 promptVersion 并更新兼容快照；长度硬校验不加。
工作项 3（R1，低风险）：建立契约-提示词对照表文档（登记 .claude/shared/contracts/ 各契约与桌面端 prompts/ 的同源关系与关键禁令映射）放 apps/zhiji-desktop/docs/；可选加轻量一致性测试断言关键禁令文本存在。
工作项 4（R2，仅生产证据不改代码）：选 ≥5 条真实非模板日志样本（脱敏），对照桌面端正则分级与 Skill 判据语义判级，输出对照结果文档；出现实际分歧才另行立项。
不做项：R4（等真实使用证据）；契约审计第 7 节全部有意差异；人生设计、收藏吃灰库、第一性原理复核、闭环缺口提醒投递等未实现低频能力。

硬约束：
- 实现遵循 architecture.md 第 12-13 节（约定速查与修改检查清单）与交接文档全部硬约束。
- 桌面端代码只在 apps/zhiji-desktop/ 内改动；对齐语义只记录在兼容快照与文档。
- 每项完成后运行 npm test、npm run typecheck、npm run lint；涉及打包链变化时补跑 npm run package。
- 不得合并多个工作项为一次大重构；不得引入 architecture.md 第 14 节之外的新能力。
- 完成报告给出：改动文件、用户可见行为变化、未完成项、精确验证命令与结果、提交哈希。本地提交可执行，推送由用户手动完成。
```

## 3. 发起者注意事项

- R3/R6 已锁定选项 A（2026-08-14）。指令中工作项 1c（周报/月报类型级深度差异是否本轮补齐）仍留了一个成本评估后的拍板点，Agent 会带成本评估来问你。
- 本任务书与交接文档的约束 Prompt 叠加生效，不互相替代。
- 若 Agent 提出清单外的"优化建议"，按 AGENTS.md 必要性闸门处理：无当前问题证据的一律不做。
