# 第一性原理与输出质量契约 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use `superpowers:subagent-driven-development` (recommended) or `superpowers:executing-plans` to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 在不改变命令入口、文件路径、报告骨架、隐私边界和工作流编排的前提下，使主项目与用户版的 AI 输出更直接、可证、可行动，并支持用户显式以“依据第一性原理分析”复核或压缩任意分析结果。

**Architecture:** 新增一个短小的共享“第一性原理复核”任务契约，专门定义显式触发、场景适配和输出边界；已有日反馈、复盘综合与主题思考契约在收到显式指令时引用它。开发规范负责开发决策时的同类行为；运行时共享原则只提供跨入口的表达底线。用户版通过 overlay 同步运行时规则，但不接收主项目开发治理内容。

**Tech Stack:** Markdown/YAML 契约、PowerShell 静态完整性测试、现有 `scripts/export-zhiji-user.ps1` 导出流程。

## Global Constraints

- 不修改 command 名称、参数、hook matcher、workflow 编排、输出路径、输出文件名、报告一级标题或数据格式。
- 日反馈继续遵守 A-D 输入降级、D0-D6、一个洞察、一个行动、260/320 字上限；显式复核不能扩写为固定五步长文。
- 周/月/项目复盘继续遵守复盘六问、聊天摘要、质量自检和用户回应区。
- 主题思考继续遵守用户确认后才写入、0-6 阅读结构和事实/推断/建议区分。
- 显式“依据第一性原理分析”覆盖默认表达深度，但不覆盖证据、隐私、文件写入确认和安全边界。
- 禁止把“不要谄媚”实现为通用词黑名单；用证据、判断、影响和替代方案的语义要求约束输出。
- `AGENTS.md` 与 `CLAUDE.md` 必须逐字一致；用户版同名文件也必须逐字一致。
- 共享文件须在 `packaging/zhiji-user-boundaries.json` 声明，并保持主项目与 overlay 逐字节一致。
- 本计划仅定义实施步骤；执行前必须先取得用户对本计划的确认。

---

## File Structure

| 文件 | 责任 |
|---|---|
| `.claude/shared/contracts/first-principles-analysis.md` | 显式第一性原理复核的唯一运行时规则源。 |
| `.claude/shared/contracts/daily-feedback.md` | 为日反馈增加显式复核入口，不改变默认结构。 |
| `.claude/shared/contracts/review-synthesis.md` | 为周/月/项目复盘增加显式复核入口，不改变六问结构。 |
| `.claude/shared/contracts/topic-thinking.md` | 为主题和价值取舍增加显式复核入口，不把价值偏好伪装成事实。 |
| `.claude/shared/ai-operating-principles.md` | 定义结论先行、非谄媚、主动给出替代方案的跨入口运行原则。 |
| `.claude/shared/prompt-rules.md` | 索引新契约，并声明显式复核不改变既有输出契约。 |
| `AGENTS.md`、`CLAUDE.md` | 定义开发决策中的第一性原理与沟通规则。 |
| `packaging/zhiji-user-overlay/...` | 维护用户版运行时规则、契约和入口规则的对应来源。 |
| `packaging/zhiji-user-boundaries.json` | 把新增契约声明为 shared，并继续声明用户版差异。 |
| `tests/quality-baseline.tests.ps1` | 静态验证关键入口、契约和显式复核边界仍被消费。 |
| `docs/quality-baseline-matrix.md` | 记录静态测试的边界与人工质量验收样本。 |

## Task 1: 建立显式第一性原理复核契约

**Files:**
- Create: `.claude/shared/contracts/first-principles-analysis.md`
- Modify: `.claude/shared/contracts/daily-feedback.md`
- Modify: `.claude/shared/contracts/review-synthesis.md`
- Modify: `.claude/shared/contracts/topic-thinking.md`
- Modify: `.claude/shared/prompt-rules.md`

**Consumes:** 用户消息中的“依据第一性原理分析”“按第一性原理复核”“第一性原理压缩”等明确指令；既有任务输出、证据和任务契约。

**Produces:** 一个可由日反馈、复盘综合和主题思考共同引用的运行时契约；默认输出结构保持不变。

