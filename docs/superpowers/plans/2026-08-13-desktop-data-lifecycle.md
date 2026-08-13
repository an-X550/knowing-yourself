# 知己 Windows 客户端数据生命周期实施计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 补齐日志、复盘、项目和 AI 凭证必要的纠错与删除路径，同时保持本地引用关系和原生交互简洁。

**Architecture:** Renderer 只提交稳定 ID 和表单数据；Preload 暴露最小具名 IPC；Main Process 仓储负责名称约束和真实文件定位，Electron `shell.trashItem` 负责可恢复删除。已有复盘作为历史快照保留，不做级联改写。

**Tech Stack:** Electron 43、React 19、TypeScript 5.9、Zod 4、Vitest、Testing Library、Playwright、原生 CSS。

## Global Constraints

- 所有删除进入 Windows 回收站，不使用永久删除。
- 不级联删除或自动改写日志、项目关联和复盘正文。
- 不新增 UI 框架或运行时依赖。
- 每个行为先写失败测试并确认预期失败，再写最小实现。
- `.claude/` 产品逻辑保持不变；本次只修改 Windows 客户端及发布事实文档。

---

### Task 1: 日志与复盘安全删除

**Files:**
- Modify: `apps/zhiji-desktop/src/main-process/infrastructure/markdown/journal-repository.ts`
- Modify: `apps/zhiji-desktop/src/main-process/infrastructure/markdown/review-repository.ts`
- Modify: `apps/zhiji-desktop/src/shared/contracts/desktop-api.ts`
- Modify: `apps/zhiji-desktop/src/preload.ts`
- Modify: `apps/zhiji-desktop/src/main-process/ipc/register-handlers.ts`
- Modify: `apps/zhiji-desktop/src/main-process/bootstrap.ts`
- Modify: `apps/zhiji-desktop/src/renderer/features/history/history-reader.tsx`
- Modify: `apps/zhiji-desktop/src/renderer/pages/history-page.tsx`
- Modify: `apps/zhiji-desktop/src/renderer/pages/today-page.tsx`
- Modify: `apps/zhiji-desktop/src/renderer/pages/reviews-page.tsx`
- Test: `apps/zhiji-desktop/tests/integration/markdown-repository.test.ts`
- Test: `apps/zhiji-desktop/tests/unit/today-page.test.tsx`
- Test: `apps/zhiji-desktop/tests/unit/reviews-page.test.tsx`

**Interfaces:**
- Produces: `journals.delete(id): Promise<void>`、`reviews.delete(id): Promise<void>`，内部只向注入的 `trashItem(path)` 传解析后的真实路径。

- [ ] 写仓储和页面失败测试：稳定 ID 定位文件、确认后调用删除、删除后刷新、其他实体不被调用。
- [ ] 运行目标测试，确认因接口或按钮不存在而失败。
- [ ] 实现仓储、IPC、Preload、确认 UI 和刷新逻辑。
- [ ] 运行目标测试并确认通过。

### Task 2: 项目完整安全生命周期

**Files:**
- Modify: `apps/zhiji-desktop/src/main-process/infrastructure/markdown/project-repository.ts`
- Modify: `apps/zhiji-desktop/src/shared/schemas/ipc.ts`
- Modify: `apps/zhiji-desktop/src/shared/contracts/desktop-api.ts`
- Modify: `apps/zhiji-desktop/src/preload.ts`
- Modify: `apps/zhiji-desktop/src/main-process/ipc/register-handlers.ts`
- Modify: `apps/zhiji-desktop/src/main-process/bootstrap.ts`
- Modify: `apps/zhiji-desktop/src/renderer/features/projects/project-form.tsx`
- Modify: `apps/zhiji-desktop/src/renderer/pages/projects-page.tsx`
- Test: `apps/zhiji-desktop/tests/integration/markdown-repository.test.ts`
- Test: `apps/zhiji-desktop/tests/unit/ipc-schema.test.ts`
- Test: `apps/zhiji-desktop/tests/unit/projects-page.test.tsx`

**Interfaces:**
- Produces: `projects.rename({id,name})`、`projects.restore(id)`、`projects.delete(id)`；删除 handler 在 Main Process 检查 `journals.list()` 中无项目引用。

- [ ] 写失败测试：忽略大小写/空格的全局重名、重命名、恢复、空项目删除、有关联日志拒绝。
- [ ] 运行目标测试，确认失败原因对应缺失行为。
- [ ] 实现 Zod 契约、仓储方法、IPC/Preload 和项目页操作。
- [ ] 运行目标测试并确认通过。

### Task 3: API Key 清除与原生下拉统一

**Files:**
- Modify: `apps/zhiji-desktop/src/main-process/application/configure-ai.ts`
- Modify: `apps/zhiji-desktop/src/shared/contracts/desktop-api.ts`
- Modify: `apps/zhiji-desktop/src/preload.ts`
- Modify: `apps/zhiji-desktop/src/main-process/ipc/register-handlers.ts`
- Modify: `apps/zhiji-desktop/src/renderer/pages/settings-page.tsx`
- Modify: `apps/zhiji-desktop/src/renderer/styles.css`
- Test: `apps/zhiji-desktop/tests/unit/settings-page.test.tsx`
- Test: `apps/zhiji-desktop/tests/integration/credential-store.test.ts`

**Interfaces:**
- Produces: `settings.clearApiKey(): Promise<PublicProviderConfig>`，删除当前公开配置所选服务商的凭证。

- [ ] 写设置页失败测试：确认后清除、刷新全局状态、显示成功反馈。
- [ ] 运行测试确认因接口或按钮不存在而失败。
- [ ] 实现 Main/Preload/Renderer 链路和全局 `select` CSS；不新增组件库。
- [ ] 运行设置和渲染测试并确认通过。

### Task 4: 集中验证与发布同步

**Files:**
- Modify: `apps/zhiji-desktop/README.md`
- Modify: `PROJECT_STATUS.md`
- Modify: `CHANGELOG.md`
- Modify: `VERSION`

**Interfaces:**
- Consumes: Tasks 1–3 的全部公开行为。

- [ ] 运行 `npm test`、`npm run typecheck`、`npm run lint`。
- [ ] 运行 `npm run test:e2e` 和 `npm run package`，关闭锁定打包目录的本项目进程后再执行。
- [ ] 更新客户端说明、测试数量、版本、状态和一条合并 CHANGELOG。
- [ ] 运行版本一致性与 `git diff --check`。
- [ ] 本地提交并确认工作区干净；不推送远端。
