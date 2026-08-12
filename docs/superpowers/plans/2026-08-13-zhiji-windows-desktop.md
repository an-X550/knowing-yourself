# 知己 Windows 桌面客户端 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 在不改变现有 CLI、Skill 和 Agent 的前提下，交付一个普通 Windows 用户可安装使用的本地优先 AI 复盘客户端。

**Architecture:** 在 `apps/zhiji-desktop/` 新建 Electron 模块化单体。React Renderer 只负责界面，Preload 通过类型安全的具名 IPC 暴露业务能力，Main Process 编排本地 Markdown、OpenAI 兼容接口、Windows 安全存储和 ZIP 迁移。

**Tech Stack:** Electron、Electron Forge、React 19、TypeScript、Vite、React Router、TanStack Query、Zustand、React Hook Form、Zod、Tailwind CSS、Vitest、Testing Library、Playwright。

## Global Constraints

- 仅支持 Windows 10/11；第一版生成 Windows 安装包，不开发 Android、在线 Web 版、商店上架或自动更新。
- 客户端位于 `apps/zhiji-desktop/`；不得修改 `.claude/` 中现有 Skill、Agent、命令和工作流。
- 客户端不得调用 Codex CLI，不得要求最终用户理解 Skill、Agent、项目目录或 Markdown。
- `nodeIntegration: false`、`contextIsolation: true`、Renderer sandbox 开启，不加载远程页面。
- Renderer 不得访问 Node.js、文件系统、API Key 或任意网络接口；所有系统能力通过具名 IPC。
- 正式日志和复盘以本地 Markdown 为唯一真相；缓存必须可从正式文件重建。
- API Key 只由 Main Process 通过 Electron `safeStorage` 处理，不进入 Renderer、普通配置、日志、诊断或导出包。
- 自定义 OpenAI 兼容地址只允许 HTTPS；开发模式可显式允许 `http://localhost` 或 `http://127.0.0.1`。
- 所有正式文件使用临时文件、复读校验和原子替换；导入失败不得改变已有数据。
- 同一时间只运行一个正式 AI 生成任务；任务支持取消，未通过 Schema 校验的模型输出不得保存为正式复盘。
- 不新增 SQLite、云同步、账号系统、微服务、微前端、GraphQL、飞书或滴答集成。
- 不暂存或提交任务开始前已存在的 `zhiji-user/` 和 `user-html-onboarding` 工作区改动。
- 每项实现先写失败测试；任务结束只提交该任务列出的文件。

---

## File Structure

```text
apps/zhiji-desktop/
├─ package.json                         # 脚本、依赖和 Forge 配置入口
├─ forge.config.ts                      # Windows 打包与 Vite 插件
├─ vite.main.config.ts                  # Main Process 构建
├─ vite.preload.config.ts               # Preload 构建
├─ vite.renderer.config.ts              # React Renderer 构建
├─ vitest.config.ts                     # 单元与集成测试
├─ playwright.config.ts                 # Electron E2E
├─ src/
│  ├─ main.ts                           # Electron 启动与安全窗口配置
│  ├─ preload.ts                        # contextBridge 入口
│  ├─ renderer.tsx                      # React 启动
│  ├─ index.html                        # CSP 与挂载点
│  ├─ shared/
│  │  ├─ schemas/domain.ts              # Journal/Review/Project Schema
│  │  ├─ schemas/ipc.ts                 # IPC 输入输出 Schema
│  │  ├─ contracts/desktop-api.ts       # Renderer 可见 API 类型
│  │  └─ errors/app-error.ts            # 稳定错误模型
│  ├─ main-process/
│  │  ├─ bootstrap.ts                   # 依赖组装
│  │  ├─ ipc/register-handlers.ts       # 具名 IPC 注册
│  │  ├─ application/                   # 用例
│  │  ├─ domain/                        # 纯业务规则
│  │  └─ infrastructure/
│  │     ├─ markdown/                   # 原子写入与 Repository
│  │     ├─ ai/                         # OpenAI compatible Provider
│  │     ├─ credentials/                # safeStorage
│  │     ├─ transfer/                   # ZIP 导入导出
│  │     └─ diagnostics/                # 脱敏诊断
│  └─ renderer/
│     ├─ app/                           # Router、QueryClient、布局
│     ├─ pages/                         # 今天/复盘/项目/历史/设置
│     ├─ features/                      # 表单、查询与用户操作
│     ├─ stores/ui-store.ts             # 纯 UI 临时状态
│     └─ styles.css                     # Tailwind 与主题
├─ tests/
│  ├─ unit/                             # 领域与 Schema
│  ├─ integration/                      # 文件、IPC、迁移
│  └─ fixtures/                         # 脱敏样本
└─ e2e/desktop.spec.ts                  # 安装前 Electron 主闭环
```

---

### Task 1: 安全 Electron + React 桌面壳

**Files:**
- Create: `apps/zhiji-desktop/**`（仅 Forge/Vite 基础文件、`src/main.ts`、`src/preload.ts`、`src/renderer.tsx`、`src/index.html`、`src/renderer/app/app.tsx`）
- Create: `apps/zhiji-desktop/tests/unit/window-options.test.ts`
- Modify: `.gitignore`

**Interfaces:**
- Produces: `createWindowOptions(preloadPath: string): Electron.BrowserWindowConstructorOptions`
- Produces: 空的 `window.zhiji` 安全桥骨架，后续任务增加具名方法。

