# 知己 Windows 客户端日志完整性与历史补写实施计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 让用户能在任意今天或过去日期创建多条互不覆盖的本地日志，显式编辑指定记录，并确保今日反馈和周期复盘读取最新、正确范围的材料。

**Architecture:** 保留 Electron 模块化单体与本地 Markdown，把模糊的 `journals.save` 拆成 create/update 两条具名 IPC；Repository 以稳定 ID 寻址新文件，同时兼容读取旧日期文件。Renderer 默认创建空白记录，历史视图显式进入编辑；日反馈按当天全部日志与来源版本判断新鲜度，项目材料改用项目和日期交集。

**Tech Stack:** Electron 43、React 19、TypeScript 5.9、Zod、Markdown/gray-matter、Vitest、Testing Library、Playwright。

## Global Constraints

- 不引入数据库、新依赖、云服务、账号或自动迁移。
- 新日志路径固定为 `journals/<year>/<date>--<journal-id>.md`；旧 `YYYY-MM-DD.md` 继续可读。
- 新建永不覆盖；更新必须携带 `expectedUpdatedAt` 并只修改目标 ID。
- 日期只允许本地今天或过去，`createdAt` 保留真实创建时间。
- 补写历史日志不自动调用 AI。
- 删除、回收站、版本历史、富文本、附件和批量迁移继续暂缓。
- 每批先写失败测试，再做最小实现；不修改 `.claude/` 产品逻辑。

---

## 文件结构

- Modify `src/shared/schemas/ipc.ts`：新增 create/update 输入契约。
- Modify `src/shared/schemas/domain.ts`：Review v1/v2 兼容及来源版本类型。
- Modify `src/shared/contracts/desktop-api.ts`、`src/preload.ts`、`src/main-process/ipc/register-handlers.ts`：暴露具名 create/update。
- Split `src/main-process/application/save-journal.ts` 为创建和更新用例，或在原文件中导出两个职责清晰的类。
- Modify `src/main-process/infrastructure/markdown/journal-repository.ts`：ID 路径、旧文件兼容、移动与冲突保护。
- Modify `src/renderer/pages/today-page.tsx`：日期、新建/编辑状态、保存顺序与草稿保护。
- Modify `src/renderer/pages/history-page.tsx`、`src/renderer/features/history/history-reader.tsx`：显式编辑入口与同日记录辨识。
- Modify `src/renderer/app/app.tsx`、`src/renderer/app/navigation.ts`：短生命周期编辑意图和导航保护。
- Modify `src/main-process/application/generate-daily-review.ts`、`src/renderer/domain/next-step.ts`：当天多日志反馈与新鲜度。
- Modify `src/main-process/domain/material-selector.ts`：项目和日期交集。
- Modify `src/main-process/infrastructure/transfer/business-archive-validator.ts`：重复日志 ID 校验。
- Modify unit/integration/E2E tests：覆盖多日志、补写、编辑、分析、重启和备份。

### Task 1: 多日志安全存储与旧文件兼容

**Files:**
- Modify: `apps/zhiji-desktop/src/shared/schemas/ipc.ts`
- Modify: `apps/zhiji-desktop/src/shared/contracts/desktop-api.ts`
- Modify: `apps/zhiji-desktop/src/preload.ts`
- Modify: `apps/zhiji-desktop/src/main-process/ipc/register-handlers.ts`
- Modify: `apps/zhiji-desktop/src/main-process/application/save-journal.ts`
- Modify: `apps/zhiji-desktop/src/main-process/infrastructure/markdown/journal-repository.ts`
- Modify: `apps/zhiji-desktop/tests/integration/markdown-repository.test.ts`
- Create: `apps/zhiji-desktop/tests/integration/journal-commands.test.ts`

**Interfaces:**
- Produces: `CreateJournalInput = { date; body; projectIds }`
- Produces: `UpdateJournalInput = { id; date; body; projectIds; expectedUpdatedAt }`
- Produces: `MarkdownJournalRepository.create(journal)` and `update(input)`; `get/list` remain compatible.

- [ ] **Step 1: Write failing repository tests**

Add tests that create two journals with the same date and assert two files and two readable IDs; update one and assert the other is unchanged; load one legacy `YYYY-MM-DD.md` beside a new file; reject duplicate IDs.

