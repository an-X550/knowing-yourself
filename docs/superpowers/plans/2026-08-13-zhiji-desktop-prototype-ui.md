# 知己 Windows 客户端原型界面 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 将已确认的 HTML 交互原型转化为连接真实本地数据、具备完整异步状态和可访问性的 React Windows 客户端界面。

**Architecture:** 保持现有 Electron Main/Preload/Renderer 安全边界，只重构 Renderer。用无业务依赖的 UI primitives、统一 AppShell 和按页面拆分的状态组件替换当前单体 `App`；所有正式数据继续从 `window.zhiji` 具名 IPC 读取。

**Tech Stack:** React 19、TypeScript、原生 CSS variables、Vitest、Testing Library；不新增 UI 或图标依赖。

## Global Constraints

- 视觉与布局以 `C:\Users\panda\.codex\visualizations\2026\08\12\019ff702-7267-7170-a35a-4508132fe79d\zhiji-windows-prototype.html` 为基线。
- 真实数据与安全边界优先于原型演示内容；不显示虚假统计、虚假自动保存或占位 API Key。
- Renderer 不使用 Node、文件系统或 `fetch`；所有业务动作只调用 `window.zhiji`。
- 不新增大型 UI、图标、动画或字体依赖；图标使用本地 SVG React 组件。
- 每个异步主操作必须有 loading/success/error，失败时保留用户输入。
- 支持键盘焦点、`aria-live`、Modal Escape 和 `prefers-reduced-motion`。
- 900px 以下收窄侧栏，最低支持现有窗口 `minWidth: 900`。

---

### Task 1: 设计变量、UI primitives 与应用壳

**Files:**
- Create: `apps/zhiji-desktop/src/renderer/components/icons.tsx`
- Create: `apps/zhiji-desktop/src/renderer/components/button.tsx`
- Create: `apps/zhiji-desktop/src/renderer/components/page-header.tsx`
- Create: `apps/zhiji-desktop/src/renderer/components/status-banner.tsx`
- Create: `apps/zhiji-desktop/src/renderer/components/empty-state.tsx`
- Create: `apps/zhiji-desktop/src/renderer/app/app-shell.tsx`
- Create: `apps/zhiji-desktop/src/renderer/app/navigation.ts`
- Modify: `apps/zhiji-desktop/src/index.css`
- Test: `apps/zhiji-desktop/tests/unit/app-shell.test.tsx`

**Interfaces:**
- Produces: `type AppView = 'today' | 'reviews' | 'projects' | 'history' | 'settings'`.
- Produces: `AppShell({ view, onNavigate, connectionReady, children })`.
- Produces: `Button`, `PageHeader`, `StatusBanner`, `EmptyState` shared components.

- [ ] **Step 1: Write the failing navigation test**

Render `AppShell` at `view="reviews"`; assert five navigation buttons exist, the reviews button has `aria-current="page"`, clicking history invokes `onNavigate('history')`, and the privacy copy says data stays local.

- [ ] **Step 2: Run test to verify it fails**

Run: `npm test -- --run tests/unit/app-shell.test.tsx`
Expected: FAIL because `app-shell` does not exist.

- [ ] **Step 3: Implement primitives and shell**

Create focused components with typed props. `icons.tsx` exports five inline 20px SVG icons with `aria-hidden`. `Button` supports `primary | secondary | ghost | danger`, loading text and disabled state. `StatusBanner` uses `role="status"` and `aria-live="polite"`. `AppShell` reproduces prototype sidebar/header and renders children in a scrollable view.

- [ ] **Step 4: Replace CSS with formatted design system**

Define exact prototype variables `--bg`, `--panel`, `--ink`, `--muted`, `--line`, `--brand`, `--brand-soft`, `--warm`, `--danger`, `--shadow`; add component classes, focus-visible rings, 900px compact sidebar and reduced-motion rule. Do not minify the source CSS.

- [ ] **Step 5: Verify and commit**

Run: `npm test -- --run tests/unit/app-shell.test.tsx && npm run typecheck`
Expected: PASS.

Commit: `feat(desktop): add prototype-based design system`

---

### Task 2: 真实数据加载与今天页闭环

**Files:**
- Create: `apps/zhiji-desktop/src/renderer/hooks/use-app-data.ts`
- Create: `apps/zhiji-desktop/src/renderer/pages/today-page.tsx`
- Create: `apps/zhiji-desktop/src/renderer/components/field.tsx`
- Modify: `apps/zhiji-desktop/src/renderer/app/app.tsx`
- Test: `apps/zhiji-desktop/tests/unit/today-page.test.tsx`

