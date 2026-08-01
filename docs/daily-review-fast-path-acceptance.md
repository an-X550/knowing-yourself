# 日分析快路径验收说明

## 目的

这份说明只回答一件事：`/daily-review` 或单日日志粘贴入口，这一次是否真的按日分析快路径执行了。

它是验收工具，不是新的执行入口，也不是新的默认输入源。

## 适用范围

- `/daily-review`
- 单日日志粘贴后由 `log` skill 路由到 `daily-analyzer`

## 通过标准

### A. 入口分支正确

满足以下任一情况即通过：

1. 已有同日反馈文件，且用户没有要求“重新分析 / 刷新”，直接展示已有反馈。
2. 用户明确要求重跑，重新执行 `daily-analyzer`。
3. 首次生成该日期反馈，正常执行 `daily-analyzer`。

若已有反馈却仍然无条件重跑，判定为不通过。

### B. 读取集合正确

执行过程中允许读取：

- `.claude/shared/paths.md`
- `.claude/shared/contracts/daily-feedback.md`
- `.claude/shared/contracts/evidence-and-verification.md`
- 目标日期日志
- 上一条日反馈（仅用于昨日闭环）
- `context.verified_patterns`

默认不应读取：

- `PROJECT_STATUS.md`
- `CHANGELOG.md`
- `VERSION`
- `README.md`
- `AGENTS.md`
- `CLAUDE.md`
- git 状态、提交流转说明

只要无必要地读取了上述治理文件，就判定为不通过。

### C. 输出动作正确

必须同时满足：

1. 输出内容符合 `.claude/shared/contracts/daily-feedback.md`。
2. 反馈写入 `output.daily_feedback` 对应文件。
3. 按 `.claude/shared/contracts/evidence-and-verification.md` 更新 `verified-patterns.md`，或明确说明这次没有写回。
4. 仅在首次成功保存正式日反馈并完成验证沉淀后，才可调用 `review-readiness-checker` 的 `delivery` 模式；其非空返回只能作为日反馈后的独立提醒行，不得写入或改变 `output.daily_feedback`、`verified-patterns.md`。快路径、D 级输入、无日志和分析失败不得调用该模式。

### D. 无额外扩读

不应为了“更稳”而额外通读：

- 整月原始日志
- 方法论文档
- 开发规范文档

如果出现证据缺口，应先说明缺口，再做最小补读；不能直接扩成全量阅读。

## 验收问题单

每次验收只看四个问题：

1. 这次走的是“复用已有反馈”还是“重新分析”分支？
2. 读取集合是否仍停留在日分析最小集合？
3. 是否写回了正确输出文件和验证沉淀？
4. 是否发生了无必要扩读？

四项都为“是 / 正确 / 没有”时，判定通过。

## 失败归因

若未通过，优先归因为以下三类：

1. 复用分支失效：已有反馈却仍重跑。
2. 治理上下文串入：无必要读取版本、README、规范或 git。
3. 证据边界失控：没有证据缺口却扩读大量原始日志或方法论文档。
