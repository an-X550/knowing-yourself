# Directory Boundary Tightening Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 收紧 `.claude/` 与 `docs/` 的职责边界，消除重复权威来源，降低长期维护成本。

**Architecture:** 以 `.claude/shared/` 作为唯一运行契约层，收缩 `workflows/shared.js` 为运行 helper，明确 `log skill` 仅做入口编排，区分正式 spec、开发过程文档与归档文档。

**Tech Stack:** Markdown, JSON, Claude Code command/agent/skill docs, existing workflow JavaScript.

## Global Constraints

- 不改变现有 command 名称、入口参数、输出路径、报告文件名或 workflow 编排。
- `.claude/` 继续作为唯一运行真相，`docs/` 只承载说明、设计与历史记录。
- `AGENTS.md` 与 `CLAUDE.md` 只有在其中一份被修改时才需要同步。
- 本轮为结构收口与文档设计，不引入新功能。

---

### Task 1: 固化结构边界契约

**Files:**
- Modify: `AGENTS.md`
- Modify: `CLAUDE.md`
- Modify: `README.md`
- Modify: `PROJECT_STATUS.md`
- Test: `CHANGELOG.md`

**Interfaces:**
- Consumes: `docs/specs/directory-boundary-tightening.md`
- Produces: 明确的职责边界、默认上下文读取规则、spec 引用入口

- [ ] **Step 1: Write the failing test**

```text
检查 README / PROJECT_STATUS / AGENTS / CLAUDE 是否能回答以下问题：
1. `.claude/` 与 `docs/` 各自负责什么？
2. `docs/specs/` 与 `docs/superpowers/specs/` 如何区分？
3. 新 spec 是否被 README 或 PROJECT_STATUS 引用？
```

- [ ] **Step 2: Run test to verify it fails**

Run: `Get-ChildItem README.md,PROJECT_STATUS.md,AGENTS.md,CLAUDE.md | Select-String -Pattern 'directory-boundary-tightening|docs/superpowers/specs|docs/specs'`
Expected: 至少缺少新 spec 引用或边界说明不完整

- [ ] **Step 3: Write minimal implementation**

```text
1. 在 README 的方法论/设计入口处新增对 `docs/specs/directory-boundary-tightening.md` 的引用
2. 在 PROJECT_STATUS 的待办或关键决策中登记本轮结构收口任务
3. 如需补强，更新 AGENTS.md / CLAUDE.md 中关于 `.claude/` 与 `docs/` 的边界表述
```

- [ ] **Step 4: Run test to verify it passes**

Run: `Get-ChildItem README.md,PROJECT_STATUS.md,AGENTS.md,CLAUDE.md | Select-String -Pattern 'directory-boundary-tightening|docs/superpowers/specs|docs/specs'`
Expected: 新 spec 被引用，边界关键词可检索到

- [ ] **Step 5: Commit**

```bash
git add README.md PROJECT_STATUS.md AGENTS.md CLAUDE.md docs/specs/directory-boundary-tightening.md
git commit -m "docs: define directory boundary contracts"
```

### Task 2: 收紧单一权威来源

**Files:**
- Modify: `.claude/workflows/shared.js`
- Modify: `.claude/shared/paths.md`
- Modify: `.claude/shared/prompt-rules.md`
- Modify: `.claude/shared/banned-phrases.json`
- Test: `.claude/commands/monthly-review.md`

**Interfaces:**
- Consumes: 现有 shared 契约与 workflow helper
- Produces: 更清晰的 shared ownership，减少平行常量

- [ ] **Step 1: Write the failing test**

```text
检查 `.claude/workflows/shared.js` 是否仍手写维护 PATH_TEMPLATES 或 BANNED_PHRASES，
并检查 shared 文档是否已经声明它们是唯一权威。
```

- [ ] **Step 2: Run test to verify it fails**

Run: `Get-ChildItem .claude/workflows/shared.js,.claude/shared/paths.md,.claude/shared/banned-phrases.json | Select-String -Pattern 'PATH_TEMPLATES|BANNED_PHRASES|唯一|权威'`
Expected: `shared.js` 仍含重复常量或 shared 文档约束不足

- [ ] **Step 3: Write minimal implementation**

```text
1. 将 `shared.js` 改为只保留 helper，并注明 shared 数据来源
2. 在 `paths.md` / `prompt-rules.md` / `banned-phrases.json` 中补足“唯一权威/镜像来源/消费者”说明
3. 检查 command 文档对 shared 契约的引用是否与实现匹配
```

- [ ] **Step 4: Run test to verify it passes**

Run: `Get-ChildItem .claude/workflows/shared.js,.claude/shared/paths.md,.claude/shared/prompt-rules.md,.claude/shared/banned-phrases.json | Select-String -Pattern '唯一|权威|来源|consumer|镜像'`
Expected: shared ownership 清晰，`shared.js` 不再像副本真相

- [ ] **Step 5: Commit**

```bash
git add .claude/workflows/shared.js .claude/shared/paths.md .claude/shared/prompt-rules.md .claude/shared/banned-phrases.json .claude/commands/monthly-review.md
git commit -m "refactor: tighten shared authority sources"
```

### Task 3: 收紧入口职责与 hook 边界

**Files:**
- Modify: `.claude/skills/log.md`
- Modify: `.claude/commands/daily-review.md`
- Modify: `.claude/commands/import.md`
- Modify: `.claude/agents/daily-analyzer.md`
- Modify: `.claude/settings.json`

