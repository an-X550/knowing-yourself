# Non-Template Journal Input Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 让非模板日志稳定进入现有日反馈闭环，并让输出深度按 A-D 输入证据等级自动收敛。

**Architecture:** 保留 `settings -> log -> daily-analyzer -> verified-patterns` 链路，新增一份短输入契约，不新增代理或模型调用。用无依赖 PowerShell 脚本回归 Hook 路由、日期格式、契约消费者和日志教练路由，再同步用户版覆盖层与导出结果。

**Tech Stack:** Markdown runtime contracts, JSON hook config, PowerShell 5+, Git

## Global Constraints

- `.claude/` 是唯一主运行真相；用户版差异必须从覆盖层导出，不直接手改 `zhiji-user/`。
- 不要求用户采用固定日志模板，不重写原始日志。
- 不新增 `journal-intake` 代理或额外模型调用。
- 不改变现有输出目录、文件名、命令参数或周/月/项目复盘一级结构。
- 所有中文 Markdown 按 UTF-8 读写。
- 行为改变使用 TDD：先运行失败的回归检查，再修改运行文件。

---

### Task 1: 建立输入与路由回归检查

**Files:**
- Create: `tests/journal-input-contract.tests.ps1`
- Test: `tests/journal-input-contract.tests.ps1`

**Interfaces:**
- Consumes: `.claude/settings.json`, `.claude/skills/log.md`, `.claude/agents/daily-analyzer.md`, `.claude/commands/journal-coach.md`
- Produces: 一个退出码为 0/1 的无依赖 PowerShell 回归入口

- [ ] **Step 1: 写入失败测试**

测试必须加载 Hook matcher，验证以下正例命中：`日志：今天很累`、`日记：今天完成了报告`、`记录一下：下午开会`、`请分析这篇日志：今天拒绝了加班`、现有模板字段；同时验证 `如何修改日志分析项目的 README`、`请解释什么是日记` 不命中。

测试还必须从 `log.md` 日期规则表提取正则，并验证 `# 7 月 8 日`、`## 2026-07-08`、`2026/7/8`、`日志 7.8` 至少被一个规则命中。

最后断言：

```powershell
Assert-Contains '.claude/skills/log.md' 'contracts/journal-input.md'
Assert-Contains '.claude/agents/daily-analyzer.md' 'contracts/journal-input.md'
Assert-Contains '.claude/commands/journal-coach.md' 'subagent_type: journal-quality-coach'
Assert-Path '.claude/agents/journal-quality-coach.md'
```

- [ ] **Step 2: 运行测试并确认按预期失败**

Run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tests/journal-input-contract.tests.ps1
```

Expected: exit 1；至少报告自然语言入口未命中、空格日期未命中、输入契约缺失、journal-coach 路由错误。

---

### Task 2: 新增输入契约并接入日反馈链路

**Files:**
- Create: `.claude/shared/contracts/journal-input.md`
- Modify: `.claude/shared/prompt-rules.md`
- Modify: `.claude/settings.json`
- Modify: `.claude/skills/log.md`
- Modify: `.claude/agents/daily-analyzer.md`
- Modify: `.claude/shared/contracts/daily-feedback.md`

**Interfaces:**
- Consumes: 设计 spec 中的证据卡、A-D 等级和日期规则
- Produces: `journal-input.md` 统一输入契约；`log` 与 `daily-analyzer` 作为消费者

- [ ] **Step 1: 扩展入口 matcher**

在保留模板字段的前提下，增加有边界的明确入口：

```text
(^|\s)(日志|日记|记录一下)\s*[:：]
(分析|看看|点评).{0,8}(这篇|今天的|我的)?(日志|日记|记录)
```

不得用单独的“今天”“我”“记录”触发。

- [ ] **Step 2: 写入输入契约**

契约必须包含：保证触发条件、日期格式、日期不确定时确认、证据卡七字段、A-D 表格、模板无关原则和降级输出规则。

- [ ] **Step 3: 更新日期规则和边界处理**

`log.md` 日期表至少加入：

```text
^#{1,2}\s+\d{1,2}\s*月\s*\d{1,2}\s*日
^#{1,2}\s+\d{4}-\d{1,2}-\d{1,2}
^\d{4}[/-]\d{1,2}[/-]\d{1,2}
^(幸福日志|日志)\s+\d{1,2}\.\d{1,2}
```

把“解析失败用今天”改为“有今天/昨天语义则换算，否则只问一次日期”。单日重复存档前检查同日日期头，存在时合并或提示，不盲目追加。

- [ ] **Step 4: 接入 daily-analyzer**

在读取日志后先生成内部证据卡与等级：A/B 允许洞察，C 只镜像与维护闭环动作，D 返回一个补证问题且不生成正式反馈。不得显示等级。

- [ ] **Step 5: 运行回归检查**

Run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tests/journal-input-contract.tests.ps1
```

Expected: 入口、日期和契约消费者相关检查通过；journal-coach 相关检查仍失败。

---

### Task 3: 收紧洞察与验证质量门

**Files:**
- Modify: `.claude/shared/contracts/daily-feedback.md`
- Modify: `.claude/shared/contracts/evidence-and-verification.md`
- Modify: `.claude/agents/daily-analyzer.md`
- Modify: `.claude/commands/daily-review.md`
- Modify: `.claude/skills/log.md`