- [ ] **Step 2: Run the repository tests to verify failure**

Run: `npm test -- --run tests/integration/markdown-repository.test.ts tests/integration/journal-commands.test.ts`

Expected: FAIL because save still maps every date to one path and create/update do not exist.

- [ ] **Step 3: Implement new path and create/update semantics**

Use `<date>--<id>.md` for new files. Update locates the existing file by ID, checks `expectedUpdatedAt`, atomically writes the destination, and only removes the old path after successful validation when the date changes. `list/get` scan both naming forms and reject duplicate IDs.

- [ ] **Step 4: Replace save IPC with create/update**

Add strict Zod schemas, desktop API methods, preload mappings and handlers. Reject future dates against a Main Process local-date helper, not only an HTML constraint.

- [ ] **Step 5: Run tests and typecheck**

Run: `npm test -- --run tests/integration/markdown-repository.test.ts tests/integration/journal-commands.test.ts tests/unit/ipc-schema.test.ts`

Run: `npm run typecheck`

Expected: PASS.

- [ ] **Step 6: Commit the storage checkpoint**

Commit message: `fix(desktop): preserve every journal entry`

### Task 2: 自选日期、新建/编辑分离与草稿保护

**Files:**
- Modify: `apps/zhiji-desktop/src/renderer/app/navigation.ts`
- Modify: `apps/zhiji-desktop/src/renderer/app/app.tsx`
- Modify: `apps/zhiji-desktop/src/renderer/pages/today-page.tsx`
- Modify: `apps/zhiji-desktop/src/renderer/pages/history-page.tsx`
- Modify: `apps/zhiji-desktop/src/renderer/features/history/history-reader.tsx`
- Modify: `apps/zhiji-desktop/src/renderer/domain/history-items.ts`
- Modify: `apps/zhiji-desktop/src/index.css`
- Modify: `apps/zhiji-desktop/tests/unit/today-page.test.tsx`
- Modify: `apps/zhiji-desktop/tests/unit/history-page.test.tsx`
- Modify: `apps/zhiji-desktop/tests/unit/app.test.tsx`

**Interfaces:**
- Produces: `journal.edit` intent carrying a journal ID.
- Consumes: `window.zhiji.journals.create/update` from Task 1.
- Produces: dirty-state guard for in-app navigation and window close.

- [ ] **Step 1: Write failing Renderer tests**

Assert a blank new form despite existing today journals; local today is default; past dates are accepted and future max is today; two consecutive saves call `create` twice without IDs; history edit calls `update` with `expectedUpdatedAt`; dirty navigation asks before discarding.

- [ ] **Step 2: Run tests to verify failure**

Run: `npm test -- --run tests/unit/today-page.test.tsx tests/unit/history-page.test.tsx tests/unit/app.test.tsx`

Expected: FAIL against current implicit-today editing behavior.

- [ ] **Step 3: Implement the focused journal form**

Add date, optional project and body. Default to create mode and empty body. After create, clear body but retain date. Only `journal.edit` loads a journal and calls update. Show historical-date explanation and one truthful primary action.

- [ ] **Step 4: Add explicit edit and dirty-state protection**

History items display date, local creation time and first line. Reader exposes Edit. App navigation asks once before discarding dirty changes; closing the window uses a narrow IPC contract only if renderer dirty state cannot cover it safely.

- [ ] **Step 5: Run tests and typecheck**

Run: `npm test -- --run tests/unit/today-page.test.tsx tests/unit/history-page.test.tsx tests/unit/app.test.tsx`

Run: `npm run typecheck`

Expected: PASS.

- [ ] **Step 6: Commit the UI checkpoint**

Commit message: `feat(desktop): support dated journal backfill`

### Task 3: 最新日反馈与正确复盘材料

