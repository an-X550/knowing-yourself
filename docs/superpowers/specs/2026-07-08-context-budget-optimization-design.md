---
created: 2026-07-08
status: approved
---

# 上下文预算优化设计

## 背景

项目已经完成过 prompt 去重、日反馈压缩、第一性原理拆分和月度证据包等减法工作。当前主要问题不再是“输出太长”，而是运行时上下文仍有部分粗粒度读取：单日反馈需要完整阅读通用分析标准，周报和月报重复维护六问、证据、验证沉淀等规则。

这会增加 token 消耗、等待时间和模型执行时的冲突概率。优化目标不是降低分析质量，而是让每个 skill 读取完成当前任务所需的最小充分契约。

## 目标

1. 降低 `/daily-review`、`/weekly-review`、`/monthly-review` 等高频或长链路任务的非必要上下文读取。
2. 保留现有输出质量要求：证据纪律、日反馈闭环、复盘六问、方向锚点缺席检查、验证沉淀消费。
3. 修正旧结构描述，避免命令层与 agent 层对报告结构给出互相冲突的指令。
4. 保持命令名、参数格式、输出路径、文件名、workflow 编排和报告一级结构不变。

## 非目标

- 不新增命令、agent、workflow 或视角。
- 不改变用户输入方式。
- 不引入证据索引缓存；这是后续阶段，需等验证闭环稳定后再做。
- 不缩短最终报告章节结构，不删除质量自检。
- 不把 `.codex/` 纳入运行真相。

## 设计

### 1. 契约分层

新增 `.claude/shared/contracts/`，把原先集中在 `.claude/shared/prompt-rules.md` 的任务型细则拆成短契约：

| 文件 | 职责 |
|------|------|
| `.claude/shared/contracts/daily-feedback.md` | 日反馈输出契约、D0-D6 轻量质量门、压缩检查 |
| `.claude/shared/contracts/review-synthesis.md` | 周/月/项目类复盘综合契约、复盘六问、方向锚点缺席检查 |
| `.claude/shared/contracts/evidence-and-verification.md` | 通用证据规则、验证沉淀写回和周/月消费规则 |

`.claude/shared/prompt-rules.md` 保留为索引和全局硬规则：路径读取、入口边界、输出责任、禁用词同步、减法边界。具体任务只读取相关 contract。

### 2. 日反馈轻量读取

`daily-analyzer` 改为读取：

1. `.claude/shared/paths.md`
2. `.claude/shared/contracts/daily-feedback.md`
3. `.claude/shared/contracts/evidence-and-verification.md`
4. `context.verified_patterns`（若存在）

它不再要求读取完整 `docs/analysis-standards.md`。D0-D6 被移动到日反馈契约中，保证质量门仍在，但 token 负担更小。

### 3. 复盘综合统一读取

`weekly-synthesis` 和 `monthly-synthesis` 改为读取：

1. `.claude/shared/paths.md`
2. `.claude/shared/contracts/review-synthesis.md`
3. `.claude/shared/contracts/evidence-and-verification.md`
4. 必要时按需读取 `docs/analysis-standards.md` 和 `docs/methodology-review.md`

复盘六问、方向锚点缺席检查、验证沉淀消费由 `review-synthesis.md` 维护，agent 文件只保留各自差异：周期、输入来源、深度、输出文件和错误处理。

### 4. 命令层冲突修正

`weekly-review.md` 当前仍保留旧式“7章→5段”描述，与 `weekly-synthesis` 的复盘六问结构冲突。该描述应更新为六问结构说明，避免模型同时收到旧结构和新结构。

### 5. 文档与版本同步

这是运行契约重构，会影响 agent 读取方式和用户体验，应作为发布级变化处理：

- `VERSION` 修订号 +1。
- `PROJECT_STATUS.md` 更新当前版本，并在当前进度或关键决策中记录上下文预算化。
- `CHANGELOG.md` 追加一条 `[重构]` 记录。
- 如 `README.md` 的共享契约说明受影响，同步补充 contracts 目录。

## 成功指标

1. `/daily-review` 必读文档不再包含完整 `docs/analysis-standards.md`。
2. 日反馈契约仍包含昨日闭环、原文支撑、盲点、模式连接、一个动作、原子粒度、预测可验证、260 字常规上限。
3. 周/月综合仍显式保留复盘六问、方向锚点缺席检查和验证沉淀消费。
4. `weekly-review.md` 不再出现旧式“7章→5段”或“5段简化复盘”描述。
5. 新增 contract 文件均有 YAML frontmatter，路径引用存在。
6. `VERSION`、`PROJECT_STATUS.md` 与 `CHANGELOG.md` 版本一致。

## 风险与控制

| 风险 | 控制 |
|------|------|
| 拆分后 agent 忘读关键质量门 | 在每个 agent 必读规则中显式列出 contract 文件 |
| 重构误改输出结构 | 明确禁止改命令、参数、输出路径、文件名和报告一级结构 |
| contract 与旧文档漂移 | `prompt-rules.md` 只做索引，不复制细则 |
| 为省 token 删除证据纪律 | 证据与验证契约单独保留，作为所有任务共同依赖 |

## 后续阶段

证据索引缓存暂不进入本轮。等真实 `/daily-review` 至少连续运行 5 次、`verified-patterns.md` 有稳定写回后，再评估是否设计结构化证据索引。
