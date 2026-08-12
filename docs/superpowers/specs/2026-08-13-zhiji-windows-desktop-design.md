# 知己 Windows 桌面客户端设计

## 1. 目标与必要性

知己现有 CLI、Skill 与 Agent 已能完成日志分析和周期复盘，但普通用户必须理解项目目录、Markdown、AI 工具和运行命令，首次使用门槛过高。客户端的目标不是替换现有专业入口，而是让不熟悉这些概念的用户通过普通 Windows 软件完成同一价值闭环：

```text
写日志 → 得到一个可验证洞察 → 尝试一个行动 → 记录结果 → 周期复盘
```

第一版的成功标准：陌生用户无需理解 Skill、Agent 或 CLI，即可独立配置自己的 AI 服务，完成首次日反馈，并在后续记录行动验证结果。

## 2. 产品范围

### 2.1 第一版包含

- Windows 10/11 桌面客户端与安装包。
- 用户自己的 OpenAI 兼容 API Key。
- OpenAI、DeepSeek 等常见预设，以及自定义 Base URL 和模型名。
- 日志创建、编辑、自动保存与历史查看。
- 日反馈、周复盘、月复盘和项目复盘。
- 写日志时可选项目；项目复盘时可补选日期范围。
- 单用户、本地 Markdown 存储。
- `.zhiji.zip` 数据包导入、导出与冲突处理。
- 脱敏的本地诊断信息。

### 2.2 第一版不包含

- Android、Web 在线版、账号系统、云同步或自建 AI 服务。
- 年度复盘、人生设计、主题思考、收藏库、飞书和滴答集成。
- 商店上架、自动更新、多人协作和 AI 自动项目分类。
- SQLite、微服务、微前端、GraphQL 或其他没有当前收益证据的基础设施。

## 3. 与现有知己的隔离

客户端新增在 `apps/zhiji-desktop/`，不修改 `.claude/` 中现有 Skill、Agent、命令和工作流。现有 CLI 使用者继续使用项目中的日志、复盘与上下文；普通用户的客户端数据默认保存在 Windows 文档目录下的独立“知己”目录。

客户端不调用 Codex CLI，也不在运行时解析 `.claude/` 开发文件。第一版从现有稳定契约提炼带版本号的客户端提示词和输出 Schema；待客户端经过真实使用验证后，再评估是否提取共享运行包，避免提前重构成熟链路。

## 4. 技术选型与架构

采用 Electron、React 19、TypeScript 和 Vite，形成一个本地优先的模块化单体。该选型同时服务产品与求职叙事：Renderer 展示现代 Web 前端能力，Main Process 展示 Node.js、本地系统能力和类似后端的应用编排，Preload 负责安全、类型化的边界。

```text
┌────────────────────────────────────┐
│ React Renderer                     │
│ 页面、组件、ViewModel、交互状态    │
│ 不接触 Node、文件系统或 API Key    │
└────────────────┬───────────────────┘
                 │ Typed IPC
┌────────────────▼───────────────────┐
│ Preload Security Bridge            │
│ 具名业务方法 + Zod 输入输出校验    │
└────────────────┬───────────────────┘
                 │
┌────────────────▼───────────────────┐
│ Electron Main / Application        │
│ 日、周、月、项目复盘用例           │
├────────────────────────────────────┤
│ Domain                             │
│ Journal / Project / Review / Rules │
├────────────────────────────────────┤
│ Infrastructure Adapters            │
│ Markdown / AI / Credential / ZIP   │
└────────────────┬───────────────────┘
                 │
          用户本地数据目录
```

架构关键词为 Local-first、Modular Monolith、Ports & Adapters 和 Typed IPC。当前只有一个交付物，不拆 monorepo 或多个 npm package。

## 5. 代码结构

