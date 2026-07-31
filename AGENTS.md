# 开发规范 - 知己

## 元规则

**冲突解决**：具体规则优先于通用规则；编号大的规则优先于编号小的规则。

**跳过阈值**：以下情况可跳过非必要流程，直接执行：
- 纯信息查询、阅读文件回答问题
- 单文件小改动（<20 行变更）
- 用户明确说“直接改”/“跳过”/“不用走流程”
- 用户执行日志分析操作（粘贴日志、`/daily-review`、`/weekly-review`、`/monthly-review`、`/journal-coach` 等）

> ⚠️ **Superpowers 例外**：若当前环境实际提供 superpowers 技能，仍按「六、工作流控制」评估是否触发；若不可用，回退到本文件内置流程，不阻塞任务。

### 沟通与决策

- 默认结论先行；随后只给支撑结论所需的证据、用户影响和下一步。
- 不以无证据的赞美或附和替代判断。方案有问题时，直接说明问题、证据、用户影响和更简单的替代方案。
- 技术或流程决策必须说明要解决的真实问题、最小可行路径，以及对使用摩擦和验证闭环的影响。
- 用户明确要求“依据第一性原理分析”、复核或压缩既有结论时，读取 `.claude/shared/contracts/first-principles-analysis.md`。第一性原理复核用于提高决策质量，不能替代新功能必要性闸门、证据边界或写入确认。

### 维护边界

- **唯一运行真相**：`.claude/`。产品逻辑只维护 `.claude/agents/`、`.claude/commands/`、`.claude/workflows/`、`.claude/skills/`、`.claude/settings.json` 与 `.claude/shared/`。
- **唯一开发规范**：`AGENTS.md` / `CLAUDE.md` 必须保持逐字同步。
- **Codex 边界**：`.codex/` 仅保留开发辅助配置，不承载产品逻辑。
- **本地 AI 辅助边界**：`.agents/skills/superpowers/` 仅作本地开发辅助目录，已 gitignore，不属于产品运行真相，也不纳入提交范围。
- **文档职责边界**：
  - `README.md`：项目入口与使用导航
  - `PROJECT_STATUS.md`：当前事实、进度、待办、已知问题
  - `CHANGELOG.md`：发布级变化历史
  - `AGENTS.md` / `CLAUDE.md`：执行规范
  - `docs/archive/`：不再作为当前真相，但仍需保留引用价值的历史文档

### 日志粘贴处理

当用户直接粘贴日志原文，且内容尚未被 `log` skill 预处理时，按以下契约执行：

1. 追加到对应月份日志文件：`日志/谢安的YYYY-N月日志.md`
2. 优先调用 `daily-analyzer`；如无法调用，则按 `.claude/shared/prompt-rules.md` 与 `.claude/agents/daily-analyzer.md` 的约定回退生成
3. 将分析结果写入 `复盘/每日反馈/YYYY-MM-DD.md`
4. 对话中展示与文件一致的反馈内容

### Codex 自然语言复盘入口

当用户以自然语言请求周报、月报或项目复盘时，读取并执行 `.claude/shared/contracts/codex-natural-language-routing.md`。`.claude/` 仍是唯一运行真相；Codex 不以 Claude slash command、`Workflow` 或 `Task` 为运行前置条件。

### 主题思考入口

普通提问涉及用户既有观点、长期困惑或价值判断时，先读取 `.claude/shared/contracts/topic-thinking.md`，按契约检查 `context.thinking_index`；没有明显匹配则不读取详细主题。用户主动探讨形成可沉淀认识时，必须先展示归纳并获得确认，不能从日志自动摘录。

---

## 一、上下文加载

### 最小足够上下文

每次对话默认按以下顺序读取：

0. `.claude/shared/ai-operating-principles.md`
1. `PROJECT_STATUS.md`
2. `CHANGELOG.md` 最近 5 条
3. `README.md` 仅在对外说明、目录结构、命令表、安装使用、版本徽章受影响时读取

`docs/first-principles.md` 是给开发者和用户看的提醒文档，不作为 AI 默认长上下文；当讨论项目初心、开发者纪律或用户纪律时再读取。

### 开发治理按需上下文

仅当本次会修改项目文件时，读取 `docs/development-governance.md`。该文件定义版本、CHANGELOG、状态同步、文档/目录检查、提交、回退与 Spec-Before-Code 细则；不在日志分析、复盘生成、普通答疑时默认读取。

---

## 二、工作流控制

### 新功能必要性闸门

新增 command、agent、workflow、skill、hook、配置行为、报告形态或用户入口时，必须在 spec、plan 和代码之前先判断是否值得做。用户说“直接改”“不用规划”或“立即实现”不能跳过本闸门。

只有以下四项同时成立，才进入后续开发流程：

1. 有当前、具体的问题证据，不是“未来可能需要”。
2. 直接服务项目核心目标或明确的面试叙事目标。
3. 现有能力、流程调整或删除复杂度无法更简单地解决。
4. 实现后能立即验证是否解决了问题。

任一项不成立时：

1. 停止实施，不创建 spec、plan 或代码。
2. 说明缺失的证据、继续开发的机会成本和更简单的替代方案。
3. 明确劝阻用户现在不要新增该功能。
4. 只有用户读完理由、明确复述风险并再次要求继续，才允许覆盖本次劝阻并进入现有开发流程。

本闸门不阻挡 bug 修复、安全修复、兼容性修复、测试补齐、文档纠错和删除冗余。任务同时包含维护与新增能力时，只拦截新增部分，不阻塞可独立完成的维护部分。

### Superpowers 集成

当用户执行开发任务且当前环境实际提供对应 superpowers 技能时，按任务类型自动调用；若技能不可用，则回退到本文件内置流程。

| 用户场景 | 自动调用的技能 |
|---------|----------------|
| 新增功能/需求 | `superpowers:brainstorming` -> `superpowers:writing-plans` -> `superpowers:executing-plans` |
| Bug 修复 | `superpowers:systematic-debugging` |
| 代码重构 | `superpowers:writing-plans` -> `superpowers:verification-before-completion` |
| 测试 | `superpowers:test-driven-development` |
| 请求代码审查 | `superpowers:requesting-code-review` |
| 接收审查反馈 | `superpowers:receiving-code-review` |
| 并行任务 | `superpowers:dispatching-parallel-agents` |
| 完成分支 | `superpowers:finishing-a-development-branch` |
| Git 工作树隔离 | `superpowers:using-git-worktrees` |

以下情况不强制调用：

- 纯信息查询
- 已处于某个 superpowers 技能上下文中
- 仅文档/注释/格式修正
- 用户明确说“不用 superpowers”
