---
created: 2026-07-05
last_updated: 2026-08-01
---

# PROJECT_STATUS - 知己

**当前版本**：1.9.5

## 项目概述

**知己** 是面向中文个人日志的 AI 复盘系统，把日记、复盘与长期方向校准收敛为可验证的行动闭环。

- 高频闭环：日志粘贴 -> 日反馈 -> 次日验证
- 低频校准：周/月/项目/年复盘 -> 方向异常提醒 -> 人生设计升级

## 技术栈

| 层面 | 选型 |
|------|------|
| 运行平台 | Codex 自然语言入口；Claude 命令兼容 |
| 内容格式 | Markdown + YAML frontmatter |
| 核心入口 | 自然语言 + 兼容 Slash Commands |
| 共享契约 | `.claude/shared/` |
| 配置与版本 | JSON；Git + 语义化版本 |

## 架构设计

```text
命令层 -> 用户入口与流程编排
代理层 -> 日志读取、分析执行、综合输出
视角层 -> 分析框架、评分标准、输出边界
```

`.claude/` 是唯一运行真相；`zhiji-user/` 是用户版分发包，`packaging/zhiji-user-overlay/` 是其变体定义源。README 负责入口，本文档只记录当前事实，CHANGELOG 记录发布历史，AGENTS/CLAUDE 定义执行规范。

## 当前进度

| 项目 | 状态 | 当前能力或证据缺口 |
|------|------|------|
| 日反馈闭环 | 已完成 | 日志粘贴与 `/daily-review` 统一进入 `daily-analyzer`；输出按单洞察、单行动、可观察预测收敛，输入不足按 A-D 证据等级降级。 |
| 日志质量教练 | 已完成 | `journal-quality-coach` 独立评估分析就绪度与六步法写作习惯。 |
| 周/月/项目复盘 | 已完成真实验收 | 统一复盘六问；按会改变判断、重来选择或行动的内容自适应展开，保留证据、边界、项目锚点与行动质量门。Codex 可直接理解三类自然语言请求，Claude slash command 保持兼容。 |
| 低频人生设计 | 已完成 | `/life-design` 是独立方向校准入口；年度链路仍待更多月报样本完成端到端验证。 |
| 运行快路径 | 已完成 | 日反馈优先复用已有反馈；复盘优先消费沉淀物和证据包，仅在冲突或引用缺失时扩大读取范围。 |
| 用户版分发与边界 | 已完成 | overlay、manifest、导出链路、Codex 日志路由、Windows Stop Hook、年度目录和分发边界测试已具备；仍需真实用户干运行。 |
| 质量基线 | 已完成 | 覆盖日反馈、周/月/项目/年度复盘、人生设计和用户版的组件边界；真实样本仍需持续补齐。 |
| 主题思考库 | 已完成首轮审查 | 首稿先给可确认主线；确认后才按用途写入 0–6 或短结构。新认知先分类其影响，再重组受影响的当前论证；篇幅按理解所需决定，默认执行第一性原理审查与合并更新。 |
| 收藏吃灰库 | 已完成 | 用户明确收录时按标题、摘要、关键词、原文/摘录、链接五段式保存，并有主项目与用户版路由回归。 |
| 治理文档职责 | 已完成 | 默认上下文只保留入口与当前事实；文件改动时按需加载治理细则，历史决策独立归档。 |

## 待办事项

当前仍有引用价值的实现规格：[`audit-cleanup`](docs/specs/audit-cleanup.md)、[`directory-boundary-tightening`](docs/specs/directory-boundary-tightening.md)、[`evolution-roadmap`](docs/specs/evolution-roadmap.md)、[`git-commit-escalation-flow`](docs/specs/git-commit-escalation-flow.md)、[`monthly-perspective-audit`](docs/specs/monthly-perspective-audit-2026-07-08.md)、[`monthly-processor-evidence-packets`](docs/specs/monthly-processor-evidence-packets.md)、[`monthly-synthesis-theme-compression`](docs/specs/monthly-synthesis-theme-compression.md)。

### 高优先级

- [ ] 连续运行至少 5 次真实 `/daily-review`，验证 `verified-patterns.md` 写回质量。
- [ ] 以真实样本观察周/月/项目复盘；仅在出现可复现的重复、证据缺口或行动不可检查时修复。
- [ ] 跑完一次真实 `/life-design --quick`。
- [ ] 用 `zhiji-user/` 完成一次用户视角干运行，并发给 3–5 位目标用户试用。
- [ ] 按 `packaging/zhiji-user-boundaries.json` 与质量矩阵补真实素材验收；只收敛已有证据支持的 shared 文件。

### 中优先级

- [ ] 用真实非模板日志补 A/B/C/D 证据等级样本，并补周报、项目复盘示例。
- [ ] 为 `/yearly-review` 准备足够月报样本。

### 低优先级

- [ ] 在真实需求出现前，暂缓 CSV 导出、自动化回归扩张和国际化。

## 已知问题

1. 输入与输出目录仍使用中文名称，部分 Windows/CI 环境可能有编码或路径兼容性问题。
2. 日志常按“单文件包整月”存储，增加解析复杂度。
3. `/yearly-review` 依赖链条长，尚缺足够端到端验证。
4. 样本仍偏单用户和真实个人语境，迁移到其他用户前需校准提示语和示例。
5. overlay 仍有已声明理由的 override，后续只在有收益证据时收敛为 byte-identical shared 文件。
6. 没有“日志 / 日记 / 记录一下”等意图的自由文本无法仅靠 Hook 安全区分普通对话，当前会先确认一次再存档。

## 关键决策记录

2026-07-15 之前的历史决策见 [`project-status-decisions-through-2026-07-15.md`](docs/archive/project-status-decisions-through-2026-07-15.md)。

| 日期 | 决策 | 理由 |
|------|------|------|
| 2026-07-15 | 显式第一性原理请求采用共享复核契约而非新命令 | 用户在发现内容过长或结论可疑时已主动使用该表述；用短契约覆盖默认表达深度，不改变入口、路径或报告骨架。 |
| 2026-08-01 | 确认后的主题更新先重组当前论证 | 仅要求比较与合并仍会诱发机械追加；新认知先分类其对当前判断的影响，再重组受影响章节并检查依据、去重、边界与行动/转向，不限制篇幅，也不增加用户成本。 |
| 2026-07-19 | 主题思考采用默认审查、合并更新与自适应行动门槛 | 新信息会长期追加；创建和更新都比较旧内容，以保留、修正、替换、合并、归档或不写入收敛重复、冲突和失效行动；只有会改变判断、行动或验证时才展开。 |
| 2026-07-31 | 主题首稿与确认沉淀分离 | 首稿只读取问题、依据、判断和下一步；0–6、维护与全量审查只在用户确认沉淀后读取，继续讨论只在会改变当前判断时可选。 |
| 2026-07-31 | Codex 以自然语言直达周/月/项目复盘 | 用户实际在 Codex 中工作；以单一共享路由复用 `.claude/` 综合定义，保留 Claude slash command 兼容，未增加默认调用或读取范围。 |