- [ ] **Step 1: 建立隔离目录并生成 Forge Vite TypeScript 基线**

Run:

```powershell
New-Item -ItemType Directory -Path apps -Force
Set-Location apps
pnpm dlx create-electron-app@latest zhiji-desktop --template=vite-typescript
Set-Location zhiji-desktop
pnpm add react@^19 react-dom@^19 zod
pnpm add -D @types/react@^19 @types/react-dom@^19 @vitejs/plugin-react vitest jsdom @testing-library/react @testing-library/jest-dom
```

Expected: `apps/zhiji-desktop/package.json`、Forge/Vite 配置和 Electron 入口生成；现有根目录文件未改变。

- [ ] **Step 2: 写安全窗口配置失败测试**

Create `tests/unit/window-options.test.ts`:

```ts
import { describe, expect, it } from 'vitest';
import { createWindowOptions } from '../../src/main-process/window-options';

describe('createWindowOptions', () => {
  it('isolates the renderer from Node and enables sandboxing', () => {
    const options = createWindowOptions('C:/app/preload.js');
    expect(options.webPreferences).toMatchObject({
      preload: 'C:/app/preload.js',
      nodeIntegration: false,
      contextIsolation: true,
      sandbox: true,
    });
  });
});
```

- [ ] **Step 3: 运行测试并确认失败**

Run: `pnpm vitest run tests/unit/window-options.test.ts`

Expected: FAIL，提示无法找到 `src/main-process/window-options`。

- [ ] **Step 4: 实现安全窗口与 React 挂载**

Create `src/main-process/window-options.ts`:

```ts
import type { BrowserWindowConstructorOptions } from 'electron';

export function createWindowOptions(
  preloadPath: string,
): BrowserWindowConstructorOptions {
  return {
    width: 1200,
    height: 780,
    minWidth: 900,
    minHeight: 640,
    show: false,
    backgroundColor: '#f4f6f3',
    webPreferences: {
      preload: preloadPath,
      nodeIntegration: false,
      contextIsolation: true,
      sandbox: true,
    },
  };
}
```

Update `src/main.ts` to create the window with `createWindowOptions`, show it on `ready-to-show`, deny `setWindowOpenHandler`, and reject all navigation whose URL differs from the bundled Renderer URL.

Create `src/renderer/app/app.tsx`:

```tsx
export function App() {
  return (
    <main>
      <h1>知己</h1>
      <p>数据保存在你的电脑上。</p>
    </main>
  );
}
```

Set `src/index.html` CSP to:

```html
<meta http-equiv="Content-Security-Policy"
  content="default-src 'self'; script-src 'self'; style-src 'self'; img-src 'self' data:; connect-src https: http://localhost:* http://127.0.0.1:*">
```

- [ ] **Step 5: 验证测试、类型检查和开发启动**

Run:

```powershell
pnpm vitest run tests/unit/window-options.test.ts
pnpm exec tsc --noEmit
pnpm start
```

Expected: 测试和类型检查通过；窗口显示“知己 / 数据保存在你的电脑上”；DevTools 中 `typeof require` 为 `undefined`。

- [ ] **Step 6: 忽略桌面构建产物并提交**

Append to root `.gitignore`:

```gitignore
/apps/zhiji-desktop/node_modules/
/apps/zhiji-desktop/.vite/
/apps/zhiji-desktop/out/
/apps/zhiji-desktop/coverage/
/apps/zhiji-desktop/playwright-report/
```

Run:

```powershell
git add .gitignore apps/zhiji-desktop
git commit -m "feat(desktop): scaffold secure Electron shell"
```

Expected: 仅 `.gitignore` 和 `apps/zhiji-desktop/` 基线进入提交。

---

### Task 2: 领域 Schema、错误模型与原子 Markdown 存储

**Files:**
- Create: `src/shared/schemas/domain.ts`
- Create: `src/shared/errors/app-error.ts`
- Create: `src/main-process/infrastructure/markdown/path-policy.ts`
- Create: `src/main-process/infrastructure/markdown/atomic-write.ts`
- Create: `src/main-process/infrastructure/markdown/journal-repository.ts`
- Test: `tests/unit/domain-schema.test.ts`
- Test: `tests/integration/markdown-repository.test.ts`

**Interfaces:**
- Produces: `JournalSchema`, `ProjectSchema`, `ReviewSchema` and inferred domain types.
- Produces: `AppError` discriminated union.
- Produces: `MarkdownJournalRepository.save(input)` / `get(id)` / `list(query)`.

- [ ] **Step 1: 写领域 Schema 和非法路径失败测试**

Create `tests/unit/domain-schema.test.ts`:

```ts
import { describe, expect, it } from 'vitest';
import { JournalSchema } from '../../src/shared/schemas/domain';

describe('JournalSchema', () => {
  it('requires stable ids and ISO dates', () => {
    expect(() => JournalSchema.parse({ id: '../escape', date: '13/08/2026' }))
      .toThrow();
  });
});
```

Create `tests/integration/markdown-repository.test.ts` with a temporary data root and assertions that saving then reading preserves body/frontmatter, while ID `../outside` is rejected and no file appears outside the root.

- [ ] **Step 2: 运行测试并确认失败**

Run: `pnpm vitest run tests/unit/domain-schema.test.ts tests/integration/markdown-repository.test.ts`

Expected: FAIL，缺少 Schema 和 Repository。

