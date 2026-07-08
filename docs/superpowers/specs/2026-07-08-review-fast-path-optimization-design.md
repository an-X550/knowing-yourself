---
created: 2026-07-08
status: approved
---

# 复盘快路径优化设计

## 背景

当前项目已经完成运行契约拆分，但高频日反馈与周/月/life-design 这类复盘命令仍存在两类额外成本：

1. 读取与当前任务无关的开发治理上下文。
2. 在综合阶段重复回查原始日志、方法论文档或质量标准文档。

这些读取会增加等待时间和上下文冲突概率，但不会稳定提高输出质量。真正不能省的是证据、闭环和输出契约。

## 目标

1. 为 `/daily-review` 建立明确的单日快路径。
2. 为周/月/life-design 建立“沉淀物 -> 证据包 -> 原始日志抽查”的分层读取顺序。
3. 保留现有输出质量：证据纪律、昨日闭环、验证沉淀、复盘六问、方向锚点缺席检查、life-design 的实验性输出。
4. 不改变命令入口、默认输出路径、报告一级结构和 workflow 总体编排。

## 非目标

- 不引入结构化缓存或索引文件。
- 不新增命令或 agent。
- 不压缩周/月/life-design 的最终章节结构。
- 不为提速删除证据核验或反例说明。

## 设计

### 1. 日分析快路径

`daily-review` 与 `daily-analyzer` 默认只读取：

1. `.claude/shared/paths.md`
2. `.claude/shared/contracts/daily-feedback.md`
3. `.claude/shared/contracts/evidence-and-verification.md`
4. 目标日志
5. 上一条每日反馈
6. `context.verified_patterns`

默认不触发版本校验、`PROJECT_STATUS.md`、`CHANGELOG.md`、`README.md`、开发规范、git 状态或提交流程。

若目标反馈文件已存在且用户未明确要求重跑，优先直接展示现有反馈，不重新分析。

### 2. 复盘综合分层读取

周/月/life-design 的默认读取顺序统一为：

1. 沉淀物：每日反馈、周/月报、`context.current`、`context.verified_patterns`
2. 证据包：视角分析结果
3. 原始日志：仅在引用缺失、证据冲突或需要补证时抽查

`docs/analysis-standards.md` 和 `docs/methodology-review.md` 仅保留为必要时的补充参考，不再作为默认重读材料。

### 3. 周报链路收口

`weekly-synthesis` 不再默认依赖整周原始日志做补充叙述。它先消费：

- 三个核心视角分析
- 本周每日反馈
- `context.verified_patterns`
- `context.current`
- 上周或当月报告中的方向锚点

只有引用不完整或视角之间冲突时，才回查原始日志。

同时修正 `monthly-processor` 对周度输入的说明，避免 `Process week ...` 与“只处理月份”的提示冲突。

### 4. 月报综合收口

`monthly-synthesis` 以 workflow 传入的视角分析为主输入，不默认回读整月原始日志、方法论文档或质量标准文档。

它保留以下必要补充读取：

- `context.current`
- `context.verified_patterns`
- 上月月报
- 核心画像

若视角证据已足够，则直接归并主题；只有证据冲突、上月假说需要核验或关键引用缺失时才抽查原始日志。

### 5. Life Design 分模式优化

`life-design-synthesis` 改为显式分层：

- `quick`：优先读取最近 7 条日反馈、最近 1 份月报、`context.current`、`context.core_profile`、`context.verified_patterns`；仅抽样日志锚定证据。
- `standard`：优先读取最近 14 条日反馈、最近 1-3 份周/月复盘与长期上下文；原始日志只在综合材料不足时抽查。
- `full` / `odyssey`：允许更深的原始日志阅读，因为目标就是深度校准。

## 成功指标

1. 日反馈文档明确声明快路径与“已存在反馈优先展示”。
2. `weekly-synthesis`、`monthly-synthesis`、`life-design-synthesis` 都把原始日志读取改为条件触发。
3. `weekly-review.js` 与 `monthly-review.js` 的综合提示不再鼓励默认回读原始日志。
4. `monthly-processor` 明确支持周度输入或明确周度边界，不再与周报 workflow 冲突。
5. `prompt-rules.md` 明确新增“复盘类命令默认走运行快路径”的共享规则。

## 风险与控制

| 风险 | 控制 |
|------|------|
| 过度减法导致证据不足 | 明确规定只有开发治理上下文可跳过，证据链不可跳过 |
| 周报因不读原始日志而漏掉细节 | 允许在引用缺失、证据冲突时回查原始日志 |
| 月报综合与 workflow 指令不一致 | 同步收口 `monthly-review.js` 与 `monthly-synthesis.md` |
| life-design 变成“只读摘要瞎判断” | `quick` 和 `standard` 保留日志抽样核验，`full` / `odyssey` 保留深读 |