```text
apps/zhiji-desktop/
├─ src/
│  ├─ renderer/
│  │  ├─ app/
│  │  ├─ pages/
│  │  ├─ features/
│  │  └─ components/
│  ├─ preload/
│  │  ├─ bridge.ts
│  │  └─ api-types.ts
│  ├─ main/
│  │  ├─ ipc/
│  │  ├─ application/
│  │  ├─ domain/
│  │  └─ infrastructure/
│  │     ├─ ai/
│  │     ├─ markdown/
│  │     ├─ credentials/
│  │     └─ transfer/
│  └─ shared/
│     ├─ contracts/
│     ├─ schemas/
│     └─ errors/
├─ test/
└─ e2e/
```

Renderer 使用 React Router、TanStack Query、Zustand、React Hook Form 和 Zod。Tailwind CSS 与 shadcn/ui 用于快速形成一致、可访问的界面。Vitest、Testing Library 和 Playwright 分别覆盖单元、组件与端到端测试；Electron Forge 生成 Windows 安装包。

## 6. 进程职责与 IPC

### 6.1 Renderer

Renderer 负责日志编辑、Markdown 展示、项目与历史筛选、复盘材料确认、设置表单，以及加载、失败、取消和重试状态。它不直接读取文件、持有 API Key、请求模型或访问 Node.js 全局对象。

### 6.2 Preload

Preload 仅通过 `contextBridge` 暴露具名业务方法，不暴露 `ipcRenderer`、`fs`、`shell`、命令执行、任意网络请求或任意路径访问。

```ts
interface ZhijiDesktopApi {
  journals: {
    save(input: SaveJournalInput): Promise<Journal>;
    list(query: JournalQuery): Promise<JournalSummary[]>;
    get(id: JournalId): Promise<Journal>;
  };
  reviews: {
    generate(input: ReviewGenerationInput): Promise<GenerationTask>;
    cancel(taskId: string): Promise<void>;
  };
  projects: {
    create(input: CreateProjectInput): Promise<Project>;
    list(): Promise<Project[]>;
  };
  transfer: {
    previewImport(path: string): Promise<ImportPreview>;
    importData(input: ConfirmImportInput): Promise<ImportResult>;
    exportData(): Promise<ExportResult>;
  };
}
```

IPC 请求和响应均使用共享 Zod Schema 校验。Renderer 提供的 ID、URL、日期和路径片段一律视为不可信输入。

### 6.3 Main Process

Main Process 负责 AI 请求、密钥读取、Markdown 原子写入、数据目录限制、上下文选择与 Token 预算、任务取消、ZIP 迁移、冲突检测、索引重建和脱敏诊断。

## 7. 本地数据模型

默认数据目录：`%USERPROFILE%/Documents/知己/`。界面使用中文，受控文件和目录名使用英文以降低 Windows 路径兼容风险。

```text
知己/
├─ manifest.json
├─ journals/2026/2026-08-13.md
├─ reviews/
│  ├─ daily/2026-08-13.md
│  ├─ weekly/2026-W33.md
│  ├─ monthly/2026-08.md
│  └─ projects/<project-id>/<review-id>.md
├─ projects/<project-id>.json
├─ settings/preferences.json
└─ .cache/content-index.json
```

Markdown 是日志和复盘的权威数据，`.cache` 只是可从正式文件重建的派生索引。项目元数据使用 JSON，并通过稳定 ID 与日志建立关系。

### 7.1 日志

```markdown
---
schema_version: 1
id: journal_01k...
date: 2026-08-13
created_at: 2026-08-13T20:10:00+08:00
updated_at: 2026-08-13T20:20:00+08:00
project_ids:
  - project_01k...
---

今天准备写方案，但一直在整理资料……
```

一篇日志可以关联多个项目。删除项目只移除关系，不删除日志。

### 7.2 复盘

```markdown
---
schema_version: 1
id: review_01k...
type: daily
period_start: 2026-08-13
period_end: 2026-08-13
source_ids:
  - journal_01k...
project_id: null
provider: openai-compatible
model: example-model
prompt_version: daily-review-v1
created_at: 2026-08-13T20:21:00+08:00
---

# 8月13日日反馈
```

