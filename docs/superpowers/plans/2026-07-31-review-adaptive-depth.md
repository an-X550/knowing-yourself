# 复盘自适应深度改造 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 在不改变复盘入口、六问导航和运行兼容性的前提下，让周报、月报和项目复盘按证据强度与决策影响自适应展开。

**Architecture:** 共享 `review-synthesis` 契约定义不可放松的质量门槛与可自适应的展开条件；三个 synthesis agent 只保留各自周期差异。静态测试锚定新行为与既有兼容边界，用户版由 overlay 和既有导出脚本同步。

**Tech Stack:** Markdown runtime contracts and agents, PowerShell static contract tests, Node.js workflow summary extraction, PowerShell user-package export.

## Global Constraints

- 仅覆盖周报、月报、项目复盘；不改年度复盘、人生设计、命令入口、工作流、路径和输出目录。
- 保留 YAML frontmatter、聊天摘要边界、六问一级标题及周报用户回应区。
- 重要结论的证据/降级、反例或限制、方向锚点缺席检查、可检查行动不得放松。
- 不新增 agent、command、workflow、配置、报告类型、评分体系或大规模端到端测试。
- 不设为完整感服务的最低篇幅；无新增判断的栏目允许简写或明确说明。
- 修改共享运行文件后同步 overlay、导出 `zhiji-user/` 并通过分发边界检查。
- 发布性行为变更按规范更新 `VERSION`、`PROJECT_STATUS.md`、`CHANGELOG.md` 后本地提交；不推送。

---

### Task 1: 先建立自适应深度的静态回归边界

**Files:**
- Modify: `tests/review-workflow-contract.tests.ps1`
- Modify: `tests/quality-baseline.tests.ps1`
- Modify: `docs/quality-baseline-matrix.md`

**Interfaces:**
- Consumes: 测试既有的 `Read-Utf8`、`Add-Failure`、`Assert-Contains`。
- Produces: 周/月/项目 synthesis 和共享契约必须遵守的自适应深度检查。

- [ ] **Step 1: 写失败断言**

在 `tests/review-workflow-contract.tests.ps1` 的用户回应区检查后增加：

```powershell
foreach ($relativePath in @(
  '.claude/shared/contracts/review-synthesis.md',
  '.claude/agents/weekly-synthesis.md',
  '.claude/agents/monthly-synthesis.md',
  '.claude/agents/project-synthesis.md'
)) {
  foreach ($expected in @('判断驱动展开', '无新增判断')) {
    if ((Read-Utf8 $relativePath) -notmatch [regex]::Escape($expected)) {
      Add-Failure "$relativePath missing adaptive-depth rule: $expected"
    }
  }
}
Assert-Contains '.claude/agents/weekly-synthesis.md' '1–3 个影响下周决策的判断'
Assert-Contains '.claude/agents/monthly-synthesis.md' '2–3 个影响下月决策的判断'
Assert-Contains '.claude/agents/project-synthesis.md' '由项目复杂度决定'
```

在 `tests/quality-baseline.tests.ps1` 增加：

```powershell
Assert-Contains '.claude/shared/contracts/review-synthesis.md' '判断驱动展开'
Assert-Contains '.claude/shared/contracts/review-synthesis.md' '不为覆盖清单而重复正文'
Assert-Contains 'docs/quality-baseline-matrix.md' 'adaptive-depth'
```

在矩阵的 `weekly-monthly-review` 与 `project-review` 行加入 `adaptive-depth`；在“不变约束”下写明“适配深度不等于省略证据、方向锚点或行动检查”。

- [ ] **Step 2: 运行并确认红灯**

Run: `powershell -ExecutionPolicy Bypass -File tests/review-workflow-contract.tests.ps1`

Expected: FAIL，报出缺少 `判断驱动展开` 或 `无新增判断`；现有摘要和用户回应区检查仍执行。

- [ ] **Step 3: 提交红灯基线**

```powershell
git add tests/review-workflow-contract.tests.ps1 tests/quality-baseline.tests.ps1 docs/quality-baseline-matrix.md
git commit -m "test: define adaptive review depth contract"
```

### Task 2: 收敛共享复盘契约与质量标准

**Files:**
- Modify: `.claude/shared/contracts/review-synthesis.md`
- Modify: `docs/analysis-standards.md`
- Modify: `docs/methodology-review.md`
- Modify: 上述三个文件在 `packaging/zhiji-user-overlay/` 中的镜像

