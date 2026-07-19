# 主题思考合并式质量写入 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 让主题思考的创建和更新默认执行第一性原理质量审查并将新信息与既有内容合并，同时逐篇审查和优化全部现有主题。

**Architecture:** `topic-thinking.md` 是唯一运行协议：先定义候选信息的保留门槛，再定义更新时的逐项合并决策和行动生命周期。主题模板只提供可伸缩的变更入口；PowerShell 契约测试验证主项目、overlay 与用户版都含有默认审查和非追加写入规则。

**Tech Stack:** UTF-8 Markdown、PowerShell 静态契约测试、Git。

## Global Constraints

- 不新增用户命令、模式或额外口头触发；第一性原理质量审查是主题创建和更新的默认步骤。
- 保持用户确认写入、路径安全、0–6 阅读路径、最多一个进行中实验和用户版三份运行副本逐字节一致。
- 新信息必须逐项分类为 `保留`、`修正`、`替换`、`合并`、`归档到观点演化` 或 `不写入`；禁止无判断的追加。
- 行动不设数量目标；行动可新增、修正、替换、完成或停止，当前行动卡只显示仍有效的最小入口。
- 未改变判断、行动或验证的信息不写入主题正文；来源材料只保留入口。

---

### Task 1: 用失败测试锁定默认审查与合并语义

**Files:**
- Modify: `tests/topic-thinking-contract.tests.ps1`
- Test: `tests/topic-thinking-contract.tests.ps1`

**Interfaces:**
- Consumes: 三份运行契约与用户版主题模板。
- Produces: 静态断言，证明创建/更新默认审查、逐项合并决策和行动生命周期不可被后续改动移除。

- [ ] **Step 1: 添加缺失规则断言**

  在 `$contractPaths` 的 `Assert-ContainsAll` 中加入：`默认`、`创建和更新`、`保留.*修正.*替换.*合并.*归档.*不写入`、`完成或停止`、`不得.*追加`、`来源.*入口`。模板断言加入“变更摘要”和“当前仍有效”。

- [ ] **Step 2: 运行并确认失败原因正确**

  Run: `powershell -ExecutionPolicy Bypass -File tests/topic-thinking-contract.tests.ps1`

  Expected: `FAIL: topic thinking contract checks`，失败项只指向尚未存在的默认审查、合并决策、行动生命周期和模板变更入口。

### Task 2: 在运行契约中实现默认质量审查与合并更新

**Files:**
- Modify: `.claude/shared/contracts/topic-thinking.md`
- Modify: `packaging/zhiji-user-overlay/.claude/shared/contracts/topic-thinking.md`
- Modify: `zhiji-user/.claude/shared/contracts/topic-thinking.md`
- Test: `tests/topic-thinking-contract.tests.ps1`

**Interfaces:**
- Consumes: Task 1 的断言与既有内容质量门槛。
- Produces: 所有主题创建和更新入口共用的“候选 → 决策 → 写入”协议。

- [ ] **Step 1: 新增“默认质量审查与合并更新”小节**

  写明创建和更新都默认按真实问题、事实、假设、约束/代价、最小验证杠杆审查；用户不必额外说“依据第一性原理分析”。显式请求仍可要求更深复核，但不是质量闸门的开关。

- [ ] **Step 2: 定义逐项合并决策**

  对每条候选判断、反例、行动或来源，先与现有内容比较，再选择：`保留`（仍是必要依据）、`修正`（核心成立但边界变化）、`替换`（新证据否定旧结论）、`合并`（同一问题的重复表达）、`归档到观点演化`（历史变化仍有解释价值）、`不写入`（不改变判断/行动/验证）。明确禁止未经比较直接追加。

- [ ] **Step 3: 定义行动生命周期与冲突处理**

  行动新增前检查是否重复、被替代或已失效；完成、停止或被替代的行动从 `0. 当前行动卡` 与 `5. 下一次怎么做` 移除，必要时在 `6. 我的观点演化路径` 留简短原因。`4. 值得保留的行动` 只保留可复用的稳定动作，不承接一次性任务；当前仍有效的行动数量由现实需要决定。

- [ ] **Step 4: 同步三份副本并转绿**

  将主契约的完全相同文本同步到 overlay 与 `zhiji-user/`，运行：

  ```powershell
  powershell -ExecutionPolicy Bypass -File tests/topic-thinking-contract.tests.ps1
  ```

  Expected: `PASS: topic thinking contract checks`。

### Task 3: 将模板改为合并式更新入口

