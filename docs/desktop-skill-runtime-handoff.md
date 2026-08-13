---
created: 2026-08-14
last_updated: 2026-08-14
status: active-handoff
---

# 知己桌面端 Skill Runtime：架构、状态与交接

> **交接用途：** 本文是给新接手的 AI Agent 或开发者的运行手册，而不是产品宣传页。它记录已确认的架构边界、当前代码事实、已验证证据、后续切片与停止条件。开始任何桌面端改动前必须完整阅读本文；若本文与代码冲突，以代码、测试和最新 Git 提交为准，并在完成核查后修正文档。

## 30 分钟接手清单

不要根据聊天记录或文件名猜测状态；按下列顺序建立可复核基线。

1. 在主仓库 `C:\Users\panda\.claude\skills\知己` 执行 `git status --short`，确认用户未提交的改动；不要清理、重置或覆盖它们。
2. 读取 `AGENTS.md`、`PROJECT_STATUS.md`、`CHANGELOG.md` 最近条目和本文。它们分别定义项目规范、当前事实、发布历史与桌面端边界。
3. 桌面端实现不在 `main`：切换或新建隔离工作树，基于远端分支 `origin/codex/desktop-daily-skill-runtime`。其截至 P0 的最新提交为 `a695b20`；不要在主工作区直接实现桌面端功能。
4. 在 `<worktree>/apps/zhiji-desktop` 执行：

   ```powershell
   npm test
   npm run typecheck
   npm run lint
   npm run package
   ```

   期望：测试通过、类型检查通过、lint 无 error、Windows x64 package 成功。lint 有 5 条既有 warning，位于未修改的既有文件；不要为消除它们扩大本任务范围。
5. 检查 `git status --short`。工作树可能有本地 Agent 生成的未跟踪 `.superpowers/` 目录；它不是产品文件，不可加入提交。
6. 只在基线通过后选择一个后续切片。先通过“必要性闸门”，再写新的 spec 和实施计划；不要把 P0 发布门再次当作待实现功能。

## 可直接复制给执行 Agent 的约束 Prompt

```text
你正在继续开发“知己桌面端 Skill Runtime”。请先完整阅读：
1. docs/desktop-skill-runtime-handoff.md
2. AGENTS.md
3. docs/superpowers/specs/2026-08-14-skill-runtime-agent-architecture-design.md
4. apps/zhiji-desktop/docs/skill-compatibility-matrix.md

目标与方法：
- 以第一性原理和高性价比为最高决策方法：先定义真实用户问题、证据、不可突破约束与最小验证；优先复用成熟架构和现有基础设施，禁止为了“未来可能需要”重复造轮子或提前引入复杂度。
- 当前产品边界是 Windows 本地桌面端、单用户、仅应用打开时运行、本地保存数据。暂不做云端、后台常驻、多用户、移动端、飞书、滴答清单、MCP marketplace、通用 Agent、shell 或任意文件工具。
- 只有通过必要性闸门才新增能力：存在当前具体问题证据；直接服务核心目标；既有能力不能更简单解决；完成后可立即验证。任一条件不成立，停止实现并在交接中说明原因。

绝对边界：
- 原 Codex + .claude Skill 系统是用户日常开发和使用的独立系统。禁止读取、执行、修改、复制、迁移或在运行时依赖 .claude/ 的任何内容。
- 桌面端功能代码只允许在 apps/zhiji-desktop/ 内修改；架构/交接/计划文档只允许在 docs/ 内修改。不得为了同步桌面端而改动 .claude/、.agents/ 或既有 Skill 文件。
- 不得删除、覆盖、移动或重置用户现有文件、项目数据、Git 历史、工作树或依赖目录。不得使用 git reset --hard、git checkout --、递归删除或破坏性命令。
- 不得把模型赋予 shell、任意路径读写/删除、递归磁盘扫描、任意 URL 浏览或自行创建工作流的权限。新工具必须是注册的业务工具，具备 Zod Schema、固定数据范围、明确副作用和用户确认策略。
- 所有正式写入必须通过现有仓储、原子写入和复读验证；删除继续走 Windows 回收站；不得把审计 JSONL 当作长期记忆或业务真相。

运行与安全授权：
- 用户睡眠期间，若选择不会影响电脑正常运行、不破坏电脑、不删除本机文件、不影响当前项目或原 Skill 系统的推荐方案，可直接选择并执行，不必等待回复。
- 遇到会扩大权限、删除/覆盖数据、影响原 Skill 系统、启动常驻服务、修改系统设置、安装全局软件、推送远端、合并分支、创建外部账号/费用，或选择会显著改变产品方向时，停止并等待用户明确授权。
- 默认使用隔离 Git 工作树；保留用户已有的未提交改动和未跟踪文件，不把 .superpowers/ 等本地 Agent 目录纳入提交。

依赖与网络：
- 安装任何依赖前，先只读检索本机现有资源：项目 node_modules、npm 缓存、C 盘和 D 盘的已知依赖目录。确认不存在兼容可用版本后，才安装最小必要依赖。
- 优先使用项目已存在的依赖、锁文件和官方源。下载缓慢时可使用阿里云或腾讯云镜像；禁止使用清华镜像源。
- 不因网络、缓存或权限临时失败而删除 node_modules、修改系统 npm 设置、复制大量依赖或改业务代码。记录准确错误，提供可安全重试条件。

工程流程：
- 先验证当前基线：在桌面端目录运行 npm test、npm run typecheck、npm run lint、npm run package；任何基线失败先判断是现有问题、环境问题还是本次改动，不掩盖失败。
- 生产行为改动一律 TDD：先写并运行能正确失败的测试，再写最小实现，再跑关联测试和全量验证。
- 每个完成项必须更新兼容矩阵/交接文档中真正变化的事实，并在最终报告中给出：改动文件、用户可见行为、未完成项、精确验证命令与结果、提交哈希、外部阻塞。
- 不以“模型输出看起来合理”替代测试、Schema 校验、数据完整性和发布验证。

当前优先级：
1. P0 发布门已经完成，不要重复实现；仅在 Runtime 边界、依赖或构建链改变时重跑验证。
2. P1“受确认的验证模式沉淀”尚未获必要性闸门通过；只有出现真实跨日复用需求且 JSONL 审计不足时，才能为它单独写 spec 和计划。
3. 其后依次才是 P2 周/月/项目复盘迁移、P3 主题思考与受控联网、P4 模糊意图路由。每个都是独立切片，不得合并成通用 Agent 重构。

开始工作前先报告：你选择的切片、必要性闸门证据、将改动的精确文件和验证方式。若没有通过闸门，停止编码并给出更简单替代方案。
```

