# 知己桌面端核心能力对齐 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 在不增加一级导航和外部依赖的前提下，让 Windows 客户端承接 Skill 的可信日反馈、个人上下文、日志教练、年度回顾与快速方向校准。

**Architecture:** 继续使用 Electron + React + TypeScript + Zod + 本地 Markdown；扩展 Review 领域类型，并新增独立的深度分析应用服务。所有新能力复用现有预览令牌、AI Provider、ReviewRepository 和渐进展开式“复盘”页面。

**Tech Stack:** Electron Forge、React 19、TypeScript、Zod 4、Vitest、Testing Library、Playwright。

## Global Constraints

- 不修改 `.claude/` 产品运行逻辑。
- 不实现飞书、滴答清单、独立假说台账、主题库和旧格式迁移器。
- 不新增一级导航、数据库、云服务或 UI 依赖。
- 所有生成必须先预览，所有资料只在用户开启 AI 使用开关后注入。
- 使用 TDD；每个任务完成后运行对应测试，本轮结束统一提交。

---

### Task 1: 扩展领域契约与深度分析材料选择

**Files:**
- Modify: `apps/zhiji-desktop/src/shared/schemas/domain.ts`
- Modify: `apps/zhiji-desktop/src/shared/schemas/ipc.ts`
- Modify: `apps/zhiji-desktop/src/shared/contracts/desktop-api.ts`
- Create: `apps/zhiji-desktop/src/main-process/domain/insight-materials.ts`
- Test: `apps/zhiji-desktop/tests/unit/domain-schema.test.ts`
- Test: `apps/zhiji-desktop/tests/unit/ipc-schema.test.ts`
- Create: `apps/zhiji-desktop/tests/unit/insight-materials.test.ts`

**Interfaces:**
- Produces: `InsightReviewType`, `InsightReviewPreviewInput`, `InsightReviewGenerateInput`, `selectInsightMaterials(input, journals, reviews)`。

- [ ] 为 `coach | yearly | life-design` 写失败的 schema 和材料门槛测试：教练至少 3 篇日志，年度至少 6 份月报，方向校准优先高层复盘并限制材料数量。
- [ ] 运行 `npm test -- --run tests/unit/domain-schema.test.ts tests/unit/ipc-schema.test.ts tests/unit/insight-materials.test.ts`，确认新断言失败。
- [ ] 最小扩展 Review 枚举、严格 IPC schema 与纯材料选择函数。
- [ ] 重跑同一命令，确认通过。

### Task 2: 让个人资料开关和每日闭环真正生效

**Files:**
- Modify: `apps/zhiji-desktop/src/main-process/application/generate-daily-review.ts`
- Modify: `apps/zhiji-desktop/src/main-process/application/generate-periodic-review.ts`
- Modify: `apps/zhiji-desktop/src/main-process/prompts/daily-review-v1.ts`
- Modify: `apps/zhiji-desktop/src/main-process/bootstrap.ts`
- Modify: `apps/zhiji-desktop/src/renderer/pages/settings-page.tsx`
- Test: `apps/zhiji-desktop/tests/integration/generate-daily-review.test.ts`
- Test: `apps/zhiji-desktop/tests/integration/generate-periodic-review.test.ts`
- Test: `apps/zhiji-desktop/tests/unit/settings-page.test.tsx`

**Interfaces:**
- Consumes: existing `MarkdownProfileRepository.get()`。
- Produces: model user payload `{ profile?: string, context/materials: ... }`，`renderDailyReview()` 的可见上一行动章节。

- [ ] 写失败测试：开关开启时包含 profile、关闭时不包含；上一行动非空时正文渲染状态与证据。
- [ ] 运行三个目标测试，确认断言失败。
- [ ] 将可选 ProfileRepository 注入两个生成服务，构造结构化请求；更新每日提示词与渲染；修正设置文案。
- [ ] 重跑目标测试，确认通过且旧测试保持兼容。

### Task 3: 实现复用式深度分析服务

**Files:**
- Create: `apps/zhiji-desktop/src/main-process/prompts/insight-review-prompts.ts`
- Create: `apps/zhiji-desktop/src/main-process/application/generate-insight-review.ts`
- Modify: `apps/zhiji-desktop/src/main-process/bootstrap.ts`
- Modify: `apps/zhiji-desktop/src/main-process/ipc/register-handlers.ts`
- Modify: `apps/zhiji-desktop/src/preload.ts`
- Create: `apps/zhiji-desktop/tests/integration/generate-insight-review.test.ts`

