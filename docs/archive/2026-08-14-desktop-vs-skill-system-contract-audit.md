# 桌面产品与 Skill 系统差异审查：契约与功能

> 审计日期：2026-08-14
>
> 审计性质：`.claude/` Skill 系统与 `apps/zhiji-desktop/` 桌面产品的契约级差异审查；与 `apps/zhiji-desktop/docs/skill-compatibility-matrix.md`（桌面端自证视角）互补，本文从 Skill 契约出发做反向核对
>
> 证据口径：两侧均以当前本地 `main` 文件为准；桌面端 P1-P4 切片已按 2026-08-14 合并记录进入 main
>
> 结论标签：`代码实测`、`契约事实`、`差异判定`、`风险推断`

## 1. 执行摘要：最重要的 5 个结论

### 1.1 日反馈链路两侧基本一致，桌面端强制力更强

**标签：代码实测、契约事实**

输出模板逐字一致（`📋⏮️🔍🔗⚡💊` 五段），D0-D6 质量门核心规则、昨日闭环证据规则、单洞察单行动、长度上限均映射到桌面端系统提示词。桌面端额外用 zod strict schema、C 级强制 `patternConnection = null`、D 级不调模型等代码兜底，强制力高于 Skill 侧的自觉遵守。

主要证据：

- `.claude/shared/contracts/daily-feedback.md` 与 `apps/zhiji-desktop/src/main-process/prompts/daily-review-v1.ts`
- `apps/zhiji-desktop/src/main-process/skill-runtime/daily-runtime.ts`

### 1.2 周期复盘是最大契约缺口：稳定结构与硬质量门缺失

**标签：契约事实、差异判定**

Skill 侧 `review-synthesis.md` 的 YAML frontmatter、聊天摘要、复盘六问显式一级标题（回顾目标/评估结果/分析原因正向/负向/重来演练/后续规划）、质量自检、方向锚点缺席五态检查、判断插槽与判断驱动展开，在桌面端均无对应实现。桌面端输出为压缩五段（结果/有效/无效/证据与矛盾/重来/行动），缺“回顾目标”与“质量自检”。语义保留但报告骨架与硬质量门不同构，两侧周期复盘产物不可互相替代阅读。

主要证据：

- `.claude/shared/contracts/review-synthesis.md`
- `apps/zhiji-desktop/src/main-process/prompts/periodic-review-v1.ts`

### 1.3 证据分级判据一致，实现分裂，存在等级分歧风险

**标签：代码实测、风险推断**

A-D 判据表两侧一致，但 Skill 侧由 AI 语义判断，桌面侧由中文关键词正则分句归类（`daily-evidence.ts`）。自由叙事未命中关键词时桌面端可能判得更低；反之关键词密集但缺乏真实经历的文本可能被高判。目前无测试约束两侧对同一输入给出相同等级。

主要证据：

- `.claude/shared/contracts/journal-input.md`
- `apps/zhiji-desktop/src/main-process/skill-runtime/daily-evidence.ts`

### 1.4 验证沉淀是语义相近、机制不同的两套系统

**标签：代码实测、差异判定**

Skill 侧由调用方在日反馈后自动写回 `verified-patterns.md`，有六个状态词、3 次独立支持/2 个情境的升级门槛、连续 3 次没做降门槛等细则。桌面侧是人工流程：从单篇复盘提取 0-3 条候选，用户确认后写入 JSON 快照，无状态词流转、无升级门槛、无连续没做检测。两者都坚持“确认后才沉淀”的精神，但桌面端不存在验证循环的自动记账。

主要证据：

- `.claude/shared/contracts/evidence-and-verification.md`
- `apps/zhiji-desktop/src/main-process/application/verified-patterns.ts`
- `apps/zhiji-desktop/src/main-process/skill-runtime/daily-audit-recorder.ts`（JSONL 仅追加审计，不做沉淀）

### 1.5 两套提示词为人工维护的平行文本，无一致性测试

**标签：代码实测、风险推断**

桌面端兼容矩阵明确声明“不读取 `.claude/shared/contracts/`”，隔离规则本身正确，但代价是契约更新后桌面端提示词漂移只能靠人发现。当前没有契约一致性测试或版本对照表登记两侧规则的同源关系。这是本审查发现的最高优先级流程风险。

主要证据：

- `apps/zhiji-desktop/docs/skill-compatibility-matrix.md`（隔离规则节）
- `apps/zhiji-desktop/src/main-process/prompts/` 全部提示词文件