**Interfaces:**
- Consumes: Task 1 的 `判断驱动展开`、`无新增判断` 断言。
- Produces: 三个综合代理可直接消费的统一写作协议，主项目与 overlay 逐字节一致。

- [ ] **Step 1: 写入共享协议**

在 `review-synthesis.md` 的“六问写作协议”后加入：

```markdown
## 判断驱动展开

六问是稳定导航，不是逐栏填空表。每节只写会改变本周期评价、重来选择或后续行动的判断；同一证据不得跨节重复铺陈。

没有新增判断时，可用一句话说明“无新增判断”并转入下一节；不得为了覆盖清单补写目标、感受、他人反馈、优势或偏差。

展开深度由证据强度和决策影响共同决定：存在证据冲突、关键取舍、策略调整或高风险不确定性时展开；背景事实、重复证据和不改变行动的信息压缩或省略。

不可省略的是重要结论的证据/降级、关键判断的反例或限制、方向锚点缺席检查，以及从判断推导出的可检查行动。不为覆盖清单而重复正文。
```

将各六问的“必须覆盖”改为“出现且会改变判断时覆盖”，但保留方向锚点、验证沉淀、根因、反例和行动链。将主题综合原则第一条改为“六问是稳定导航；主题只能在六问内部归并”。

在 `analysis-standards.md` 中，把“每章 1–3 要点”“每目标必须百分比/标签”“必须开放性问题”“必须展示 5Why 链条”等绝对表述改为仅在材料充分且会改变判断时使用；不可量化时必须写证据边界，不伪造百分比。保留证据、明确判断、可改变根因、行动检查。

在 `methodology-review.md` 补入：`六问提供稳定阅读路径；栏目深度必须服从证据和决策价值，而不是表面完整度。`

- [ ] **Step 2: 同步 overlay**

```powershell
Copy-Item '.claude/shared/contracts/review-synthesis.md' 'packaging/zhiji-user-overlay/.claude/shared/contracts/review-synthesis.md' -Force
Copy-Item 'docs/analysis-standards.md' 'packaging/zhiji-user-overlay/docs/analysis-standards.md' -Force
Copy-Item 'docs/methodology-review.md' 'packaging/zhiji-user-overlay/docs/methodology-review.md' -Force
```

- [ ] **Step 3: 验证共享层并提交**

Run: `powershell -ExecutionPolicy Bypass -File tests/review-workflow-contract.tests.ps1`

Expected: 共享契约断言通过，但三个 agent 的新断言仍失败。

```powershell
git add .claude/shared/contracts/review-synthesis.md docs/analysis-standards.md docs/methodology-review.md packaging/zhiji-user-overlay/.claude/shared/contracts/review-synthesis.md packaging/zhiji-user-overlay/docs/analysis-standards.md packaging/zhiji-user-overlay/docs/methodology-review.md
git commit -m "refactor: make review depth judgment-driven"
```

### Task 3: 让三个综合代理消费自适应协议

**Files:**
- Modify: `.claude/agents/weekly-synthesis.md`
- Modify: `.claude/agents/monthly-synthesis.md`
- Modify: `.claude/agents/project-synthesis.md`
- Modify: 三个文件在 `packaging/zhiji-user-overlay/.claude/agents/` 中的镜像

**Interfaces:**
- Consumes: Task 2 的共享 `判断驱动展开` 协议。
- Produces: 三种复盘在不改标题、摘要或路径接口的前提下按周期差异展开。

- [ ] **Step 1: 更新周报规则**

将“只聚焦 `1-3` 个重点”替换为：`只保留 1–3 个影响下周决策的判断；无新增判断时明确简写，不为覆盖清单而重复正文。` 补入：`按共享契约的“判断驱动展开”决定每节深度；方向锚点缺席和行动检查不得因简写省略。` 保留 3Why、最小实验、摘要和用户回应区。

- [ ] **Step 2: 更新月报规则**

保留 2–3 主主题、验证沉淀、方向锚点和 life-design 升级。将主题“补齐”清单改为：`为每个保留主题提供足以改变判断的证据与反例/边界；若某字段没有新增决策价值，不重复展开。` 将第一条改为：`整份月报只保留 2–3 个影响下月决策的判断；无新增判断时明确简写。`

