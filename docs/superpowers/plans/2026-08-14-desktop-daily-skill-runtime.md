# 桌面端日反馈 Skill Runtime 实施计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use `superpowers:subagent-driven-development` or `superpowers:executing-plans` to implement task-by-task.

**Goal:** 在不改变 Codex + `.claude/` 原有运行的前提下，为 Windows 本地桌面端建立可审计的日反馈工作流，并满足已冻结的日反馈契约子集。

**Architecture:** 桌面端只使用 `apps/zhiji-desktop/src/main-process/skill-runtime/` 下的版本化适配定义；绝不运行、读写或依赖 `.claude/`。`GenerateDailyReview` 委托给 LangGraph 的单次内存工作流：构建证据卡、D 级停止、A/B/C 调用模型、校验输出并审计。业务数据仍是现有 Markdown/JSON；审计写入用户数据根目录 `runtime/audit.jsonl`。第一阶段不引入 SQLite：应用关闭后不承诺恢复，避免 Electron 原生依赖的打包风险。

**Tech Stack:** Electron 43、TypeScript 5、React 19、Zod 4、Vitest 2、`@langchain/langgraph`、现有 Markdown repositories。

## Global Constraints

- 只支持 Windows、本地单用户、应用开启时运行；不做云端、后台、飞书、滴答、多用户、MCP、通用 shell 或任意文件工具。
- Codex + `.claude/` 是开发和日常使用的独立系统；本计划不改动 `.claude/` 中的任何文件、数据或运行行为。
- 新代码只能在 `apps/zhiji-desktop/` 内；桌面端在运行时不得出现 `.claude` 路径。
- D 级：不调用模型、不保存正式反馈、不写验证沉淀；未记录上一行动不得推断“没做”。
- 每项生产行为先写并运行失败的测试，才写最小实现。

---

## Task 1: 冻结适配范围与兼容矩阵

**Files:**

- Create: `apps/zhiji-desktop/src/main-process/skill-runtime/compatibility/daily-feedback-v1.ts`
- Create: `apps/zhiji-desktop/docs/skill-compatibility-matrix.md`
- Test: `apps/zhiji-desktop/tests/unit/daily-runtime.test.ts`

**Interfaces:**

```ts
export const DAILY_FEEDBACK_COMPATIBILITY = Object.freeze({
  id: 'desktop-daily-feedback-v1',
  sourceRuleVersion: '2026-07-31',
  runtimeReadsClaudeDirectory: false,
  materialCategories: ['target-journals', 'previous-daily-review', 'verified-patterns'] as const,
  supports: ['A-D evidence grading', 'prior-action closure', 'single action', 'validated write'] as const,
  deferred: ['verified-pattern persistence', 'distribution', 'reminders'] as const,
});
```

- [ ] Add a test asserting the exact ID, material categories, and `runtimeReadsClaudeDirectory === false`.
- [ ] Run `npm test -- tests/unit/daily-runtime.test.ts`; expected failure: module missing.
- [ ] Create the module and matrix documenting each supported/deferred feature and its test; no `.claude` imports or copied runtime paths.
- [ ] Run the same command; expected pass.
- [ ] Commit: `git add apps/zhiji-desktop/src/main-process/skill-runtime/compatibility/daily-feedback-v1.ts apps/zhiji-desktop/docs/skill-compatibility-matrix.md apps/zhiji-desktop/tests/unit/daily-runtime.test.ts; git commit -m "docs: define desktop daily feedback compatibility"`.

## Task 2: 以测试驱动实现 A-D 证据卡

**Files:**

- Create: `apps/zhiji-desktop/src/main-process/skill-runtime/daily-evidence.ts`
- Test: `apps/zhiji-desktop/tests/unit/daily-evidence.test.ts`

**Interfaces:**

```ts
export type DailyEvidenceGrade = 'A' | 'B' | 'C' | 'D';
export interface DailyEvidence { grade: DailyEvidenceGrade; facts: string[]; states: string[]; interpretations: string[]; intentions: string[]; gaps: string[]; }
export function buildDailyEvidence(journals: Journal[]): DailyEvidence;
```

- [ ] Test A: `完成了报告，感到轻松。我发现上午先关消息有效，明天继续。`; B: `完成了报告，但很累。`; C: `今天很累。`; D: `不知道。`.
- [ ] Run `npm test -- tests/unit/daily-evidence.test.ts`; expected failure: module missing.
- [ ] Implement conservative deterministic phrase extraction. Ambiguity lowers grade; no model call and no filesystem read. D requires no recognizable first-person concrete experience; thin but recognizable experience is C.
- [ ] Run focused test; expected pass.
- [ ] Commit: `git add apps/zhiji-desktop/src/main-process/skill-runtime/daily-evidence.ts apps/zhiji-desktop/tests/unit/daily-evidence.test.ts; git commit -m "feat: add daily evidence grading"`.

## Task 3: 接入 LangGraph 单次工作流

**Files:**

- Modify: `apps/zhiji-desktop/package.json`, `apps/zhiji-desktop/package-lock.json`
- Create: `apps/zhiji-desktop/src/main-process/skill-runtime/daily-runtime.ts`
- Test: `apps/zhiji-desktop/tests/unit/daily-runtime.test.ts`

**Interfaces:**

