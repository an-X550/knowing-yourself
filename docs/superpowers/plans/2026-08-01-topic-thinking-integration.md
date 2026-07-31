# Topic Thinking Integration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 在用户确认后的主题更新中，要求先重组整篇当前论证，再写入新认知，并以真实主题的脱敏回放验证结果。

**Architecture:** 只修改确认后沉淀契约及其两个分发镜像。测试只检查这条更新规则在三个版本中存在且一致；回放审计独立记录一份私有主题的重建限制、输入影响和四项全文检查，不能以测试替代体验判断。

**Tech Stack:** UTF-8 Markdown、PowerShell 静态回归测试、Git。

## Global Constraints

- 不改首次讨论契约、用户主题正文、入口、workflow、hook、表单、默认读取范围或确认次数。
- 不设篇幅、标题或行动数量目标；段落只按当前论证所需保留。
- 不新增依赖、mock、skip/todo、`|| true`，不放宽既有断言或删除测试。
- 仅在回放明显改善且所有既有检查通过时发布；否则回退候选契约并记录审计结论。

---

### Task 1: 先锁定“整篇重组”规则

**Files:**
- Modify: `tests/topic-thinking-contract.tests.ps1`
- Modify: `.claude/shared/contracts/topic-thinking-persistence.md`
- Modify: `packaging/zhiji-user-overlay/.claude/shared/contracts/topic-thinking-persistence.md`
- Modify: `zhiji-user/.claude/shared/contracts/topic-thinking-persistence.md`

**Interfaces:**
- Consumes: 三份确认后主题更新契约。
- Produces: 三份字节一致的“影响分类 → 当前论证重组 → 全文闭环检查”规则。

- [ ] **Step 1: 写入最小失败断言**

在 `tests/topic-thinking-contract.tests.ps1` 的 persistence 必含模式中加入：`补强.*修正.*反驳.*分支.*行动变化.*不写入`、`先.*当前问题.*当前判断.*受影响`、`改写.*移动.*合并.*删除`、`同一理由.*重复`、`历史.*观点演化`。不要改动原有模式。

- [ ] **Step 2: 验证红灯**

运行：`powershell -ExecutionPolicy Bypass -File tests/topic-thinking-contract.tests.ps1`

预期：失败信息指出三份 persistence 契约缺少新增模式。

- [ ] **Step 3: 写入最小契约规则并同步镜像**

在“更新与全量审查”开头增加一段：每次确认更新先判定新认知的六类影响；以更新后的当前问题、当前判断和受影响章节为中心重组全文；允许改写、移动、合并或删除；将必要历史差异仅放进观点演化；在写入前检查依据是否仍支持判断、理由是否重复、分支/代价/未知是否位于影响判断的位置、行动/验证/等待/转向是否仍由当前判断和约束推出；任一项不成立则继续重组或不写入。

- [ ] **Step 4: 验证绿灯**

运行：`powershell -ExecutionPolicy Bypass -File tests/topic-thinking-contract.tests.ps1`

预期：`PASS: topic thinking contract checks`。

### Task 2: 用真实主题的脱敏重放判断体验

**Files:**
- Create: `docs/archive/2026-08-01-topic-thinking-integration-audit.md`

**Interfaces:**
- Consumes: 已授权的私有主题及其 2026-07-30 新认知来源；不复制原文或主题名称。
- Produces: 可审阅的回放结论，明确它是依据演化记录重建的旧稿而非历史快照。

- [ ] **Step 1: 记录回放输入和限制**

写明：选用一份有 2026-07-30 更新的主题；旧稿依据演化记录重建；新增认知为关于长期选择权判断的外部材料；不把私密原文、具体人物或链接写入仓库。

- [ ] **Step 2: 记录一次完整重放结果**

以五行以内记录：影响分类、更新后的主判断、合并/移动/删除的逻辑、四项全文检查的实际结论、是否增加用户成本。若发现失败，记录具体失败而非改写为通过。

- [ ] **Step 3: 判定是否继续发布**

只有四项全文检查均成立且没有增加用户成本时保留契约；否则使用 `git checkout HEAD --` 精确还原 Task 1 候选契约和测试改动，并在审计中记录“不发布”。

### Task 3: 全量回归、发布记录与提交

**Files:**
- Modify: `VERSION`
- Modify: `PROJECT_STATUS.md`
- Modify: `CHANGELOG.md`
- Modify: `README.md`（仅在主题思考说明需反映行为变化时）

- [ ] **Step 1: 运行完整验证**

运行：

```powershell
powershell -ExecutionPolicy Bypass -File tests/topic-thinking-contract.tests.ps1
powershell -ExecutionPolicy Bypass -File tests/distribution-boundary.tests.ps1
powershell -ExecutionPolicy Bypass -File tests/quality-baseline.tests.ps1
git diff --check
```

预期：四条命令均为零退出。

- [ ] **Step 2: 验证新增断言会报警**

临时删除主契约中的新规则，运行主题契约测试并确认失败；立即还原，再运行确认通过。不得提交临时删除。

- [ ] **Step 3: 记录发布事实并提交**

若 Task 2 判定可发布，版本从 `1.9.2` 升至 `1.9.3`，同步 `PROJECT_STATUS.md`、`CHANGELOG.md`、README 版本徽章及必要的主题思考说明；运行版本/链接/旧版本残留检查后，本地提交。若 Task 2 不可发布，不更新版本或发布文档，只保留审计记录。
