# 知己

> AI 日志分析教练：用更低摩擦的方式，把日志变成可行动的复盘。
[![Blog](https://img.shields.io/badge/博客-阅读全文-blue)](https://vystrcil.com/blog/ai-journaling/)
[![Version](https://img.shields.io/badge/版本-v1.5.0-green)](VERSION)
[![License](https://img.shields.io/badge/许可证-MIT-yellow)](LICENSE)

**知己** 是一个基于 [Claude Code](https://docs.anthropic.com/en/docs/claude-code) 的日志分析与复盘 Skill。它围绕日、周、月、项目、年与低频人生设计六类节奏工作，用多视角分析、统一复盘协议和方向校准帮助用户识别模式、形成行动、持续闭环。

## 快速开始

1. 写日志，推荐按六步法记录：回忆事实 → 筛选重点 → 评估结果 → 洞察思考 → 行为改进 → 分享讨论。
2. 将日志粘贴到 Claude Code。
3. 运行命令获取反馈：

```bash
/daily-review
/weekly-review
/monthly-review
/project-review
/life-design
/review
```

没有日志时，可先使用 [`examples/demo/sample-journal.md`](examples/demo/sample-journal.md) 试跑。更完整的初始化说明见 [`SETUP.md`](SETUP.md)。

## 核心命令

| 命令 | 用途 | 备注 |
|------|------|------|
| `/review` | 自然语言统一入口 | 自动判断更适合日 / 周 / 月 / 项目 / 年 / 人生设计哪类分析；无参数时可提示方向异常 |
| `/daily-review` | 单日日志即时反馈 | 最短闭环，适合日常使用 |
| `/weekly-review` | 周度综合复盘 | 3 个核心视角并行，输出遵守六问一级标题 |
| `/monthly-review` | 月度深度复盘 | `fast` / `standard` / `full` / 自定义，输出遵守六问一级标题 |
| `/project-review` | 项目 / 版本 / 里程碑复盘 | 项目复盘专用入口，固定输出六问一级标题 |
| `/yearly-review` | 年度成长回顾 | 依赖已有月度报告 |
| `/life-design` | 人生设计校准 | 基于长期日志、日反馈和复盘证据，输出重力问题、能量地图、奥德赛原型和 7 天验证实验 |
| `/journal-coach` | 多日趋势反馈 | 适合最近几天的连续观察；高密度方向信号会提示 `/life-design --quick` |
| `/interview` | 建立个人画像 | 生成 `关于我/core-profile.md` |
| `/update-current` | 更新当前状态快照 | 输出到 `关于我/current.md` |
| `/import` | 手动导入日志 | 用于 hook 未触发时 |
| `/提交` | 发起本地提交 | 推送仍手动执行 `git push` |

## 架构概览

```text
命令层 (Commands)     -> 用户入口，解析参数，编排流程
代理层 (Agents)       -> 执行任务，读取日志，组织分析
视角层 (Perspectives) -> 定义专业视角、评分标准、输出边界
```

生命周期分工：

| 周期 | 入口 | 核心处理 |
|------|------|---------|
| 日 | `/daily-review` | `daily-analyzer` |
| 周 | `/weekly-review` | `monthly-processor` ×3 + `weekly-synthesis`（六问外壳 + 轻量综合） |
| 月 | `/monthly-review` | `monthly-processor` ×N + `monthly-synthesis`（六问外壳 + 主题综合） |
| 项目 | `/project-review` | `project-synthesis`（六问外壳 + 项目机制综合） |
| 年 | `/yearly-review` | `yearly-synthesis` |
| 人生设计 | `/life-design` | `life-design-synthesis`（证据优先 + 奥德赛原型 + 7 天验证实验） |

## 视角体系

### 生活内容视角（6）

- `chronicle`：事实记录
- `coach`：目标与执行
- `therapist`：情绪与认知
- `relationships`：关系与连接
- `strengths`：优势与成长证据
- `values-meaning`：价值感与意义感

### 方法论视角（3）

- `growth-dimensions`：六维成长覆盖度
- `journal-quality`：六步法写作质量
- `review-coach`：复盘六问深度

更多说明见 [`perspectives/README.md`](perspectives/README.md)。

## 方法论与质量标准

- 产品哲学与行动原则：[`docs/first-principles.md`](docs/first-principles.md)
- 日志写法：[`docs/methodology-journal.md`](docs/methodology-journal.md)
- 复盘写法：[`docs/methodology-review.md`](docs/methodology-review.md)
- 分析质量标准：[`docs/analysis-standards.md`](docs/analysis-standards.md)

README 只保留总览；具体规则以上述文档和 `AGENTS.md` / `CLAUDE.md` 为准。

## 项目结构

```text
.
├── .claude/
│   ├── agents/
│   ├── commands/
│   ├── shared/
│   ├── skills/
│   ├── workflows/
│   └── settings.json
├── .codex/
│   └── hooks.json
├── docs/
├── perspectives/
├── examples/
├── .github/
├── README.md
├── AGENTS.md
├── CLAUDE.md
├── PROJECT_STATUS.md
├── CHANGELOG.md
├── SETUP.md
├── VERSION
└── LICENSE
```

## 维护边界

- `.claude/` 是唯一运行真相
- `AGENTS.md` 与 `CLAUDE.md` 是唯一开发规范，且保持同步
- `.codex/` 仅承载开发辅助配置
- `.agents/skills/superpowers/` 是本地 AI 辅助目录，已 gitignore，不纳入产品逻辑

## 配置入口

- 路径约定：[`.claude/shared/paths.md`](.claude/shared/paths.md)
- 共享提示词规则：[`.claude/shared/prompt-rules.md`](.claude/shared/prompt-rules.md)
- Hook 与权限配置：[`.claude/settings.json`](.claude/settings.json)

## 版本管理

本项目遵循语义化版本：

- 文档 / 规范 / 修复更新：修订号递增
- 向后兼容的新功能：次版本号递增
- 破坏性变更：主版本号递增

当前版本见 [`VERSION`](VERSION)。