复盘记录来源 ID、模型和提示词版本，以支持依据追溯和结果解释；不保存 API Key、隐藏推理、完整请求或无必要设备信息。

### 7.3 项目

项目保存稳定 ID、名称、状态和创建/归档时间。项目复盘使用显式关联日志，加上用户补选日期范围内的日志，按 ID 去重并展示材料预览；用户确认后才生成，不做 AI 自动归类。

## 8. 数据可靠性与迁移

正式文件使用以下写入事务：

```text
同目录临时文件写入
→ 重新读取并校验
→ 原子替换正式文件
→ 更新可重建索引
```

导出为单个 `.zhiji.zip`，包含日志、复盘、项目、manifest 和非敏感偏好；不包含 API Key、缓存或诊断日志。

导入流程：

```text
解压到临时目录
→ 校验 manifest、路径、Schema 与校验和
→ 展示新增、重复和冲突摘要
→ 用户确认
→ 原子合并
```

冲突不静默覆盖。用户可以保留本地版、使用导入版，或两份保留并为导入内容生成新 ID。任何校验或合并失败都回滚本次导入。

## 9. AI Provider 与密钥

第一版采用 Chat Completions 兼容协议，内置 OpenAI、DeepSeek 等预设，并提供自定义 Base URL 和模型名。

```ts
interface AiProvider {
  testConnection(config: PublicProviderConfig): Promise<TestResult>;
  streamReview(
    request: ReviewGenerationRequest,
    signal: AbortSignal,
  ): AsyncIterable<ReviewChunk>;
}
```

模型请求只从 Main Process 发出。API Key 使用 Electron `safeStorage` 加密后保存，不进入 Renderer、普通配置、日志、诊断或导出包。

需明确处理密钥无效、模型不存在、限流或余额不足、超时、断网、用户取消及输出结构不合格。输出不合格时允许一次低成本格式修复；修复仍失败则不保存正式复盘。

## 10. 页面与交互

客户端采用固定侧栏和五个一级入口：

1. **今天**：写日志、选择项目、查看上次行动、生成或查看日反馈。
2. **复盘**：进入周、月、项目复盘，先预览材料再生成。
3. **项目**：创建、归档项目，查看关联材料并补选日期范围。
4. **历史**：按日期和项目查看日志与复盘。
5. **设置**：配置 AI 服务、测试连接、管理本地数据与导入导出。

原型路径位于本地可视化目录，不纳入产品实现：`C:/Users/panda/.codex/visualizations/2026/08/12/019ff702-7267-7170-a35a-4508132fe79d/zhiji-windows-prototype.html`。

## 11. 状态管理

- TanStack Query 管理日志、项目、历史复盘、生成任务等来自 Main Process 的异步状态。
- Zustand 只保存未提交草稿、筛选器、侧栏偏好和复盘材料临时选择。
- React Hook Form 与 Zod 管理日志、项目、AI 设置和导入冲突表单。
- Markdown Repository 是正式业务数据的唯一真相，不将 Zustand 当数据库。

同一时间只允许一个正式 AI 生成任务。任务可取消，切换页面后仍显示进度；应用退出前提示未完成任务。同一周期已有复盘时默认打开现有版本；显式重新生成时保留旧版本。

## 12. 上下文构建

日反馈读取当日日志、上一条行动和必要的已验证模式。

周复盘读取本周日志、本周日反馈和上一周仍待验证的行动。月复盘优先读取本月周复盘、缺少周复盘覆盖日期的日反馈，并仅在需要证据时补少量原始日志。

材料超过 Token 预算时：

1. 优先保留用户原文证据。
2. 保留已验证、已证伪和连续未执行的行动。
3. 删除重复解释。
4. 分批生成带来源 ID 的证据摘要。
5. 最终复盘只消费这些证据包。

项目复盘只读取显式关联项目的日志和用户本次补选日期范围，不允许 AI 自行扩大材料范围。

