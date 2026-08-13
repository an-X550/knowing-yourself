# 知己任务型首页与体验收敛实施计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 用一个确定性“建议下一步”和三个低权重入口替代模块堆叠感，并在不改后端的前提下把一级导航收敛为开始、日志、复盘、项目、设置。

**Architecture:** Renderer 新增无副作用的下一步规则和带短生命周期意图的导航契约；开始页只读取 `useAppData` 已加载的数据并导航，业务操作仍由日志、复盘、项目页面承担。原历史阅读组件按允许类型复用到日志页和复盘页，Main Process、Preload、IPC、本地文件和密钥机制保持不变。

**Tech Stack:** Electron 43、React 19、TypeScript 5.9、Vitest、Testing Library、Playwright、现有 CSS 变量与本地 SVG。

## Global Constraints

- 一级导航固定为开始、日志、复盘、项目、设置五项。
- 开始页只有一个 primary 操作和三个低权重能力入口。
- 下一步规则只读取本地日志与复盘，不调用 AI。
- 周末定义为星期六或星期日；周报门槛为本周至少 3 篇日志；已有当前周报时不得重复推荐。
- 不增加 Main Process、Preload 或 IPC 接口，不引入依赖或全局状态库。
- 不实现行动跟踪、聊天入口、统计图、年报、人生设计、主题思考或装饰动画。
- 保留未配置 AI 时仍可保存日志、生成结果原位显示以及本地数据安全边界。
- 3–5 位陌生用户的 10 秒理解测试属于发布后的人工验证门；本轮只交付任务脚本并在状态中保留待验证，不得用组件测试或 E2E 冒充完成。
- 不修改或提交工作区中与本任务无关的未跟踪文件。

---

## 文件结构

- Create `apps/zhiji-desktop/src/renderer/domain/next-step.ts`：纯函数计算建议类型、原因和导航目标。
- Modify `apps/zhiji-desktop/src/renderer/app/navigation.ts`：定义五个页面与类型化导航意图。
- Create `apps/zhiji-desktop/src/renderer/pages/start-page.tsx`：渲染唯一建议和三个次级入口。
- Modify `apps/zhiji-desktop/src/renderer/app/app.tsx`：持有导航目标、消费意图并组合页面。
- Modify `apps/zhiji-desktop/src/renderer/app/app-shell.tsx`：呈现新导航与低频设置入口。
- Modify `apps/zhiji-desktop/src/renderer/pages/today-page.tsx`：演进为日志任务页，接受日志意图并内嵌日志历史。
- Modify `apps/zhiji-desktop/src/renderer/pages/reviews-page.tsx`：接受复盘意图并内嵌复盘历史。
- Modify `apps/zhiji-desktop/src/renderer/pages/history-page.tsx`：变为可按允许类型复用的 `RecordBrowser`，保留安全正文阅读。
- Modify `apps/zhiji-desktop/src/renderer/features/history/history-filter.tsx`：只展示调用方允许的记录类型。
- Modify `apps/zhiji-desktop/src/renderer/pages/projects-page.tsx`：携带项目 ID 发起复盘并修正术语。
- Modify `apps/zhiji-desktop/src/renderer/pages/settings-page.tsx`：统一页面标题和渐进披露层级。
- Modify `apps/zhiji-desktop/src/index.css`：实现克制的开始页、分段阅读和 150–200ms 状态过渡。
- Modify `apps/zhiji-desktop/e2e/desktop.spec.ts`：验证开始页建议随日志保存更新。
- Modify unit tests under `apps/zhiji-desktop/tests/unit/`：覆盖规则、导航、历史归并和项目上下文。
- Modify `VERSION`, `CHANGELOG.md`, `PROJECT_STATUS.md`, `apps/zhiji-desktop/README.md`：完成后同步已实现事实。

### Task 1: 确定性下一步规则与导航契约

**Files:**
- Create: `apps/zhiji-desktop/src/renderer/domain/next-step.ts`
- Create: `apps/zhiji-desktop/tests/unit/next-step.test.ts`
- Modify: `apps/zhiji-desktop/src/renderer/app/navigation.ts`
- Modify: `apps/zhiji-desktop/tests/unit/app-shell.test.tsx`

**Interfaces:**
- Produces: `NavigationTarget = { view: AppView; intent?: NavigationIntent }`
- Produces: `resolveNextStep(input: { today: string; dayOfWeek: number; journals: Journal[]; reviews: Review[] }): NextStep`
- Produces: `NextStep = { kind: 'write-journal' | 'generate-daily' | 'weekly-review' | 'recent-records'; title: string; reason: string; target: NavigationTarget }`

- [ ] **Step 1: 写下一步规则的失败测试**

覆盖无今日日志、已有日志无日反馈、周末三篇日志、已有本周周报和普通日期回落五种输入，并断言建议类型与目标意图。

- [ ] **Step 2: 运行规则测试确认失败**

Run: `npm test -- --run tests/unit/next-step.test.ts`

Expected: FAIL，提示 `next-step` 模块不存在。

