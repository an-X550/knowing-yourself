# 桌面端洞察三链路契约审计（coach / yearly / life-design）

> 审计日期：2026-08-14
>
> 范围：桌面端 `apps/zhiji-desktop/` 三条洞察链路与 `.claude/` Skill 侧对应 command/agent 的契约对照（只读审计，不修改 `.claude/`）。
>
> 方法：逐条对照门槛、判据、输出结构与禁令；差异分三级——结构漂移（流程/结构缺失）、判据漂移（判据措辞或触发条件不一致）、设计性差异（桌面语境的有意取舍，只登记不修）。

## 结论总览

| 链路 | Skill 侧权威 | 桌面端载体 | 结论 |
|---|---|---|---|
| coach | `commands/journal-coach.md` + `agents/journal-quality-coach.md` + `docs/methodology-journal.md` | `prompts/journal-coach-v2.ts` + `domain/insight-materials.ts` | 基本同构；2 处判据漂移（六步法命名、方向信号判据） |
| yearly | `commands/yearly-review.md` + `agents/yearly-synthesis.md` | `prompts/insight-review-prompts.ts` + `domain/insight-materials.ts` | 基本同构；1 处判据漂移（缺升级提醒）；2 处设计性差异 |
| life-design | `commands/life-design.md` + `agents/life-design-synthesis.md` | `prompts/insight-review-prompts.ts` + `domain/insight-materials.ts` | quick 模式基本同构；1 处判据漂移（缺"下次如何验证"）；1 处设计性差异 |

无结构漂移。

## 一、coach 日志质量教练

### 同构项（证据）

- ≥3 篇门槛与文案：Skill `agents/journal-quality-coach.md` L41-45；桌面 `domain/insight-materials.ts` L13，文案逐字一致；`tests/integration/generate-insight-review.test.ts` L33 断言。
- A-D 就绪度判据（A 四要素充分 / B 事实+状态或解释 / C 简短片段 / D 无法确认）：Skill L49-56；桌面 `journal-coach-v2.ts` L8，判据一致。
- 输出结构（聊天摘要 / 就绪度表 / 六步法表 / 重复模式 / 优先改进一件事 / 方向提醒）：Skill L95-129；桌面 `journal-coach-v2.ts` L40-50 渲染，表格列头与 Skill L116 一致。
- 自由叙事不扣分、分享未观察只标注：Skill L18/L69；桌面 `journal-coach-v2.ts` L9。

### 判据漂移（立项修复）

1. **六步法命名**：权威六步法为「回忆事实、筛选重点、评估结果、洞察思考、行为改进、分享讨论」（`docs/methodology-journal.md` L49-116；`agents/journal-quality-coach.md` L62-67 步骤 3 枚举同）。桌面 `journal-coach-v2.ts` L9 写成「事实回顾、重点筛选、感受、思考、行为改进、分享讨论」，与方法论权威不符（混入了报告表头简写）。修复：对齐权威命名 → `journal-coach-v3`。
2. **方向性信号判据**：Skill L83-87 明确四类信号枚举（反复怀疑长期方向、同一行动连续失效、目标与能量持续冲突、长期失衡被合理化为"没办法"）与排除条件（单日低落或普通任务压力不触发）。桌面 `journal-coach-v2.ts` L11 只有「至少两类方向性信号」一句，无枚举无排除，模型触发口径不可控。修复：补枚举与排除，同版本递增。

### 已知差异（登记不修）

- Skill 汇总要求「六步法最稳定/最薄弱环节」（`agents/journal-quality-coach.md` L77）；桌面 `patterns` 只含 stable/missing/issue 三项（`journal-coach-v2.ts` L18/L27），未单列六步法环节维度。影响轻微（patterns.stable/missing 可覆盖该语义），不加字段。

## 二、yearly 年度回顾

### 同构项（证据）

- 材料门槛 6 份月报：Skill `commands/yearly-review.md` L36-38；桌面 `insight-materials.ts` L18-19。
- 只依据已确认月报、引用材料、不得补造：Skill `agents/yearly-synthesis.md` L120-123 综合原则；桌面 `insight-review-prompts.ts` L10。

### 判据漂移（立项修复）

- **缺年度升级提醒**：Skill `agents/yearly-synthesis.md` L124（综合原则 5）规定四类触发条件（长期方向冲突、重复卡点、工作观/人生观冲突、新年战略方向无法靠局部优化回答）满足时必须输出升级提醒，且不自动生成 life-design。桌面 `insight-review-prompts.ts` L10 的 yearly 系统提示无此语义。修复：补触发条件与提醒语义，措辞指向复盘页方向校准（桌面语境不出现命令字样），版本 `yearly-review-v1` → `yearly-review-v2`。与阶段 B 月报升级提醒口径一致。

### 设计性差异（登记不修）

1. **<6 份处理**：Skill 警告并继续生成部分综合（`agents/yearly-synthesis.md` L31、L129）；桌面硬拦截（`insight-materials.ts` L19）。桌面为预览-确认交互，硬拦截比生成残缺报告更省成本，维持。
2. **输出结构**：Skill 为 13 节固定长报告（L49-116）；桌面为自由简洁 Markdown 五要素（`insight-review-prompts.ts` L10）。桌面定位是轻量本地复盘，维持简洁结构。

## 三、life-design 方向校准

### 同构项（证据）

- quick 模式定位与材料规则：Skill `commands/life-design.md` 四模式；quick 证据范围见 `agents/life-design-synthesis.md` L61；桌面 `insight-materials.ts` L23-30（月>周>日复盘 + 日志混排取 40 条）与 quick 的"近期复盘+日志抽样"语义一致。
- 输出要素：问题重述、张力与资源、可选方向、7 天低成本实验、可观察判据：对应 Skill 报告结构 L122-138 的核心节；桌面 `insight-review-prompts.ts` L14。
- 禁令：不做心理诊断/人格诊断、不包装不可控现实：Skill `agents/life-design-synthesis.md` L162-168；桌面 L14「不要做人格诊断或宏大结论」。

### 判据漂移（立项修复）

- **缺"下次如何验证"**：Skill 质量要求含「下次如何验证」（`commands/life-design.md` L86-89；报告第七节 `agents/life-design-synthesis.md` L140-141：下一篇日志、日反馈、下次月报应观察哪些信号）。桌面提示词只有「可观察判据」，未要求给出后续验证路径。修复：补该要求，版本 `life-design-v1` → `life-design-v2`。

### 设计性差异（登记不修）

- **仅 quick 模式**：Skill 有 quick/standard/full/odyssey 四模式（`agents/life-design-synthesis.md` L17、L48-53）；桌面只实现 quick（复盘页"更多洞察"入口）。桌面定位为低频轻量校准，维持。

## 处置决定

1. 判据漂移 4 项立项修复（TDD 先红后绿，版本常量递增）：coach 六步法命名 + 方向信号判据（`journal-coach-v3`）、yearly 升级提醒（`yearly-review-v2`）、life-design 下次如何验证（`life-design-v2`）。
2. 设计性差异 4 项与已知差异 1 项只登记进兼容矩阵与契约对照表，不实现。
