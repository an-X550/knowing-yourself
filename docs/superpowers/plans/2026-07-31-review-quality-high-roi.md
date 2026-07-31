# Review Quality High-ROI Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 在不增加默认运行成本的前提下，用真实样本验证并实施复盘生成质量的三项高性价比优化。

**Architecture:** 先将当前周/月/项目复盘作为基线，只有基线确认存在对应问题时，才修改共享复盘契约与三个综合代理。共享文件改动通过用户版导出同步，静态回归守住六问、证据降级、方向检查、行动检查与周报用户回应区。

**Tech Stack:** Markdown runtime contracts and agents, JavaScript workflows, PowerShell static-contract tests, Git.

## Global Constraints

- 不新增 agent、workflow、视角、命令、报告类型、外部数据源或模型调用。
- 不增加默认原始日志读取范围；只有既有证据冲突或引用缺失时按现有规则抽查。
- 保留六问、聊天摘要、YAML frontmatter、证据或降级、关键判断限制/反例、方向检查、可验证行动与周报用户回应区。
- 基线与复跑均使用相同真实材料；验收记录不复制个人日志原文。
- 任一候选优化未带来可观察改善，撤回该候选而非继续叠加规则。

---

### Task 1: 建立真实样本基线并决定实施范围

**Files:**
- Create: `output/review-quality-baseline-2026-07-31.md`（gitignore 本地验收记录）
- Read: `复盘/每日反馈/`、`日志/`、`关于我/current.md`、`关于我/verified-patterns.md`
- Read: `.claude/commands/weekly-review.md`, `.claude/commands/monthly-review.md`, `.claude/commands/project-review.md`

**Interfaces:**
- Consumes: 现有运行入口与真实材料。
- Produces: 每种复盘一行 `implement / skip` 决定，以及四项不含原文的基线判断。

- [ ] **Step 1: 选择同一批可重复材料**

在 Codex 运行环境确认所选日期/月份有完整日志和日反馈；优先使用已有的完整周 `2026-W28`、月 `2026-06`，项目使用当前“复盘生成质量优化验收”材料。若任一材料缺失，替换为最近一个完整周期，并在验收记录中写明替换原因。

- [ ] **Step 2: 运行三份当前版本复盘**

在运行环境分别执行：

```text
/weekly-review 2026-W28
/monthly-review 2026-06
/project-review 复盘生成质量优化验收
```

不得在运行前手动修改输入、提示词或旧报告；保留生成路径，供复跑时使用同一输入对照。

- [ ] **Step 3: 记录四项基线，不复制隐私原文**

创建以下内容；方括号替换为简短结论，引用只写日期、报告段名或视角名：

```markdown
# 复盘生成质量基线（本地）

| 类型 | 新判断/取舍 | 证据可追溯 | 填充或重复 | 行动可验证 | 候选改动决定 |
|---|---|---|---|---|---|
| 周报 | [是/否与段名] | [是/否与段名] | [无/具体段名] | [是/否与段名] | [A/C implement 或 skip] |
| 月报 | [是/否与段名] | [是/否与段名] | [无/具体段名] | [是/否与段名] | [A/C implement 或 skip] |
| 项目复盘 | [是/否与段名] | [是/否与段名] | [无/具体段名] | [是/否与段名] | [B implement 或 skip] |
```

- [ ] **Step 4: 执行实施闸门**

只有当 A（规则竞争/填充）、B（无关个人锚点）或 C（质量自检逐项自证）在对应样本中可观察到时，才执行其后续任务。三项均为 `skip` 时停止，不修改运行文件，并在本地记录“当前优化已足够”。

### Task 2: 先补静态回归，锁定通过闸门的行为边界

**Files:**
- Modify: `tests/review-workflow-contract.tests.ps1`
- Modify: `tests/quality-baseline.tests.ps1`

**Interfaces:**
- Consumes: Task 1 中为 `implement` 的候选项。
- Produces: 修改前失败、修改后通过的文本契约检查。


- [ ] **Step 1: 添加候选 A 的失败断言（仅在 A 为 implement 时）**

