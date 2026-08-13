# Windows Desktop P0 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 让不使用 CLI、Skill 或 Agent 的 Windows 单用户能看见并带走本地数据，维护最小个人背景，并在当前页面完成日志与复盘反馈闭环。

**Architecture:** 保持 Electron + React + TypeScript 模块化单体。Renderer 只通过具名 Preload API 调用 Main Process；Main Process 独占文件系统、原生对话框和 Shell 权限；Markdown/JSON Repository 继续作为唯一数据实现。首轮不引入数据库、服务进程、目录迁移、合并恢复、诊断中心或新依赖。

**Tech Stack:** Electron 43、React 19、TypeScript 5.9、Zod 4、Vitest、Testing Library、Playwright、Markdown + YAML、JSON。

## Global Constraints

- 唯一代码工作区：`.worktrees/zhiji-windows-desktop-impl`，分支 `codex/zhiji-windows-desktop-impl`。
- 数据默认保存在 `%USERPROFILE%\Documents\知己`；测试继续使用 `ZHIJI_DATA_ROOT` 隔离目录。
- API Key 只保存在 Electron `userData` 的 Windows `safeStorage` 中，绝不进入数据备份和 Renderer 返回值。
- Profile 固定为 `profile/about-me.md`，字段仅含 `schemaVersion`、`body`、`enabledForAi`、`createdAt`、`updatedAt`。
- Profile P0 只提供显式存储和控制，不自动从日志推断，也不注入 AI Prompt。
- 备份 P0 仍只恢复到空目录；合并、冲突处理和运行中目录迁移不实现。
- 每个行为变更遵循 RED → GREEN；每个检查点只提交其相关文件。
- 不重新安装依赖；复用已链接到 D 盘的 `node_modules`。

---

### Task 1: 数据位置可见、可打开

**Files:**
- Create: `apps/zhiji-desktop/src/main-process/infrastructure/data-directory/data-directory-service.ts`
- Modify: `apps/zhiji-desktop/src/shared/contracts/desktop-api.ts`
- Modify: `apps/zhiji-desktop/src/preload.ts`
- Modify: `apps/zhiji-desktop/src/main-process/bootstrap.ts`
- Modify: `apps/zhiji-desktop/src/main-process/ipc/register-handlers.ts`
- Modify: `apps/zhiji-desktop/src/renderer/hooks/use-app-data.ts`
- Modify: `apps/zhiji-desktop/src/renderer/app/app.tsx`
- Modify: `apps/zhiji-desktop/src/renderer/app/app-shell.tsx`
- Modify: `apps/zhiji-desktop/src/renderer/pages/settings-page.tsx`
- Test: `apps/zhiji-desktop/tests/integration/data-directory-service.test.ts`
- Test: `apps/zhiji-desktop/tests/unit/app-shell.test.tsx`
- Test: `apps/zhiji-desktop/tests/unit/settings-page.test.tsx`

**Interfaces:**
- Produces: `DataDirectoryInfo { path, writable, fileCount, totalBytes, categories }`。
- Produces: `window.zhiji.dataDirectory.getInfo()` 与 `open()`；Renderer 不传任意路径。

- [ ] **Step 1: 写失败测试**

```ts
it('reports the actual root and portable data counts', async () => {
  const info = await new DataDirectoryService(root, async () => '').getInfo();
  expect(info).toMatchObject({ path: root, writable: true, fileCount: 2 });
});

it('opens only its configured root', async () => {
  const openPath = vi.fn(async () => '');
  await new DataDirectoryService(root, openPath).open();
  expect(openPath).toHaveBeenCalledWith(root);
});
```

- [ ] **Step 2: 运行定向测试，确认因接口不存在而失败**

Run: `npm test -- tests/integration/data-directory-service.test.ts tests/unit/app-shell.test.tsx tests/unit/settings-page.test.tsx`

- [ ] **Step 3: 最小实现服务、IPC、Preload 和 UI**

侧栏状态卡点击后进入设置；设置中的“数据与备份”显示完整绝对路径、可写状态、文件数量和“打开数据文件夹”。不实现目录选择或迁移。

- [ ] **Step 4: 运行定向测试和类型检查**

Run: `npm test -- tests/integration/data-directory-service.test.ts tests/unit/app-shell.test.tsx tests/unit/settings-page.test.tsx`

Run: `npm run typecheck`

- [ ] **Step 5: 提交检查点 1A**

```powershell
git add apps/zhiji-desktop/src apps/zhiji-desktop/tests
git commit -m "feat(desktop): expose local data location"
```

### Task 2: 最小个人背景与可验证备份

