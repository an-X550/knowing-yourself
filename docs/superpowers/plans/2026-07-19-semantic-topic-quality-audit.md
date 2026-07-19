# 主题思考语义质量审查 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 让主题契约默认审查语义重复、跨主题重叠、过期冲突、证据质量、行动质量与篇幅价值，并要求审查结论落实为文件修改。

**Architecture:** 在现有“默认质量审查与合并更新”中补充六维审查顺序、跨主题主从引用和文件级落实边界；静态测试验证这些规则及三份运行副本同步，不新增用户命令。

**Tech Stack:** UTF-8 Markdown、PowerShell 静态契约测试、Git。

## Global Constraints

- 不把长度、行动数或格式整齐作为质量指标。
- 不删除仍影响当前判断、行动、验证或高风险边界的内容。
- 全量审查必须输出逐项决策、实际文件修改与跨主题重叠映射；审查表本身不是完成证据。
- 保持确认写入、0–6 结构、路径安全和用户版三副本逐字节一致。

---

### Task 1: 用失败测试锁定语义审查边界

**Files:**
- Modify: `tests/topic-thinking-contract.tests.ps1`

- [ ] **Step 1: 添加缺失规则断言**

  在三份契约的必含模式中加入：`主题内重复`、`跨主题重叠`、`过期与冲突`、`证据质量`、`行动质量`、`篇幅价值`、`主主题`、`实际文件修改`、`不以审查记录代替`。

- [ ] **Step 2: 运行并确认失败**

  Run: `powershell -ExecutionPolicy Bypass -File tests/topic-thinking-contract.tests.ps1`

  Expected: 失败项仅为尚未写入的六维审查与落实要求。

### Task 2: 定向补强主题契约并同步副本

**Files:**
- Modify: `.claude/shared/contracts/topic-thinking.md`
- Modify: `packaging/zhiji-user-overlay/.claude/shared/contracts/topic-thinking.md`
- Modify: `zhiji-user/.claude/shared/contracts/topic-thinking.md`
- Test: `tests/topic-thinking-contract.tests.ps1`

- [ ] **Step 1: 新增“语义质量审查与全量优化”小节**

  写明六个审查维度、各维度的保留或合并边界、跨主题主主题/引用决策，以及“仅当内容改变判断、行动或验证才保留”。

- [ ] **Step 2: 强制审查落地**

  明确全量审查逐项记录 `保留 / 合并 / 删除 / 修正 / 替换 / 归档` 与证据，但必须执行对应实际文件修改；不得以审查记录代替优化。无须改动的主题也要说明保留依据。

- [ ] **Step 3: 同步并转绿**

  逐字同步三份副本，运行：`powershell -ExecutionPolicy Bypass -File tests/topic-thinking-contract.tests.ps1`。

### Task 3: 发布同步与提交

**Files:**
- Modify: `VERSION`, `README.md`, `PROJECT_STATUS.md`, `CHANGELOG.md`
- Test: `tests/topic-thinking-contract.tests.ps1`, `tests/distribution-boundary.tests.ps1`

- [ ] **Step 1: 完整验证**

  Run: `powershell -ExecutionPolicy Bypass -File tests/topic-thinking-contract.tests.ps1`; `powershell -ExecutionPolicy Bypass -File tests/distribution-boundary.tests.ps1`; `git diff --check`。

- [ ] **Step 2: 版本与提交**

  修订版本、README 徽章、状态和发布记录；只在验证后提交运行契约、测试、计划与治理文档，不提交私有主题数据。
