# Codex Natural-Language Routing Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 让 Codex 以自然语言执行周报、月报和项目复盘，同时复用 `.claude/` 的唯一运行契约与既有输出路径。

**Architecture:** 新增一个共享路由契约，由主项目与用户版的 `AGENTS.md` / `CLAUDE.md` 引用。Codex 根据意图读取既有命令、综合代理、证据与路径契约后直接生成报告；不调用 Claude `Workflow` / `Task`，不在 `.codex/` 创建产品逻辑。

**Tech Stack:** Markdown runtime contracts, AGENTS guidance, PowerShell static-contract tests, existing user-package export script.

## Global Constraints

- `.claude/` 保持唯一运行真相；`.codex/` 不承载复盘提示词、路径或行为规则。
- 不新增 agent、workflow、视角、报告类型、模型调用或默认原始日志读取量。
- 保留 YAML frontmatter、聊天摘要、复盘六问、硬质量门、质量自检异常披露、周报用户回应区及既有输出路径。
- 自然语言不明确时只追问一个会改变报告对象的问题；证据不足时生成部分复盘，不伪造多视角结果。
- 用户版共享文件必须逐字一致；发布前 `AGENTS.md` / `CLAUDE.md` 必须逐字一致。

---

### Task 1: 先建立 Codex 路由的静态验收边界

**Files:**
- Create: `tests/codex-routing-contract.tests.ps1`
- Modify: `tests/distribution-boundary.tests.ps1`

**Interfaces:**
- Consumes: `.claude/shared/contracts/codex-natural-language-routing.md`、主/用户版 AGENTS 与输出路径契约。
- Produces: `PASS: Codex natural-language routing contract checks`；缺失路由、错误路径、Claude 调度依赖或镜像漂移必须失败。

- [ ] **Step 1: 编写失败测试**

创建 `tests/codex-routing-contract.tests.ps1`，复用现有 `Read-Utf8`、`Add-Failure` 样式，并加入：

```powershell
Assert-Contains '.claude/shared/contracts/codex-natural-language-routing.md' '生成 2026-W28 周报'
Assert-Contains '.claude/shared/contracts/codex-natural-language-routing.md' '生成 2026 年 6 月月报'
Assert-Contains '.claude/shared/contracts/codex-natural-language-routing.md' '对 X 做项目复盘'
Assert-Contains '.claude/shared/contracts/codex-natural-language-routing.md' 'output.weekly_report'
Assert-Contains '.claude/shared/contracts/codex-natural-language-routing.md' 'output.monthly_report'
Assert-Contains '.claude/shared/contracts/codex-natural-language-routing.md' 'output.project_report'
Assert-Contains '.claude/shared/contracts/codex-natural-language-routing.md' '不调用不存在的 Claude `Workflow` / `Task` 工具'
Assert-Contains 'AGENTS.md' 'Codex 自然语言复盘入口'
```

同时检查主项目与用户版 `AGENTS.md` / `CLAUDE.md` 各自哈希一致，并检查新共享契约在边界清单中声明为 `shared`。

- [ ] **Step 2: 运行并确认失败原因正确**

Run: `powershell -ExecutionPolicy Bypass -File tests/codex-routing-contract.tests.ps1`  
Expected: FAIL，只因路由契约和入口尚未存在。

### Task 2: 实现唯一的 Codex 自然语言路由契约

**Files:**
- Create: `.claude/shared/contracts/codex-natural-language-routing.md`
- Modify: `AGENTS.md`
- Modify: `CLAUDE.md`
- Modify: `README.md`
- Modify: `packaging/zhiji-user-boundaries.json`

**Interfaces:**
- Consumes: `.claude/shared/paths.md`、`.claude/shared/contracts/review-synthesis.md`、既有命令与综合代理说明。
- Produces: Codex 收到自然语言时可遵循的稳定读取顺序、意图映射与降级规则。

- [ ] **Step 1: 写入共享路由契约**

创建文件并包含以下不可省略内容：

```markdown
# Codex 自然语言复盘路由

| 意图 | 读取顺序 | 输出 key |
|---|---|---|
| `生成 2026-W28 周报` / `本周复盘` | `weekly-review.md` -> `weekly-synthesis.md` -> `review-synthesis.md` -> `evidence-and-verification.md` | `output.weekly_report` |
| `生成 2026 年 6 月月报` / `六月复盘` | `monthly-review.md` -> `monthly-synthesis.md` -> `review-synthesis.md` -> `evidence-and-verification.md` | `output.monthly_report` |
| `对 X 做项目复盘` / `X 优化验收` | `project-review.md` -> `project-synthesis.md` -> `review-synthesis.md` -> `evidence-and-verification.md` | `output.project_report` |
```

在表后明确：Codex 直接执行综合；不调用不存在的 Claude `Workflow` / `Task` 工具；已有视角证据包优先消费；没有足够证据时按既有规则标注部分复盘；不得假装已并行运行视角。

- [ ] **Step 2: 添加最小主入口**

在 `AGENTS.md` 的“日志粘贴处理”之后加入 `### Codex 自然语言复盘入口`，只引用新契约并声明 `.claude/` 为唯一运行真相。将同一文本同步到 `CLAUDE.md`，不得手工产生差异。

- [ ] **Step 3: 声明共享边界**

将 `.claude/shared/contracts/codex-natural-language-routing.md` 加入 `packaging/zhiji-user-boundaries.json` 的 `shared` 数组。此声明与新契约同时提交，使 Task 1 的路由测试在 Task 2 完成后能够转绿。

