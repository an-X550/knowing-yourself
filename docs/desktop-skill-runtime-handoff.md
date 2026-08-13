---
created: 2026-08-14
last_updated: 2026-08-14
status: active-handoff
---

# 知己桌面端 Skill Runtime：架构、状态与交接

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

### P1：验证模式的受确认沉淀

当前 JSONL 审计能追溯“行动是否被验证”，但不是用户可管理的长期模式库。只有在真实使用中确认用户需要跨日复用已验证模式时，新增桌面端自己的 `verified-patterns` 数据模型。

关键规则：模型只能提出候选；UI 展示来源、证据与变更差异；用户明确确认后保存。绝不把单次日反馈或审计日志直接升格为长期事实。

### P2：周/月/项目复盘迁移为第二个垂直切片

先用已有周期复盘能力建立兼容矩阵和金样本，再迁移“下游沉淀优先、证据不足降级、复盘六问、确认写入”。不要只把现有 prompt 丢进 LangGraph。

### P3：主题思考与受控联网

实现“匹配索引 → 最多读取两个相关主题 → 讨论 → 提议差异 → 用户确认后保存”的暂停/恢复闭环。联网只由用户明确请求触发，来源与查询可见，搜索结果不能静默沉淀。

### P4：模糊意图路由

仅在明确入口不足时，让模型从注册工作流枚举中选择 `WorkflowIntent`；Zod 校验失败即回退到澄清。不得允许模型创造流程、工具或权限。

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
3. 使用新隔离工作树，基于 `codex/desktop-daily-skill-runtime` 分支；先执行 `npm ci`、`npm test`、`npm run typecheck`，确认基线。
4. 只选择本文件 P0–P4 的一个切片。先做必要性闸门；通过后写规格与逐步计划，再实现。
5. 每任务坚持 TDD、最小改动、聚焦提交；完成后跑关联测试、全量测试、类型检查、lint、实际存在的打包脚本。
6. 在最终交接中报告：改动文件、用户可见行为、未完成项、精确验证命令/结果、提交哈希和任何外部阻塞。

## 权威文件索引

- 架构设计：`docs/superpowers/specs/2026-08-14-skill-runtime-agent-architecture-design.md`
- 已执行的日反馈计划：`docs/superpowers/plans/2026-08-14-desktop-daily-skill-runtime.md`
- 本交接：`docs/desktop-skill-runtime-handoff.md`
- 下一步可执行计划：`docs/superpowers/plans/2026-08-14-desktop-runtime-release-gate.md`
- 桌面端兼容范围：`apps/zhiji-desktop/docs/skill-compatibility-matrix.md`
