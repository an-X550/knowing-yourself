# 关切优先级主题重写 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 将“有限精力、选择性投入与不亏欠感”重写为以 Nozomi 发言为核心、可直接调用的关切优先级地图。

**Architecture:** 仅重写既有私有主题正文，不新增运行入口或模板规则。主题以明确的自定义结构承载原文、第一性原理复核、筛选器与边界；治理文件只同步此次主题能力的版本与发布事实。

**Tech Stack:** UTF-8 Markdown、PowerShell、Git。

## Global Constraints

- 使用 Nozomi 原文，但清晰标注其个人经验与用户的认可，不能将原文中的具体财务状态写成用户事实。
- 主题 frontmatter 必须包含 `format` 和 `semantic_role`，且不使用 0–6 标题。
- 主题保留当前调用入口、事实/推断/价值区分、来源与反例校正、复查条件和观点演化。
- 版本从 `1.8.1` 递增至 `1.8.2`；`PROJECT_STATUS.md`、`CHANGELOG.md` 与 `VERSION` 同步。
- 不暂存或提交现有无关未跟踪文件。

---

### Task 1: 重写主题正文

**Files:**
- Modify: `关于我/思考/有限精力、选择性投入与不亏欠感.md`

**Interfaces:**
- Consumes: `docs/superpowers/specs/2026-07-23-attention-allocation-topic-design.md` 的结构和边界。
- Produces: 自定义格式的“关切优先级地图”主题，供 `关于我/思考/index.md` 的既有入口调用。

- [ ] **Step 1: 以自定义 frontmatter 和直接调用原则替换主题开头**

  写入 `format: concern-priority-map` 和 `semantic_role: 关切与注意力的优先级地图；日程容量、行动主权与具体关系经营分别转向相邻主题`，并用“先判定这件事是否影响长期选择权、核心关系、健康、价值一致性或有累积效应”作为入口。

- [ ] **Step 2: 写入 Nozomi 原文与第一性原理复核**

  完整保存用户提供的原文，标注为“来源：Nozomi 发言；用户于 2026-07-23 表示完全认可”。随后分开写明：真实问题是注意力如何排序而非如何装下全部事项；时间、精力与注意力不可复制；“99.9%”及“十年存款”是原作者表达而非用户事实；选择哪些资产优先是价值取舍。

- [ ] **Step 3: 写入四类优先资产、焦虑筛选器和边界校正**

  将原文的投资能力、身边人的人品、财务安全、价值一致与自我塑造解释为长期选择权资产；提供长期选择权、不可替代性、不可逆性和累积效应四问。明确健康、信誉、已作出的关系承诺和小但可复利的习惯不得因单次影响小而被忽略。

- [ ] **Step 4: 补齐来源、相邻主题转向、复查条件与观点演化**

  链接“精力管理、规划冗余与任务执行”“坚定相信自己、行动主体性与滚雪球方向”“真诚、利他与共事关系”“健康生活、生命力与恢复边界”。规定当筛选器被用来回避必要承诺、长期后果或现实风险时，应重新评估；记录从“广泛覆盖避免亏欠”到“维护少数重要变量”的观点变化。

- [ ] **Step 5: 验证正文结构与链接**

  Run: `Select-String -Path '关于我\\思考\\有限精力、选择性投入与不亏欠感.md' -Pattern '^## [0-6]\\.' -Encoding utf8; Select-String -Path '关于我\\思考\\有限精力、选择性投入与不亏欠感.md' -Pattern 'format: concern-priority-map|semantic_role:|Nozomi|长期选择权|不可替代性|不可逆性|累积效应' -Encoding utf8`

  Expected: 第一条命令无输出；第二条命令命中全部关键结构。

### Task 2: 同步发布事实与验证

**Files:**
- Modify: `VERSION`
- Modify: `PROJECT_STATUS.md`
- Modify: `CHANGELOG.md`
- Test: `tests/topic-thinking-contract.tests.ps1`

**Interfaces:**
- Consumes: Task 1 的主题重写和当前版本 `1.8.1`。
- Produces: 一致的 `1.8.2` 发布事实和可追溯变更记录。

- [ ] **Step 1: 递增版本并更新项目状态**

  将 `VERSION` 改为 `1.8.2`，将 `PROJECT_STATUS.md` 的当前版本改为 `1.8.2`，并在“轻量主题思考库”状态说明中补充：主题“有限精力”已改为经确认的 `concern-priority-map` 自定义结构，以 Nozomi 原文为核心。

- [ ] **Step 2: 在 CHANGELOG 顶部写入发布级记录**

  新增 `## [2026-07-24 00:00] [文档] 重写有限精力主题为关切优先级地图 (v1.8.1 -> v1.8.2)`，列出主题文件、规格、计划、`PROJECT_STATUS.md`、`CHANGELOG.md` 与 `VERSION`，说明变化让用户可用更少摩擦判断何事值得挂念，同时保留原文的适用边界。

- [ ] **Step 3: 运行主题契约与一致性检查**

  Run: `powershell -ExecutionPolicy Bypass -File tests/topic-thinking-contract.tests.ps1; $version = Get-Content -Raw -Encoding utf8 VERSION; $status = Select-String -Path PROJECT_STATUS.md -Pattern '^\*\*当前版本\*\*：' -Encoding utf8; Write-Output $version.Trim(); Write-Output $status.Line`

  Expected: 测试退出码为 0，且两个版本均为 `1.8.2`。

- [ ] **Step 4: 仅暂存本任务文件并提交**

  Run: `git add -- '关于我/思考/有限精力、选择性投入与不亏欠感.md' 'docs/superpowers/specs/2026-07-23-attention-allocation-topic-design.md' 'docs/superpowers/plans/2026-07-24-attention-allocation-topic-rewrite.md' VERSION PROJECT_STATUS.md CHANGELOG.md; git diff --cached --check; git commit -m "[文档] 重写有限精力主题为关切优先级地图"`

  Expected: 空白检查无输出，提交只包含列出的任务文件。
