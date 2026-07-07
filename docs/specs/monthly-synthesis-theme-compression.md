---
created: 2026-07-07
status: 已完成
---

# 需求目标

收紧月度综合引擎的主题归并能力，让月报从“按视角铺陈”转为“按主题综合”。

> 作为月度复盘的读者，我想看到 2-3 个跨视角验证过的核心主题，而不是多个视角段落的拼接，这样我能更快抓住本月主线和下月验证重点。

# 边界约束

- 不做什么：本阶段不改 `monthly-processor` 输出协议，不改 `perspectives/*.md`，不新增视角，不改命令入口、输出路径或报告骨架。
- 影响范围：`.claude/agents/monthly-synthesis.md` 为主；如有必要，轻量调整 `.claude/workflows/monthly-review.js` 传给综合引擎的附加指令。
- 技术约束：保留现有 YAML frontmatter、聊天摘要区块、月报章节骨架、中文输出、证据规则与 `paths.md`/`prompt-rules.md` 权威引用。

# 验收标准

- [x] `monthly-synthesis` 明确要求先做主题归并，再写章节，禁止按视角顺序重述分析结果。
- [x] 月报执行摘要与关键章节只保留 2-3 个主主题，每个主题都包含支持视角、关键证据和反例/证据不足说明。
- [x] 同一份月报在不改上游视角文件的前提下，读感从“视角汇编”转向“主题综合”，且原有报告骨架不变。

# 实施计划

1. 修改 `.claude/agents/monthly-synthesis.md`，新增主题归并步骤、降权规则和主题写作约束。
2. 视情况微调 `.claude/workflows/monthly-review.js` 的 `extraInstruction`，强调“不要按视角顺序展开”。
3. 以现有月报样本为对照进行回归检查，确认输出仍保留骨架但更聚焦主题。

# 当前状态：已完成