- [ ] **Step 3: 实现领域 Schema 与稳定错误模型**

Create `src/shared/schemas/domain.ts`:

```ts
import { z } from 'zod';

const StableId = z.string().regex(/^(journal|review|project)_[a-z0-9]+$/);
const IsoDate = z.string().regex(/^\d{4}-\d{2}-\d{2}$/);
const IsoDateTime = z.string().datetime({ offset: true });

export const JournalSchema = z.object({
  schemaVersion: z.literal(1),
  id: StableId.refine((id) => id.startsWith('journal_')),
  date: IsoDate,
  createdAt: IsoDateTime,
  updatedAt: IsoDateTime,
  projectIds: z.array(StableId.refine((id) => id.startsWith('project_'))),
  body: z.string().min(1),
});

export const ProjectSchema = z.object({
  schemaVersion: z.literal(1),
  id: StableId.refine((id) => id.startsWith('project_')),
  name: z.string().trim().min(1).max(80),
  status: z.enum(['active', 'archived']),
  createdAt: IsoDateTime,
  archivedAt: IsoDateTime.nullable(),
});

export const ReviewSchema = z.object({
  schemaVersion: z.literal(1),
  id: StableId.refine((id) => id.startsWith('review_')),
  type: z.enum(['daily', 'weekly', 'monthly', 'project']),
  periodStart: IsoDate,
  periodEnd: IsoDate,
  sourceIds: z.array(StableId).min(1),
  projectId: StableId.nullable(),
  provider: z.literal('openai-compatible'),
  model: z.string().min(1),
  promptVersion: z.string().regex(/^[a-z-]+-v\d+$/),
  createdAt: IsoDateTime,
  body: z.string().min(1),
});

export type Journal = z.infer<typeof JournalSchema>;
export type Project = z.infer<typeof ProjectSchema>;
export type Review = z.infer<typeof ReviewSchema>;
```

Create `src/shared/errors/app-error.ts` with the exact error codes from the design and `toAppError(error: unknown): AppError` for unknown failures.

- [ ] **Step 4: 实现路径策略、原子写入与 Journal Repository**

Implement `resolveInsideRoot(root, ...segments)` using `path.resolve`, reject results not starting with `root + path.sep`, and use `lstat` to reject symbolic links in existing path components.

Implement `atomicWriteUtf8(target, content, validate)`:

```ts
export async function atomicWriteUtf8(
  target: string,
  content: string,
  validate: (value: string) => void,
): Promise<void> {
  const temp = `${target}.${crypto.randomUUID()}.tmp`;
  await fs.mkdir(path.dirname(target), { recursive: true });
  try {
    await fs.writeFile(temp, content, 'utf8');
    const reread = await fs.readFile(temp, 'utf8');
    validate(reread);
    await fs.rename(temp, target);
  } finally {
    await fs.rm(temp, { force: true });
  }
}
```

`MarkdownJournalRepository` serializes YAML frontmatter with `gray-matter`, stores `journals/<year>/<date>.md`, and validates reread content through `JournalSchema`.

- [ ] **Step 5: 验证原子存储**

Run: `pnpm vitest run tests/unit/domain-schema.test.ts tests/integration/markdown-repository.test.ts`

Expected: PASS；测试临时目录外没有新文件。

- [ ] **Step 6: 提交领域与存储基础**

```powershell
git add apps/zhiji-desktop/src/shared apps/zhiji-desktop/src/main-process/infrastructure/markdown apps/zhiji-desktop/tests/unit/domain-schema.test.ts apps/zhiji-desktop/tests/integration/markdown-repository.test.ts apps/zhiji-desktop/package.json apps/zhiji-desktop/pnpm-lock.yaml
git commit -m "feat(desktop): add local-first markdown storage"
```

---

### Task 3: 项目、日志用例与类型安全 IPC 纵向闭环

**Files:**
- Create: `src/shared/schemas/ipc.ts`
- Create: `src/shared/contracts/desktop-api.ts`
- Create: `src/main-process/infrastructure/markdown/project-repository.ts`
- Create: `src/main-process/application/save-journal.ts`
- Create: `src/main-process/application/manage-projects.ts`
- Create: `src/main-process/ipc/register-handlers.ts`
- Modify: `src/preload.ts`
- Create: `src/renderer/pages/today-page.tsx`
- Create: `src/renderer/pages/projects-page.tsx`
- Test: `tests/integration/journal-ipc.test.ts`
- Test: `tests/unit/project-materials.test.ts`

**Interfaces:**
- Consumes: `MarkdownJournalRepository`, `JournalSchema`, `ProjectSchema`.
- Produces: `window.zhiji.journals.save/list/get` and `window.zhiji.projects.create/list/archive`.
- Produces: `selectProjectMaterials(projectId, range, journals): Journal[]`.

- [ ] **Step 1: 写 IPC 输入校验与项目材料去重失败测试**

Assert that an IPC request with `date: 'today'` is rejected before Repository invocation. Assert that project materials combine linked journals and date-range journals, remove duplicate IDs, and sort by date ascending.

```ts
expect(selectProjectMaterials('project_a1', range, journals).map((j) => j.id))
  .toEqual(['journal_a1', 'journal_a2', 'journal_a3']);
```

- [ ] **Step 2: 运行目标测试并确认失败**

Run: `pnpm vitest run tests/integration/journal-ipc.test.ts tests/unit/project-materials.test.ts`