## 2. 审计范围与方法

- 对象 A（Skill 系统）：`.claude/agents/` 9 个代理、`.claude/commands/` 13 个命令、`.claude/skills/`、`.claude/shared/contracts/` 11 个契约、`.claude/workflows/`。
- 对象 B（桌面产品）：`apps/zhiji-desktop/src/main-process/` 的 application、skill-runtime、prompts、infrastructure 与 IPC 契约。
- 方法：逐契约对照提示词、输出 schema 与渲染函数；以文件内容为唯一证据，不做运行时验证。
- 不在范围：飞书/滴答运行链路（矩阵已声明排除）、渲染层 UI 差异、性能与安装矩阵。

## 3. 功能差异总矩阵

| Skill 系统能力 | Skill 侧载体 | 桌面侧对应 | 状态 |
|---|---|---|---|
| 日反馈 | `daily-analyzer` + `daily-feedback.md` + `journal-input.md` | `GenerateDailyReview` + `daily-runtime` | 已对齐 |
| 日志质量教练 | `journal-quality-coach` | `journal-coach-v2` + `GenerateInsightReview` | 已对齐 |
| 周/月/项目复盘 | `weekly/monthly/project-synthesis` + `review-synthesis.md` | `periodic-runtime` | 结构精简，见 4.3 |
| 主题思考 | `topic-thinking.md` + `topic-thinking-persistence.md` | `TopicThinkingService` + `topic-thinking-v1` | 已对齐，见 4.5 细节差异 |
| 验证沉淀 | `evidence-and-verification.md` 写回规则 | `VerifiedPatternService`（候选+确认） | 机制不同，见 1.4 |
| 自然语言路由 | `codex-natural-language-routing.md` | `IntentRoutingService` + `intent-routing-v1` | 精神对齐，范围不同 |
| 闭环缺口检查与提醒投递 | `review-readiness-checker` + `readiness-delivery.md` | 无（首页仅确定性下一步建议） | 未实现 |
| 人生设计 | `/life-design` + `life-design-synthesis` | 无 | 未实现 |
| 收藏吃灰库 | `collection.md` | 无 | 未实现 |
| 第一性原理复核 | `first-principles-analysis.md` | 无 | 未实现 |
| 结果分发 | `result-distribution.md` + 飞书/滴答 CLI | 无 | 有意排除（矩阵声明） |
| 日志存档契约 | `journal-input.md` 存档边界 | `save-journal.ts` + Markdown 仓储 | 部分覆盖，见 4.2 |
| 飞书手机入口 | `local-feishu-daily-feedback.ps1` | 不适用 | 有意排除 |
| 开发者技能路由 | `developer-skill-routing.md` | 不适用（开发域） | 不适用 |

## 4. 契约差异明细

### 4.1 daily-feedback.md（日反馈输出契约）

| 契约条目 | Skill 侧 | 桌面侧 | 结论 |
|---|---|---|---|
| 输出模板五段 | 定义于契约 | `renderDailyReview` 逐字复刻 | 一致 |
| D0-D6 质量门 | 表格定义 | 系统提示词内嵌摘要 | 核心一致 |
| 昨日闭环三态 | ✅/❌/⚠️，禁止“没写=没做” | `priorAction.status` 枚举 done/not_done/insufficient，提示词同禁令 | 一致 |
| 原文引用 | `「」` 引用当天日志 | `insight.quote` 必填字段 + 渲染加 `「」` | 一致且强制 |
| 单行动 ≤5 分钟 | 硬约束 | 提示词约束 + 字段结构单一 | 一致 |
| 预测 24 小时可观察 | 硬约束 | 提示词约束 | 一致 |
| 禁止确定性心理归因 | 有 | 有 | 一致 |
| 长度上限 | 常规 260 / 例外 320 | 提示词仅写 320；zod 字段上限宽松（insight.text 达 4000），代码层无长度校验 | 部分差异 |
| 禁止跨段重复同一判断 | 有压缩检查清单 | 无显式提示词约束；结构化字段天然分隔，渲染每段一次，结构性缓解 | 部分差异 |
| 第一性原理复核入口 | 有 | 无 | 缺失 |

### 4.2 journal-input.md（日志输入契约）