- [ ] **Step 1: 在质量基线测试中先声明预期的契约与引用点。**

  在 `tests/quality-baseline.tests.ps1` 增加以下静态断言，暂不修改生产契约：

  ```powershell
  Assert-Contains '.claude/shared/contracts/first-principles-analysis.md' '显式触发'
  Assert-Contains '.claude/shared/contracts/daily-feedback.md' 'first-principles-analysis.md'
  Assert-Contains '.claude/shared/contracts/review-synthesis.md' 'first-principles-analysis.md'
  Assert-Contains '.claude/shared/contracts/topic-thinking.md' 'first-principles-analysis.md'
  Assert-Contains '.claude/shared/prompt-rules.md' '第一性原理复核'
  ```

- [ ] **Step 2: 运行测试并确认它因缺失契约和引用而失败。**

  运行：

  ```powershell
  powershell -NoProfile -ExecutionPolicy Bypass -File tests/quality-baseline.tests.ps1
  ```

  预期：退出码为 `1`，并包含 `missing file` 或 `does not contain`，指向新增的第一性原理契约或三个引用位置。

- [ ] **Step 3: 写入最小共享契约。**

  创建的契约必须包含以下精确语义：

  ```markdown
  ## 显式触发

  仅当用户明确要求“依据第一性原理分析”、要求复核/压缩既有结论，或表达等价意图时启用。本契约覆盖默认表达深度，不覆盖证据、隐私、写入确认、安全边界和当前任务的稳定输出结构。

  ## 复核顺序

  1. 指出待解决的真实问题，而不是复述现有方案或表面现象。
  2. 区分已知事实、未验证假设、不可突破约束和价值取舍。
  3. 检查是否沿用惯例、把现象当根因，或遗漏更小的替代路径。
  4. 给出更直接的结论、替代解释或最小验证；证据不足时明确降级判断。

  ## 场景适配

  日反馈优先压缩到“事实/关键假设/最小验证”，不增加第二个洞察或行动；复盘保留六问并把复核结果放回对应章节；主题与价值选择必须把价值、事实、约束和不可消除的代价分开，不输出伪客观的唯一答案。
  ```

  另加“长度与表达”段：内容过长时先删除不改变判断、行动或验证的信息；不得为了展示推理过程复制完整五步模板。加“非谄媚”段：不以礼貌性肯定代替判断；提出问题时同时说明证据、影响与替代路径。

- [ ] **Step 4: 在三个既有任务契约中加入条件引用。**

  - 在 `daily-feedback.md` 的输出规则后加一句：收到显式触发词时读取新契约；保持 D0-D6、单洞察、单行动和长度限制，复核只用于收缩/修正当前判断。
  - 在 `review-synthesis.md` 的主题综合原则后加一句：收到显式触发词时读取新契约；结果必须归入六问或聊天摘要的既有位置，不新增一级标题。
  - 在 `topic-thinking.md` 的“探讨与确认”后加一句：收到显式触发词时读取新契约；价值判断继续以用户选择为主，AI 只能指出冲突、代价、反例或证据缺口。

- [ ] **Step 5: 在共享提示词规则中登记新契约与优先级。**

  在“任务契约索引”增加“显式第一性原理复核 / 压缩 / 质疑既有分析”的行，指向新文件；在“减法边界”增加一条：显式复核可以改变分析深度与措辞，但不得改变命令接口、路径、稳定章节或工作流。

- [ ] **Step 6: 运行质量基线测试并确认通过。**

  运行：

  ```powershell
  powershell -NoProfile -ExecutionPolicy Bypass -File tests/quality-baseline.tests.ps1
  ```

  预期：`PASS: quality baseline checks`。

## Task 2: 固化开发协作与运行表达原则

**Files:**
- Modify: `AGENTS.md`
- Modify: `CLAUDE.md`
- Modify: `.claude/shared/ai-operating-principles.md`
- Modify: `packaging/zhiji-user-overlay/AGENTS.md`
- Modify: `packaging/zhiji-user-overlay/CLAUDE.md`
- Modify: `packaging/zhiji-user-overlay/.claude/shared/ai-operating-principles.md`

**Consumes:** Task 1 的显式复核定义，以及现有“事实、推断、建议”和“发现模式 → 形成行动 → 后续验证”原则。

**Produces:** 开发治理与用户运行入口都能以一致方式处理直接判断、替代方案与显式第一性原理请求。