## 当前交付的可复核快照

| 范畴 | 事实 | 证据 |
|---|---|---|
| 桌面端实现分支 | `codex/desktop-daily-skill-runtime` | 已推送到 `origin/codex/desktop-daily-skill-runtime` |
| 日反馈 Runtime 主提交 | `37dba5a feat: complete desktop daily skill runtime` | 包含 LangGraph、审计、API/UI 迁移 |
| P0 隔离与发布门提交 | `a695b20 test: guard desktop runtime isolation` | Runtime 源码隔离回归测试与 README 边界 |
| 主分支交接文档 | `2b8290f docs: record desktop runtime release gate` | 发布门证据写入本文和 P0 计划 |
| 最新完整测试 | 35 files / 140 tests 通过 | `npm test`，2026-08-14 |
| 静态检查 | `npm run typecheck` 通过；`npm run lint` 0 error / 5 warning | 2026-08-14 |
| 封装 | Electron Forge Windows x64 package 成功 | `npm run package`，2026-08-14 |

## 系统地图：请求、数据和责任如何流动

```text
Renderer (React)
  TodayPage -> window.zhiji.reviews.generateDaily({ date })
       | 只显示 review.body 或 clarification.question
       v
Preload + validated IPC
  reviews:generate-daily -> GenerateDailyReview.execute({ date, model })
       v
Application layer
  读取目标日期 journals + reviews + 可选 profile
  检查同日 sourceVersions 缓存
  创建可取消 ReviewTask
       v
Skill Runtime (LangGraph)
  build_evidence -> D: clarify -> END
                 -> A/B/C: provider.collect -> JSON Schema -> render -> END
       v
Persistence boundary
  MarkdownReviewRepository.save (atomic write + reread validation)
  DailyAuditRecorder.record (append-only JSONL summary)
       v
Desktop data root only
  journals/ reviews/ projects/ profile/ runtime/daily-feedback-audit.jsonl
```

**责任分割必须保持：** Renderer 不接触文件、密钥或模型；IPC 不接受未校验数据；Runtime 不直接读路径；仓储负责业务数据写入；审计只记录摘要；模型不决定权限、文件路径或是否创建新工作流。

## 当前关键接口：后续 Agent 不要重新发明