**Interfaces:**
- Consumes: `journal-input.md` 的 A-D 等级
- Produces: 证据强度匹配的洞察、预测与 verified-patterns 写回语义

- [ ] **Step 1: 收紧 D2**

把洞察优先级写为“事实矛盾 -> 计划与行为差距 -> 自我评价与证据差距 -> 重复模式 -> 隐含动机假说”。没有用户自述或跨日证据时，隐含动机必须使用“一个可能解释”，禁止确定性心理归因。

- [ ] **Step 2: 调整预测**

预测优先观察真实行为或结果，不要求下一篇日志出现固定栏目或特定措辞；“没有写”只能得到“证据不足”，不能自动得到“没做”。

- [ ] **Step 3: 区分假说与干预实验**

写回状态统一为：`待验证 / 部分支持 / 本次未奏效 / 多次支持 / 出现反例 / 证据不足`。至少 3 次独立支持、覆盖 2 个日期或情境且无强反例，才能升级为已确认模式。

- [ ] **Step 4: 扩展回归断言并运行**

测试断言 evidence contract 包含上述六种状态、`3 次` 和 `2 个日期或情境`；断言 daily contract 包含“一个可能解释”和“不得从没有写推导没有做”。

Run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tests/journal-input-contract.tests.ps1
```

Expected: 质量门检查通过；journal-coach 相关检查仍失败。

---

### Task 4: 修复主项目日志教练路由

**Files:**
- Create: `.claude/agents/journal-quality-coach.md`
- Modify: `.claude/commands/journal-coach.md`
- Modify: `perspectives/journal-quality.md`
- Test: `tests/journal-input-contract.tests.ps1`

**Interfaces:**
- Consumes: `docs/methodology-journal.md`, `perspectives/journal-quality.md`, `.claude/shared/contracts/journal-input.md`
- Produces: `journal-quality-coach` agent 和正确的 `/journal-coach` 路由

- [ ] **Step 1: 将用户版质量代理回抽到主运行真相**

以覆盖层现有 `journal-quality-coach.md` 为基线，增加“分析就绪度与六步法习惯分开判断”“自由叙事不因缺少栏目扣分”“分享讨论为可选增强项”。

- [ ] **Step 2: 修正命令路由**

将每日日志并行调用 `daily-analyzer` 改为一次调用：

```text
subagent_type: journal-quality-coach
Coach journals [日期范围]
```

报告写入仍由质量代理负责，命令不重复汇总。

- [ ] **Step 3: 运行回归检查**

Run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tests/journal-input-contract.tests.ps1
```

Expected: `PASS: journal input contract regression checks`，exit 0。

---

### Task 5: 同步用户版并完成发布验证

**Files:**
- Modify: `packaging/zhiji-user-overlay/.claude/**` 对应运行文件
- Modify: `packaging/zhiji-user-overlay/perspectives/journal-quality.md`
- Regenerate: `zhiji-user/`
- Modify: `README.md`
- Modify: `packaging/zhiji-user-overlay/README.md`
- Modify: `PROJECT_STATUS.md`
- Modify: `CHANGELOG.md`
- Modify: `VERSION`

**Interfaces:**
- Consumes: Tasks 2-4 的主运行真相
- Produces: 可分发用户版、版本 1.5.22 和发布记录

- [ ] **Step 1: 同步覆盖层**

把本次修改的运行契约、agent、command、skill、settings 和 perspective 同步到 `packaging/zhiji-user-overlay/`，保留用户版不含开发治理能力的边界。

- [ ] **Step 2: 更新用户说明**

README 明确：自由文本使用 `日志：` / `日记：` / `记录一下：` 可保证触发；模板只是可选示例。删除“优先沿用模板才能稳定触发”的暗示。

- [ ] **Step 3: 导出用户版**

Run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/export-zhiji-user.ps1
```

Expected: export/smoke check 成功，`zhiji-user/` 关键文件与覆盖层一致。

- [ ] **Step 4: 同步版本和治理文件**

将 `VERSION`、`PROJECT_STATUS.md` 当前版本和 README 徽章从 `1.5.21` 更新到 `1.5.22`；状态中记录非模板输入适配完成，并从待办中移除已完成的 A-D 输入契约项。向 CHANGELOG 顶部增加一条 `[功能]` 发布记录。

- [ ] **Step 5: 全量验证**

Run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tests/journal-input-contract.tests.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/export-zhiji-user.ps1
```

回归脚本同时用 SHA-256 检查覆盖层与 `zhiji-user/` 的关键导出文件，并检查版本三处一致。另检查 Markdown 相对链接存在、修改文件无旧路由残留。

- [ ] **Step 6: 本地提交**

使用 `source-command-commit`：从 CHANGELOG 最新条目提取提交信息，`git add .` 后本地提交；不推送。

## Self-Review

1. Spec coverage：入口、日期、证据卡、A-D、洞察边界、验证状态、日志教练和用户版同步均有对应任务。
2. Placeholder scan：无 TBD/TODO/“以后再实现”占位。
3. Interface consistency：唯一新增运行契约名为 `.claude/shared/contracts/journal-input.md`；消费者固定为 `log`、`daily-analyzer`、`journal-quality-coach`。