- [ ] **Step 3: 更新项目复盘规则**

紧接“项目复盘的特点”加入：`展开由项目复杂度决定；无新增判断时明确写“无新增判断”，不得为通用清单补写协作、流程或机制分析。` 在“内层重点”前写明：下列内容仅在有材料且会改变结论、重来选择或后续机制时覆盖。

- [ ] **Step 4: 同步、验证、提交**

```powershell
Copy-Item '.claude/agents/weekly-synthesis.md' 'packaging/zhiji-user-overlay/.claude/agents/weekly-synthesis.md' -Force
Copy-Item '.claude/agents/monthly-synthesis.md' 'packaging/zhiji-user-overlay/.claude/agents/monthly-synthesis.md' -Force
Copy-Item '.claude/agents/project-synthesis.md' 'packaging/zhiji-user-overlay/.claude/agents/project-synthesis.md' -Force
powershell -ExecutionPolicy Bypass -File tests/review-workflow-contract.tests.ps1
powershell -ExecutionPolicy Bypass -File tests/quality-baseline.tests.ps1
git add .claude/agents packaging/zhiji-user-overlay/.claude/agents
git commit -m "refactor: adapt review report depth to evidence"
```

Expected: 两个测试 PASS；现有全文摘要、用户回应区和工作流接口断言不变。

### Task 4: 导出用户版、记录发布状态并完成回归

**Files:**
- Modify: `zhiji-user/` 的生成副本
- Modify: `VERSION`
- Modify: `PROJECT_STATUS.md`
- Modify: `CHANGELOG.md`

**Interfaces:**
- Consumes: 已同步的 overlay 与 `scripts/export-zhiji-user.ps1`。
- Produces: 用户版与主项目一致、版本/状态/发布记录同步的可发布状态。

- [ ] **Step 1: 导出并检查分发边界**

```powershell
powershell -ExecutionPolicy Bypass -File scripts/export-zhiji-user.ps1
powershell -ExecutionPolicy Bypass -File tests/distribution-boundary.tests.ps1
```

Expected: PASS；共享文件逐字节一致。

- [ ] **Step 2: 更新版本与发布记录**

将 `VERSION` 从 `1.8.9` 升至 `1.8.10`。在 `PROJECT_STATUS.md` 的当前进度记录：周/月/项目复盘保持六问导航，按证据与决策价值伸缩；真实样本验收尚未完成。

在 `CHANGELOG.md` 顶部增加（以实际时间替换 `HH:MM`）：

```markdown
## [2026-07-31 HH:MM] [优化] 复盘改为判断驱动的自适应深度 (v1.8.9 -> v1.8.10)

- **受影响文件**: 复盘综合契约、周/月/项目综合代理、质量基线测试、用户版镜像与发布状态文件
- **改动摘要**: 周报、月报和项目复盘继续使用复盘六问作导航，但只展开会改变评价、重来选择或后续行动的判断；证据、边界、方向缺席和行动检查仍为不可省略的质量门槛。
```

- [ ] **Step 3: 完整验证并提交发布**

```powershell
powershell -ExecutionPolicy Bypass -File tests/review-workflow-contract.tests.ps1
powershell -ExecutionPolicy Bypass -File tests/quality-baseline.tests.ps1
powershell -ExecutionPolicy Bypass -File tests/distribution-boundary.tests.ps1
powershell -ExecutionPolicy Bypass -File tests/project-integrity.tests.ps1
git diff --check
git status --short
git add VERSION PROJECT_STATUS.md CHANGELOG.md zhiji-user
git commit -m "feat: adapt review depth to decision value"
```

Expected: 四个测试 PASS，`git diff --check` 无输出；不执行 `git push`。没有真实输入对照时，不得宣称生成质量已被证明提升。

## Plan Self-Review

- 覆盖性：Task 1 建立验收边界；Task 2 修改共享契约和质量标准；Task 3 修改三个目标代理；Task 4 同步用户版、发布事实和回归。设计中的范围、非目标、质量门槛、适应规则、风险控制与验收都有对应步骤。
- 无占位项：没有待定项、未定义的测试或模糊实现；所有改动都有路径、文字或命令。
- 接口一致性：测试锚点 `判断驱动展开` 与 `无新增判断` 在共享契约和三个 agent 一致；用户版由共享/导出机制同步；摘要工作流接口未改变。