**Files:**
- Create: `apps/zhiji-desktop/src/main-process/infrastructure/markdown/profile-repository.ts`
- Create: `apps/zhiji-desktop/src/main-process/infrastructure/transfer/business-archive-validator.ts`
- Modify: `apps/zhiji-desktop/src/shared/schemas/domain.ts`
- Modify: `apps/zhiji-desktop/src/shared/schemas/ipc.ts`
- Modify: `apps/zhiji-desktop/src/shared/contracts/desktop-api.ts`
- Modify: `apps/zhiji-desktop/src/preload.ts`
- Modify: `apps/zhiji-desktop/src/main-process/bootstrap.ts`
- Modify: `apps/zhiji-desktop/src/main-process/ipc/register-handlers.ts`
- Modify: `apps/zhiji-desktop/src/main-process/infrastructure/markdown/journal-repository.ts`
- Modify: `apps/zhiji-desktop/src/main-process/infrastructure/markdown/review-repository.ts`
- Modify: `apps/zhiji-desktop/src/main-process/infrastructure/transfer/archive-manifest.ts`
- Modify: `apps/zhiji-desktop/src/main-process/infrastructure/transfer/data-transfer-service.ts`
- Modify: `apps/zhiji-desktop/src/renderer/pages/settings-page.tsx`
- Test: `apps/zhiji-desktop/tests/integration/profile-repository.test.ts`
- Test: `apps/zhiji-desktop/tests/integration/data-transfer.test.ts`
- Test: `apps/zhiji-desktop/tests/unit/settings-page.test.tsx`

**Interfaces:**
- Produces: `ProfileSchema`、`Profile`、`ProfileRepository.get/save/clear`。
- Produces: `window.zhiji.profile.get/save/clear`。
- Consumes: Journal、Review、Project、Profile 现有 Schema；备份预览和 staging 切换前复用同一校验器。

- [ ] **Step 1: 写 Profile Repository 失败测试**

```ts
it('round-trips one explicit profile file and clears it', async () => {
  const saved = await repository.save({ body: '我偏好先验证再扩展。', enabledForAi: false });
  expect(await repository.get()).toEqual(saved);
  await repository.clear();
  expect(await repository.get()).toBeNull();
});
```

- [ ] **Step 2: 写备份业务校验失败测试**

```ts
it('rejects a checksum-valid archive containing an invalid project', async () => {
  const preview = new DataTransferService(target, '1.0.0').preview(archive);
  await expect(preview).rejects.toThrow(/projects\/project_a1.json|项目/);
});

it('exports and restores profile but never credentials', async () => {
  expect(zip.getEntry('profile/about-me.md')).not.toBeNull();
  expect(zip.getEntries().map((entry) => entry.entryName).join('\n')).not.toMatch(/credential|api.?key/i);
});
```

- [ ] **Step 3: 运行定向测试，确认缺少 Profile 和业务校验而失败**

Run: `npm test -- tests/integration/profile-repository.test.ts tests/integration/data-transfer.test.ts tests/unit/settings-page.test.tsx`

- [ ] **Step 4: 实现最小 Profile、API 与设置区**

设置区只提供正文、`允许 AI 使用` 开关、保存和清空；开关先持久化但 P0 不消费。资料位置明确显示为 `<数据目录>\profile\about-me.md`，完整备份承担导入导出。

- [ ] **Step 5: 实现单一业务校验器并接入导出、预览和 staging**

校验器按路径调用现有 Zod Schema，并验证 Journal 的 `projectIds`、Review 的 `projectId/sourceIds` 指向包内对象；旧格式不猜测迁移，返回包含文件路径的可执行错误。

- [ ] **Step 6: 运行定向测试、全量测试和类型检查**

Run: `npm test -- tests/integration/profile-repository.test.ts tests/integration/data-transfer.test.ts tests/unit/settings-page.test.tsx`

Run: `npm test`

Run: `npm run typecheck`

- [ ] **Step 7: 提交检查点 1B 并集中复核检查点 1**

```powershell
git add apps/zhiji-desktop/src apps/zhiji-desktop/tests
git commit -m "feat(desktop): add portable personal profile"
```

检查：用户能在 10 秒内找到数据目录；Profile 文件与 UI 一致；有效备份可恢复；无效业务对象在写入前被拒绝；API Key 不在备份中。

### Task 3: 原位完成日反馈与周期复盘

**Files:**
- Modify: `apps/zhiji-desktop/src/renderer/pages/today-page.tsx`
- Modify: `apps/zhiji-desktop/src/renderer/pages/reviews-page.tsx`
- Modify: `apps/zhiji-desktop/src/renderer/app/app.tsx`
- Modify: `apps/zhiji-desktop/src/index.css`
- Test: `apps/zhiji-desktop/tests/unit/today-page.test.tsx`
- Test: `apps/zhiji-desktop/tests/unit/reviews-page.test.tsx`

