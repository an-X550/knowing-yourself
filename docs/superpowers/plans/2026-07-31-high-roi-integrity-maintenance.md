# High-ROI Integrity Maintenance Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 用最小改动消除两个已观察到的维护风险：项目总回归遗漏 Codex 路由测试，以及状态文档重复要求已完成的真实验收。

**Architecture:** 不新增运行能力、契约、入口或抽象层。总完整性测试继续作为现有回归聚合器，只补入已存在的路由测试；状态文档只修正已完成事项的表述，避免默认上下文反复触发无价值的重复验收。

**Tech Stack:** PowerShell static-contract tests, Markdown project status, Git.

## Global Constraints

- 不新增 agent、workflow、command、skill、hook、配置键或报告类型。
- 不修改 `.claude/shared/` 运行契约、模型调用、默认视角或默认读取范围。
- 只修改下列两个文件：`tests/project-integrity.tests.ps1`、`PROJECT_STATUS.md`。
- 通过 `tests/project-integrity.tests.ps1`、`tests/codex-routing-contract.tests.ps1` 与 `git diff --check` 验证。
- 本轮是内部回归与事实纠正，不递增版本；若记录变更，提交信息使用简短维护说明。

---

### Task 1: 将 Codex 路由纳入总完整性回归

**Files:**
- Modify: `tests/project-integrity.tests.ps1`
- Test: `tests/project-integrity.tests.ps1`

**Interfaces:**
- Consumes: 已存在的 `tests/codex-routing-contract.tests.ps1`，其成功标志为 `PASS: Codex natural-language routing contract checks`。
- Produces: `project-integrity` 在路由测试失败时累计一条 `Codex routing contract checks failed` 失败，并以非零状态退出。

- [ ] **Step 1: 写入失败聚合断言**

在现有 quality baseline 调用之后加入：

```powershell
& powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $repoRoot 'tests/codex-routing-contract.tests.ps1')
if ($LASTEXITCODE -ne 0) {
  Add-Failure 'Codex routing contract checks failed'
}
```

- [ ] **Step 2: 运行总完整性回归**

Run: `powershell -ExecutionPolicy Bypass -File tests/project-integrity.tests.ps1`

Expected: `PASS: distribution boundary checks`、`PASS: quality baseline checks`、`PASS: Codex natural-language routing contract checks` 与最后的 `PASS: project integrity checks`。

- [ ] **Step 3: 确认测试只聚合既有边界**

Run: `git diff -- tests/project-integrity.tests.ps1`

Expected: 只包含上述已有测试的调用与失败累积；不存在新的路由规则、输入模式或运行配置。

### Task 2: 修正已完成验收的状态待办

**Files:**
- Modify: `PROJECT_STATUS.md`
- Test: `PROJECT_STATUS.md`

**Interfaces:**
- Consumes: 当前进度中“周/月/项目复盘自适应深度 | 已完成真实样本验收”的事实，以及质量基线矩阵的真实样本验收记录。
- Produces: 待办不再重复要求分别运行周报、月报和项目复盘；保留需要持续收集真实使用证据的行动。

- [ ] **Step 1: 替换三条重复待办**

删除以下已完成的一次性验收项：

```markdown
- [ ] 用真实素材各跑完一次 `/weekly-review` 与 `/monthly-review`
- [ ] 用真实素材跑完一次 `/project-review`
```

在同一位置加入唯一持续性待办：

```markdown
- [ ] 继续以真实使用样本观察周/月/项目复盘质量；仅在出现可复现的重复、证据缺口或行动不可检查问题时修复
```

- [ ] **Step 2: 核对事实无矛盾**

Run: `Select-String -Path PROJECT_STATUS.md -Pattern '周/月/项目复盘自适应深度|真实素材各跑完一次|用真实素材跑完一次|继续以真实使用样本观察'`

Expected: 已完成状态与唯一持续性待办同时出现；两条旧待办不存在。

### Task 3: 全量验证与最小提交

**Files:**
- Modify: `tests/project-integrity.tests.ps1`
- Modify: `PROJECT_STATUS.md`

**Interfaces:**
- Consumes: Task 1 与 Task 2 的最小差异。
- Produces: 已验证的本地维护提交；无版本、运行契约或用户版变更。

- [ ] **Step 1: 运行所有相关回归**

Run:

```powershell
powershell -ExecutionPolicy Bypass -File tests/project-integrity.tests.ps1
powershell -ExecutionPolicy Bypass -File tests/codex-routing-contract.tests.ps1
git diff --check
```

Expected: 两个测试均以 `PASS` 结束，且 `git diff --check` 无输出。

- [ ] **Step 2: 审核提交范围**

Run: `git status --short`

Expected: 仅 `PROJECT_STATUS.md` 与 `tests/project-integrity.tests.ps1` 为本轮工作树改动；忽略的 `.superpowers/` 执行草稿不进入提交。

- [ ] **Step 3: 创建本地维护提交**

Run:

```powershell
git add PROJECT_STATUS.md tests/project-integrity.tests.ps1
git commit -m "test: include Codex routing in integrity checks"
```

Expected: 仅这两个文件进入提交；不执行 `git push`。

## 自检

- 范围覆盖：Task 1 处理总回归遗漏，Task 2 处理默认上下文中的状态矛盾，Task 3 验证并限制提交范围。
- 无占位符：每个修改都给出精确文件、文本和命令。
- 第一性原理边界：未发现运行契约冲突、路径镜像漂移或默认输入膨胀的当前证据，因此没有为它们增加任务。