- [ ] **Step 3: 最小实现规则与周区间计算**

实现 ISO 周一开始、周日结束的本地日期字符串比较；日反馈必须为 `type === 'daily'` 且 `sourceIds` 包含今日日志 ID；当前周报必须覆盖本周起止日期。

- [ ] **Step 4: 写导航契约失败测试并修改五项导航**

断言导航标签严格等于开始、日志、复盘、项目、设置，删除 `history` AppView；导航意图联合类型包含 `journal.compose`、`journal.generate-daily`、`review.weekly`、`review.project`、`records.journals`。

- [ ] **Step 5: 运行规则和应用壳测试**

Run: `npm test -- --run tests/unit/next-step.test.ts tests/unit/app-shell.test.tsx`

Expected: PASS。

- [ ] **Step 6: 提交本批**

```powershell
git add apps/zhiji-desktop/src/renderer/domain/next-step.ts apps/zhiji-desktop/src/renderer/app/navigation.ts apps/zhiji-desktop/tests/unit/next-step.test.ts apps/zhiji-desktop/tests/unit/app-shell.test.tsx
git commit -m "feat(desktop): define task navigation rules"
```

### Task 2: 开始页与单一主建议

**Files:**
- Create: `apps/zhiji-desktop/src/renderer/pages/start-page.tsx`
- Create: `apps/zhiji-desktop/tests/unit/start-page.test.tsx`
- Modify: `apps/zhiji-desktop/src/renderer/app/app.tsx`
- Modify: `apps/zhiji-desktop/src/renderer/app/app-shell.tsx`
- Modify: `apps/zhiji-desktop/tests/unit/app.test.tsx`
- Modify: `apps/zhiji-desktop/src/index.css`

**Interfaces:**
- Consumes: `resolveNextStep` and `NavigationTarget` from Task 1.
- Produces: `StartPage({ journals, reviews, hasApiKey, onNavigate })`.
- Produces: `App` navigation state storing `NavigationTarget`, defaulting to `{ view: 'start' }`.

- [ ] **Step 1: 写开始页失败测试**

断言页面只有一个 primary 按钮；无日志时显示“写下今天的经历”和原因；另有做复盘、查看记录、管理项目三个次级按钮，分别发出 `reviews`、`records.journals`、`projects` 目标。

- [ ] **Step 2: 运行开始页测试确认失败**

Run: `npm test -- --run tests/unit/start-page.test.tsx`

Expected: FAIL，提示 `start-page` 不存在。

- [ ] **Step 3: 实现开始页并接入 App**

开始页仅调用 `onNavigate`；`App` 默认打开开始页，业务页面收到对应意图。AppShell 的数据状态继续进入设置，侧栏不新增第六项。

- [ ] **Step 4: 收敛开始页视觉**

新增 `.start-page`、`.next-step-card`、`.capability-links`，只让建议按钮使用 `--brand`；移除壳层的大面积深绿依赖，使用中性侧栏和低对比选中态；保留可访问焦点和 reduced motion。

- [ ] **Step 5: 更新 App/AppShell 测试并运行**

Run: `npm test -- --run tests/unit/start-page.test.tsx tests/unit/app.test.tsx tests/unit/app-shell.test.tsx`

Expected: PASS，且 App 首屏为“开始”。

- [ ] **Step 6: 提交本批**

```powershell
git add apps/zhiji-desktop/src/renderer/pages/start-page.tsx apps/zhiji-desktop/src/renderer/app/app.tsx apps/zhiji-desktop/src/renderer/app/app-shell.tsx apps/zhiji-desktop/src/index.css apps/zhiji-desktop/tests/unit/start-page.test.tsx apps/zhiji-desktop/tests/unit/app.test.tsx apps/zhiji-desktop/tests/unit/app-shell.test.tsx
git commit -m "feat(desktop): add task-driven start page"
```

### Task 3: 日志与复盘归并各自历史

**Files:**
- Modify: `apps/zhiji-desktop/src/renderer/pages/history-page.tsx`
- Modify: `apps/zhiji-desktop/src/renderer/features/history/history-filter.tsx`
- Modify: `apps/zhiji-desktop/src/renderer/pages/today-page.tsx`
- Modify: `apps/zhiji-desktop/src/renderer/pages/reviews-page.tsx`
- Modify: `apps/zhiji-desktop/tests/unit/history-page.test.tsx`
- Modify: `apps/zhiji-desktop/tests/unit/today-page.test.tsx`
- Modify: `apps/zhiji-desktop/tests/unit/reviews-page.test.tsx`
- Modify: `apps/zhiji-desktop/src/index.css`

**Interfaces:**
- Produces: `RecordBrowser({ journals, reviews, projects, allowedKinds, title?, description? })`.
- Consumes: `NavigationIntent`；日志页支持 `journal.compose`、`journal.generate-daily`、`records.journals`，复盘页支持 `review.weekly` 和 `review.project`。

- [ ] **Step 1: 写分流历史失败测试**

