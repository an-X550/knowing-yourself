# Default Context Budget Optimization Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 在不改变产品行为的前提下，减少每次会话默认加载的治理上下文。

**Architecture:** 已测得 `AGENTS.md` 为 13,474 字节、每次默认读取的 `PROJECT_STATUS.md` 为 18,599 字节，合计 32,073 字节。把仅在修改文件时需要的细则迁入单一 `docs/development-governance.md`；根规则只保留触发条件。状态文件只保留当前事实，把不再影响当前决策的历史决策归档。

**Tech Stack:** Markdown, PowerShell contract checks, Git.

## Global Constraints

- 不新增 agent、workflow、command、skill、hook、模型调用、视角或输出路径。
- 不修改复盘运行契约、agents、commands 或 workflows。
- `AGENTS.md` 与 `CLAUDE.md` 必须逐字节一致；不改为软链接。
- 最多新建一个按需治理文档和一个历史归档；不得继续拆规则文件。
- 仅当默认总量减少至少 30%、且未丢失当前事实或硬边界时保留。
- 不把字符上限写成永久规则；它只是一轮验收数据。
- 验收通过后递增修订版本、同步状态/README/CHANGELOG、本地提交；不推送。

---

### Task 1: 建立基线和停止闸门

**Files:**
- Create: `output/default-context-budget-baseline-2026-07-31.md` (gitignored)
- Read: `AGENTS.md`, `CLAUDE.md`, `PROJECT_STATUS.md`

**Interfaces:**
- Consumes: 根规则要求每轮读取 `PROJECT_STATUS.md` 的默认上下文约定。
- Produces: 默认保留、按需迁移、历史归档三类清单。

- [ ] **Step 1: 记录基线**

Run: `$agent = (Get-Item AGENTS.md).Length; $status = (Get-Item PROJECT_STATUS.md).Length; "AGENTS=$agent; PROJECT_STATUS=$status; DEFAULT_TOTAL=$($agent + $status)"`

Expected: 当前基线为 `DEFAULT_TOTAL=32073`；若文件已变化，记录实际值。

- [ ] **Step 2: 固定不可迁移内容**

写入基线记录：冲突解决、跳过阈值、唯一运行真相、日志/主题/Codex 入口、最小上下文读取顺序、新功能必要性闸门、Superpowers 映射、状态文件的必需章节/当前进度/真实待办/已知问题必须保留默认上下文。

版本、CHANGELOG 模板、同步清单、目录细则、回退步骤和 Spec-Before-Code 细节标为“修改文件时按需读取”。

- [ ] **Step 3: 停止条件**

若任一待迁移内容会改变日志、复盘、普通答疑或新功能必要性闸门的默认行为，停止并保留现状。

### Task 2: 建立单一按需开发治理入口

**Files:**
- Create: `docs/development-governance.md`
- Modify: `AGENTS.md`
- Modify: `CLAUDE.md`
- Modify: `tests/project-integrity.tests.ps1`

**Interfaces:**
- Consumes: 根规则的启动校验、改动追踪、版本、代码/目录、回退与 Spec-Before-Code 细则。
- Produces: 文件改动时的唯一细节来源；根规则只有一个路由段。

- [ ] **Step 1: 写入失败检查**

在 `tests/project-integrity.tests.ps1` 的 AGENTS/CLAUDE 哈希检查前加入：

```powershell
$governance = Read-Utf8 'docs/development-governance.md'
if (-not $governance.Contains('# 开发治理细则')) {
  Add-Failure 'development governance document is missing its title'
}
if ((Read-Utf8 'AGENTS.md') -notmatch [regex]::Escape('docs/development-governance.md')) {
  Add-Failure 'AGENTS.md does not route file changes to development governance'
}
```

- [ ] **Step 2: 确认失败原因**

Run: `powershell -ExecutionPolicy Bypass -File tests/project-integrity.tests.ps1`

Expected: 仅新增治理文档及根路由缺失导致失败；既有检查继续通过。

- [ ] **Step 3: 创建并迁移细则**

创建 `# 开发治理细则`，固定一级标题为：

```markdown
## 启动校验与发布事实
## 改动追踪与文档同步
## 版本管理
## 代码与目录约定
## 回退与 Spec-Before-Code
```

迁移 `VERSION`/状态校验、CHANGELOG 格式、同步等级/清单/验证、提交推送、版本递增、不递增、编码/目录、回退表与 Spec-Before-Code。不得删除硬边界。

- [ ] **Step 4: 收敛根规则**

