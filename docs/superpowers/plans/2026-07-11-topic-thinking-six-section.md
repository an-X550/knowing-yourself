# Topic Thinking Six-Question Structure Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use `superpowers:subagent-driven-development` (recommended) or `superpowers:executing-plans` to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the abstract topic-thinking structure with six user-readable questions, require evidence-based external review, and ensure each topic leads to one verifiable active experiment.

**Architecture:** Keep one authoritative runtime contract in `.claude/shared/contracts/topic-thinking.md`. The user-overlay contract and template are the distribution sources; `scripts/export-zhiji-user.ps1` regenerates `zhiji-user/`. Extend the existing PowerShell contract test to lock the new headings and quality constraints, then migrate the existing local information-anxiety topic as an acceptance sample.

**Tech Stack:** UTF-8 Markdown, PowerShell test scripts, JSON manifest-driven PowerShell export, Git.

## Global Constraints

- Do not add a command, agent, hook, report type, topic subdirectory, or second review file.
- Preserve confirmation-before-write, dynamic topic paths, privacy boundaries, current-expression priority, and maximum-two-topic recall.
- Every serious AI challenge must name an evidence gap, counterexample, inference leap, value conflict, risk, or alternative explanation.
- A topic has at most one active experiment; untested proposals remain experiments, not conclusions.
- Maintain byte-identical main/overlay/exported topic-thinking contracts and tracked generic templates.
- Follow UTF-8 reads and writes. Bump the patch version from `1.6.8` to `1.6.9` for this user-visible runtime behavior change.

---

### Task 1: Lock the six-question contract with failing tests

**Files:**
- Modify: `tests/topic-thinking-contract.tests.ps1:65-105`
- Test: `tests/topic-thinking-contract.tests.ps1`

**Interfaces:**
- Consumes: the three synchronized contract paths and overlay generic template already listed in the test.
- Produces: static regression assertions for required headings and quality constraints.

- [ ] **Step 1: Replace the template heading expectations with the six user questions**

In the `$requiredHeading` array, replace the old five patterns with:

```powershell
@(
  '## \u6211\u5728\u56f0\u6270\u4ec0\u4e48\uff1f',
  '## \u6211\u76ee\u524d\u600e\u4e48\u7406\u89e3\uff1f',
  '## \u6211\u51ed\u4ec0\u4e48\u8fd9\u6837\u60f3\uff0c\u54ea\u91cc\u53ef\u80fd\u9519\uff1f',
  '## \u4ec0\u4e48\u503c\u5f97\u7ee7\u7eed\u4fdd\u7559\uff1f',
  '## \u63a5\u4e0b\u6765\u600e\u4e48\u8bd5\uff1f',
  '## \u6211\u7684\u770b\u6cd5\u600e\u4e48\u53d8\u4e86\uff1f'
)
```

- [ ] **Step 2: Add failing contract assertions for the new quality rules**

Add these escaped patterns to the `Assert-ContainsAll $path` array for every contract path:

```powershell
'\u4e8b\u5b9e.*\u63a8\u65ad.*\u5efa\u8bae',
'\u8bc1\u636e\u7f3a\u53e3|\u53cd\u4f8b|\u63a8\u7406\u8df3\u8dc3|\u4ef7\u503c\u51b2\u7a81|\u66ff\u4ee3\u89e3\u91ca',
'\u4e00\u4e2a.*\u8fdb\u884c\u4e2d.*\u884c\u52a8\u5b9e\u9a8c',
'\u5b9e\u8d28\u53d8\u5316.*\u89c2\u70b9\u6f14\u5316'
```

- [ ] **Step 3: Run the targeted test and verify it fails for missing headings and constraints**

Run:

```powershell
pwsh -NoProfile -File tests/topic-thinking-contract.tests.ps1
```

Expected: `FAIL: topic thinking contract checks` reporting missing six-question headings and new quality-rule patterns.

### Task 2: Implement the authoritative contract and distribution template

**Files:**
- Modify: `.claude/shared/contracts/topic-thinking.md:13-25`
- Modify: `packaging/zhiji-user-overlay/.claude/shared/contracts/topic-thinking.md:13-25`
- Modify: `packaging/zhiji-user-overlay/关于我/templates/thinking-topic.template.md:11-19`
- Generated: `zhiji-user/.claude/shared/contracts/topic-thinking.md`
- Generated: `zhiji-user/关于我/templates/thinking-topic.template.md`
- Test: `tests/topic-thinking-contract.tests.ps1`

