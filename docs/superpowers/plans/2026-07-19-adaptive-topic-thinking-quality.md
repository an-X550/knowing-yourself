# 自适应主题思考质量边界 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 让主题思考的篇幅、行动条目和实验步骤只由证据、风险、关键约束与验证需要决定，并完成全部现有主题文件的第一性原理复核。

**Architecture:** 共享主题契约负责运行时判断标准，模板只提供可伸缩的阅读骨架，PowerShell 契约测试防止主项目、overlay 和分发包漂移。个人主题文件是运行时私有数据，逐篇按统一审查问题修订，而不是套用固定格式。

**Tech Stack:** UTF-8 Markdown、PowerShell 静态契约测试、Git。

## Global Constraints

- 保持 `0.` 到 `6.` 标题、确认写入、路径安全、自动召回和同时最多一个行动实验的既有边界。
- 不设置任何行动、长期行动或实验步骤的最低数量；无合格行动必须允许明确不行动。
- 先写会失败的静态测试，再修改运行契约或模板。
- `.claude/shared/contracts/topic-thinking.md`、overlay 和 `zhiji-user/` 的对应文件必须逐字节一致。
- 个人主题文件不纳入 Git；不得把个人内容写入 CHANGELOG 或提交。

---

### Task 1: 用失败测试锁定自适应质量规则

**Files:**
- Modify: `tests/topic-thinking-contract.tests.ps1`
- Test: `tests/topic-thinking-contract.tests.ps1`

**Interfaces:**
- Consumes: 三份 `topic-thinking.md` 与用户版通用主题模板。
- Produces: 可重复运行的 PowerShell 断言，证明运行契约与模板禁止固定行动数量，并允许“当前不行动”。

- [ ] **Step 1: 添加会失败的契约与模板断言**

  在 `$contractPaths` 的 `Assert-ContainsAll` 模式列表中加入下列 Unicode 正则：

  ```powershell
  '\u4e0d\u8bbe\u7f6e.*\u6700\u4f4e\u6570\u91cf',
  '\u5f53\u524d\u4e0d\u884c\u52a8',
  '\u76f4\u63a5\u56de\u5e94.*\u5173\u952e\u7ea6\u675f',
  '\u7528\u6237\u53ef\u63a7\u8303\u56f4',
  '\u89e6\u53d1\u6761\u4ef6.*\u6700\u5c0f\u52a8\u4f5c',
  '\u53ef\u89c2\u5bdf.*\u7ee7\u7eed.*\u8c03\u6574.*\u505c\u6b62',
  '\u5224\u65ad.*\u884c\u52a8.*\u9a8c\u8bc1'
  ```

  将模板的固定五行、固定四步模式断言替换为：模板必须含“按需增减”“当前不行动”，且不得包含 `| 短期可执行动作 |`、`| 长期坚持动作 |`、`1. 触发条件：` 这些固定填充行。

- [ ] **Step 2: 运行测试并确认它因缺少新规则失败**

  Run: `powershell -ExecutionPolicy Bypass -File tests/topic-thinking-contract.tests.ps1`

  Expected: `FAIL: topic thinking contract checks`，失败项指向尚未存在的“最低数量”“当前不行动”或模板伸缩规则。

- [ ] **Step 3: 不修改其他文件，保存失败测试**

  失败原因必须是现有契约/模板尚未实现目标行为，而非路径、编码或 PowerShell 语法错误。

### Task 2: 实现共享运行边界与可伸缩模板

**Files:**
- Modify: `.claude/shared/contracts/topic-thinking.md`
- Modify: `packaging/zhiji-user-overlay/.claude/shared/contracts/topic-thinking.md`
- Modify: `zhiji-user/.claude/shared/contracts/topic-thinking.md`
- Modify: `packaging/zhiji-user-overlay/关于我/templates/thinking-topic.template.md`
- Modify: `zhiji-user/关于我/templates/thinking-topic.template.md`
- Test: `tests/topic-thinking-contract.tests.ps1`

**Interfaces:**
- Consumes: Task 1 的失败断言与既有 0–6 主题结构。
- Produces: 供所有主题思考入口使用的内容保留门槛、行动门槛与动态模板。

- [ ] **Step 1: 在契约中加入第一性原理质量门槛**

  在“主题文件结构”后新增一个紧邻的“内容质量与行动门槛”小节，写明：内容只有改变当前判断、下一步行动或验证方式时才保留；按真实问题、事实、假设、约束/代价、最小验证杠杆审查；高风险、不可逆代价、证据冲突或复杂因果才展开；无新信息时应短写理由。

- [ ] **Step 2: 在同一小节明确行动与不行动条件**

  规则必须逐项写明：不设最低数量；行动直接回应问题/关键约束、用户可控、有触发条件与最小动作、结果可观察并可决定继续/调整/停止；不满足不得列入。无合格行动时写“当前不行动”及等待条件。长期行动仅在有证据、稳定价值或正向结果支撑时保留，实验步骤按需写且只保留一个进行中实验。