### 日反馈 Runtime

`apps/zhiji-desktop/src/main-process/skill-runtime/daily-runtime.ts`

```ts
export interface ProviderPort {
  collect(messages: ChatMessage[], signal?: AbortSignal, options?: CollectOptions): Promise<string>;
}

export type DailyRuntimeResult =
  | { kind: 'review'; body: string; grade: 'A' | 'B' | 'C'; output: DailyReviewOutput }
  | { kind: 'clarification'; question: string; grade: 'D' };
```

图内只有三个节点：`build_evidence`、`clarify`、`generate`。D 级必须在 `clarify` 结束，不能调用 `provider.collect`、不能保存 Review。A/B/C 才允许调用模型；模型输出必须经 `DailyReviewOutputSchema` 解析。C 级无条件将 `patternConnection` 归零；B 级提示词禁止无跨日证据的历史模式断言。

### 应用层结果联合类型

`GenerateDailyReview.execute` 与 Renderer API 都返回：

```ts
type DailyGenerationResult =
  | { kind: 'review'; review: Review }
  | { kind: 'clarification'; question: string };
```

任何新 UI 或 IPC 消费者必须穷尽处理两个分支；不得把澄清误当 Error，也不得为 D 级伪造空 Review。相同 `sourceVersions` 的当日记录在未传 `regenerate: true` 时直接复用，这是避免重复 LLM 调用和重复写入的缓存契约。

### 证据和审计数据

`DailyEvidence` 只保存从目标 journals 中确定性提取的 `facts`、`states`、`interpretations`、`intentions` 与 `gaps`。它不是心理诊断，也不是长期记忆。

审计事件格式固定为：

```ts
interface DailyAuditEvent {
  date: string;
  sourceIds: string[];
  grade: 'A' | 'B' | 'C' | 'D';
  outcome: 'review' | 'clarification';
  priorActionStatus?: 'done' | 'not_done' | 'insufficient';
}
```

写入位置为 `<dataRoot>/runtime/daily-feedback-audit.jsonl`，每行一个 JSON 对象并附加 `at`。不得把日志正文、模型原始回复、API Key、完整个人资料写入该文件。审计写入目前是正常成功路径的一部分；若未来想改为“审计失败不影响复盘保存”，必须先有明确故障证据、单独 spec、测试和用户可见的降级说明。

## 给后续 AI Agent 的一句话

知己桌面端不是“再调用一次 LLM”的产品，也不是开放权限的通用 Agent；它是一个 Windows 本地、单用户、应用打开时运行的**受控 Skill Runtime**。它用版本化兼容快照复现已验证的业务规则子集，使用 LangGraph JS 编排确定的工作流，并让模型只在受限上下文、严格 Schema 和程序化读写边界内工作。

当前首个垂直切片（日反馈）已经完成于隔离工作树。继续开发时，**绝不能读取、执行、修改、复制或在运行时依赖 `.claude/`**；用户仍以 Codex + 原 Skill 系统进行开发和日常使用。

## 真实问题与架构结论

### 第一性原理

用户需要的是“从记录中发现模式，形成小行动，并在后续验证”的可信闭环，而不是模型有更多自由。LLM 本身没有本地读写、网络或流程控制能力；若让它自由决定工具、路径和写入时机，质量与安全都不可复现。

因此，产品必须把不可替代的约束交给程序：最小证据包、输入降级、上下文范围、输出校验、写入前后检查、审计和用户确认。模型仅用于受限的语言理解、归纳和生成。

### 已确定的技术取舍

| 决策 | 采用 | 原因 |
|---|---|---|
| 产品形态 | Electron Windows 本地桌面端 | 第一阶段只服务单用户、应用开启时运行和本地数据保存 |
| 工作流编排 | LangGraph JS | 复用状态图、条件路由和未来的暂停/恢复能力，不自研状态机 |
| LLM 接入 | 现有 OpenAI-compatible Provider | 复用已有安全密钥存储与 Provider 抽象；不引入通用 Agent 框架 |
| 业务数据 | 现有 Markdown/JSON 仓储 | 人可读、可备份、已有原子写入与回收站能力 |
| 首阶段审计 | 本地 append-only JSONL | 应用关闭后不需要恢复运行，避免 SQLite/原生依赖的打包成本 |
| 权限 | 注册业务工具 + Zod + 路径策略 | 不提供 shell、任意文件读写、任意联网或模型自创流程 |
| 规则来源 | 独立兼容快照 | 与原 Skill 语义对齐，但桌面端在运行时完全隔离 `.claude/` |