- [ ] **Step 4: 更新公开使用导航**

将 `README.md` 的周/月/项目复盘入口示例改为自然语言示例，并明确 Claude slash command 是兼容入口，不是 Codex 的前置条件。保留报告类型、输出位置和证据边界说明。

- [ ] **Step 5: 运行路由测试转绿**

Run: `powershell -ExecutionPolicy Bypass -File tests/codex-routing-contract.tests.ps1`  
Expected: PASS。

### Task 3: 同步用户版与分发边界

**Files:**
- Create: `packaging/zhiji-user-overlay/.claude/shared/contracts/codex-natural-language-routing.md`
- Modify: `packaging/zhiji-user-overlay/AGENTS.md`
- Modify: `packaging/zhiji-user-overlay/CLAUDE.md`
- Modify: `packaging/zhiji-user-overlay/README.md`
- Generated: `zhiji-user/`

**Interfaces:**
- Consumes: Task 2 的共享契约与主入口文本。
- Produces: 用户版可使用相同自然语言入口，且 shared 契约逐字一致。


- [ ] **Step 1: 建立相同契约文件**

用户版 overlay 中同路径路由契约必须与主项目逐字一致；shared 边界声明已在 Task 2 建立。

- [ ] **Step 2: 以用户版边界同步入口与文档**

在 overlay 的 `AGENTS.md` / `CLAUDE.md` 中加入与主项目同义的“Codex 自然语言复盘入口”，但不引入主项目的开发提交规则。更新用户版 README 的三条自然语言示例；不得暴露 Claude `Workflow` / `Task` 为用户步骤。

- [ ] **Step 3: 导出并验证分发包**

Run:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/export-zhiji-user.ps1
powershell -ExecutionPolicy Bypass -File tests/distribution-boundary.tests.ps1
powershell -ExecutionPolicy Bypass -File tests/codex-routing-contract.tests.ps1
```

Expected: 导出完成，两个测试均为 PASS。

### Task 4: 用 Codex 对同一材料做真实运行验收

**Files:**
- Create: `output/codex-routing-acceptance-2026-07-31.md`（gitignore 本地记录）
- Write: `复盘/每周复盘/2026-W28.md`
- Write: `复盘/每月复盘/2026-06.md`
- Write: `复盘/项目复盘/YYYY-MM-DD-project-复盘生成质量优化.md`

**Interfaces:**
- Consumes: Task 2 路由契约、现有真实日志/上下文与 Task 3 的用户版验证。
- Produces: 三份由 Codex 自然语言路由实际生成的报告，以及明确的保留/回退判断。

- [ ] **Step 1: 通过自然语言触发三类复盘**

在 Codex 任务中依次输入：

```text
生成 2026-W28 周报
生成 2026 年 6 月月报
对复盘生成质量优化做项目复盘
```

每次确认报告写入对应 `output.*_report` 路径，且不调用 Claude CLI、Workflow 或 Task。

- [ ] **Step 2: 对照四项质量指标**

在 `output/codex-routing-acceptance-2026-07-31.md` 写入：新判断/取舍、证据可追溯、重复或填充、行动可验证。每项仅引用报告日期或段名，不复制私人日志原文。

- [ ] **Step 3: 执行保留闸门**

仅当三份报告均不降低证据可追溯性与行动可验证性、至少一份减少重复或澄清行动、且没有增加默认调用/视角/原始日志读取量时，保留路由。否则精确删除 Task 2/3 的路由改动，保留原 `.claude/` Claude 兼容文件。

### Task 5: 完整回归、发布同步与提交

**Files:**
- Modify when Task 4 passes: `VERSION`, `PROJECT_STATUS.md`, `CHANGELOG.md`
- Modify when Task 4 passes: `README.md`, 用户版 README 与路由相关测试
- Modify when Task 4 passes: `tests/quality-baseline.tests.ps1`, `docs/quality-baseline-matrix.md`

**Interfaces:**
- Consumes: Task 4 的验收结论。
- Produces: 可发布的 Codex 自然语言入口或精确回退，无半迁移状态。

- [ ] **Step 1: 运行完整静态回归**

Run:

```powershell
powershell -ExecutionPolicy Bypass -File tests/quality-baseline.tests.ps1
powershell -ExecutionPolicy Bypass -File tests/review-workflow-contract.tests.ps1
powershell -ExecutionPolicy Bypass -File tests/distribution-boundary.tests.ps1
powershell -ExecutionPolicy Bypass -File tests/codex-routing-contract.tests.ps1
git diff --check
```

Expected: 全部 PASS 且无 diff whitespace error。

- [ ] **Step 2: 仅在验收通过时更新发布事实**

将 `VERSION` 从当前版本递增一个修订号；用同一版本更新 `PROJECT_STATUS.md` 的当前版本、Codex 自然语言入口状态和关键决策；在 `CHANGELOG.md` 顶部写一条 `[功能]` 记录，说明 Codex 已成为自然语言入口、Claude 命令保留兼容。在 `tests/quality-baseline.tests.ps1` 的矩阵 id 列表中加入 `codex-natural-language-routing`，并在 `docs/quality-baseline-matrix.md` 新增同材料周/月/项目对照行。

- [ ] **Step 3: 最终验证与本地提交**

再次运行 Step 1 全部命令，执行 `git status --short` 核对只包含路由、用户版镜像、测试、文档与发布文件，然后按项目提交流程创建本地提交。不执行 `git push`。