**Interfaces:**
- Consumes: `reviews.generateDaily()` 与 `reviews.generatePeriodic()` 已返回的 `Review`，不新增后端调用。
- Produces: 页面内完整 Review 正文、历史入口；周/月默认日期隐藏，用户点“调整日期”后再显示。

- [ ] **Step 1: 写失败的交互测试**

```tsx
it('shows the generated daily review without forcing a history jump', async () => {
  vi.mocked(window.zhiji.reviews.generateDaily).mockResolvedValue(review);
  fireEvent.click(screen.getByRole('button', { name: '生成今日反馈' }));
  expect(await screen.findByText('今天最重要的反馈')).toBeInTheDocument();
});

it('keeps standard weekly dates collapsed and shows generated content inline', async () => {
  expect(screen.queryByLabelText('开始日期')).not.toBeInTheDocument();
  fireEvent.click(screen.getByRole('button', { name: '调整日期' }));
  expect(screen.getByLabelText('开始日期')).toBeInTheDocument();
  expect(await screen.findByText('本周有效行动')).toBeInTheDocument();
});
```

- [ ] **Step 2: 运行测试，确认当前只显示成功消息而失败**

Run: `npm test -- tests/unit/today-page.test.tsx tests/unit/reviews-page.test.tsx`

- [ ] **Step 3: 最小实现原位结果和渐进日期**

复用返回的 `Review` 保存页面状态；不引入富文本、Markdown 渲染库、流式输出或复杂缓存。AI 失败不清空草稿和已保存日志。

- [ ] **Step 4: 运行定向测试和类型检查**

Run: `npm test -- tests/unit/today-page.test.tsx tests/unit/reviews-page.test.tsx`

Run: `npm run typecheck`

- [ ] **Step 5: 提交并集中复核检查点 2**

```powershell
git add apps/zhiji-desktop/src/renderer apps/zhiji-desktop/src/index.css apps/zhiji-desktop/tests/unit
git commit -m "feat(desktop): keep review results in context"
```

检查：日志可不配 AI 单独保存；日反馈和周期复盘生成后无需跳页阅读；标准周/月日期不占默认界面；项目仍可补选范围。

### Task 4: 条件提示、真实 E2E 与治理收口

**Files:**
- Modify: `apps/zhiji-desktop/src/renderer/pages/today-page.tsx`
- Modify: `apps/zhiji-desktop/src/renderer/app/app.tsx`
- Modify: `apps/zhiji-desktop/e2e/desktop.spec.ts`
- Modify: `apps/zhiji-desktop/README.md`
- Modify: `PROJECT_STATUS.md`
- Modify: `CHANGELOG.md`
- Modify: `VERSION`

**Interfaces:**
- Consumes: `settings.hasApiKey`、`DataDirectoryInfo`、Profile 和现有 OpenAI-compatible Provider。
- Produces: 未配置 AI 时的一条非阻塞 CTA；Fake localhost OpenAI-compatible E2E。

- [ ] **Step 1: 写失败测试：未配 AI 仍可保存，并能从条件提示进入设置**

```tsx
expect(screen.getByText('先保存日志也可以')).toBeInTheDocument();
fireEvent.click(screen.getByRole('button', { name: '配置 AI' }));
expect(onNavigate).toHaveBeenCalledWith('settings');
```

- [ ] **Step 2: 最小实现条件提示**

今天页仅在 `hasApiKey=false` 时显示一条提示；不创建向导、步骤状态机或遮罩。数据路径保持侧栏和设置常驻可见，不再增加首次确认流程。

- [ ] **Step 3: 扩展 E2E 主路径**

在测试进程启动 localhost Fake AI，走设置配置自定义 OpenAI-compatible 接口，然后验证：打开数据位置入口可见、保存个人背景、新建项目、写日志、生成并原位阅读日反馈、生成周报。导出/空目录恢复继续由真实 ZIP 集成测试覆盖，避免为系统文件对话框引入测试专用生产接口。

- [ ] **Step 4: 运行完整验证**

Run: `npm test`

Run: `npm run typecheck`

Run: `npm run lint`

Run: `npm run test:e2e`

Run: `npm run package`

- [ ] **Step 5: 同步用户事实与版本**

README 说明数据、Profile、API Key、导出恢复位置和边界；`PROJECT_STATUS.md` 只记录实际完成事实；按治理规则更新 `VERSION` 和 `CHANGELOG.md`，不声称 P1/P2 已实现。

- [ ] **Step 6: 提交检查点 3 并做最终需求逐项复核**

```powershell
git add apps/zhiji-desktop e2e README.md PROJECT_STATUS.md CHANGELOG.md VERSION
git commit -m "feat(desktop): complete local-first user loop"
```

最终复核：审计 P0 每项均有实现文件和验证证据；P1/P2 无意外混入；工作树无未提交的本任务改动；不在开发机执行安装、升级或卸载试验。