Expected: FAIL，接口和选择函数不存在。

- [ ] **Step 3: 定义共享 IPC Schema 和 API**

In `src/shared/schemas/ipc.ts`, define:

```ts
export const SaveJournalInputSchema = z.object({
  id: z.string().regex(/^journal_[a-z0-9]+$/).optional(),
  date: z.string().regex(/^\d{4}-\d{2}-\d{2}$/),
  body: z.string().trim().min(1),
  projectIds: z.array(z.string().regex(/^project_[a-z0-9]+$/)).default([]),
});

export const JournalQuerySchema = z.object({
  start: z.string().regex(/^\d{4}-\d{2}-\d{2}$/).optional(),
  end: z.string().regex(/^\d{4}-\d{2}-\d{2}$/).optional(),
  projectId: z.string().regex(/^project_[a-z0-9]+$/).optional(),
});
```

Define `ZhijiDesktopApi` exactly once in `desktop-api.ts`, then augment `Window` in `src/renderer/global.d.ts`.

- [ ] **Step 4: 实现项目 Repository、用例和具名 IPC**

Store project JSON under `projects/<project-id>.json` with atomic write and `ProjectSchema` validation. Register only fixed channels such as `journals:save`, `journals:list`, `projects:create`, never accept a channel name from Renderer.

Expose preload methods one by one:

```ts
contextBridge.exposeInMainWorld('zhiji', {
  journals: {
    save: (input) => ipcRenderer.invoke('journals:save', input),
    list: (query) => ipcRenderer.invoke('journals:list', query),
    get: (id) => ipcRenderer.invoke('journals:get', id),
  },
  projects: {
    create: (input) => ipcRenderer.invoke('projects:create', input),
    list: () => ipcRenderer.invoke('projects:list'),
    archive: (id) => ipcRenderer.invoke('projects:archive', id),
  },
});
```

- [ ] **Step 5: 实现“今天”和“项目”最小页面**

Today page uses React Hook Form + Zod, project multi-select, autosaves after 800 ms idle through `window.zhiji.journals.save`, and displays “已保存到本机” only after the IPC resolves.

Projects page supports create, list and archive. Archiving removes the project ID from affected journals through an application use case; it never deletes journal files.

- [ ] **Step 6: 验证纵向闭环**

Run:

```powershell
pnpm vitest run tests/integration/journal-ipc.test.ts tests/unit/project-materials.test.ts
pnpm exec tsc --noEmit
pnpm start
```

Expected: 可以新建项目、选择项目、保存日志、重启应用后重新读取；非法日期 IPC 被拒绝。

- [ ] **Step 7: 提交日志与项目闭环**

```powershell
git add apps/zhiji-desktop/src apps/zhiji-desktop/tests
git commit -m "feat(desktop): add journal and project workflow"
```

---

### Task 4: 安全凭据与 OpenAI 兼容 Provider

**Files:**
- Create: `src/main-process/infrastructure/credentials/credential-store.ts`
- Create: `src/main-process/infrastructure/ai/provider-config.ts`
- Create: `src/main-process/infrastructure/ai/openai-compatible-provider.ts`
- Create: `src/main-process/application/configure-ai.ts`
- Create: `src/renderer/pages/settings-page.tsx`
- Test: `tests/unit/provider-config.test.ts`
- Test: `tests/integration/credential-store.test.ts`
- Test: `tests/integration/openai-provider.test.ts`

**Interfaces:**
- Produces: `CredentialStore.save/read/delete(providerId)`.
- Produces: `OpenAiCompatibleProvider.testConnection()` and `streamReview(request, signal)`.
- Produces: `window.zhiji.settings.getPublicConfig/save/testConnection`; public config never includes API Key.

- [ ] **Step 1: 写 URL、安全存储和错误映射失败测试**

Test accepted URLs: `https://api.openai.com/v1`, `https://api.deepseek.com`; reject `http://example.com`, `file://`, credentials in URL, and non-local private HTTP addresses. In test mode accept `http://127.0.0.1:<port>`.

Mock `safeStorage.encryptString/decryptString` and assert the persisted credential file does not contain the plaintext key.

Use a local HTTP test server to return 401, 404, 429 and SSE chunks; assert stable `AppError` mapping and cancellation via `AbortController`.

- [ ] **Step 2: 运行测试并确认失败**

Run: `pnpm vitest run tests/unit/provider-config.test.ts tests/integration/credential-store.test.ts tests/integration/openai-provider.test.ts`

Expected: FAIL，缺少 Provider、URL 规则和 CredentialStore。

- [ ] **Step 3: 实现公开配置与 URL 策略**

Define presets:

```ts
export const PROVIDER_PRESETS = {
  openai: { baseUrl: 'https://api.openai.com/v1', defaultModel: 'gpt-5-mini' },
  deepseek: { baseUrl: 'https://api.deepseek.com', defaultModel: 'deepseek-chat' },
} as const;
```

Public settings contain `providerId`, `baseUrl`, `model`, and `hasApiKey`; never return encrypted bytes or plaintext.

- [ ] **Step 4: 实现 safeStorage CredentialStore**

Save `safeStorage.encryptString(apiKey).toString('base64')` under Electron `userData`, use owner-only file permissions where supported, and fail closed when encryption is unavailable. Tests inject a `SafeStoragePort` instead of importing Electron directly.