**Files:**
- Modify: `apps/zhiji-desktop/src/shared/schemas/domain.ts`
- Modify: `apps/zhiji-desktop/src/main-process/application/generate-daily-review.ts`
- Modify: `apps/zhiji-desktop/src/main-process/domain/daily-context.ts`
- Modify: `apps/zhiji-desktop/src/main-process/domain/material-selector.ts`
- Modify: `apps/zhiji-desktop/src/renderer/domain/next-step.ts`
- Modify: `apps/zhiji-desktop/src/renderer/pages/today-page.tsx`
- Modify: `apps/zhiji-desktop/tests/integration/generate-daily-review.test.ts`
- Modify: `apps/zhiji-desktop/tests/unit/daily-context.test.ts`
- Modify: `apps/zhiji-desktop/tests/unit/material-selector.test.ts`
- Modify: `apps/zhiji-desktop/tests/unit/next-step.test.ts`

**Interfaces:**
- Produces: Review v2 `sourceVersions: { id; updatedAt }[]` while parsing v1 reviews.
- Produces: daily generation by date/all current journals, returning cached review only when source versions match.

- [ ] **Step 1: Write failing analysis tests**

Cover two journals on one date, a modified source invalidating old feedback, a new same-day journal invalidating old feedback, save-before-generate order, and project materials requiring both project linkage and date inclusion.

- [ ] **Step 2: Run tests to verify failure**

Run: `npm test -- --run tests/integration/generate-daily-review.test.ts tests/unit/daily-context.test.ts tests/unit/material-selector.test.ts tests/unit/next-step.test.ts tests/unit/today-page.test.tsx`

Expected: FAIL because daily review is single-journal and project selection uses OR.

- [ ] **Step 3: Implement source-version freshness**

Generate daily feedback from all journals for a date, sorted by `createdAt`. Persist `sourceIds` and `sourceVersions`; parse v1 reviews but treat them as stale when they cannot prove current versions. Save a new review rather than overwrite history.

- [ ] **Step 4: Enforce save-then-generate and project intersection**

Renderer awaits create/update, refreshes the date collection, then invokes generation. AI failure leaves the journal saved. Project selection becomes `inRange && linked` when a project ID is present; absent project ID remains date-range selection.

- [ ] **Step 5: Run tests and typecheck**

Run the Task 3 test command and `npm run typecheck`.

Expected: PASS.

- [ ] **Step 6: Commit the analysis checkpoint**

Commit message: `fix(desktop): analyze current journal sources`

### Task 4: 备份、E2E、治理与发布

**Files:**
- Modify: `apps/zhiji-desktop/src/main-process/infrastructure/transfer/business-archive-validator.ts`
- Modify: `apps/zhiji-desktop/tests/integration/data-transfer.test.ts`
- Modify: `apps/zhiji-desktop/e2e/desktop.spec.ts`
- Modify: `apps/zhiji-desktop/README.md`
- Modify: `CHANGELOG.md`
- Modify: `PROJECT_STATUS.md`
- Modify: `VERSION`

**Interfaces:**
- Consumes all previous tasks.
- Produces a verified Windows build and user-facing release facts.

- [ ] **Step 1: Add backup and E2E regressions**

Backup test round-trips two same-day files and rejects duplicate journal IDs. E2E saves two today entries and one past entry, restarts, edits only one, verifies all remain, checks daily source coverage and confirms the past entry appears in a periodic preview.

- [ ] **Step 2: Run targeted tests to verify failure, then implement minimal validator support**

Run: `npm test -- --run tests/integration/data-transfer.test.ts`

Expected before implementation: FAIL on duplicate-ID acceptance or multi-file fixture assumptions; after validator changes: PASS.

- [ ] **Step 3: Run full quality gates**

Run: `npm test`

Run: `npm run typecheck`

Run: `npm run lint`

Run: `npm run test:e2e`

Expected: all tests and E2E PASS; TypeScript and Lint report 0 errors.

- [ ] **Step 4: Review and package**

Run a read-only code review against this plan, fix Critical/Important findings, rerun affected and full gates, then run `npm run package` if not already performed by the E2E pre-hook.

- [ ] **Step 5: Sync release facts**

Bump from the actual current `VERSION` at execution time using a backward-compatible minor version. CHANGELOG records data-loss prevention, dated backfill, feedback freshness and compatibility. PROJECT_STATUS only claims verified counts and keeps real-user usability validation pending.

- [ ] **Step 6: Commit and integrate**

Use the latest CHANGELOG heading for the final local commit, merge the feature branch into current main without overwriting concurrent work, rerun the main-branch gates, remove only the owned worktree, and do not push.