- [ ] **Step 1: 为两对 AGENTS/CLAUDE 文件添加逐字一致性断言。**

  在 `tests/quality-baseline.tests.ps1` 增加：

  ```powershell
  if ((Get-FileHash AGENTS.md -Algorithm SHA256).Hash -ne (Get-FileHash CLAUDE.md -Algorithm SHA256).Hash) {
    Add-Failure 'main AGENTS.md and CLAUDE.md are not byte-identical'
  }
  if ((Get-FileHash 'packaging/zhiji-user-overlay/AGENTS.md' -Algorithm SHA256).Hash -ne (Get-FileHash 'packaging/zhiji-user-overlay/CLAUDE.md' -Algorithm SHA256).Hash) {
    Add-Failure 'user overlay AGENTS.md and CLAUDE.md are not byte-identical'
  }
  ```

- [ ] **Step 2: 写入主项目开发协作规则。**

  在 `AGENTS.md` 与 `CLAUDE.md` 的开发规范部分增加同一节，要求：结论先行；不作无证据肯定；指出方案问题时写清问题、证据、用户影响和替代方案；技术决策写清真实问题、最小路径和对使用摩擦/验证闭环的影响；用户显式要求第一性原理分析时读取 Task 1 的契约。

  该节必须明确：新功能必要性闸门仍是实施授权门槛，第一性原理复核只是决策质量方法，二者不能相互替代。

- [ ] **Step 3: 写入主项目运行原则。**

  在 `.claude/shared/ai-operating-principles.md` 增加“沟通与决策”节：默认结论先行；事实/推断/建议继续区分；不以赞美替代判断；发现更优路径时说明适用条件和代价；显式第一性原理请求按共享契约处理。

- [ ] **Step 4: 写入用户版的最小等价规则。**

  在 overlay 的 `AGENTS.md` 与 `CLAUDE.md` 增加用户可见的运行入口规则：显式第一性原理分析时按共享契约复核，不扩读全部历史材料，仍遵守隐私和确认写入边界。

  在 overlay 的 `ai-operating-principles.md` 写入与主项目等价的运行表达原则，但不得加入版本、提交、发布、新功能闸门或本地开发流程。

- [ ] **Step 5: 验证两对入口规则逐字一致，并运行质量基线。**

  运行：

  ```powershell
  powershell -NoProfile -Command "(Get-FileHash AGENTS.md).Hash -eq (Get-FileHash CLAUDE.md).Hash; (Get-FileHash 'packaging/zhiji-user-overlay/AGENTS.md').Hash -eq (Get-FileHash 'packaging/zhiji-user-overlay/CLAUDE.md').Hash"
  powershell -NoProfile -ExecutionPolicy Bypass -File tests/quality-baseline.tests.ps1
  ```

  预期：第一条输出两行 `True`；第二条输出 `PASS: quality baseline checks`。

## Task 3: 同步用户版边界、导出并做静态回归

**Files:**
- Modify: `packaging/zhiji-user-boundaries.json`
- Create: `packaging/zhiji-user-overlay/.claude/shared/contracts/first-principles-analysis.md`
- Modify: `packaging/zhiji-user-overlay/.claude/shared/contracts/daily-feedback.md`
- Modify: `packaging/zhiji-user-overlay/.claude/shared/contracts/review-synthesis.md`
- Modify: `packaging/zhiji-user-overlay/.claude/shared/contracts/topic-thinking.md`
- Modify: `packaging/zhiji-user-overlay/.claude/shared/prompt-rules.md`
- Generated: `zhiji-user/` 中对应的受控文件
- Modify: `tests/distribution-boundary.tests.ps1`
- Modify: `docs/quality-baseline-matrix.md`

**Consumes:** 主项目运行时文件、Task 1/2 的静态测试、既有 manifest 的 `mirrorDir` 导出方式。

**Produces:** 用户版获得相同的运行时质量契约；边界测试保证所有 shared 文件逐字节一致。

- [ ] **Step 1: 在边界清单中声明新契约是 shared。**

  在 `packaging/zhiji-user-boundaries.json` 的 `shared` 数组中加入：

  ```json
  ".claude/shared/contracts/first-principles-analysis.md"
  ```

  不把它列为 override：该契约不包含用户版特有路径、隐私描述或开发治理信息。

- [ ] **Step 2: 将所有已改的 shared 任务契约从主项目逐字节复制到 overlay。**

  确认以下文件与主项目哈希一致：

  ```text
  .claude/shared/contracts/first-principles-analysis.md
  .claude/shared/contracts/daily-feedback.md
  .claude/shared/contracts/review-synthesis.md
  .claude/shared/contracts/topic-thinking.md
  ```

  `prompt-rules.md` 与 `ai-operating-principles.md` 继续作为 override，仅手工合并本计划要求的运行时规则，不覆盖用户版路径与隐私规则。