- [ ] **Step 3: 同步三份契约并改写两份模板**

  用相同内容覆盖 overlay 和用户版契约，保持字节一致。把模板的固定表格行改为注释说明和可选表头，例如：

  ```markdown
  <!-- 仅列满足行动门槛的条目；可为 0 项。没有合格行动时写“当前不行动：等待……”。按需要增减条目，不补空行。 -->
  | 当前最小必要行动 | 触发场景 | 最小动作 | 观察/停止条件 |
  |---|---|---|---|
  ```

  `4.` 和 `5.` 使用同样的按需提示，删除预填的一行长期行动及固定的四步编号。

- [ ] **Step 4: 运行目标测试确认转绿**

  Run: `powershell -ExecutionPolicy Bypass -File tests/topic-thinking-contract.tests.ps1`

  Expected: `PASS: topic thinking contract checks`。

### Task 3: 逐篇审查并修订全部主题文件

**Files:**
- Modify: `关于我/思考/*.md`（排除 `index.md`，共 24 个文件）
- Test: 临时只读 PowerShell 审计命令与 Task 1 测试

**Interfaces:**
- Consumes: Task 2 的内容/行动门槛。
- Produces: 每个主题保留 0–6 阅读路径，并且没有因固定数量而填充的行动或实验步骤。

- [ ] **Step 1: 生成只读审计清单**

  对每篇文件摘出 `0. 当前行动卡`、`4. 值得保留的行动`、`5. 下一次怎么做`，记录行动数、长期行动数、实验步骤数和每节是否有“当前不行动”。审计清单仅用于本轮判断，不写入仓库。

- [ ] **Step 2: 对每个主题执行相同的五问审查**

  逐篇判断：真实问题是什么；哪些是事实、假设、价值取舍；不可消除的约束/代价是什么；当前最小可验证杠杆是什么；每个行动是否同时满足 Task 2 的四项条件。删除无法通过的问题背景重复、伪行动、重复行动和为填表而写的步骤；没有合格行动则写清“当前不行动”和等待条件。

- [ ] **Step 3: 保留必要复杂度并修订行动层**

  对高风险、不可逆或证据冲突主题，保留足够的反例与边界；对低风险或证据不足主题，压缩为足以支撑当前判断的最短内容。行动卡、长期动作表和实验步骤可为 0、1 或多项，但只保留满足门槛的条目；实验始终最多一个。

- [ ] **Step 4: 执行结构和内容复查**

  运行只读检查，确认每篇都有 `## 0.` 至 `## 6.`，没有空表格行、没有仅为固定数量而保留的“短期可执行动作/长期坚持动作”模板文字，且每个有行动的主题都包含触发或观察条件。人工复读每篇修改后的行动层，确认未因压缩删除关键约束或验证方式。

### Task 4: 全量回归、发布同步与提交

**Files:**
- Modify: `VERSION`
- Modify: `PROJECT_STATUS.md`
- Modify: `CHANGELOG.md`
- Test: `tests/topic-thinking-contract.tests.ps1`

**Interfaces:**
- Consumes: Task 2 和 Task 3 的完成状态。
- Produces: 可发布的质量边界升级记录与本地提交。

- [ ] **Step 1: 运行契约测试与相关分发边界测试**

  Run:

  ```powershell
  powershell -ExecutionPolicy Bypass -File tests/topic-thinking-contract.tests.ps1
  powershell -ExecutionPolicy Bypass -File tests/distribution-boundary.tests.ps1
  ```

  Expected: 两项均输出 `PASS` 且退出码为 0。

- [ ] **Step 2: 同步发布状态**

  按语义化版本将 `VERSION` 修订号加一，在 `PROJECT_STATUS.md` 更新主题思考质量边界的当前进度与关键决策；在 `CHANGELOG.md` 顶部追加一条 `[修复]` 记录，说明行动数量不再由模板固定、全量主题已经复核。

- [ ] **Step 3: 执行同步验证**

  检查 `VERSION` 与 `PROJECT_STATUS.md`、README 版本徽章一致；检查修改 Markdown 的相对链接目标存在；对契约文件运行哈希比较；执行 `git diff --check`。

- [ ] **Step 4: 提交发布级改动**

  Run:

  ```powershell
  git add .claude/shared/contracts/topic-thinking.md packaging/zhiji-user-overlay/.claude/shared/contracts/topic-thinking.md zhiji-user/.claude/shared/contracts/topic-thinking.md packaging/zhiji-user-overlay/关于我/templates/thinking-topic.template.md zhiji-user/关于我/templates/thinking-topic.template.md tests/topic-thinking-contract.tests.ps1 VERSION PROJECT_STATUS.md CHANGELOG.md
  git commit -m "[修复] 主题思考改为自适应质量边界"
  ```

  Expected: 本地提交成功；不包含 `关于我/思考/` 的私人主题内容。
