---
created: 2026-07-09
last_updated: 2026-07-09
status: 已确认
type: 实施计划
---

# Beta Pilot Validation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 产出并执行一轮 3-5 人的小范围内测，验证“把今天的日志贴进来，系统能否稳定给出用户认可的洞察与愿意尝试的动作”。

**Architecture:** 先冻结试用版承诺与最小用户包边界，再把首次体验收缩到“今天日志”默认入口，随后用自然反馈和后续日志痕迹观察准确性、有用性与闭环延续。整个计划优先验证核心价值，不把时间消耗在完整分发体系或更重产品形态上。

**Tech Stack:** Markdown, Claude Code Skill, GitHub / 压缩包分发, PowerShell 验证命令, 人工内测记录

## Global Constraints

- 第一轮内测只主打“今天日志”场景，不以周报、月报、life-design、项目复盘作为首要承诺。
- 首页或首句引导只卖用户价值，不要求用户先理解命令体系。
- 内测期以自然反馈为主，不强制用户填写结构化表单。
- 主判断维度按“准确性 -> 有用性 -> 后续日志验证痕迹”排序。
- `.claude/` 仍是唯一运行真相；试用包不能依赖仓库中被移除的隐式文件。
- 本轮优先优化试用包装、入口文案和观测方法，不新增与内测假设无关的功能。

---

### Task 1: 冻结试用版承诺与成功标准

**Files:**
- Create: `docs/specs/beta-pilot-validation.md`
- Modify: `README.md`
- Modify: `PROJECT_STATUS.md`

**Interfaces:**
- Consumes: `docs/first-principles.md`, `docs/specs/evolution-roadmap.md`, `PROJECT_STATUS.md`, 当前 `README.md`
- Produces: 一份明确的内测假设文档，以及与之对齐的公开入口表述

- [ ] **Step 1: 写出单句试用承诺**

将试用版承诺固定为：

```text
把今天的日志贴进来，我来帮你看你自己没发现的模式。
```

并在 `docs/specs/beta-pilot-validation.md` 里补充两条解释：

```text
- 第一轮验证的是核心价值，不是完整功能覆盖率。
- 第一轮默认入口是“今天日志”，其他分析能力保留但不作为主卖点。
```

- [ ] **Step 2: 写出成功标准**

在同一文档中明确：

```text
主指标：
1. 用户是否明确反馈分析准确
2. 用户是否明确反馈分析有用

次指标：
3. 后续日志里是否出现对前次建议的执行、回应、修正或反驳痕迹
```

- [ ] **Step 3: 同步 README 的首屏承诺**

将 `README.md` 的快速开始前两段收紧为：

```markdown
> AI 日志分析与复盘技能：把今天的日志变成一个你愿意验证的洞察与动作。

第一次试用时，优先直接贴今天的日志，先跑出一次日反馈，再决定是否继续使用周/月/项目等更重入口。
```

- [ ] **Step 4: 同步 PROJECT_STATUS 的阶段事实**

新增一条当前进度或关键决策，明确：

```text
已形成外部内测行动方案，第一轮验证优先聚焦“今天日志”入口和自然反馈。
```

### Task 2: 裁剪最小用户包并补齐首用说明

**Files:**
- Create: `docs/specs/minimal-user-package.md`
- Modify: `SETUP.md`
- Modify: `README.md`

**Interfaces:**
- Consumes: 当前仓库目录、运行真相边界、Task 1 的试用承诺
- Produces: 一份最小用户包清单和一套不依赖开发上下文的首用说明

- [ ] **Step 1: 枚举用户运行必需文件**

在 `docs/specs/minimal-user-package.md` 中列出：

```text
- 必须给用户的文件 / 目录
- 仅开发使用、不得进入试用包的文件 / 目录
- 每个保留项的用途
```

至少显式判断这些路径：

```text
.claude/
README.md
SETUP.md
docs/
.codex/
AGENTS.md
CLAUDE.md
PROJECT_STATUS.md
CHANGELOG.md
```

- [ ] **Step 2: 写出“拖入后怎么开始”的最短说明**

把 `SETUP.md` 中与试用直接相关的部分压缩成 3 步：

```markdown
1. 导入最小用户包
2. 打开 Claude Code
3. 直接粘贴今天的日志，优先使用 `/review` 或 `/daily-review`
```

同时删除或下沉会让非编程用户分心的开发说明。

- [ ] **Step 3: 写出“第一次不知道选哪个命令怎么办”**

在 `README.md` 里增加一句保护性说明：

```markdown
如果你不确定该选哪个入口，先直接贴今天的日志；统一入口 `/review` 会优先帮助你开始，而不是要求你先理解全部命令差异。
```

- [ ] **Step 4: 做一次包边界自检**

人工核对：

```text
- 最小用户包不引用被移除的开发文档
- README / SETUP 的相对链接在试用包形态下仍成立
- 用户第一次使用时不需要理解 AGENTS / CHANGELOG / PROJECT_STATUS
```

### Task 3: 把第一次体验收紧到“洞察 + 动作”

**Files:**
- Modify: `.claude/commands/review.md`
- Modify: `.claude/commands/daily-review.md`
- Modify: `.claude/agents/daily-analyzer.md`

**Interfaces:**
- Consumes: 当前 `/review` 路由逻辑、日反馈契约、Task 1 的试用承诺
- Produces: 更清晰的首用导向，以及与内测目标一致的日反馈输出重心