- [ ] **Step 3: 扩充分发边界测试，验证新契约已分类且无运行时漂移。**

  在 `tests/distribution-boundary.tests.ps1` 的现有 shared 遍历保留哈希检查；新增明确断言，确保边界清单包含 `first-principles-analysis.md`，并让失败信息说明“显式复核契约未声明为 shared”。

- [ ] **Step 4: 更新质量基线矩阵。**

  在 `docs/quality-baseline-matrix.md` 为现有 `daily-feedback`、`weekly-monthly-review`、`life-design`/主题思考与 `user-package` 行补充：显式第一性原理复核不改变稳定结构、证据边界或用户版同步边界。

- [ ] **Step 5: 导出用户版并运行全部静态回归。**

  运行：

  ```powershell
  powershell -NoProfile -ExecutionPolicy Bypass -File scripts/export-zhiji-user.ps1
  powershell -NoProfile -ExecutionPolicy Bypass -File tests/distribution-boundary.tests.ps1
  powershell -NoProfile -ExecutionPolicy Bypass -File tests/quality-baseline.tests.ps1
  powershell -NoProfile -ExecutionPolicy Bypass -File tests/project-integrity.tests.ps1
  ```

  预期：导出报告包含 `mirrorDir  .claude`；三个测试分别输出 `PASS: distribution boundary checks`、`PASS: quality baseline checks`、`PASS: project integrity checks`。

## Task 4: 人工质量验收、治理同步与提交

**Files:**
- Modify: `docs/quality-baseline-matrix.md`
- Modify: `PROJECT_STATUS.md`
- Modify: `CHANGELOG.md`
- Modify: `VERSION`

**Consumes:** Task 3 的静态回归和用户认可的代表性输入样本。

**Produces:** 对“语言质量未下降”的人工证据、发布级治理记录和本地提交。

- [ ] **Step 1: 选取四类既有或脱敏样本，分别做前后人工对照。**

  样本必须覆盖：

  1. A 或 B 级单日日志，且包含可被误判为根因的表面现象；
  2. 一份周或月复盘材料，且存在目标与实际投入偏差；
  3. 一段主题思考或价值冲突材料；
  4. 一段“内容太长或结论可疑”的既有输出，并追加“请依据第一性原理分析”。

  对每个样本按以下五项记录通过/不通过及一句证据：`证据准确`、`判断清晰`、`没有无信息量肯定`、`行动或下一步可执行`、`原有结构与长度边界未退化`。

- [ ] **Step 2: 将人工验收结果写入质量基线矩阵。**

  写明样本路径或脱敏摘要、验收日期、五项结果和任何降级原因。若任一项不通过，回到 Task 1-3 修改契约，不得以静态测试通过替代质量验收。

- [ ] **Step 3: 同步版本与项目状态。**

  此次属于兼容的运行提示词/规范优化：将 `VERSION` 的修订号加一；以 `VERSION` 为准更新 `PROJECT_STATUS.md` 的当前版本、当前进度和关键决策，说明新增的是“显式复核契约”，不是新命令或报告形态。

- [ ] **Step 4: 完成同步验证并追加 CHANGELOG。**

  执行：

  ```powershell
  powershell -NoProfile -ExecutionPolicy Bypass -File tests/project-integrity.tests.ps1
  git diff --check
  git status --short
  ```

  确认版本号在 `VERSION`、`PROJECT_STATUS.md` 和受影响公开说明中一致；确认 Markdown 链接存在；确认没有未声明的 overlay 差异。然后按仓库格式在 `CHANGELOG.md` 顶部追加一条 `[修复]` 记录。

- [ ] **Step 5: 本地提交主项目与用户版导出结果。**

  先检查两个仓库的 staged diff，确认没有 `日志/`、`复盘/` 或真实画像数据；再分别提交。提交信息应说明“强化第一性原理复核与输出质量边界”，不得推送。

## Plan Self-Review

- **覆盖性：** 包含显式触发、日/周/月/主题适配、非谄媚表达、用户版同步、静态回归、人工质量验收、版本与发布治理。
- **边界：** 没有新增命令、hook、workflow、文件输出或报告章节；第一性原理仅在用户显式请求时覆盖表达深度。
- **可验证性：** 静态测试验证契约消费与分发一致性；人工样本验证语言质量，避免将结构测试误认为质量证明。
- **风险：** 主要风险是规则过长或与既有契约重复；Task 1 将新契约限定为短契约，Task 4 以“内容压缩且不退化”为验收条件。