```ts
export type DailyRuntimeResult =
  | { kind: 'review'; body: string; grade: Exclude<DailyEvidenceGrade, 'D'> }
  | { kind: 'clarification'; question: string; grade: 'D' };
export async function runDailyFeedback(input: { journals: Journal[]; reviews: Review[]; provider: ProviderPort; profile?: string; signal?: AbortSignal }): Promise<DailyRuntimeResult>;
```

- [ ] Add tests: D returns one clarification and does not call `provider.collect`; a ready journal calls once and returns rendered review.
- [ ] Run `npm test -- tests/unit/daily-runtime.test.ts`; expected failure: `runDailyFeedback` missing.
- [ ] Run `npm install @langchain/langgraph @langchain/core`.
- [ ] Implement `StateGraph` nodes `build_evidence`, `clarify`, `generate`, `validate_render`, with `MemorySaver`. A/B/C use grade-specific prompt restrictions: B cannot assert unsupported history; C cannot emit `🔗` or root-cause language. Keep full bodies only in the single request, not in state history.
- [ ] Run focused test; expected pass.
- [ ] Commit: `git add apps/zhiji-desktop/package.json apps/zhiji-desktop/package-lock.json apps/zhiji-desktop/src/main-process/skill-runtime/daily-runtime.ts apps/zhiji-desktop/tests/unit/daily-runtime.test.ts; git commit -m "feat: orchestrate daily feedback with langgraph"`.

## Task 4: 添加最小审计并迁移 use case

**Files:**

- Create: `apps/zhiji-desktop/src/main-process/skill-runtime/audit-recorder.ts`
- Modify: `apps/zhiji-desktop/src/main-process/bootstrap.ts`, `apps/zhiji-desktop/src/main-process/application/generate-daily-review.ts`
- Test: `apps/zhiji-desktop/tests/unit/daily-runtime.test.ts`, `apps/zhiji-desktop/tests/integration/generate-daily-review.test.ts`

**Interfaces:**

```ts
export interface DailyRunAudit { runId: string; workflowVersion: string; grade: DailyEvidenceGrade; sourceIds: string[]; provider: string; model: string; outcome: 'clarified' | 'saved' | 'invalid_output' | 'cancelled' | 'failed'; createdAt: string; }
export interface AuditRecorder { record(event: DailyRunAudit): Promise<void>; }
export type DailyReviewResult = { kind: 'review'; review: Review } | { kind: 'clarification'; question: string };
```

- [ ] Test `JsonlAuditRecorder` writes `runtime/audit.jsonl` with the workflow ID and source IDs but never journal content/API keys.
- [ ] Add integration test: D input returns `{ kind: 'clarification' }`, invokes no model and leaves `reviews.list()` empty.
- [ ] Run both focused tests; expected failure: recorder/result union absent and existing use case always saves.
- [ ] Implement serialized JSONL appends; audit errors must not invalidate a successfully saved review. Inject recorder from bootstrap. Delegate use case analysis to `runDailyFeedback`; clarification completes task without saving, normal review preserves source-version cache and atomic write.
- [ ] Update `register-handlers.ts`, preload/API contract and `today-page.tsx` to render the returned review or clarification, without exposing raw audit/internal reasoning.
- [ ] Run both focused tests; expected pass.
- [ ] Commit: `git add apps/zhiji-desktop/src/main-process/skill-runtime/audit-recorder.ts apps/zhiji-desktop/src/main-process/bootstrap.ts apps/zhiji-desktop/src/main-process/application/generate-daily-review.ts apps/zhiji-desktop/src/main-process/ipc/register-handlers.ts apps/zhiji-desktop/src/preload.ts apps/zhiji-desktop/src/shared/contracts/desktop-api.ts apps/zhiji-desktop/src/renderer/pages/today-page.tsx apps/zhiji-desktop/tests/unit/daily-runtime.test.ts apps/zhiji-desktop/tests/integration/generate-daily-review.test.ts; git commit -m "feat: audit desktop daily feedback runs"`.

## Task 5: 验证边界与发布门

**Files:**

- Modify: `apps/zhiji-desktop/README.md`
- Test: `apps/zhiji-desktop/tests/unit/daily-runtime.test.ts`

- [ ] Add an isolation test asserting all source files under `skill-runtime/` contain no `.claude` string.
- [ ] Run it; expected failure only if an accidental dependency was added. If it passes immediately, retain it as a regression test.
- [ ] Document that the desktop runtime uses an independent compatibility snapshot and never executes/modifies the Codex Skill system.
- [ ] Run `npm test`, `npm run typecheck`, `npm run lint`, `npm run test:e2e`, and `npm run package`; all must exit 0.
- [ ] Confirm `git diff --name-only` contains no `.claude/` path; commit `git add apps/zhiji-desktop/README.md apps/zhiji-desktop/tests/unit/daily-runtime.test.ts; git commit -m "docs: clarify desktop runtime isolation"`.

## Review

- This plan intentionally defers verification-pattern persistence, topic thinking, web tools, SQLite checkpoint recovery and all external integrations. They are subsequent independently testable slices.
- The original architecture proposed SQLite checkpoints; first-principles scope review removes them because phase one does not require post-close resume and native Electron dependencies add packaging risk.
- Success is measured by Skill-compatible behavior and tests, not merely successful LangGraph installation.
