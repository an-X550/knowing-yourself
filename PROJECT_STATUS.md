---
created: 2026-07-05
last_updated: 2026-07-08
---

# PROJECT_STATUS — 知己

**当前版本**：1.3.23

## 项目概述

**知己** 是一个基于 Claude Code 的 AI 日志分析与复盘教练 Skill，围绕日、周、月、年的复盘节奏运行，通过多视角分析帮助用户做自我认知、成长追踪和行动改进。

**目标场景**：个人长期日志记录、周期性复盘、成长模式识别。

**方法论基础**：
- 日志六步法
- 六维成长模型
- 复盘六问框架
- 加分制评分体系

## 技术栈

| 层面 | 技术 |
|------|------|
| 运行平台 | Claude Code CLI / VSCode Extension |
| 内容格式 | Markdown + YAML frontmatter |
| 命令系统 | Claude Code Slash Commands（10 个） |
| 代理系统 | Claude Code Sub-agents（6 个） |
| 配置 | JSON |
| 版本控制 | Git + 语义化版本 |
| 语言 | 中文内容 + 英文配置字段 |

### 维护边界

- **唯一运行真相**：`.claude/`
- **唯一开发规范**：`AGENTS.md` / `CLAUDE.md`
- **Codex 边界**：`.codex/` 仅保留开发辅助配置
- **本地 AI 辅助边界**：`.agents/skills/superpowers/` 不属于产品逻辑且不纳入提交

## 架构设计

### 三层结构

```text
命令层 -> 用户入口与流程编排
代理层 -> 日志读取、分析执行、综合输出
视角层 -> 分析框架、评分标准、输出边界
```

### 生命周期入口

| 周期 | 命令 | 核心处理 |
|------|------|---------|
| 日 | `/daily-review` | `daily-analyzer` |
| 周 | `/weekly-review` | `monthly-processor` ×3 + `weekly-synthesis` |
| 月 | `/monthly-review` | `monthly-processor` ×N + `monthly-synthesis` |
| 年 | `/yearly-review` | `yearly-synthesis` |
| 任意 | `/review` | `review-readiness-checker` 路由 |

### 视角结构

- **生活内容视角（6）**：`chronicle`、`coach`、`therapist`、`relationships`、`strengths`、`values-meaning`
- **方法论视角（3）**：`growth-dimensions`、`journal-quality`、`review-coach`

## 当前进度

### 核心模块

| 模块 | 状态 | 说明 |
|------|------|------|
| 命令系统 | ✅ 完成 | 10 个命令均已就绪 |
| 代理系统 | ✅ 完成 | 6 个代理均已就绪 |
| 视角体系 | ✅ 完成 | 9 个视角均已就绪 |
| 共享规则与路径契约 | ✅ 完成 | `paths.md` / `prompt-rules.md` / `banned-phrases.json` 已收口 |
| 月度综合链路 | ✅ 完成 | 已对齐“证据包 → 主题综合” |
| 年度链路端到端验证 | 🔶 进行中 | 依赖更多月度报告和实测 |
| 示例与自动化测试 | 🔶 进行中 | 仍需补样本与测试覆盖 |

### 命令完成度（10/10）

`/review`、`/daily-review`、`/weekly-review`、`/monthly-review`、`/yearly-review`、`/journal-coach`、`/interview`、`/update-current`、`/import`、`/提交`

### 代理完成度（6/6）

`daily-analyzer`、`weekly-synthesis`、`monthly-processor`、`monthly-synthesis`、`yearly-synthesis`、`review-readiness-checker`

### 产出与样本

| 项目 | 状态 |
|------|------|
| 月度复盘报告 | ✅ 已有 2026-04 / 2026-05 / 2026-06 / 2026-07 |
| 日分析样本 | ✅ 已有 2 份 |
| 周/月样本补充 | 🔶 待继续增加 |
| `关于我/current.md` | ✅ 已建占位，由 `/update-current` 维护 |

## 待办事项

### 高优先级

- [ ] 运行 `/weekly-review` 对最近一周做完整测试
- [ ] 运行 `/journal-coach` 对最近 7 天做完整测试

### 中优先级

- [ ] 增加更多单日分析样本，覆盖 A/B/C/D 不同质量等级
- [ ] 测试 `/yearly-review`（需要至少 6 个月度报告）
- [ ] 添加示例周志/月志文件

### 低优先级

- [ ] 为视角文件增加更多示例输出
- [ ] 自动化测试
- [ ] CSV 导出功能
- [ ] 国际化支持
- [ ] README 英文版

## 已知问题

### 路径与兼容性

1. 输入/输出目录使用中文名，在部分 Windows / CI 环境中可能遇到编码问题。
2. `日志/周志/`、`日志/月志/` 与 `output/` 的部分目录仍依赖运行时创建。

### 数据与格式

3. 当前日志常以“单文件包整月”的方式存储，而不是每日独立文件，增加了解析复杂度。
4. 用户现有日志模板缺少“分享讨论”这一显式栏位，会影响 `journal-quality` 评分。

### 行为与验证

5. `review-coach` 依赖用户先写好周志/月志，否则无法产出有效评估。
6. `/yearly-review` 依赖链较长，尚未完成端到端验证。
7. 当前分析样本仍偏少，尤其缺周度与月度示例。

### 适配性

8. 项目仍偏单用户语境，迁移到其他用户时需调整画像与部分提示语境。
9. 方法论文档当前仅提供中文版本。

## 关键决策记录

| 日期 | 决策 | 理由 |
|------|------|------|
| 2026-07-05 | 采用命令 → 代理 → 视角三层结构 | 降低耦合，分离入口、执行与分析定义 |
| 2026-07-05 | 视角拆分为生活内容 6 + 方法论 3 | 同时覆盖“内容洞察”和“写作/复盘质量评估” |
| 2026-07-05 | 支持单文件整月日志 | 适配真实使用方式，而非强制每日独立文件 |
| 2026-07-06 | `/monthly-review` 支持多模式 | 在速度、覆盖度与摩擦之间做分层选择 |
| 2026-07-07 | `.claude/` 固化为唯一运行真相 | 避免 `.codex/` 与 `.claude/` 双份漂移 |
| 2026-07-07 | 维护文件改为影响驱动读取与更新 | 降低上下文噪音和维护成本 |
| 2026-07-07 | 日反馈统一为 `daily-analyzer` 契约 | 保证 `/daily-review` 与 `log` skill 输出一致 |
| 2026-07-07 | 路径与提示词规则集中到共享文件 | 降低 agent/command/workflow 漂移风险 |
| 2026-07-08 | Git 提交流程改为“验证在内、写入在外” | 适配受限环境下的提权边界 |
| 2026-07-08 | 月度上游中间产物收紧为证据包 | 让综合层按主题归并，减少“按视角拼贴”的月报读感 |