- [ ] **Step 5: 实现流式 Provider 和错误映射**

POST `${baseUrl}/chat/completions` with `stream: true`, parse SSE `data:` frames, stop at `[DONE]`, and yield text deltas. Never log headers or request body. Map status 401/404/429 and timeout into the stable error union.

- [ ] **Step 6: 实现设置页面与连通性测试**

The form offers OpenAI, DeepSeek and Custom. Presets hide Base URL unless advanced mode is opened. Saving sends API Key once to Main Process; reloading shows only `hasApiKey: true`. Connection test uses a minimal request and presents actionable Chinese messages.

- [ ] **Step 7: 验证密钥不泄漏并提交**

Run:

```powershell
pnpm vitest run tests/unit/provider-config.test.ts tests/integration/credential-store.test.ts tests/integration/openai-provider.test.ts
pnpm exec tsc --noEmit
```

Expected: PASS；`Select-String -Recurse -Pattern 'test-secret-key' <test-user-data>` 无匹配。

Commit:

```powershell
git add apps/zhiji-desktop/src apps/zhiji-desktop/tests
git commit -m "feat(desktop): add secure AI provider configuration"
```

---

### Task 5: 日反馈、行动验证与生成任务状态机

**Files:**
- Create: `src/main-process/domain/review-task.ts`
- Create: `src/main-process/domain/daily-context.ts`
- Create: `src/main-process/application/generate-daily-review.ts`
- Create: `src/main-process/infrastructure/markdown/review-repository.ts`
- Create: `src/main-process/prompts/daily-review-v1.ts`
- Create: `src/renderer/features/reviews/use-review-task.ts`
- Modify: `src/renderer/pages/today-page.tsx`
- Test: `tests/unit/daily-context.test.ts`
- Test: `tests/unit/review-task.test.ts`
- Test: `tests/integration/generate-daily-review.test.ts`

**Interfaces:**
- Produces: `ReviewTaskManager.start/cancel/getCurrent` with a one-task invariant.
- Produces: `GenerateDailyReview.execute({ journalId, regenerate })`.
- Produces: IPC events `reviews:progress` containing only `taskId`, `phase`, and text delta.

- [ ] **Step 1: 写上下文、单任务和失败不落盘测试**

Test that daily context includes today's journal and the latest prior daily action, but excludes unrelated future journals. Test that starting a second task returns `TASK_ALREADY_RUNNING`. Test that provider failure or invalid final output leaves no official review file.

- [ ] **Step 2: 运行测试并确认失败**

Run: `pnpm vitest run tests/unit/daily-context.test.ts tests/unit/review-task.test.ts tests/integration/generate-daily-review.test.ts`

Expected: FAIL，缺少上下文和用例。

- [ ] **Step 3: 提炼版本化日反馈 Prompt 和输出 Schema**

Create `daily-review-v1.ts` as a client-owned constant. Require one evidence-backed insight, one action under five minutes, one observable prediction, optional prior-action verification, and a tracking line. Define a Zod response object:

```ts
export const DailyReviewOutputSchema = z.object({
  priorAction: z.object({ status: z.enum(['done', 'not_done', 'insufficient']), evidence: z.string() }).nullable(),
  insight: z.object({ quote: z.string(), text: z.string() }),
  action: z.object({ step: z.string(), prediction: z.string() }),
  trackingLine: z.string(),
});
```

- [ ] **Step 4: 实现任务状态机和日反馈用例**

Use phases `queued | building_context | generating | validating | saving | completed | failed | cancelled`. Keep one `AbortController`. If a review exists and `regenerate` is false, return it without model invocation. Regeneration creates a new review ID and preserves the old file.

Allow one repair request only when final JSON fails Schema validation. The repair request receives invalid output and Schema description, not an expanded personal context.

- [ ] **Step 5: 实现 Today 页面生成、取消和验证交互**

Display streamed content as preview only. Mark it “已保存” only after Main confirms atomic write. Add previous action choices `做了 / 做了一部分 / 没做` plus a free-text result; save this evidence in the next journal body/metadata through the journal use case.

- [ ] **Step 6: 验证核心闭环并提交**

Run:

```powershell
pnpm vitest run tests/unit/daily-context.test.ts tests/unit/review-task.test.ts tests/integration/generate-daily-review.test.ts
pnpm exec tsc --noEmit
```

Expected: Fake Provider 可跑通保存；失败、取消、非法输出均无正式反馈文件。

Commit:

```powershell
git add apps/zhiji-desktop/src apps/zhiji-desktop/tests
git commit -m "feat(desktop): complete daily reflection loop"
```

---

### Task 6: 周、月、项目材料选择与 Token 预算

**Files:**
- Create: `src/main-process/domain/date-periods.ts`
- Create: `src/main-process/domain/material-selector.ts`
- Create: `src/main-process/domain/token-budget.ts`
- Create: `src/main-process/prompts/weekly-review-v1.ts`
- Create: `src/main-process/prompts/monthly-review-v1.ts`
- Create: `src/main-process/prompts/project-review-v1.ts`
- Test: `tests/unit/date-periods.test.ts`
- Test: `tests/unit/material-selector.test.ts`
- Test: `tests/unit/token-budget.test.ts`

**Interfaces:**
- Produces: `getIsoWeekRange(date)`, `getMonthRange(date)`.
- Produces: `selectWeeklyMaterials`, `selectMonthlyMaterials`, `selectProjectMaterials`.
- Produces: `buildEvidencePackets(materials, budget): EvidencePacket[]` with source IDs.