断言 `allowedKinds={['journal']}` 只呈现日志选项和正文；复盘允许 `daily/weekly/monthly/project` 且不出现原始日志；搜索与项目筛选仍有效。

- [ ] **Step 2: 运行历史测试确认失败**

Run: `npm test -- --run tests/unit/history-page.test.tsx`

Expected: FAIL，因为现组件没有 `allowedKinds`。

- [ ] **Step 3: 提取可复用 RecordBrowser**

保留 `buildHistoryItems` 和 `HistoryReader`，在构建列表后先按 `allowedKinds` 限制，再应用用户筛选；类型下拉只渲染允许类型，单一允许类型时隐藏类型选择。

- [ ] **Step 4: 写日志/复盘意图与历史归并失败测试**

日志页 `records.journals` 时可看到过去日志，`journal.compose` 聚焦编辑器，`journal.generate-daily` 保持今日日志并让生成按钮成为主操作；复盘页 `review.weekly` 默认展开本周设置，`review.project` 自动选择项目；两页都提供各自历史的次级入口。

- [ ] **Step 5: 最小实现两页归并**

TodayPage 增加 `intent` 和内嵌日志浏览；ReviewsPage 增加 `reviews`、`intent` 和复盘浏览。历史浏览与创作/生成使用页面内分段按钮，不增加一级导航。

- [ ] **Step 6: 运行页面测试**

Run: `npm test -- --run tests/unit/history-page.test.tsx tests/unit/today-page.test.tsx tests/unit/reviews-page.test.tsx`

Expected: PASS。

- [ ] **Step 7: 提交本批**

```powershell
git add apps/zhiji-desktop/src/renderer/pages/history-page.tsx apps/zhiji-desktop/src/renderer/features/history/history-filter.tsx apps/zhiji-desktop/src/renderer/pages/today-page.tsx apps/zhiji-desktop/src/renderer/pages/reviews-page.tsx apps/zhiji-desktop/src/index.css apps/zhiji-desktop/tests/unit/history-page.test.tsx apps/zhiji-desktop/tests/unit/today-page.test.tsx apps/zhiji-desktop/tests/unit/reviews-page.test.tsx
git commit -m "refactor(desktop): place history within user tasks"
```

### Task 4: 项目上下文、设置层级和全闭环验收

**Files:**
- Modify: `apps/zhiji-desktop/src/renderer/pages/projects-page.tsx`
- Modify: `apps/zhiji-desktop/src/renderer/pages/settings-page.tsx`
- Modify: `apps/zhiji-desktop/tests/unit/projects-page.test.tsx`
- Modify: `apps/zhiji-desktop/tests/unit/settings-page.test.tsx`
- Modify: `apps/zhiji-desktop/e2e/desktop.spec.ts`
- Modify: `apps/zhiji-desktop/README.md`
- Modify: `PROJECT_STATUS.md`
- Modify: `CHANGELOG.md`
- Modify: `VERSION`

**Interfaces:**
- Consumes: `NavigationTarget` from Task 1.
- Produces: 项目页调用 `onNavigate({ view: 'reviews', intent: { type: 'review.project', projectId } })`。

- [ ] **Step 1: 写项目上下文和设置标题失败测试**

断言项目页标题为“项目与关联日志”，发起复盘携带选中项目 ID；设置页主标题为“设置”，并保留 AI 服务、本地数据、个人背景三分区。

- [ ] **Step 2: 实现术语和上下文跳转**

仅修改 Renderer 文案和导航目标；不改变项目、设置、数据或凭据接口。

- [ ] **Step 3: 更新 E2E 为任务型主链**

验证空数据开始页建议写日志；创建项目后从开始进入日志并保存；返回开始页后建议更新为生成今日反馈；从日志历史读到本地正文。Fake AI 不可用时不强行覆盖生成成功，单元测试负责该规则分支。

- [ ] **Step 4: 运行完整客户端验证**

Run: `npm test`

Expected: 全部测试通过。

Run: `npm run typecheck`

Expected: 退出码 0。

Run: `npm run lint`

Expected: 0 errors；既有 warnings 可记录但不得增加新的高风险问题。

Run: `npm run test:e2e`

Expected: Electron E2E 全部通过，使用隔离临时数据目录。

- [ ] **Step 5: 同步发布事实**

将版本从 `1.18.0` 升至 `1.19.0`；CHANGELOG 记录任务型首页、历史归并与透明推荐；PROJECT_STATUS 和客户端 README 只陈述已通过验证的事实，不声称陌生用户 10 秒测试已完成。

在客户端 README 追加四项人工任务脚本：开始写日志、生成今日反馈、寻找周复盘、指出数据位置；PROJECT_STATUS 将 3–5 位目标用户验证列为待办。

- [ ] **Step 6: 治理与差异检查**

Run: `git diff --check`

Expected: 无错误。

核对 `VERSION` 与 `PROJECT_STATUS.md` 一致，确认两份无关未跟踪文档未暂存。

- [ ] **Step 7: 提交最终批次**

从 CHANGELOG 最新标题提取提交信息，仅暂存本任务文件并提交；不推送远程。