**Interfaces:**
- Consumes: `selectInsightMaterials`、Review/Journal/Profile repositories、ProviderPort、ReviewTaskManager。
- Produces: `preview(input)` 与 `execute({...input, previewToken, model})`，保存扩展 Review。

- [ ] 写失败集成测试：必须预览、材料改变令牌失效、正确 prompt/version、profile 条件注入、保存与取消。
- [ ] 运行 `npm test -- --run tests/integration/generate-insight-review.test.ts`，确认模块缺失而失败。
- [ ] 实现三套克制的系统提示词和单一生成服务，并连接 bootstrap、IPC 与 preload。
- [ ] 重跑测试，确认通过。

### Task 4: 在现有复盘页做渐进展开入口

**Files:**
- Create: `apps/zhiji-desktop/src/renderer/features/reviews/insight-tools.tsx`
- Modify: `apps/zhiji-desktop/src/renderer/pages/reviews-page.tsx`
- Modify: `apps/zhiji-desktop/src/renderer/domain/history-items.ts`
- Modify: `apps/zhiji-desktop/src/renderer/pages/history-page.tsx`
- Modify: `apps/zhiji-desktop/src/index.css`
- Test: `apps/zhiji-desktop/tests/unit/reviews-page.test.tsx`
- Test: `apps/zhiji-desktop/tests/unit/history-page.test.tsx`

**Interfaces:**
- Consumes: `window.zhiji.reviews.previewInsight/generateInsight`。
- Produces: 默认折叠的“更多洞察”，三种工具共用日期、主题（仅方向校准）、预览和生成流程。

- [ ] 写失败 UI 测试：默认不出现三张工具卡；点击后出现；选择工具后调用正确 API；新类型可在历史查看。
- [ ] 运行两个目标测试，确认失败。
- [ ] 实现渐进展开组件及页面状态分流，复用 MaterialPreview、Field、Button 与 StatusBanner。
- [ ] 重跑目标测试，确认通过。

### Task 5: 首页只给一个更聪明的下一步

**Files:**
- Modify: `apps/zhiji-desktop/src/renderer/domain/next-step.ts`
- Modify: `apps/zhiji-desktop/src/renderer/app/navigation.ts`
- Modify: `apps/zhiji-desktop/src/renderer/pages/start-page.tsx`
- Modify: `apps/zhiji-desktop/src/renderer/pages/reviews-page.tsx`
- Test: `apps/zhiji-desktop/tests/unit/next-step.test.ts`
- Test: `apps/zhiji-desktop/tests/unit/start-page.test.tsx`

**Interfaces:**
- Produces: `review.monthly | review.yearly | review.coach` 意图；原有写日志、日反馈、周复盘优先级不变。

- [ ] 写失败测试：月初且有足够周报时建议月报；年初且有 6 份月报时建议年度；低质量日志积累且高频任务完成时建议教练；任何时刻只返回一个建议。
- [ ] 运行两个目标测试，确认失败。
- [ ] 按频率和材料门槛扩展纯决策函数、导航意图与页面接收逻辑。
- [ ] 重跑目标测试，确认通过。

### Task 6: 全量验证、文档同步与本地提交

**Files:**
- Modify: `README.md`
- Modify: `PROJECT_STATUS.md`
- Modify: `CHANGELOG.md`
- Modify: `docs/archive/2026-08-13-windows-desktop-product-audit.md`
- Modify: `apps/zhiji-desktop/e2e/app.spec.ts`（仅当现有断言需要适配）

**Interfaces:**
- Produces: 可复核的产品事实、安装路径和本地提交。

- [ ] 运行 `npm test`、`npm run typecheck`、`npm run lint`，修复由本轮引入的问题。
- [ ] 运行 `npm run test:e2e`，确认桌面主闭环仍可操作。
- [ ] 使用既有 D 盘依赖和阿里系 Electron 镜像运行 `npm run package`，确认 `out/知己-win32-x64/知己.exe` 存在且主入口完整。
- [ ] 更新四份文档，只记录已验证事实、明确仍暂缓能力，并同步版本号。
- [ ] 检查 `git diff --check`、工作树范围和全量测试证据，按 CHANGELOG 生成单一本地提交。

## Self-Review

- 规格中的可信日反馈、资料注入、三种深度工具、渐进展开、首页建议、历史/删除/备份兼容均有对应任务。
- 计划没有引入飞书、滴答、数据库、云同步、独立台账或新一级导航。
- 所有跨任务类型名称统一为 `coach | yearly | life-design`；IPC 统一为 `previewInsight` / `generateInsight`。
- 每项新增能力都具有失败测试、最小实现和可观察验收。