- [ ] **Step 1: 写日期边界、选择优先级和预算失败测试**

Cover ISO week crossing year end, leap-year February, duplicate project/range material IDs, monthly preference for weekly reviews, and budget overflow preserving quoted journal evidence plus verified/disproved/not-done actions.

```ts
expect(getIsoWeekRange('2026-01-01')).toEqual({
  start: '2025-12-29',
  end: '2026-01-04',
  key: '2026-W01',
});
```

- [ ] **Step 2: 运行测试并确认失败**

Run: `pnpm vitest run tests/unit/date-periods.test.ts tests/unit/material-selector.test.ts tests/unit/token-budget.test.ts`

Expected: FAIL，领域函数不存在。

- [ ] **Step 3: 实现纯领域选择器**

Weekly materials = journals and daily reviews inside the ISO week + unresolved action from the preceding week. Monthly materials = weekly reviews inside the month + daily reviews on dates not covered by those week reviews; raw journals are only attached as evidence on demand. Project materials = linked journals + explicit date range, deduplicated by stable ID, never AI-expanded.

- [ ] **Step 4: 实现 Token 预算与证据包**

Use a deterministic conservative estimator `Math.ceil(text.length / 2)` for Chinese-heavy content in v1. Rank material fragments: direct quote, verified/disproved/not-done action, review conclusion, repeated explanation. When over budget, split into packets with `sourceIds`, `period`, `facts`, `quotes`, and `actions`; never emit a packet without source IDs.

- [ ] **Step 5: 添加三个版本化 Prompt**

Each prompt requires six review questions: result, effective behavior, ineffective behavior, evidence/contradiction, redo choice, next verifiable action. Weekly/monthly/project prompts consume only the supplied evidence packet and must return cited `sourceIds`.

- [ ] **Step 6: 验证领域规则并提交**

Run: `pnpm vitest run tests/unit/date-periods.test.ts tests/unit/material-selector.test.ts tests/unit/token-budget.test.ts`

Expected: PASS across year/month boundaries and budget overflow fixtures.

Commit:

```powershell
git add apps/zhiji-desktop/src/main-process/domain apps/zhiji-desktop/src/main-process/prompts apps/zhiji-desktop/tests/unit
git commit -m "feat(desktop): add periodic review context selection"
```

---

### Task 7: 周、月、项目复盘用例与五页产品界面

**Files:**
- Create: `src/main-process/application/generate-periodic-review.ts`
- Create: `src/renderer/app/router.tsx`
- Create: `src/renderer/app/query-client.ts`
- Create: `src/renderer/app/app-shell.tsx`
- Create: `src/renderer/pages/reviews-page.tsx`
- Create: `src/renderer/pages/history-page.tsx`
- Create: `src/renderer/features/reviews/material-preview.tsx`
- Create: `src/renderer/stores/ui-store.ts`
- Modify: Today, Projects, Settings pages
- Test: `tests/integration/generate-periodic-review.test.ts`
- Test: `tests/unit/material-preview.test.tsx`

**Interfaces:**
- Consumes: Task manager, material selectors, prompts, Provider and Review Repository.
- Produces: `GeneratePeriodicReview.preview(input)` and `.execute(confirmedInput)`.
- Produces: routes `/today`, `/reviews`, `/projects`, `/history`, `/settings`.

- [ ] **Step 1: 写预览确认门与 UI 状态失败测试**

Assert that `execute` rejects inputs without a preview token, a preview token cannot be reused after material changes, and Project review only receives IDs shown in the confirmed preview. Component test verifies source count and date range before the Generate button becomes enabled.

- [ ] **Step 2: 运行测试并确认失败**

Run: `pnpm vitest run tests/integration/generate-periodic-review.test.ts tests/unit/material-preview.test.tsx`

Expected: FAIL，缺少用例和组件。

- [ ] **Step 3: 实现周期复盘预览与执行**

`preview` returns an expiring in-memory token, review type, range, ordered source summaries and a SHA-256 digest of source IDs plus updated timestamps. `execute` rebuilds the digest and rejects stale previews. Reuse the one-task state machine and final output validation from daily review.

- [ ] **Step 4: 实现五页 Router 与布局**

Build the approved fixed sidebar: 今天、复盘、项目、历史、设置. Use TanStack Query for all Main Process data. `ui-store.ts` contains only sidebar collapse, unsaved draft and temporary filters—no journals, projects or reviews.

- [ ] **Step 5: 实现复盘预览、历史和来源追溯**

Reviews page offers weekly/monthly/project cards. Every flow shows range, material count, titles/dates and excluded reason before generation. History can filter by date/type/project and open Markdown-derived content. Each review exposes its `sourceIds` as a source drawer.

- [ ] **Step 6: 验证界面和用例并提交**

Run:

```powershell
pnpm vitest run tests/integration/generate-periodic-review.test.ts tests/unit/material-preview.test.tsx
pnpm exec tsc --noEmit
pnpm start
```

Expected: 五个入口可用；周/月/项目必须预览确认；切页不丢失进行中任务状态。

Commit:

```powershell
git add apps/zhiji-desktop/src apps/zhiji-desktop/tests
git commit -m "feat(desktop): add periodic reviews and product workspace"
```

---

### Task 8: `.zhiji.zip` 导入导出与事务回滚