在 `AGENTS.md` 保留元规则、维护边界、用户入口、最小上下文、新功能必要性闸门与 Superpowers 映射；删除已迁入细则。加入且只加入：

```markdown
### 开发治理按需上下文

仅当本次会修改项目文件时，读取 `docs/development-governance.md`。该文件定义版本、CHANGELOG、状态同步、文档/目录检查、提交、回退与 Spec-Before-Code 细则；不在日志分析、复盘生成、普通答疑时默认读取。
```

将完全相同的内容同步到 `CLAUDE.md`。

- [ ] **Step 5: 转绿**

Run: `powershell -ExecutionPolicy Bypass -File tests/project-integrity.tests.ps1`

Expected: 全部 PASS，且 AGENTS/CLAUDE 哈希一致。

### Task 3: 压缩状态默认上下文，归档历史决策

**Files:**
- Create: `docs/archive/project-status-decisions-through-2026-07-15.md`
- Modify: `PROJECT_STATUS.md`
- Modify: `README.md`

**Interfaces:**
- Consumes: PROJECT_STATUS 必需章节与 README 对状态文件的职责说明。
- Produces: 状态文件只含当前状态；历史决策仍可追溯。

- [ ] **Step 1: 归档历史决策**

把“关键决策记录”中日期早于 `2026-07-15` 的行移到 archive。文件开头必须为：

```markdown
---
archived_through: 2026-07-15
source: PROJECT_STATUS.md
---

# 项目状态历史决策归档

这些记录保留历史理由，不再作为每次会话的默认上下文。
```

状态文件的“关键决策记录”前加入：

```markdown
2026-07-15 之前的历史决策见 [`project-status-decisions-through-2026-07-15.md`](../../archive/project-status-decisions-through-2026-07-15.md)。
```

- [ ] **Step 2: 合并重复的已完成进度**

只合并语义相同的“已完成”行；保留日反馈、复盘、用户版、主题思考、年度验证和真实用户试用的独立状态。保留行只说明当前能力或缺少的真实证据，不复述版本过程。

- [ ] **Step 3: 保持 README 边界**

README 继续只将 `PROJECT_STATUS.md` 作为当前版本、进度、待办、已知问题的入口；不得把归档历史或开发细则复制进 README。

### Task 4: 验收、发布同步与最小提交

**Files:**
- Modify: `VERSION`, `CHANGELOG.md`, `PROJECT_STATUS.md`, `README.md`
- Modify: `AGENTS.md`, `CLAUDE.md`, `docs/development-governance.md`
- Modify: `docs/archive/project-status-decisions-through-2026-07-15.md`, `tests/project-integrity.tests.ps1`

**Interfaces:**
- Consumes: Task 1 的基线和 Task 2/3 的精确迁移。
- Produces: 默认上下文至少减少 30%，开发改动仍能加载完整治理，运行行为不变。

- [ ] **Step 1: 记录改后预算和保留判断**

Run: `$agent = (Get-Item AGENTS.md).Length; $status = (Get-Item PROJECT_STATUS.md).Length; "POST_DEFAULT_TOTAL=$($agent + $status)"`

将结果写回本地基线。只有改后总量不高于基线 70%、且 Task 1 的默认保留项都在，才保留；否则精确回退无收益或遗漏内容。

- [ ] **Step 2: 完整回归**

Run: `powershell -ExecutionPolicy Bypass -File tests/project-integrity.tests.ps1`，随后运行 `powershell -ExecutionPolicy Bypass -File tests/codex-routing-contract.tests.ps1`，再运行 `git diff --check`。

Expected: 两项测试全部 PASS，差异检查无输出。

- [ ] **Step 3: 发布同步和提交**

将 `VERSION` 从 `1.9.0` 改为 `1.9.1`，同步 PROJECT_STATUS 当前版本与 README 徽章；顶部追加 `[重构]` CHANGELOG，说明默认开发细则改为按需加载、运行能力未改变。

Run: `git add AGENTS.md CLAUDE.md PROJECT_STATUS.md README.md VERSION CHANGELOG.md docs/development-governance.md docs/archive/project-status-decisions-through-2026-07-15.md tests/project-integrity.tests.ps1; git commit -m "refactor: load development governance on demand"`

Expected: 只提交默认上下文分层文件；不执行 `git push`。

## 自检

- 已测得的默认输入成本是本轮真实问题；迁移而非重写是最小路径。
- 不因 AGENTS 行数本身而优化；不拆多个治理文件；不改用户版入口或复盘运行逻辑；不新增永久字数门。
- Task 1 给出停止门，Task 2 收敛规则，Task 3 收敛状态，Task 4 用预算与回归决定保留或回退。
