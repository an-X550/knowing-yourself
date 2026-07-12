# 质量基线验收矩阵

本矩阵用于约束“优化不删功能、不改入口、不改报告结构”的质量底线。它不是新功能清单，也不是要求一次性补大量端到端样本；它只描述真正需要守住的组件边界。

| id | 链路 | 必须验证 | 当前自动证据 | 仍需真实素材验收 |
|---|---|---|---|---|
| daily-feedback | 日反馈 | archive, evidence-level, single-insight, single-action, verification-writeback | `tests/journal-input-contract.tests.ps1` 检查日志入口、A-D 输入等级、昨日闭环、单洞察/单动作契约和验证沉淀状态 | 连续 5 次真实 `/daily-review`，确认 `verified-patterns.md` 写回质量 |
| weekly-monthly-review | 周/月复盘 | multi-perspective, six-question-report, chat-summary, user-response-section, output-path | `tests/review-workflow-contract.tests.ps1` 检查 synthesis 返回全文、摘要提取和周报用户回应区；`tests/quality-baseline.tests.ps1` 检查多视角并行、六问契约、用户回应入口与输出路径 key | 用真实素材跑一次 `/weekly-review` 与 `/monthly-review` |
| project-review | 项目复盘 | conversation-materials, project-filename, six-question-report, chat-summary, output-path | `tests/quality-baseline.tests.ps1` 检查 `sanitizeProjectSlug`、`output.project_report`、当前对话材料消费提示和项目复盘命令模式 | 用真实项目材料跑一次 `/project-review` |
| yearly-review | 年度复盘 | monthly-report-reading, insufficient-material-degradation, annual-summary, chat-summary, output-path | `tests/quality-baseline.tests.ps1` 检查 12/6 月报阈值、无月报降级、年度摘要与 `yearly_extra` 摘要质量门 | 准备足够月报样本后跑一次 `/yearly-review` |
| life-design | 人生设计 | mode-parameters, evidence-scope, seven-day-experiment, output-path | `tests/quality-baseline.tests.ps1` 检查 quick/standard/full/odyssey、90 天默认范围、人生设计输出路径和 7 天实验契约 | 用真实长期卡点跑一次 `/life-design --quick` |
| user-package | 用户版 | shared-capability-equivalence, developer-capability-removal, export-drift, clean-release-state | `tests/distribution-boundary.tests.ps1` 检查 shared/override/user_only、导出漂移、manifest 源跟踪和 `zhiji-user` clean gate | 用 `zhiji-user/` 做一次用户视角干运行 |

## 不变约束

- 不改变命令入口和参数。
- 不改变报告路径。
- 不改变报告一级结构。
- 不改变读取优先级和错误降级。
- 不删除任何当前功能。
- 静态契约测试只证明组件边界存在；真实质量仍需要用真实素材验收。

## 后续顺序

1. 自动边界测试已补齐，由 `tests/project-integrity.tests.ps1` 统一执行。
2. 当前按本矩阵的“仍需真实素材验收”逐项补验收记录。
3. 真实素材证明行为稳定后，再继续 agent 文本去重和共享能力回抽。