## 13. 安全边界

Electron 配置必须满足：

- `nodeIntegration: false`。
- `contextIsolation: true`。
- Renderer sandbox 开启。
- 不加载远程网页。
- Content Security Policy 禁止内联和远程脚本。
- 文件访问限制在已解析的数据目录，拦截 `..`、绝对路径、符号链接和目录逃逸。
- 自定义 Base URL 默认只允许 HTTPS；开发模式可显式允许 localhost。
- Main Process 控制所有网络和系统访问。

错误日志仅记录时间、错误码、阶段和脱敏诊断，不记录日志正文、复盘正文、API Key、完整模型响应或完整用户路径。

## 14. 错误模型

Main Process 返回稳定错误码，例如：

```ts
type AppError =
  | { code: 'INVALID_API_KEY' }
  | { code: 'MODEL_NOT_FOUND'; model: string }
  | { code: 'RATE_LIMITED'; retryAfter?: number }
  | { code: 'NETWORK_TIMEOUT' }
  | { code: 'INVALID_MODEL_OUTPUT' }
  | { code: 'FILE_CONFLICT'; path: string }
  | { code: 'DATA_CORRUPTED'; path: string }
  | { code: 'IMPORT_REJECTED'; reason: string };
```

Renderer 将错误码翻译成可操作的用户提示，不依赖解析底层错误字符串。网络或模型失败时保留日志；文件冲突停止覆盖；导入失败完整回滚。

## 15. 测试与发布验收

### 15.1 单元测试

- 日期范围、项目材料去重和复盘材料选择。
- Token 预算与证据保留顺序。
- AI 错误映射和输出结构校验。
- 导入冲突决策与路径逃逸拦截。

### 15.2 集成测试

- Markdown 原子写入和重新读取。
- 写入中断不破坏旧文件。
- 缓存删除后的索引重建。
- IPC Schema 校验。
- API Key 不进入配置或导出包。
- ZIP 导入部分失败时完整回滚。
- 使用 Fake AI Provider 跑通四类复盘。

### 15.3 E2E

1. 首次启动并配置模拟 AI。
2. 写日志并生成日反馈。
3. 下一条日志填写行动验证。
4. 生成周复盘。
5. 创建项目、关联日志并补选日期。
6. 导出、在空测试目录导入并验证数据一致性。

### 15.4 Windows 发布验收

- Windows 10、11各完成一次安装冒烟测试。
- 中文及带空格路径可用。
- 无管理员权限可安装和运行。
- 升级安装不删除用户数据。
- 离线启动和历史浏览正常。
- 模型失败不损坏日志。
- 导出包可在全新目录恢复。
- 安装包不包含真实日志、密钥或开发机路径。

## 16. 隐私与可观测性

第一版不接入第三方埋点或自动崩溃上报。用户可主动导出脱敏诊断包，其中仅含应用版本、Windows 版本、错误码、阶段、最近任务状态和数据结构校验结果。

## 17. 简历叙事

项目应准确表述为：

> 基于 Electron、React 和 TypeScript 的本地优先 AI 复盘客户端；通过 Electron 多进程与类型安全 IPC 隔离 Web UI 和本地系统权限，以 Markdown 为可迁移数据真相，通过可插拔 OpenAI 兼容 Provider 实现日、周、月和项目复盘，并以原子写入、可重建索引及校验导入保证本地数据可靠性。

简历只写已经真正实现并验证的能力，不预先声称本设计中的待实现模块。

## 18. 验收指标

产品 MVP 完成的最低判断：

- 陌生用户无需 CLI、Skill 或 Agent 即可完成 API 设置、日志输入和首次日反馈。
- 用户可在下一次日志中完成行动结果验证。
- 四类复盘均由可预览、可追溯的材料生成。
- 模型、文件或导入失败不会损坏已有正式数据。
- 数据包不含 API Key，并能在新目录恢复。
- 现有 CLI / Skill / Agent 回归测试与使用方式不受影响。