**Interfaces:**
- Produces: `useAppData(): { journals, projects, reviews, settings, loading, error, refresh }`.
- Produces: `TodayPage({ journals, projects, reviews, onRefresh, onNavigate })`.

- [ ] **Step 1: Write failing Today page tests**

Mock `window.zhiji`: assert existing today journal loads into textarea; edited text survives a rejected save; save button reports “已保存到本机” only after resolution; generation is disabled without saved journal/body; recent records are limited to three; no “自动保存” copy exists.

- [ ] **Step 2: Run and confirm failure**

Run: `npm test -- --run tests/unit/today-page.test.tsx`
Expected: FAIL because `today-page` does not exist.

- [ ] **Step 3: Implement data hook and Today page**

Load journals/projects/reviews/settings concurrently with `Promise.all`. Today page follows prototype two-column layout: editor on left; prior-action/weekly readiness on right using only real review counts. Save and generate retain body on failure, use `StatusBanner`, and disable duplicate requests.

- [ ] **Step 4: Reduce App to composition root**

`App` owns only active view and `useAppData`; render `AppShell` plus the selected page. Remove journal/project business logic from `app.tsx`.

- [ ] **Step 5: Verify and commit**

Run: `npm test -- --run tests/unit/today-page.test.tsx tests/unit/app-shell.test.tsx && npm run typecheck`
Expected: PASS.

Commit: `feat(desktop): rebuild today reflection workspace`

---

### Task 3: 三卡复盘流程与材料确认

**Files:**
- Modify: `apps/zhiji-desktop/src/renderer/pages/reviews-page.tsx`
- Create: `apps/zhiji-desktop/src/renderer/features/reviews/review-type-card.tsx`
- Create: `apps/zhiji-desktop/src/renderer/features/reviews/material-preview.tsx`
- Create: `apps/zhiji-desktop/src/renderer/utils/date-defaults.ts`
- Test: `apps/zhiji-desktop/tests/unit/reviews-page.test.tsx`

**Interfaces:**
- Produces: `getDefaultReviewRange(type, today)` using existing ISO week/month utilities or equivalent Renderer-safe pure functions.
- Produces: review cards and preview panel driven by real projects and IPC results.

- [ ] **Step 1: Write failing interaction tests**

Assert weekly/monthly/project cards render; selecting weekly provides Monday-Sunday range; project selection is visible only for project review; preview displays every returned source; changing a range invalidates the token and disables Generate; generation success offers a History navigation action.

- [ ] **Step 2: Run and confirm failure**

Run: `npm test -- --run tests/unit/reviews-page.test.tsx`
Expected: FAIL against the existing single-form page.

- [ ] **Step 3: Implement the four-stage flow**

Use prototype three-card entry, then an inline configuration card, material preview and status result. Keep API calls unchanged. Derive all counts from preview/projects; show no sample numbers.

- [ ] **Step 4: Verify and commit**

Run: `npm test -- --run tests/unit/reviews-page.test.tsx && npm run typecheck`
Expected: PASS.

Commit: `feat(desktop): refine periodic review interactions`

---

### Task 4: 项目管理 Modal 与项目详情

**Files:**
- Create: `apps/zhiji-desktop/src/renderer/pages/projects-page.tsx`
- Create: `apps/zhiji-desktop/src/renderer/components/modal.tsx`
- Create: `apps/zhiji-desktop/src/renderer/features/projects/project-form.tsx`
- Test: `apps/zhiji-desktop/tests/unit/projects-page.test.tsx`

**Interfaces:**
- Produces: `ProjectsPage({ projects, journals, onRefresh, onNavigate })`.
- Produces: accessible `Modal({ open, title, onClose, children })`.

- [ ] **Step 1: Write failing modal and project tests**

Assert New Project opens a dialog, input receives focus, empty submission is blocked, successful creation refreshes data, Escape closes the dialog, active project detail shows linked journal count/latest date, archive asks for inline confirmation and never calls journal delete.

- [ ] **Step 2: Run and confirm failure**

Run: `npm test -- --run tests/unit/projects-page.test.tsx`
Expected: FAIL because the page and Modal do not exist.

- [ ] **Step 3: Implement prototype project master-detail layout**