在 `tests/review-workflow-contract.tests.ps1` 的共享契约断言后加入：

```powershell
Assert-Matches '.claude/shared/contracts/review-synthesis.md' '\u786c\u8d28\u91cf\u95e8'
Assert-Matches '.claude/shared/contracts/review-synthesis.md' '\u7a33\u5b9a\u5bfc\u822a'
Assert-Matches '.claude/shared/contracts/review-synthesis.md' '\u5224\u65ad\u63d2\u69fd'
```

仅当 C 为 `implement` 时，在同一区域额外加入：

```powershell
Assert-Matches '.claude/shared/contracts/review-synthesis.md' '\u5f02\u5e38\u62ab\u9732'
```

- [ ] **Step 2: 添加候选 B 的失败断言（仅在 B 为 implement 时）**

在项目综合代理断言后加入：

```powershell
Assert-Matches '.claude/agents/project-synthesis.md' '\u9879\u76ee\u951a\u70b9'
Assert-Matches '.claude/agents/project-synthesis.md' '\u4ec5\u5f53\u7528\u6237\u6750\u6599\u660e\u786e\u8bf4\u660e'
Assert-Matches '.claude/agents/project-synthesis.md' '\u9879\u76ee\u951a\u70b9\u4e0d\u8db3'
```

- [ ] **Step 3: 运行测试并确认其因缺少新契约而失败**

Run: `powershell -ExecutionPolicy Bypass -File tests/review-workflow-contract.tests.ps1`  
Expected: FAIL，失败信息只指向本任务新加入的断言。


- [ ] **Step 4: 扩展质量基线检查（按候选决定添加）**

在 `tests/quality-baseline.tests.ps1` 的 `review-synthesis.md` 检查附近加入：

```powershell
Assert-Contains '.claude/shared/contracts/review-synthesis.md' '硬质量门'
Assert-Contains '.claude/shared/contracts/review-synthesis.md' '稳定导航'
Assert-Contains '.claude/shared/contracts/review-synthesis.md' '判断插槽'
```

仅当 C 为 `implement` 时，再加入：

```powershell
Assert-Contains '.claude/shared/contracts/review-synthesis.md' '异常披露'
```

### Task 3: 最小化修改运行契约与综合代理

**Files:**
- Modify: `.claude/shared/contracts/review-synthesis.md`
- Modify: `.claude/agents/weekly-synthesis.md`
- Modify: `.claude/agents/monthly-synthesis.md`
- Modify: `.claude/agents/project-synthesis.md`
- Modify: `docs/analysis-standards.md`

**Interfaces:**
- Consumes: Task 1 的候选决定与 Task 2 的失败测试。
- Produces: 分层规则、项目优先锚点、异常披露；不改变 workflow 接口或输出路径。

- [ ] **Step 1: 实现候选 A 的三层规则（仅在 A 为 implement 时）**

将 `review-synthesis.md` 中六问的逐项“必须覆盖”改为“可按判断启用的插槽”，并在“判断驱动展开”前加入以下语义：

```markdown
## 规则层级

### 硬质量门

重要结论必须有证据或降级；会改变行动、取舍或评价的判断必须检查限制或可信替代解释；方向锚点检查与可验证行动不可省略。

### 稳定导航

YAML frontmatter、标题、聊天摘要、复盘六问与质量自检保留为稳定阅读路径。

### 判断插槽

目标漂移、主观感受、他人反馈、成功链条、自我评价偏差等只在材料出现且会改变判断时写入；不得作为无条件覆盖清单。
```

- [ ] **Step 2: 实现候选 C 的异常披露（仅在 C 为 implement 时）**

在共享契约中将 `## 质量自检` 定义为“异常披露”：只报告证据不足、方向锚点不足、缺少基线或视角失败；无异常时只输出 `质量门已通过；无影响本次判断的已知缺口。`。同步周报和月报代理，删除任何要求逐项展示合规状态的表述。

- [ ] **Step 3: 实现候选 B 的项目优先锚点（仅在 B 为 implement 时）**