未采用：LangChain 高层 Agent、OpenClaw/AGNT、MCP marketplace、常驻服务、向量库、云端后端。它们没有解决第一阶段的真实瓶颈，却会扩大权限面、运维面和调试成本。

## 硬约束：后续 Agent 必须遵守

1. 仅支持 Windows、本地单用户、应用打开时运行；不做云端、后台常驻、多用户、移动端、飞书或滴答清单。
2. 桌面端代码只能位于 `apps/zhiji-desktop/`；运行时代码不得出现或访问 `.claude` 路径。
3. 不破坏 Codex + `.claude` 原 Skill 的开发与日常运行；不要为了“同步”而修改它。
4. 模型不能获得 shell、递归扫描、任意路径读写、任意 URL 访问、删除权限，或创建未注册工作流的能力。
5. 读本地知己数据必须通过仓储或受路径策略约束的业务工具；写入必须经 Zod 校验、原子写入和复读验证。
6. 联网仅能在用户明确请求后，经显式 `web_search` / `read_web_source` 类工具进行；搜索结果不能自动写入长期认识。
7. 长期主题、个人画像、验证模式等高影响写入，先展示差异，取得用户明确确认后才可提交。
8. 新功能先经过项目“必要性闸门”：有当前问题证据、服务核心目标、不能用既有能力更简单解决、可立即验证。四项任一不成立，停止实现。
9. 修改任何生产行为必须 TDD：先写并运行失败测试，再写最小实现；不以“模型输出看起来不错”代替验收。
10. 需要依赖时先检索本机 C/D 盘与现有 npm 缓存；确认不存在后才安装最小依赖。若下载慢可用官方源、阿里云或腾讯云镜像，禁止清华镜像。

## 当前代码与提交状态

### 工作位置

| 项目 | 位置 |
|---|---|
| 主工作区 | `C:\Users\panda\.claude\skills\知己` |
| 桌面端隔离工作树 | `C:\Users\panda\.claude\skills\知己\.worktrees\desktop-daily-skill-runtime` |
| 桌面端分支 | `codex/desktop-daily-skill-runtime` |
| 当前实现提交 | `37dba5a feat: complete desktop daily skill runtime` |
| 前置实现提交 | `9a3391c`、`3e53b9a`、`4d4058b` |

不要在主工作区直接继续修改桌面端功能；先在新的隔离工作树或上述分支继续。不要把工作树目录提交进主分支。

### 已完成：日反馈垂直切片

| 能力 | 实现位置 | 已证实行为 |
|---|---|---|
| 兼容快照 | `src/main-process/skill-runtime/compatibility/daily-feedback-v1.ts` | 明示 `runtimeReadsClaudeDirectory: false` 和桌面端支持/延后范围 |
| 兼容矩阵 | `docs/skill-compatibility-matrix.md` | 逐项说明日反馈规则、测试与状态 |
| 证据分级 | `skill-runtime/daily-evidence.ts` | 程序化 A/B/C/D 分级；不确定时降级 |
| LangGraph 编排 | `skill-runtime/daily-runtime.ts` | `build_evidence → clarify 或 generate → END`；D 级不调用模型 |
| 输出边界 | `prompts/daily-review-v1.ts` + Runtime | 严格 JSON Schema；B/C 等级收紧历史模式推断；无效模型输出不保存 |
| 昨日行动闭环 | `domain/daily-context.ts` + Runtime | 读取最近一条既有日反馈；没有明确反证时只能标记证据不足 |
| 正式写入 | `application/generate-daily-review.ts` | 保留同日来源版本缓存、任务状态、原子保存和复读校验 |
| 审计 | `skill-runtime/daily-audit-recorder.ts` | 只追加 `runtime/daily-feedback-audit.jsonl`，记录日期、来源 ID、等级、结果和昨日行动状态，不记录正文/API Key |
| UI/API | `shared/contracts/desktop-api.ts`、`renderer/pages/today-page.tsx` | UI 能显示正式反馈或补证问题，不泄漏内部推理 |

### 已完成验证

- 曾完整通过 `npm test`：35 个测试文件、139 个测试。
- `npm run typecheck` 通过。
- `npm run lint` 无 error；存在 5 个历史 warning，均在未修改的既有文件中。
- `npm run package` 已完成 Vite 生产构建；最后 Electron 运行时下载因网络 `ECONNRESET` 中断，不是编译或代码失败。
- 最新补充的审计断言和类型检查已通过；一次再次全量回归因 60 秒命令超时被终止，未产生写入。