| 契约条目 | Skill 侧 | 桌面侧 | 结论 |
|---|---|---|---|
| A-D 证据等级判据 | 语义判断 | 关键词正则（facts/states/interpretations/intentions 四组） | 判据一致、实现分裂，见 1.3 |
| 自由叙事不降级 | 明确 | 正则实现可能误降 | 风险 |
| 日期识别五类格式与相对日期 | 有 | 用户在 UI 显式选择日期，禁止未来日期 | 场景不同，桌面侧更简单可靠 |
| 存档边界：同日条目查重 | 合并或确认 | 同日多条独立文件、不互相覆盖；更新带 `expectedUpdatedAt` 冲突保护 | 机制不同但目标一致 |
| 意图触发与一次确认 | 有（长自由文本先问一次） | UI 显式操作，无需意图识别 | 场景消解 |

### 4.3 review-synthesis.md（复盘综合契约）——最大差异区

| 契约条目 | Skill 侧 | 桌面侧 | 结论 |
|---|---|---|---|
| 稳定结构：frontmatter/聊天摘要/六问一级标题/质量自检 | 硬要求 | 压缩五段（📊✅❌🔍🔄⚡） | 缺失 |
| 复盘六问 | 回顾目标/评估结果/原因正向/原因负向/重来演练/后续规划 | summary/effective/ineffective/evidence/ifRedone/nextAction（缺“回顾目标”，其余四问合并映射） | 部分映射 |
| 硬质量门：证据或降级、反例或限制 | 有 | 提示词仅“不得编造”“不得心理归因” | 弱化 |
| 方向锚点缺席五态检查 | 硬质量门 | 无 | 缺失 |
| 判断插槽与判断驱动展开 | 有 | 无 | 缺失 |
| 下游沉淀优先 | 有 | `periodic-materials` primary/supplement/journalIndex 同语义 | 一致 |
| 周报深度（3Why、下周规划三要素）与月报深度（主主题归并、life-design 升级提醒） | 有 | 无类型级深度差异 | 缺失 |
| 长度约束 | 无统一字数限制 | 800 字硬上限 | 桌面侧更严 |
| A-C 等级降级规则 | 有 | `gradeInstruction` 注入同等语义 | 一致 |

### 4.4 evidence-and-verification.md（证据与验证契约）

| 契约条目 | Skill 侧 | 桌面侧 | 结论 |
|---|---|---|---|
| 证据规则五条（引用、证据不足标注、可反驳、具体建议、诚实自检） | 有 | 提示词部分覆盖（不得编造、证据不足说明） | 部分 |
| 行为假说与干预实验区分 | 有 | 无 | 缺失 |
| 自动写回时机与来源 | 日反馈保存后自动 | 无自动写回；`DailyAuditRecorder` 仅 JSONL 审计 | 机制不同 |
| 六状态词与升级门槛（3 次/2 情境、连续 3 次没做降门槛） | 有 | 无 | 缺失 |
| 确认门 | 主题沉淀需确认 | 模式候选需确认才写快照 | 精神一致 |

### 4.5 topic-thinking.md 与 topic-thinking-persistence.md

| 契约条目 | Skill 侧 | 桌面侧 | 结论 |
|---|---|---|---|
| 首稿主线：问题→事实约束→当前判断→验证/沉淀/等待 | 有 | `SHARED_RULES` 同构 | 一致 |
| 区分事实/推断/价值取舍/未知 | 有 | 有 | 一致 |
| 行动可控、触发条件、停止条件；推不出写“当前不行动” | 有 | 有 | 一致 |
| 禁止人格标签、心理诊断、唯一客观答案 | 有 | 有 | 一致 |
| 参考既有主题最多 2 个并经索引检索 | `context.thinking_index` 语义匹配 | `referencedTopics` 最多两条 | 检索机制不同 |
| 标题必须为判断性短句、禁止空栏目 | 有 | 无对应提示词约束 | 部分缺失 |
| 未经确认不写主题文件 | 有 | 有（propose→confirm 流程，更新展示旧正文差异） | 一致且桌面侧更可视化 |
| 确认后 0-6 结构与全量维护 | `topic-thinking-persistence.md` | 归纳为“当前判断/依据来源/行动或等待条件”三段 | 精简 |

### 4.6 codex-natural-language-routing.md 与意图路由

| 契约条目 | Skill 侧 | 桌面侧 | 结论 |
|---|---|---|---|
| 语义识别复盘/周报/月报/项目请求 | 有 | `IntentRoutingService` 六值固定枚举 | 范围收窄 |
| “下一步/遗漏/该更新什么”闭环缺口检查 | 语义入口，返回一条手动建议 | 无；首页确定性下一步建议（`next-step.ts`）仅基于完成状态 | 部分替代 |
| 模型不得创建新流程 | 契约约束 | 枚举外返回 null，失败回退澄清 | 一致且更硬 |
| 确定性优先 | 无（AI 判断） | 关键词规则命中时不调模型 | 桌面侧更优 |