**Files:**
- Create: `src/main-process/infrastructure/transfer/archive-manifest.ts`
- Create: `src/main-process/infrastructure/transfer/export-data.ts`
- Create: `src/main-process/infrastructure/transfer/preview-import.ts`
- Create: `src/main-process/infrastructure/transfer/import-data.ts`
- Create: `src/renderer/features/transfer/import-dialog.tsx`
- Modify: `src/renderer/pages/settings-page.tsx`
- Test: `tests/integration/data-transfer.test.ts`
- Fixtures: `tests/fixtures/transfer/{valid,conflict,malicious}`

**Interfaces:**
- Produces: `exportData(destination): ExportResult`.
- Produces: `previewImport(archive): ImportPreview`.
- Produces: `importData(previewId, decisions): ImportResult`.

- [ ] **Step 1: 写导出排除、Zip Slip、冲突与回滚失败测试**

Assert archive contains manifest, journals, reviews, projects and public preferences; excludes `.cache`, diagnostic logs and credential files. Reject entries such as `../../outside`. Simulate failure on the second merged file and assert the original data tree is byte-identical.

- [ ] **Step 2: 运行测试并确认失败**

Run: `pnpm vitest run tests/integration/data-transfer.test.ts`

Expected: FAIL，迁移服务不存在。

- [ ] **Step 3: 实现 manifest、校验和与安全导出**

Manifest contains `formatVersion: 1`, export timestamp, application version, file paths and SHA-256 checksums. Only include allowlisted relative roots. Write archive to a temporary destination and rename after reread/checksum validation.

- [ ] **Step 4: 实现只读预览与冲突决策**

Extract into an OS temp directory. Validate path containment before extraction, then validate every Schema and checksum. Preview returns counts for `new`, `duplicate`, `conflict`, plus per-conflict choices `keep_local | use_imported | keep_both`.

- [ ] **Step 5: 实现事务导入**

Build the complete post-import tree in a staging sibling directory, validate it, rename current data to backup, rename staging to current, then remove backup. On any error restore backup. `keep_both` generates a new stable ID and rewrites internal references within the imported object.

- [ ] **Step 6: 实现导入/导出 UI 并提交**

Settings page invokes native file dialogs through dedicated IPC. Import requires preview and explicit conflict choices; closing dialog performs no write.

Run:

```powershell
pnpm vitest run tests/integration/data-transfer.test.ts
pnpm exec tsc --noEmit
git add apps/zhiji-desktop/src apps/zhiji-desktop/tests
git commit -m "feat(desktop): add verified data backup and restore"
```

Expected: 测试通过；恶意 ZIP 无法写出临时目录；失败导入完整回滚。

---

### Task 9: 脱敏诊断、IPC 安全回归与隐私边界

**Files:**
- Create: `src/main-process/infrastructure/diagnostics/diagnostic-recorder.ts`
- Create: `src/main-process/infrastructure/diagnostics/export-diagnostics.ts`
- Create: `src/main-process/ipc/ipc-guard.ts`
- Modify: `src/main-process/ipc/register-handlers.ts`
- Modify: `src/index.html`
- Test: `tests/unit/diagnostic-redaction.test.ts`
- Test: `tests/integration/ipc-security.test.ts`

**Interfaces:**
- Produces: `DiagnosticRecorder.record({ code, phase, metadata })` with an allowlist.
- Produces: `exportDiagnostics(destination)` with no personal content.
- Produces: a single `registerValidatedHandler(channel, inputSchema, handler)` path for all IPC.

- [ ] **Step 1: 写敏感信息和 IPC 攻击失败测试**

Feed diagnostics an API key, journal body, model response and absolute path; assert exported JSON contains only app version, Windows version, error code, phase, task state and structure validation result. Invoke each IPC with oversized strings, unknown keys, path traversal and invalid URLs; assert rejection before infrastructure calls.

- [ ] **Step 2: 运行测试并确认失败**

Run: `pnpm vitest run tests/unit/diagnostic-redaction.test.ts tests/integration/ipc-security.test.ts`

Expected: FAIL，缺少诊断 allowlist 和统一 guard。

- [ ] **Step 3: 实现 allowlist 诊断**

Do not implement regex-based secret scrubbing as the primary control. Construct output from an explicit schema:

```ts
const DiagnosticEntrySchema = z.object({
  timestamp: z.string().datetime({ offset: true }),
  code: z.string().max(64),
  phase: z.enum(['startup', 'storage', 'ai', 'review', 'transfer']),
  taskState: z.string().max(32).optional(),
  structureValid: z.boolean().optional(),
});
```

- [ ] **Step 4: 统一 IPC 校验并锁紧 CSP**

All handlers use `registerValidatedHandler`; `.strict()` Zod objects reject unknown fields. Add maximum body lengths and arrays. CSP production `connect-src` is generated from the configured Main Process request policy rather than permitting Renderer network access; Renderer performs no `fetch`.

- [ ] **Step 5: 运行全量安全检查并提交**

Run:

```powershell
pnpm vitest run
pnpm exec tsc --noEmit
pnpm audit --prod
```

Expected: tests/typecheck pass; production audit has no high or critical vulnerabilities. If audit reports one, record package/advisory and update or replace it before commit.

Commit:

```powershell
git add apps/zhiji-desktop/src apps/zhiji-desktop/tests apps/zhiji-desktop/pnpm-lock.yaml
git commit -m "feat(desktop): harden IPC and diagnostics privacy"
```