在 `project-synthesis.md` 将方向锚点检查替换为：先从项目原始目标、验收口径、里程碑、关键约束提取 `项目锚点`；只有用户材料明确说明项目服务某个 `context.current` 长期方向时，才增加该个人关联。项目材料不足时明确写 `项目锚点不足`，不得以个人方向替代。

- [ ] **Step 4: 同步分析标准的适用范围**

在 `docs/analysis-standards.md` 的判断驱动说明中明确：旧文中“每条/每个/必须”的字段列举属于判断插槽或适用于材料充分情形；硬质量门以 `review-synthesis.md` 为唯一运行真相。保留事实、因果、行动与证据边界的质量要求。

- [ ] **Step 5: 运行新增静态测试**

Run: `powershell -ExecutionPolicy Bypass -File tests/review-workflow-contract.tests.ps1`  
Expected: PASS。

### Task 4: 同步用户版并执行完整回归

**Files:**
- Modify: `packaging/zhiji-user-overlay/.claude/shared/contracts/review-synthesis.md`（由共享分类决定的镜像）
- Modify: `packaging/zhiji-user-overlay/.claude/agents/weekly-synthesis.md`
- Modify: `packaging/zhiji-user-overlay/.claude/agents/monthly-synthesis.md`
- Modify: `packaging/zhiji-user-overlay/.claude/agents/project-synthesis.md`
- Modify: `packaging/zhiji-user-overlay/docs/analysis-standards.md`
- Generated: `zhiji-user/` 对应文件

**Interfaces:**
- Consumes: Task 3 主项目文件。
- Produces: 与 `packaging/zhiji-user-boundaries.json` 中 shared 规则一致的用户版产物。

- [ ] **Step 1: 导出用户版**

Run: `powershell -ExecutionPolicy Bypass -File scripts/export-zhiji-user.ps1`  
Expected: 输出 `zhiji-user export complete`，且不手工编辑生成目录。

- [ ] **Step 2: 运行静态与分发回归**

Run:

```powershell
powershell -ExecutionPolicy Bypass -File tests/quality-baseline.tests.ps1
powershell -ExecutionPolicy Bypass -File tests/review-workflow-contract.tests.ps1
powershell -ExecutionPolicy Bypass -File tests/distribution-boundary.tests.ps1
```

Expected: 三个命令均输出 `PASS`。

- [ ] **Step 3: 检查范围**

Run: `git diff --check; git status --short`  
Expected: 只出现 Task 3/4 的主项目、用户版镜像、测试与必要发布治理文件；不应出现新 agent、workflow、命令或数据文件。

### Task 5: 使用同一真实材料复跑并作发布决定

**Files:**
- Modify: `output/review-quality-baseline-2026-07-31.md`（本地验收结论）
- Modify when and only when accepted: `VERSION`, `PROJECT_STATUS.md`, `CHANGELOG.md`, `AGENTS.md`, `CLAUDE.md`

**Interfaces:**
- Consumes: Task 1 基线、Task 4 回归结果。
- Produces: 保留/回退每项候选的证据化决定。

- [ ] **Step 1: 复跑相同三条命令**

```text
/weekly-review 2026-W28
/monthly-review 2026-06
/project-review 复盘生成质量优化验收
```

- [ ] **Step 2: 对照四项指标并写决定**

在本地验收记录为 A/B/C 分别写 `保留` 或 `回退`。每项保留必须同时证明：减少不改变判断的内容或增加清晰判断/行动、证据可追溯性不退步、没有提高调用/读取成本。

- [ ] **Step 3: 处理未通过候选**

仅撤回未通过候选对应的最小文本和测试断言；重新运行 Task 4 的三条测试，直到通过。不得用新增规则掩盖未通过结果。

- [ ] **Step 4: 记录发布事实并提交**

仅对保留的运行行为：按 `AGENTS.md` 将修订号加一，同步 `PROJECT_STATUS.md` 与 `CHANGELOG.md`，确认 `AGENTS.md`/`CLAUDE.md` 字节一致；运行全部回归后再执行本地提交。若全部候选回退，则不改版本、状态或 CHANGELOG，只保留 gitignored 验收记录。