Left card lists active/archived projects; right card shows selected project metrics and a direct “发起项目复盘” navigation. Modal replaces `window.prompt`. Archive confirmation stays within selected project card.

- [ ] **Step 4: Verify and commit**

Run: `npm test -- --run tests/unit/projects-page.test.tsx && npm run typecheck`
Expected: PASS.

Commit: `feat(desktop): add polished project management`

---

### Task 5: 可筛选历史主从阅读器

**Files:**
- Modify: `apps/zhiji-desktop/src/renderer/pages/history-page.tsx`
- Create: `apps/zhiji-desktop/src/renderer/features/history/history-filter.tsx`
- Create: `apps/zhiji-desktop/src/renderer/features/history/history-reader.tsx`
- Create: `apps/zhiji-desktop/src/renderer/domain/history-items.ts`
- Test: `apps/zhiji-desktop/tests/unit/history-page.test.tsx`

**Interfaces:**
- Produces: `buildHistoryItems(journals, reviews, projects): HistoryItem[]`.
- Produces: filters for type, text and project without changing source data.

- [ ] **Step 1: Write failing history tests**

Assert journal/review records merge newest-first; type/text/project filters combine; selecting a list item opens its full body and source IDs; empty filters show `EmptyState`; user content is rendered as text rather than HTML.

- [ ] **Step 2: Run and confirm failure**

Run: `npm test -- --run tests/unit/history-page.test.tsx`
Expected: FAIL against the current flat history page.

- [ ] **Step 3: Implement master-detail history**

Use prototype list styling in a two-column layout. Preserve Markdown as safe pre-wrapped text for v1; do not add an HTML renderer. On compact width stack reader below list.

- [ ] **Step 4: Verify and commit**

Run: `npm test -- --run tests/unit/history-page.test.tsx && npm run typecheck`
Expected: PASS.

Commit: `feat(desktop): add searchable local history`

---

### Task 6: 设置卡片与完整界面回归

**Files:**
- Modify: `apps/zhiji-desktop/src/renderer/pages/settings-page.tsx`
- Create: `apps/zhiji-desktop/src/renderer/features/settings/provider-card.tsx`
- Modify: `apps/zhiji-desktop/src/renderer/app/app.tsx`
- Modify: `apps/zhiji-desktop/src/index.css`
- Test: `apps/zhiji-desktop/tests/unit/settings-page.test.tsx`
- Test: `apps/zhiji-desktop/tests/unit/app.test.tsx`

**Interfaces:**
- Consumes all page components and `useAppData`.
- Produces the complete five-page prototype-derived Renderer.

- [ ] **Step 1: Write failing settings and app tests**

Assert three provider cards, custom URL conditional field, saved-key badge without key value, separate test/save loading states, navigation across all five pages, initial-load error with Retry and no unhandled promise rejection.

- [ ] **Step 2: Run and confirm failure**

Run: `npm test -- --run tests/unit/settings-page.test.tsx tests/unit/app.test.tsx`
Expected: FAIL before refactor completion.

- [ ] **Step 3: Implement settings and final composition**

Match prototype settings cards while removing unavailable data buttons. Add HTTPS/local HTTP explanation. Ensure each page uses `PageHeader`, primitives and real data.

- [ ] **Step 4: Run complete verification**

Run:

```powershell
npm test
npm run typecheck
npm audit --omit=dev --audit-level=high
```

Expected: all tests pass, no type errors, zero high/critical production vulnerabilities.

- [ ] **Step 5: Rebuild Windows package without installing**

Run from D short-path junction with temporary `ELECTRON_MIRROR=https://npmmirror.com/mirrors/electron/`, D cache and D output. Expected: Squirrel installer succeeds; do not launch or install it.

- [ ] **Step 6: Commit**

Commit: `feat(desktop): complete prototype-driven interface`

## Plan Self-Review

- Spec coverage: app shell, prototype visual variables, five pages, true async states, accessibility and compact layout are each assigned to a task.
- Scope: ZIP transfer, E2E and streaming are intentionally separate follow-on plans because each is an independently reviewable subsystem.
- Security: no task adds Renderer file/network/key access or remote assets.
- Type consistency: all page inputs derive from shared `Journal`, `Review`, `Project`, public settings and the existing `window.zhiji` contract.
- No placeholder implementation steps remain; exact tests, commands and commit boundaries are defined.