---

### Task 10: E2E、Windows 安装包、项目发布事实与回归验收

**Files:**
- Create: `apps/zhiji-desktop/e2e/desktop.spec.ts`
- Create: `apps/zhiji-desktop/tests/fixtures/fake-ai-server.ts`
- Create: `apps/zhiji-desktop/README.md`
- Modify: `apps/zhiji-desktop/forge.config.ts`
- Modify: root `README.md`
- Modify: `PROJECT_STATUS.md`
- Modify: `CHANGELOG.md`
- Modify: `VERSION`
- Modify: relevant project integrity tests if the new tracked directory must be declared

**Interfaces:**
- Consumes: complete client.
- Produces: Windows installer under `apps/zhiji-desktop/out/make/` and verified release documentation.

- [ ] **Step 1: 写端到端用户旅程**

Create `e2e/desktop.spec.ts` using Playwright Electron support and an isolated temp data directory. Test:

```ts
test('a non-CLI user completes the local reflection loop', async () => {
  // configure Fake OpenAI compatible endpoint
  // create a project and write a journal
  // generate and persist daily feedback
  // create next-day verification evidence
  // preview and generate weekly review
  // preview project material with an extra date range
  // export archive, launch with empty data root, import, compare history
});
```

Also assert exported archive contains no fake API key.

- [ ] **Step 2: 运行 E2E 并修复所有失败**

Run: `pnpm playwright test e2e/desktop.spec.ts`

Expected: PASS using Fake Provider only; no real model request or personal data.

- [ ] **Step 3: 配置 Forge Windows 安装包**

Configure Squirrel or WiX maker for per-user installation without administrator privileges, application name `知己`, stable app ID, x64 target and no auto-update module. Ensure user data is outside the installation directory.

Run: `pnpm make`

Expected: a Windows installer appears under `out/make/`; unpacked application contains no `.env`, credential fixture, real journal, absolute development path or test data.

- [ ] **Step 4: 执行 Windows 手工冒烟矩阵**

Record results in `apps/zhiji-desktop/README.md`:

```text
Windows 11: current machine — install, launch, upgrade, uninstall-with-data-retained
Windows 10: clean VM — install, launch, Chinese/space data path, offline history
```

For each environment verify: no-admin install, offline history, failed AI does not damage journal, archive restores into an empty directory, and uninstall does not remove user data. Do not mark a row passed without actually running it.

- [ ] **Step 5: 运行现有知己回归测试**

From repository root, run the current project integrity and workflow suites documented by the repository. At minimum:

```powershell
pwsh -NoProfile -File tests/project-integrity.tests.ps1
pwsh -NoProfile -File tests/review-workflow-contract.tests.ps1
pwsh -NoProfile -File tests/daily-feedback-optimization.tests.ps1
```

Expected: all existing CLI/Skill/Agent tests pass; `.claude/` has no changes from this implementation.

- [ ] **Step 6: 更新用户与协作者可见事实**

Only after Tasks 1–10 and the actual Windows smoke tests pass:

- Increment `VERSION` as a backward-compatible feature release.
- Update root README with a Windows client entry and explicit separation from CLI use.
- Update `PROJECT_STATUS.md` with actual completed/remaining evidence, not design claims.
- Add one release-level CHANGELOG entry listing client, tests, installer and isolation boundary.
- Do not describe Windows 10 as verified if its VM test was not run.

- [ ] **Step 7: 最终验证**

Run:

```powershell
Set-Location apps/zhiji-desktop
pnpm vitest run
pnpm exec tsc --noEmit
pnpm playwright test
pnpm make
Set-Location ../..
git diff --check
git status --short
```

Expected: all automated checks pass; installer exists; Git status contains only intended release files plus the pre-existing unrelated user HTML changes.

- [ ] **Step 8: 提交发布结果**

Stage only Task 10 and intentional client files; explicitly inspect `git diff --cached --name-only` before committing.

```powershell
git commit -m "feat: release local-first Windows client"
```

Expected: no personal data, API Key, `.cache`, diagnostic logs, installer binaries or pre-existing unrelated changes enter Git unless the repository explicitly tracks release artifacts.

---

## Plan Self-Review

- **Spec coverage:** Tasks 1–10 cover the secure Electron shell, typed IPC, local Markdown truth, projects, four review types, project date-range supplementation, OpenAI compatible presets/custom endpoint, safeStorage, generation cancellation, context budgeting, five-page UI, history, ZIP migration, diagnostics, tests, installer and preservation of existing CLI/Skill/Agent behavior.
- **Scope control:** Android, cloud sync, accounts, SQLite, annual/life/topic/archive features, Feishu/TickTick, stores and auto-update remain explicitly excluded.
- **Type consistency:** `Journal`, `Project`, `Review`, `AppError`, `ZhijiDesktopApi`, Repository, Provider and Task Manager names are defined before downstream use. Review generation uses one task manager for all four review types.
- **Data consistency:** Markdown/JSON are authoritative; Query/Zustand are UI caches only. API Key and diagnostic content never enter exports.
- **Testability:** External AI, safeStorage, file dialogs and data roots are injected ports in tests; no automated test requires a real API account or personal file.
- **Working-tree safety:** Every commit step stages explicit paths and preserves the unrelated `zhiji-user/` and existing onboarding files present before implementation.

