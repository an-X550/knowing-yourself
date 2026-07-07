# 知己

> 🎯 AI 日志分析教练 — 让 AI 帮你发现你自己看不见的行为模式

[![Blog](https://img.shields.io/badge/博客-阅读全文-blue)](https://vystrcil.com/blog/ai-journaling/)
[![Version](https://img.shields.io/badge/版本-v1.3.18-green)](VERSION)
[![License](https://img.shields.io/badge/许可证-MIT-yellow)](LICENSE)

**知己** 是一个基于 [Claude Code](https://docs.anthropic.com/en/docs/claude-code) 平台的 AI 日志分析与复盘教练 Skill。它通过多个专业视角并行分析你的每日日志，最终综合为结构化的复盘报告，帮助你进行自我认知、成长追踪和复盘改进。

---

## 目录

- [为什么需要它](#为什么需要它)
- [核心哲学](#核心哲学)
- [快速开始](#快速开始)
- [架构概览](#架构概览)
- [维护边界](#维护边界)
- [命令系统](#命令系统)
- [视角体系](#视角体系)
- [代理系统](#代理系统)
- [方法论文档](#方法论文档)
- [分析质量标准](#分析质量标准)
- [项目结构](#项目结构)
- [配置说明](#配置说明)
- [版本管理](#版本管理)
- [贡献指南](#贡献指南)

---

## 为什么需要它

人的三个不可克服的局限（观察者悖论、遗忘曲线、自我叙事偏差）遇上 AI 的两个不可替代优势（零情感纠葛、跨时间记忆），产生了四个核心需求：模式发现、执行问责、决策校准、成长加速。详见 [`docs/first-principles.md`](docs/first-principles.md)。

---

## 核心哲学

### 原子价值公式

```
价值 = (洞察质量 × 可行动性 × 闭环速度) / 使用摩擦
```

- **洞察质量**：你自己反思得不到的发现
- **可行动性**：能变成明天的具体行为
- **闭环速度**：从写日志到读到反馈的时间——完美的分析晚两周不如够用的分析今晚到
- **使用摩擦**：从"想分析"到"看到结果"需要做的决策数——每个额外决策都在杀死使用率

### 最小成功定义

```
至少有一条洞察，用户自己不会发现，导致了至少一个可验证的行为改变。
```

### 核心原则

| 原则 | 反例 |
|------|------|
| 闭环速度 > 分析全面性 | "等我把9个视角都跑完再一起看" |
| 被验证的洞察 > 好看的故事 | "这份报告写得真好"但什么都没改变 |
| 小量持续 > 大量冲刺 | 每天200字×30天 >> 一天3000字然后一周不写 |
| 系统服务用户 | 为了"喂饱"所有视角而刻意写某种日志 |

> 📖 完整哲学和纪律见 [`docs/first-principles.md`](docs/first-principles.md)（含 ⚡ 行动浓缩章节）

---

## 快速开始

### 前置条件

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) CLI 或 VSCode 扩展
- 将此仓库克隆到你的 Claude Code 项目根目录（或复制 `.claude/` 到已有项目）

### 三步上手

**1️⃣ 写日志** — 用你习惯的方式写每天的日志（飞书、Notion、纯文本都行）

参考六步法写日志（见 [`docs/methodology-journal.md`](docs/methodology-journal.md)）：
回忆事实 → 筛选重点 → 评估结果 → 洞察思考 → 行为改进 → 分享讨论

**2️⃣ 粘贴到 Claude Code** — 打开 Claude Code，粘贴今天的日志

系统会自动检测日志格式，存档到 `日志/` 目录。如果没有自动触发，输入 `/import` 手动导入。

**3️⃣ 获取反馈** — 输入命令获取分析

```bash
/daily-review    # 分析今天的日志，获取即时反馈（1分钟）
/weekly-review   # 本周综合复盘（3分钟）
/monthly-review  # 月度深度复盘（5-8分钟）
/review          # 自然语言统一入口："复盘六月"、"上周"
```

没有日志？复制 [`examples/demo/sample-journal.md`](examples/demo/sample-journal.md) 里的示例试试。

> 📖 详细设置说明见 [`SETUP.md`](SETUP.md)

---

## 架构概览

```
命令层 (Commands)     →  用户入口，解析参数，编排流程
代理层 (Agents)       →  执行分析任务，读取日志，应用视角
视角层 (Perspectives) →  定义分析框架、评分标准、输出结构
```

---

## 维护边界

- **唯一运行真相**：`.claude/`。Claude Code Skill 的产品逻辑只维护 `.claude/agents/`、`.claude/commands/`、`.claude/workflows/`、`.claude/skills/`、`.claude/settings.json` 与 `.claude/shared/`。
- **唯一开发规范**：`AGENTS.md` / `CLAUDE.md`。需求增删改、文档同步、版本管理、目录规则以这两份规范为准。
- **Codex 边界**：`.codex/` 只保留 Codex 开发辅助配置（如未提交提醒 hook），不作为产品逻辑维护面；`.codex/agents/` 不手工维护。如未来需要 Codex 专属 agent，必须从 `.claude/agents/` 自动生成。
- **本地 AI 辅助边界**：`.agents/skills/superpowers/` 可作为本地开发辅助目录，方便 AI 使用 Superpowers 技能；该目录已 gitignore，不属于产品运行真相。

---

### 周期层次

| 周期 | 命令 | 代理 | 频率 | 深度 |
|------|------|------|------|------|
| **日** | `/daily-review` | `daily-analyzer` | 每天 | 单篇日志质量评分 + 昨日检查 + 原子行动建议 |
| **周** | `/weekly-review` | `monthly-processor` ×3 + `weekly-synthesis` | 每周 | 3个核心视角并行分析 + 复盘六问综合报告 |
| **月** | `/monthly-review` | `monthly-processor` ×N + `monthly-synthesis` | 每月 | 6-9个视角并行分析 + 主题综合报告 |
| **年** | `/yearly-review` | `yearly-synthesis` | 每年 | 12月趋势综合 + 年度成长回顾 |
| **多日** | `/journal-coach` | `daily-analyzer` ×N | 按需 | 多日趋势 + 教练反馈 |
| **任意** | `/review` | `review-readiness-checker` | 按需 | 自然语言智能路由 |

---

## 命令系统

所有命令位于 `.claude/commands/`。

### 核心命令

| 命令 | 说明 | 模式/选项 |
|------|------|----------|
| **`/review`** 🔥 | 统一入口，支持自然语言 | 无参数时自动检测复盘时机 |
| `/daily-review` | 分析单日日志 | 自动识别最近未分析的日志 |
| `/weekly-review` | 生成周度复盘报告 | 默认上周，3核心视角 |
| `/monthly-review` | 生成月度深度复盘 | `fast`(3视角) / `standard`(6视角,默认) / `full`(9视角) / 自定义 |
| `/yearly-review` | 生成年度成长回顾 | 需要≥6份月度报告 |

### 辅助命令

| 命令 | 说明 |
|------|------|
| `/journal-coach` | 对最近N天日志进行教练式反馈 |
| `/interview` | 问答式建立个人画像（核心价值观、优势、目标等） |
| `/update-current` | 从最近日志自动更新当前状态快照 |
| `/import` | 导入外部日志文件（支持单日/多日/任意路径） |
| **`/提交`** 🆕 | 自动/手动执行本地 git add/commit，推送需手动 `git push` |

### 自动触发

系统通过 `settings.json` 中的 hook 配置，在检测到日志关键词（如"幸福日志"、"开心的事情"等）时自动触发日志存档 Skill。

---

## 视角体系

每个视角代表一个专业角色，独立分析同一批日志数据。位于 `perspectives/`。

### 生活内容分析

| 视角 | 专业角色 | 分析重点 |
|------|---------|---------|
| `chronicle` | 📋 编年史家 | 事实性事件、人物互动、活动记录 |
| `therapist` | 🧠 临床心理学家 | 情绪模式、应对机制、认知模式 |
| `coach` | 🏃 绩效教练 | 目标进度、生产力、习惯、障碍 |
| `relationships` | 💞 关系治疗师 | 连接感、依恋模式、社交能量 |
| `strengths` | 🌟 优势观察者 | 基于证据的积极面、成长、未被承认的胜利 |
| `values-meaning` | 🎯 哲学顾问 | 真实性、目的感、心流状态、价值对齐 |

### 方法论分析

| 视角 | 专业角色 | 分析重点 |
|------|---------|---------|
| `growth-dimensions` | 📐 六维成长观察者 | 六维成长模型各维度覆盖度 |
| `journal-quality` | 📝 日志质量评估师 | 对照六步法评分(1-30)、诊断典型问题 |
| `review-coach` | 🔍 复盘教练 | 对照复盘六问评估月/周志质量(1-30) |

### 使用场景

- **日常分析** (`/daily-review`)：聚焦 `journal-quality` 视角，评估单篇日志质量
- **周度复盘** (`/weekly-review`)：`chronicle` + `coach` + `therapist` 三个核心视角
- **月度复盘** (`/monthly-review standard`)：6个生活视角，默认模式
- **深度月度** (`/monthly-review full`)：9个全视角，最全面

---

## 代理系统

所有代理位于 `.claude/agents/`。

| 代理 | 职责 |
|------|------|
| `daily-analyzer` | 分析单日日志：昨日检查→模式反思→盲点检测→原子行动+预测 |
| `monthly-processor` | 以指定视角处理月度/周度日志，输出结构化分析 |
| `weekly-synthesis` | 综合3个核心视角分析，生成复盘六问结构的周报告 |
| `monthly-synthesis` | 综合6-9个视角分析，生成主题化月度报告 |
| `yearly-synthesis` | 综合12份月度报告，生成年度成长回顾 |
| `review-readiness-checker` | 轻量检测：当前是否适合建议复盘（周/月/年） |

### Workflow 脚本

月/周/年分析命令实际调用的是 `.claude/workflows/` 下的 Workflow 脚本，它们用 `parallel()` 编排多视角代理并行执行，再由 synthesis 代理综合。

| Workflow | 用途 |
|----------|------|
| `monthly-review.js` | 多视角并行月分析→综合 |
| `weekly-review.js` | 3核心视角并行周分析→综合 |
| `yearly-review.js` | 12月报告综合→年度回顾 |
| `shared.js` | 共享视角注册表、路径模板和聊天摘要质量门 |

---

## 方法论文档

位于 `docs/`，定义分析的理论框架和评分标准。

| 文档 | 内容 |
|------|------|
| [`methodology-journal.md`](docs/methodology-journal.md) | 日志六步法：回忆事实→筛选重点→评估结果→洞察思考→行为改进→分享讨论；六大典型日志问题 |
| [`methodology-review.md`](docs/methodology-review.md) | 复盘六问框架：回顾目标→评估结果→正向归因→负向归因→重来演练→下月规划；SMART 目标设定 |
| [`analysis-standards.md`](docs/analysis-standards.md) | AI 分析质量12条标准：六步法投射6条 + 复盘六问投射6条 + 日分析轻量6条标准 |
| [`first-principles.md`](docs/first-principles.md) | 第一性原理行动指南：项目为何存在、原子价值公式、开发者/用户纪律、反模式清单、诚实检查 |

### 评分体系

#### 日志质量（journal-quality）：1-30 加分制

- 对照六步法评分，每步 1-5 分
- 加分制（上不封顶），非扣分制（满分100）
- 关注积极面和成长潜力

#### 复盘质量（review-coach）：1-30 分

- 对照复盘六问评分，每问 1-5 分
- 评估月志/周志的复盘深度
- 检测常见归因错误（过度外部归因/过度内部归因/停留在表象）

---

## 分析质量标准

所有 AI 生成的分析必须满足 [12条标准](docs/analysis-standards.md)（六步法投射6条 + 复盘六问投射6条），外加[日分析轻量标准](docs/analysis-standards.md)和[聊天摘要质量门](docs/analysis-standards.md)。

---

## 项目结构

```
.
├── .claude/
│   ├── agents/               # 专用代理
│   │   ├── daily-analyzer.md
│   │   ├── weekly-synthesis.md
│   │   ├── monthly-processor.md
│   │   ├── monthly-synthesis.md
│   │   ├── yearly-synthesis.md
│   │   └── review-readiness-checker.md
│   ├── commands/             # 斜杠命令
│   │   ├── review.md         # 🔥 统一入口
│   │   ├── daily-review.md
│   │   ├── weekly-review.md
│   │   ├── monthly-review.md
│   │   ├── yearly-review.md
│   │   ├── journal-coach.md
│   │   ├── interview.md
│   │   ├── update-current.md
│   │   ├── import.md
│   │   └── commit.md          # /提交 一键 Git 本地提交
│   ├── skills/               # 技能定义
│   │   └── log.md            # 日志存档技能
│   ├── shared/               # 共享配置
│   │   ├── paths.md           # 路径权威来源
│   │   ├── prompt-rules.md    # 共享提示词规则
│   │   └── banned-phrases.json # 禁用词列表
│   ├── workflows/            # Workflow 编排脚本
│   │   ├── monthly-review.js
│   │   ├── weekly-review.js
│   │   ├── yearly-review.js
│   │   └── shared.js          # workflow 共享运行时 helper
│   └── settings.json         # 权限 + Hooks 薄路由
├── .codex/
│   └── hooks.json            # Codex 开发辅助 hook（不承载产品逻辑）
├── docs/                     # 方法论文档
│   ├── archive/
│   │   └── changelog-archive.md  # 完整改动历史
│   ├── first-principles.md   # 第一性原理行动指南
│   ├── methodology-journal.md # 日志六步法
│   ├── methodology-review.md  # 复盘六问
│   ├── analysis-standards.md  # 12条分析质量标准
│   └── specs/                # 需求规范
├── perspectives/             # 分析视角 + 架构说明
│   ├── README.md
│   ├── chronicle.md
│   ├── therapist.md
│   ├── coach.md
│   ├── relationships.md
│   ├── strengths.md
│   ├── values-meaning.md
│   ├── growth-dimensions.md
│   ├── journal-quality.md
│   └── review-coach.md
├── examples/                 # 示例（脱敏）
│   ├── demo/sample-journal.md
│   └── analyses/
├── .github/                  # Issue/PR 模板
├── README.md                 # 本文档
├── CLAUDE.md                 # AI 行为规范（6组规则）
├── PROJECT_STATUS.md         # 项目状态与进度
├── CHANGELOG.md              # 改动记录
├── SETUP.md                  # 独立可复用的初始化指南
├── VERSION                   # 语义化版本号
├── LICENSE                   # MIT
└── .gitignore
```

### Git 忽略规则

以下目录包含个人数据，不会被提交到版本控制：

| 目录 | 内容 |
|------|------|
| `日志/` | 每日日志原始文件 |
| `复盘/` | 生成的分析报告 |
| `关于我/` | 个人画像与快照 |
| `规划/` | 个人计划与日程 |
| `.vscode/` | 本地编辑器配置 |
| `.codex/agents/` | 不维护的 Codex agent 手写副本 |
| `.agents/skills/superpowers/` | 本地 AI 开发辅助技能目录 |

---

## 路径配置

所有输入/输出路径由 [.claude/shared/paths.md](.claude/shared/paths.md) 统一管理。该文件提供命名路径 key、创建责任和废弃路径说明，agent/command 应引用 key，只有用户可见提示才展开具体路径。

跨 agent 重复的提示词硬约束由 [.claude/shared/prompt-rules.md](.claude/shared/prompt-rules.md) 统一管理，用于集中维护路径、hook 入口、证据、输出契约、禁用词同步和质量门槛。`.claude/settings.json` 只保留 hook 路由，不承载分析逻辑。

---

## 版本管理

遵循[语义化版本](https://semver.org/lang/zh-CN/)：`主版本.次版本.修订号`

| 变更类型 | 示例 |
|---------|------|
| Bug修复、文档更新 | 0.19.0 → 0.19.1 |
| 新功能（向后兼容） | 0.19.0 → 0.20.0 |
| 破坏性变更 | 0.19.0 → 1.0.0 |

当前版本见 [VERSION](VERSION) 文件。

---

## 贡献指南

本项目是个人使用的 Claude Code Skill，但欢迎提出建议和反馈。

- 发现 Bug？[提交 Issue](.github/ISSUE_TEMPLATE/bug_report.md)
- 有改进想法？[提交 PR](.github/PULL_REQUEST_TEMPLATE.md)
- 想了解开发规范？阅读 [`CLAUDE.md`](CLAUDE.md)（6组AI行为规则）和 [`SETUP.md`](SETUP.md)（新项目初始化指南）

### 适配你自己的使用

1. 修改 `perspectives/` 下的视角文件，替换其中的个人化语境
2. 在 `关于我/core-profile.md` 中填写你的个人画像（通过 `/interview` 命令生成）
3. 调整 `.claude/shared/paths.md` 中的命名路径以匹配你的目录结构
4. 如更换日记模板，同步更新 `.claude/shared/prompt-rules.md` 的 hook 触发契约、`.claude/skills/log.md` 的识别说明和 `.claude/settings.json` 的 matcher

---

## 相关链接

- 📝 [博客文章：I let Claude Code read 14 years of my daily journals](https://vystrcil.com/blog/ai-journaling/)
- 🤖 [Claude Code 官方文档](https://docs.anthropic.com/en/docs/claude-code)
- 🐘 方法论来源：问问大象日记系统

---

<p align="center">
  <sub>用优先于建。日分析优先于周月报。闭环速度优先于分析全面性。被验证的改变优先于好看的故事。</sub>
</p>