### 2026-08-14：已解除的执行环境阻塞与最终发布验证

在受限沙箱中再次执行 P0 发布门时，`npm test` 在加载 `vitest.config.ts` 前即失败：桌面端 `node_modules` 是到 `D:\ZhijiDependencies\desktop\node_modules` 的 Windows junction，而当前沙箱拒绝构建工具沿该路径读取（`esbuild: Cannot read directory ... Access is denied`）。同次 `npm run typecheck` 通过。

本次已在隔离工作树补齐两项 P0 工件：`tests/unit/daily-runtime.test.ts` 增加只扫描 `src/main-process/skill-runtime` 的回归测试，禁止任何 `.claude` 文本引用；`apps/zhiji-desktop/README.md` 增加 Skill Runtime 边界、LangGraph 编排、本地审计位置与不含敏感正文的说明。受当前权限限制，Vitest 无法实际加载配置以执行该测试；但同一受限目录中的只读源码扫描已确认 4 个 Runtime TypeScript 文件均不含 `.claude`，并且 `npm run typecheck` 通过。`npm run lint` 无 error，保留 5 条既有 warning。`npm run package` 同样在 Vite 配置加载阶段因同一访问拒绝中断，尚未到 Electron 下载阶段。

该限制在本机权限恢复后已解除。最终验证结果：新增隔离回归测试 `daily-runtime.test.ts` 4/4 通过；全量 `npm test` 为 35 个测试文件、140 个测试全部通过；`npm run typecheck` 通过；`npm run lint` 无 error，仍有 5 条既有 warning；`npm run package` 成功完成 Vite 构建与 Windows x64 Electron Forge 封装。P0 发布门已具备验证证据。

## 未完成的内容：按优先级而非想象力推进

### P0：日反馈发布门与隔离证明（已完成）

已完成：隔离回归测试、README 运行边界说明和一次成功的 Windows x64 封装。后续不再为该发布门新增功能；仅在依赖、构建链或 Runtime 边界变化时重跑。

### P1：验证模式的受确认沉淀（下一候选，尚未获必要性闸门通过）

当前 JSONL 审计能追溯“行动是否被验证”，但不是用户可管理的长期模式库。只有在真实使用中确认用户需要跨日复用已验证模式时，新增桌面端自己的 `verified-patterns` 数据模型。

关键规则：模型只能提出候选；UI 展示来源、证据与变更差异；用户明确确认后保存。绝不把单次日反馈或审计日志直接升格为长期事实。

开始 P1 前必须取得一次真实证据：用户需要在后续日反馈或周期复盘中主动复用一个已验证模式，而 JSONL 审计不足以让用户查看、理解或管理它。没有该证据时，不创建数据模型、页面、SQLite 或“记忆”。获准后的最小范围仅为独立仓储、候选预览、确认/拒绝、来源 review ID 与证据摘要、只读列表；不含自动提取、自动写入、向量检索、跨设备同步或通用长期记忆。

### P2：周/月/项目复盘迁移为第二个垂直切片

先用已有周期复盘能力建立兼容矩阵和金样本，再迁移“下游沉淀优先、证据不足降级、复盘六问、确认写入”。不要只把现有 prompt 丢进 LangGraph。

开始前的验收物是：周期复盘兼容矩阵、脱敏金样本、每个输出字段对应的最小材料表。没有这些，不接入图编排。

### P3：主题思考与受控联网

实现“匹配索引 → 最多读取两个相关主题 → 讨论 → 提议差异 → 用户确认后保存”的暂停/恢复闭环。联网只由用户明确请求触发，来源与查询可见，搜索结果不能静默沉淀。

这一切片需要应用关闭后的暂停/恢复，届时才评估 LangGraph 持久化与 SQLite checkpointer；不要为了 P1 或 P2 提前引入它。

### P4：模糊意图路由

仅在明确入口不足时，让模型从注册工作流枚举中选择 `WorkflowIntent`；Zod 校验失败即回退到澄清。不得允许模型创造流程、工具或权限。

## 后续 Agent 的决策表