**Interfaces:**
- Consumes: `daily-analyzer` output contract, import flow, verified-patterns contract
- Produces: `log skill` 入口编排边界与 hook 风险说明

- [ ] **Step 1: Write the failing test**

```text
检查 `log.md` 是否仍在重复维护 `daily-analyzer`、`/import`、readiness 提示三类逻辑，
以及 `settings.json` 是否缺少 Windows hook 风险边界说明。
```

- [ ] **Step 2: Run test to verify it fails**

Run: `Get-ChildItem .claude/skills/log.md,.claude/commands/import.md,.claude/agents/daily-analyzer.md,.claude/settings.json | Select-String -Pattern 'daily-analyzer|/import|review-readiness|bash -c|Windows'`
Expected: `log.md` 存在重复说明，`settings.json` 缺少边界提示

- [ ] **Step 3: Write minimal implementation**

```text
1. 精简 `log.md`，只保留日志入口编排职责
2. 用引用替代重复维护的分析格式与多日导入细节
3. 在共享规则或设置说明中明确 `bash -c` 的 Windows 兼容风险
```

- [ ] **Step 4: Run test to verify it passes**

Run: `Get-ChildItem .claude/skills/log.md,.claude/commands/daily-review.md,.claude/settings.json | Select-String -Pattern '编排|引用|bash -c|兼容'`
Expected: 入口边界更清晰，hook 风险有说明

- [ ] **Step 5: Commit**

```bash
git add .claude/skills/log.md .claude/commands/daily-review.md .claude/commands/import.md .claude/agents/daily-analyzer.md .claude/settings.json
git commit -m "docs: narrow log skill responsibilities"
```

### Task 4: 收紧文档分层与归档策略

**Files:**
- Modify: `docs/first-principles.md`
- Modify: `docs/specs/_TEMPLATE.md`
- Modify: `PROJECT_STATUS.md`
- Modify: `README.md`
- Create: `docs/archive/README.md`

**Interfaces:**
- Consumes: 正式 spec 与 process docs 的现有目录结构
- Produces: 面向维护者的分层与归档规则

- [ ] **Step 1: Write the failing test**

```text
检查仓库中是否存在对以下问题的明确说明：
1. 正式 spec 和 superpowers spec 的区别
2. plan 是否属于长期真相
3. 何时把过程文档归档
```

- [ ] **Step 2: Run test to verify it fails**

Run: `Get-ChildItem README.md,PROJECT_STATUS.md,docs/first-principles.md,docs/specs/_TEMPLATE.md,docs/archive -Recurse | Select-String -Pattern '归档|superpowers/specs|正式 spec|过程文档'`
Expected: 至少有一项缺少明确规则

- [ ] **Step 3: Write minimal implementation**

```text
1. 在 README / PROJECT_STATUS 中补充分层入口说明
2. 在 `docs/specs/_TEMPLATE.md` 中加入正式 spec 的适用边界
3. 新增 `docs/archive/README.md`，定义归档标准
4. 保持 `first-principles.md` 只讲长期原则，不引入当前指标
```

- [ ] **Step 4: Run test to verify it passes**

Run: `Get-ChildItem README.md,PROJECT_STATUS.md,docs/first-principles.md,docs/specs/_TEMPLATE.md,docs/archive -Recurse | Select-String -Pattern '归档|正式 spec|过程文档|长期原则'`
Expected: 分层与归档规则可检索、无明显空洞

- [ ] **Step 5: Commit**

```bash
git add README.md PROJECT_STATUS.md docs/first-principles.md docs/specs/_TEMPLATE.md docs/archive/README.md
git commit -m "docs: define archive and document layering rules"
```

### Task 5: 版本、变更记录与验证

**Files:**
- Modify: `VERSION`
- Modify: `CHANGELOG.md`
- Modify: `README.md`
- Modify: `PROJECT_STATUS.md`

**Interfaces:**
- Consumes: 已完成的结构收口设计与相关文档改动
- Produces: 一致的版本状态与可追溯变更记录

- [ ] **Step 1: Write the failing test**

```text
检查 `VERSION`、README 徽章、PROJECT_STATUS 当前版本、CHANGELOG 顶部记录是否一致。
```

- [ ] **Step 2: Run test to verify it fails**

Run: `Get-ChildItem VERSION,README.md,PROJECT_STATUS.md,CHANGELOG.md | Select-String -Pattern '1.5.4|1.5.3'`
Expected: 改动前仍为旧版本或缺少本轮 changelog

- [ ] **Step 3: Write minimal implementation**

```text
1. 将 `VERSION` 从 `1.5.3` 升到 `1.5.4`
2. 更新 README 徽章与 PROJECT_STATUS 当前版本
3. 追加一条 `[文档]` 或 `[重构]` CHANGELOG，描述结构收口 spec/plan
```

- [ ] **Step 4: Run test to verify it passes**

Run: `Get-ChildItem VERSION,README.md,PROJECT_STATUS.md,CHANGELOG.md | Select-String -Pattern '1.5.4'`
Expected: 四处一致，CHANGELOG 顶部包含本轮记录

- [ ] **Step 5: Commit**

```bash
git add VERSION README.md PROJECT_STATUS.md CHANGELOG.md docs/specs/directory-boundary-tightening.md docs/superpowers/plans/2026-07-08-directory-boundary-tightening.md
git commit -m "docs: add directory boundary tightening spec and plan"
```