**Files:**
- Modify: `packaging/zhiji-user-overlay/关于我/templates/thinking-topic.template.md`
- Modify: `zhiji-user/关于我/templates/thinking-topic.template.md`
- Test: `tests/topic-thinking-contract.tests.ps1`

**Interfaces:**
- Consumes: Task 2 的分类和行动生命周期。
- Produces: 创建/更新时可见的简短提示，不把主题模板变成审计表。

- [ ] **Step 1: 在模板注释中加入更新提示**

  在前置注释加入：“写入前先与现有内容比较；只写当前仍有效、会改变判断/行动/验证的信息；重复内容合并，被替代行动移出当前卡。”

- [ ] **Step 2: 在 `6. 我的观点演化路径` 加入最小变更摘要格式**

  使用一行格式：`- YYYY-MM-DD：保留 / 修正 / 替换 / 合并 / 停止 —— 原因。` 仅在实质变化时写，不记录每次聊天过程。

- [ ] **Step 3: 运行模板与副本测试**

  Run: `powershell -ExecutionPolicy Bypass -File tests/topic-thinking-contract.tests.ps1`

  Expected: `PASS: topic thinking contract checks`。

### Task 4: 全量审查并优化现有主题

**Files:**
- Modify: `关于我/思考/*.md`（排除 `index.md`，当前为 24 份主题）
- Create: `关于我/思考/quality-review-2026-07-19.md`（Git 忽略的逐篇审查清单）
- Test: 只读 PowerShell 覆盖检查与 `tests/topic-thinking-contract.tests.ps1`

**Interfaces:**
- Consumes: 新契约与模板。
- Produces: 每个现有主题均有可回查的质量结论，且实际内容只保留当前有效、非重复、可验证的信息。

- [ ] **Step 1: 建立逐篇审查清单**

  在 `quality-review-2026-07-19.md` 为 24 份主题逐篇建立一行，字段为：`主题 / 核心问题是否仍成立 / 判断或证据决策 / 当前行动决策 / 重复与过期内容决策 / 已执行修改 / 复核结论`。每个字段只能填入 Task 2 定义的分类或具体依据，不能填“看起来没问题”。

- [ ] **Step 2: 逐篇按第一性原理审查**

  对每份主题依次检查：真实问题是否仍是当前问题；事实、假设、价值和约束是否混淆；新旧判断是否重复或冲突；行动是否仍直接回应关键约束、可控、可触发且可观察；来源是否只是堆积背景。对每项内容记录 `保留 / 修正 / 替换 / 合并 / 归档到观点演化 / 不写入` 决策。

- [ ] **Step 3: 仅按审查结论优化主题文件**

  删除或合并重复背景；将被新证据否定的判断替换或写入 `6. 我的观点演化路径`；移除完成、停止、被替代或无法验证的行动；把仍有效的行动压缩到 `0. 当前行动卡`，只保留当前最小必要入口。无内容问题的主题不为覆盖率改写，但审查清单必须说明保留依据。

- [ ] **Step 4: 验证全量覆盖与主题结构**

  运行只读 PowerShell 检查，确认审查清单覆盖 24/24 主题；每篇仍含 0–6 标题；行动卡没有旧的 `项目 / 内容` 固定字段；每篇保留的行动都有触发和观察/停止条件，或明确“当前不行动”。人工复读所有标为修正、替换、合并、归档或停止的主题，确认它们与审查清单一致。

### Task 5: 发布同步与全量验证

**Files:**
- Modify: `VERSION`
- Modify: `README.md`
- Modify: `PROJECT_STATUS.md`
- Modify: `CHANGELOG.md`
- Test: `tests/topic-thinking-contract.tests.ps1`, `tests/distribution-boundary.tests.ps1`

**Interfaces:**
- Consumes: Task 2、Task 3 与 Task 4 的完成状态。
- Produces: 可发布的默认合并质量机制与全量审查记录。

- [ ] **Step 1: 执行完整回归与同步验证**

  Run:

  ```powershell
  powershell -ExecutionPolicy Bypass -File tests/topic-thinking-contract.tests.ps1
  powershell -ExecutionPolicy Bypass -File tests/distribution-boundary.tests.ps1
  git diff --check
  ```

  Expected: 三项退出码均为 0；三份运行契约哈希相同。

- [ ] **Step 2: 更新发布元数据并提交**

  修订 `VERSION`、README 徽章和 `PROJECT_STATUS.md` 当前版本；在 `CHANGELOG.md` 顶部追加 `[功能]` 或 `[修复]` 条目，说明创建/更新默认审查与合并写入，以及全量现有主题审查已经完成。完成验证后仅提交可追踪的契约、模板、测试和治理文档；个人主题与审查清单继续保持 Git 忽略。