### 4.7 readiness-delivery.md、first-principles-analysis.md、result-distribution.md

| 契约 | Skill 侧 | 桌面侧 | 结论 |
|---|---|---|---|
| 闭环缺口提醒投递（7 天冷却、可丢弃状态、单候选） | 有 | 未实现 | 缺失 |
| 第一性原理复核 | 有 | 未实现 | 缺失 |
| 结果分发（幂等键、六态状态、凭证隔离） | 有 | 有意排除（矩阵声明，飞书/滴答不属于桌面范围） | 有意差异 |

## 5. 提示词限制与输出限制汇总

| 约束维度 | Skill 侧执行方式 | 桌面侧执行方式 | 评估 |
|---|---|---|---|
| 输出结构 | Markdown 模板约定 | zod strict schema + 确定性渲染 | 桌面侧更硬 |
| 模型输出格式 | 自由文本 | JSON Object 模式 + schema 校验，失败报 `INVALID_MODEL_OUTPUT` | 桌面侧更硬 |
| 证据等级降级 | AI 遵守契约 | 提示词注入 + 代码强制（C 级 patternConnection=null，D 级不调模型） | 桌面侧更硬 |
| 长度上限 | 契约文字约束 | 提示词软约束，代码无校验 | Skill 侧反而更明确 |
| 防重复解释 | 压缩检查清单 | 无显式约束 | Skill 侧更细 |
| 禁止心理归因/拔高价值观 | 有 | 有 | 一致 |
| 确认门（沉淀前） | 有 | 有 | 一致 |
| 个人背景授权注入 | 按契约 | 仅用户开启后注入 | 一致 |

## 6. 风险清单与建议

| 编号 | 风险 | 等级 | 建议 |
|---|---|---|---|
| R1 | 两套提示词平行维护，契约更新后桌面端漂移无测试兜底 | 高 | 建立契约-提示词对照表并在任一侧契约变更时作为检查清单；或加轻量一致性测试断言关键禁令文本存在 |
| R2 | 正则证据分级与语义分级对同一输入可能分歧 | 中 | 用真实非模板日志样本做两侧分级对照；仅在出现分歧证据时调整正则或引入语义兜底 |
| R3 | 周期复盘报告骨架不同构，用户跨入口阅读体验分裂 | 中 | 决策项：要么桌面端补齐六问结构与质量自检，要么在文档中明确声明“桌面周期复盘为精简形态”并冻结差异 |
| R4 | 桌面端无验证循环自动记账，长期会弱于 Skill 侧的假说收敛能力 | 中 | 当前 JSONL 审计已留足数据基础；待真实使用证据后再评估是否升级为状态词流转 |
| R5 | 日反馈 260 常规上限与跨段防重复在桌面端未落地 | 低 | 在提示词补一句 260 常规上限；长度硬校验可待真实超长样本出现再加 |
| R6 | 方向锚点缺席检查桌面端完全缺失，长期方向可能在桌面复盘中“自然消失” | 中 | 与 R3 一并决策；若目标用户主要使用桌面端，此项重要性上升 |

## 7. 有意差异声明（不应视为缺陷）

1. 桌面端不运行 Claude Skill/Agent：2026-08-13 关键决策，Main Process 以结构化契约复刻产品行为。
2. 飞书、滴答、结果分发、闭环提醒投递不属于桌面端范围：兼容矩阵已声明排除。
3. 桌面端日志存储为独立文件 + schema 校验，Skill 侧为中文目录 Markdown 追加：两者面向不同入口，均为本地 Markdown 权威。
4. 桌面端意图路由确定性优先于模型：比 Skill 侧语义路由更保守，属改进而非缺失。

## 8. 结论

桌面产品已对齐 Skill 系统的高频核心闭环，日反馈链路的提示词限制与输出限制基本一致且桌面端强制力更强。需要用户决策的真实差异集中在三处：周期复盘报告结构是否收敛同构（R3/R6）、证据分级的实现分裂是否需要对齐测试（R2）、以及契约-提示词漂移防护机制（R1）。其余缺失项或为有意排除，或为低频能力，按 PROJECT_STATUS 待办观察即可，不建议现在新增实现。