**Interfaces:**
- Consumes: six-heading and quality-rule assertions from Task 1.
- Produces: the authoritative six-question contract and a generic user template that the export script mirrors into `zhiji-user/`.

- [ ] **Step 1: Replace the contract’s discussion and structure paragraphs**

In both source contracts, require that discussion and persisted topics use the six approved headings. State these exact responsibilities:

```markdown
- `我在困扰什么？`：记录重复现象、情境、感受和冲突，不抢先解释原因。
- `我目前怎么理解？`：区分事实、推断和价值判断；AI 的观点不能伪装成用户认识。
- `我凭什么这样想，哪里可能错？`：列出来源、反例、证据缺口、推理跳跃、价值冲突、风险或替代解释；严肃挑战必须至少给出其中一项依据。
- `什么值得继续保留？`：保留有证据支持、符合用户价值或已有正向结果的原则、做法、资源，并注明适用边界。
- `接下来怎么试？`：只保留一个进行中的行动实验，写触发条件、最小动作、预期观察和验证时间；未经验证的方案不能称为答案。
- `我的看法怎么变了？`：只有当前认识发生实质变化时才追加，记录保留、修正、反例或仍未解决及其依据。
```

Preserve the existing confirmation gate and dynamic path rules verbatim outside these changed paragraphs.

- [ ] **Step 2: Replace the overlay generic template with six headings and concise fill prompts**

Keep the existing frontmatter, then use:

```markdown
## 我在困扰什么？

<!-- 重复出现的现象、情境、感受或冲突。 -->

## 我目前怎么理解？

<!-- 分开写事实、推断与价值判断。 -->

## 我凭什么这样想，哪里可能错？

<!-- 来源、反例、证据缺口、风险或替代解释。 -->

## 什么值得继续保留？

<!-- 有支持的原则、做法、资源及适用边界。 -->

## 接下来怎么试？

<!-- 一个进行中的行动实验：触发条件、最小动作、预期观察、验证时间。 -->

## 我的看法怎么变了？

<!-- 仅在认识实质变化时追加。 -->
```

- [ ] **Step 3: Export the user edition from the overlay source**

Run:

```powershell
pwsh -NoProfile -File scripts/export-zhiji-user.ps1
```

Expected: export completes successfully and mirrors the source contract/template into `zhiji-user/`.

- [ ] **Step 4: Run the topic-thinking contract test and verify it passes**

Run:

```powershell
pwsh -NoProfile -File tests/topic-thinking-contract.tests.ps1
```

Expected: `PASS: topic thinking contract checks`.

### Task 3: Migrate the current local topic as an acceptance sample

**Files:**
- Modify: `关于我/思考/信息过载、最优解幻觉与不确定性.md`
- Test: manual structure and content review

**Interfaces:**
- Consumes: the six-question responsibilities from Task 2 and the user-confirmed current topic content.
- Produces: one real topic file that proves the headings are understandable, preserves the important concerns, and has only one active experiment.

- [ ] **Step 1: Move current content into the six questions without deleting supported concerns**

Map the existing material as follows:

```text
问题全景                         -> 我在困扰什么？
当前认识中的事实/推断/价值判断   -> 我目前怎么理解？
待验证的假说、限制、日志、资料   -> 我凭什么这样想，哪里可能错？
已吸收的原则                     -> 什么值得继续保留？
7 天信息与反馈实验               -> 接下来怎么试？
观点演化                         -> 我的看法怎么变了？
```

Keep the title and frontmatter. Preserve the user’s distinction between “需要探索信息” and “不能无限追踪信息.”

- [ ] **Step 2: Reduce the active experiment to one testable intervention**

Set the single active experiment to:

```markdown
**实验**：连续 7 天，每天先完成一个主线现实动作，再使用最多 30 分钟的信息探索预算；记录外部反馈和是否因内部信息推迟主线动作。
```

Leave GPT 阅读边界、最小行动和信息三种去向 as supporting rules or later candidates, not parallel active experiments.

- [ ] **Step 3: Perform the acceptance review**

Confirm manually:

```text
- 六个标题都能直接回答用户下次打开时的关键问题。
- “哪里可能错”包含至少一个反例或证据缺口，不只附和现有认识。
- 当前实验只有一个，并具备触发条件、最小动作、观察结果和 7 天验证时间。
- 详细日志和参考文章保持链接入口，不被复制成会话转录。
```

### Task 4: Run full synchronization checks and publish the behavior change

**Files:**
- Modify: `VERSION`
- Modify: `PROJECT_STATUS.md`
- Modify: `CHANGELOG.md`
- Modify: `README.md` only if its current topic-thinking explanation names the old five fields
- Test: `tests/topic-thinking-contract.tests.ps1`
- Test: `tests/project-integrity.tests.ps1`
- Test: `tests/distribution-boundary.tests.ps1`

**Interfaces:**
- Consumes: passing contract test, exported user edition, and migrated acceptance sample.
- Produces: a released patch version with accurate public/runtime documentation and no distribution drift.

- [ ] **Step 1: Search for old five-heading references before editing public documentation**

Run:

```powershell
Get-ChildItem -Recurse -File -Include *.md,*.ps1 | Select-String -Pattern '当前认识 / 形成依据 / 限制与反例 / 未决问题 / 观点演化|## 当前认识|## 形成依据|## 限制与反例|## 未决问题' -Encoding UTF8
```

Expected: only intentional historical material or files scheduled for migration remain. Update README only when it exposes the old topic-file structure to users.

- [ ] **Step 2: Apply release metadata changes**

Set `VERSION` to `1.6.9`. Update `PROJECT_STATUS.md` to state that topic thinking now uses the six-question, evidence-reviewed, single-experiment structure. Generate the changelog timestamp with:

```powershell
Get-Date -Format 'yyyy-MM-dd HH:mm'
```

Then add one topmost `CHANGELOG.md` entry using that generated timestamp:

```markdown
## [generated timestamp] [功能] 收敛主题思考为六问行动闭环 (v1.6.8 -> v1.6.9)

- **受影响文件**: `.claude/shared/contracts/topic-thinking.md`, `packaging/zhiji-user-overlay/`, `zhiji-user/`, `tests/topic-thinking-contract.tests.ps1`, `关于我/思考/信息过载、最优解幻觉与不确定性.md`, `PROJECT_STATUS.md`, `CHANGELOG.md`, `VERSION`
- **改动摘要**: 主题思考改用“困扰、理解、审查、保留、尝试、演化”六个用户问题，要求事实/推断/建议区分和有依据的反例审查，并将行动收敛为单一进行中实验，帮助用户保留思考痕迹并将其转化为可验证改变。
```

- [ ] **Step 3: Run the targeted and distribution regression checks**

Run:

```powershell
pwsh -NoProfile -File tests/topic-thinking-contract.tests.ps1
pwsh -NoProfile -File tests/distribution-boundary.tests.ps1
pwsh -NoProfile -File tests/project-integrity.tests.ps1
```

Expected: all scripts exit `0` and print their respective `PASS` messages.

- [ ] **Step 4: Verify the release state and commit**

Run:

```powershell
Get-Content -Raw -Encoding UTF8 VERSION
Select-String -Path PROJECT_STATUS.md,CHANGELOG.md -Pattern '1\.6\.9|六问' -Encoding UTF8
git diff --check
git status --short
```

Expected: version is `1.6.9`, metadata contains the release description, no whitespace errors, and only intended changes are staged.

Commit:

```powershell
git add -- .claude/shared/contracts/topic-thinking.md packaging/zhiji-user-overlay zhiji-user tests/topic-thinking-contract.tests.ps1 VERSION PROJECT_STATUS.md CHANGELOG.md README.md 关于我/思考/信息过载、最优解幻觉与不确定性.md
git commit -m "feat: refine topic thinking action loop"
```

## Plan Self-Review

- Spec coverage: Tasks 1-2 implement all six headings and hard constraints; Task 3 supplies the real-topic acceptance sample; Task 4 covers versioning, user edition synchronization, documentation search, regression checks, and commit.
- No placeholders: the required headings, assertions, template text, test commands, expected outputs, release version, and changelog wording are explicit.
- Scope: the plan modifies only the existing contract/template/test/export flow and one confirmed local topic; it does not introduce a new runtime entry or subsystem.