- [ ] **Step 1: 检查 `/review` 的默认导向**

确认或补强以下行为：

```text
当用户贴入单日日志或明显是“今天日志”场景时，/review 优先走日反馈链路。
```

如果当前文案不够明确，在命令说明里补一句：

```markdown
第一次试用时，如无特殊说明，优先把当天日志当作默认入口处理。
```

- [ ] **Step 2: 检查日反馈是否过度解释**

在 `.claude/agents/daily-analyzer.md` 中确认：

```text
- 输出重点是一个核心模式
- 至少给出一个愿意尝试的具体动作
- 不为了“显得聪明”而堆叠太多解释
```

- [ ] **Step 3: 补一条内测观察提醒**

在 `daily-review.md` 或 `review.md` 注释中写明给未来实现者的观察重点：

```text
内测优先看用户是否觉得“准确”和“有用”，而不是先扩展更多入口说明。
```

### Task 4: 建立内测记录与观察方法

**Files:**
- Create: `docs/specs/beta-operator-log-template.md`
- Create: `docs/specs/beta-synthesis-template.md`

**Interfaces:**
- Consumes: Task 1 的成功标准、自然反馈前提
- Produces: 一份给操作者自己用的记录模板，而不是给用户填写的表单

- [ ] **Step 1: 写出单次内测记录模板**

在 `docs/specs/beta-operator-log-template.md` 中按每位用户记录：

```markdown
## 用户代号
## 使用背景
## 第一次是否顺利开始
## 用户原话：哪里准确
## 用户原话：哪里有用 / 没用
## 后续日志是否出现验证痕迹
## 发现的问题
## 下一步处理建议
```

- [ ] **Step 2: 写出整轮内测汇总模板**

在 `docs/specs/beta-synthesis-template.md` 中汇总：

```markdown
## 总体结论
## 准确性高频反馈
## 有用性高频反馈
## 验证痕迹样本
## 首次使用摩擦点
## 暂不处理的问题
## 建议继续 / 收缩 / 改向的判断
```

- [ ] **Step 3: 明确“什么算验证痕迹”**

在模板中显式写出：

```text
验证痕迹 = 后续日志中出现对前次建议的执行、回应、修正、反驳，哪怕用户没有专门回来回复 AI。
```

### Task 5: 先跑干运行，再跑 3-5 人真实内测

**Files:**
- Modify: `docs/specs/beta-operator-log-template.md`
- Create: `docs/specs/beta-pilot-runbook.md`

**Interfaces:**
- Consumes: Task 2 的最小用户包、Task 4 的记录模板
- Produces: 一份可重复执行的内测 runbook 和至少一轮试跑记录

- [ ] **Step 1: 写出 runbook**

在 `docs/specs/beta-pilot-runbook.md` 中写清：

```markdown
1. 发包前检查什么
2. 第一次如何引导用户开始
3. 什么时候只观察不干预
4. 什么时候追问“哪里不准 / 哪里没用”
5. 什么时候记录后续日志痕迹
```

- [ ] **Step 2: 先做一次作者侧干运行**

按 runbook 自己完整走一次：

```text
- 用最小用户包视角检查 README / SETUP
- 模拟第一次导入和第一次贴日志
- 记录任何仍然需要开发者脑补的地方
```

- [ ] **Step 3: 选择 3-5 位内测用户**

筛选标准固定为：

```text
- 会用 AI
- 不会写代码或不熟悉本仓库结构
- 愿意在真实日志场景中试一次
```

- [ ] **Step 4: 按“自然反馈优先”运行内测**

执行时遵守：

```text
- 不先塞反馈表单
- 先看用户能否自然开始
- 只在反馈过于模糊时追问“哪里不准 / 哪里没用”
```

### Task 6: 汇总结论并决定下一轮优化

**Files:**
- Create: `docs/specs/beta-pilot-round-1-summary.md`
- Modify: `PROJECT_STATUS.md`
- Modify: `CHANGELOG.md`
- Modify: `VERSION`

**Interfaces:**
- Consumes: Task 5 的试跑记录与用户自然反馈
- Produces: 一轮内测总结，以及基于证据的继续 / 收缩 / 改向判断

- [ ] **Step 1: 产出首轮总结**

用 `docs/specs/beta-synthesis-template.md` 生成首轮总结，至少回答：

```text
- 用户认为哪里准确
- 用户认为哪里有用
- 有哪些验证痕迹
- 最大的首次使用摩擦是什么
```

- [ ] **Step 2: 做阶段判断**

按以下规则判断：

```text
如果准确性和有用性都弱：先回到日反馈价值核，而不是继续做分发。
如果准确性强、有用性弱：收紧动作为主，减少漂亮复述。
如果准确性和有用性都强，但首次摩擦高：优先继续优化最小用户包和引导。
```

- [ ] **Step 3: 同步项目状态**

根据首轮结论更新：

```text
- PROJECT_STATUS 的当前进度 / 待办 / 已知问题
- VERSION 的补丁版本
- CHANGELOG 的一条发布级记录
```

## Self-Review

1. Spec coverage: 已覆盖试用承诺、成功标准、最小用户包、首次体验、操作者记录、真实内测与结果回写六个层面。
2. Placeholder scan: 无 TBD、TODO、“后续再补细节”类占位。
3. Type consistency: 所有文件路径、阶段顺序和观察维度在任务间保持一致，均围绕“准确性 -> 有用性 -> 验证痕迹”展开。