| 观察到的需求 | 先做什么 | 允许的下一步 | 禁止的下一步 |
|---|---|---|---|
| “日反馈太泛/不准” | 取一条脱敏 journal 与期望输出，复现到测试 | 调整证据分级或 Schema 约束，先红测 | 仅加长 prompt、降低 D 级门槛 |
| “想记住已经验证的规律” | 记录一次真实复用场景 | 走 P1 必要性闸门 | 自动从旧日志归纳人格/模式 |
| “想做周报/月报” | 建兼容矩阵和金样本 | 走 P2 单独 spec | 复用日反馈图或泛化成 Agent loop |
| “想联网查资料” | 确认用户明确请求和使用目的 | 设计固定 web 工具与来源展示 | 给模型任意浏览器/URL 权限 |
| “想让它自己决定做什么” | 收集真实模糊入口的失败样本 | P4 注册表内 intent 路由 | 通用 Agent、shell、任意工具市场 |

## 变更质量门：必须逐项证明

1. **隔离：** `skill-runtime` 源码扫描和 `daily-runtime.test.ts` 仍通过；没有 `.claude` 运行时依赖。
2. **权限：** 新工具有输入 Zod Schema、固定数据范围、明确副作用和用户批准规则；没有通用读写/删除/shell 工具。
3. **事实边界：** 证据不足时返回澄清或 `insufficient`，不编造解释、动机、历史模式或行动完成状态。
4. **数据完整性：** 所有正式写入通过仓储、原子写入和复读；删除继续走 Windows 回收站。
5. **用户可见性：** UI 显示结果或澄清及必要的材料/权限提示，不泄露模型链式思维和隐私原文。
6. **回归：** 先运行新增失败测试，再运行关联测试、全量 `npm test`、`npm run typecheck`、`npm run lint`、`npm run package`。
7. **文档：** 更新兼容矩阵、本文、状态/变更日志中真正改变的事实；写出提交哈希、命令和准确结果。

### 可选 Spike：DeepSeek Harness

可在完全隔离、无真实用户数据的实验目录中评估其工具调用与上下文能力；不得成为发布依赖或替换 LangGraph，除非满足稳定发布、无独立服务、可嵌入 Electron、权限/审计/Schema 全部合规且金样本不劣于现有 Provider。

## 非目标与禁止的“捷径”

- 不把 `.claude/skills/*.md` 动态交给桌面端模型执行。
- 不使用通用 `read_file(path)`、`write_file(path)`、`delete(path)` 或 `shell(command)` 作为产品工具。
- 不因“未来可能要恢复”提前加入 SQLite、队列、常驻服务或云同步。
- 不把审计日志当作产品业务真相或长期记忆。
- 不为通过测试而降低 D 级门槛、伪造证据、把不确定行动标记为未完成，或删除既有测试。
- 不因换了 AI Agent 而重做已完成的 LangGraph、仓储、IPC、安全存储或原子写入基础设施。

## 后续 Agent 的启动流程

1. 在仓库根目录阅读本文件、`AGENTS.md`、`PROJECT_STATUS.md`、`CHANGELOG.md` 最近条目，以及 `docs/superpowers/specs/2026-08-14-skill-runtime-agent-architecture-design.md`。
2. 阅读 `apps/zhiji-desktop/docs/skill-compatibility-matrix.md`、`src/main-process/skill-runtime/`、相关测试和本次计划文件。
3. 使用新隔离工作树，基于 `origin/codex/desktop-daily-skill-runtime` 分支；先执行 `npm ci`、`npm test`、`npm run typecheck`、`npm run lint`、`npm run package`，确认基线。`node_modules` 可以是指向 D 盘依赖目录的 Windows junction；先复用它，只有确证本机不存在兼容依赖后才安装。
4. 只选择本文件 P0–P4 的一个切片。先做必要性闸门；通过后写规格与逐步计划，再实现。
5. 每任务坚持 TDD、最小改动、聚焦提交；完成后跑关联测试、全量测试、类型检查、lint、实际存在的打包脚本。
6. 在最终交接中报告：改动文件、用户可见行为、未完成项、精确验证命令/结果、提交哈希和任何外部阻塞。

## 权威文件索引

- 架构设计：`docs/superpowers/specs/2026-08-14-skill-runtime-agent-architecture-design.md`
- 已执行的日反馈计划：`docs/superpowers/plans/2026-08-14-desktop-daily-skill-runtime.md`
- 本交接：`docs/desktop-skill-runtime-handoff.md`
- 已完成的 P0 发布门执行记录：`docs/superpowers/plans/2026-08-14-desktop-runtime-release-gate.md`
- 桌面端兼容范围：`apps/zhiji-desktop/docs/skill-compatibility-matrix.md`
