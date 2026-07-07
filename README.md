# 知己

> 🎯 AI 日志分析教练：用更低摩擦的方式，把日志变成可行动的复盘

[![Blog](https://img.shields.io/badge/博客-阅读全文-blue)](https://vystrcil.com/blog/ai-journaling/)
[![Version](https://img.shields.io/badge/版本-v1.3.24-green)](VERSION)
[![License](https://img.shields.io/badge/许可证-MIT-yellow)](LICENSE)

**知己** 是一个基于 [Claude Code](https://docs.anthropic.com/en/docs/claude-code) 的日志分析与复盘 Skill。它围绕日、周、月、年的复盘节奏工作，用多个专业视角并行分析日志，再输出结构化反馈，帮助用户识别模式、形成行动、持续闭环。

## 快速开始

### 前置条件

- 已安装 Claude Code CLI 或 VSCode 扩展
- 已将本仓库放到 Claude Code 可读取的位置

### 三步上手

1. 写日志。推荐按六步法记录：
   回忆事实 → 筛选重点 → 评估结果 → 洞察思考 → 行为改进 → 分享讨论
2. 将日志粘贴到 Claude Code。
3. 运行命令获取反馈：

```bash
/daily-review
/weekly-review
/monthly-review
/review
```

没有日志时，可先使用 [`examples/demo/sample-journal.md`](examples/demo/sample-journal.md) 试跑。

更完整的初始化说明见 [`SETUP.md`](SETUP.md)。

## 核心命令

| 命令 | 用途 | 备注 |
|------|------|------|
| `/review` | 自然语言统一入口 | 自动判断更适合日/周/月/年哪类复盘 |
| `/daily-review` | 单日日志即时反馈 | 最短闭环，适合日常使用 |
| `/weekly-review` | 周度综合复盘 | 3 个核心视角并行 |
| `/monthly-review` | 月度深度复盘 | `fast` / `standard` / `full` / 自定义 |
| `/yearly-review` | 年度成长回顾 | 依赖已有月度报告 |
| `/journal-coach` | 多日趋势反馈 | 适合最近几天的连续观察 |
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

周期分工：

| 周期 | 入口 | 核心处理 |
|------|------|---------|
| 日 | `/daily-review` | `daily-analyzer` |
| 周 | `/weekly-review` | `monthly-processor` ×3 + `weekly-synthesis` |
| 月 | `/monthly-review` | `monthly-processor` ×N + `monthly-synthesis` |
| 年 | `/yearly-review` | `yearly-synthesis` |

## 视角体系

### 生活内容视角（6）

- `chronicle`：事实记录
- `coach`：目标与执行
- `therapist`：情绪与认知
- `relationships`：关系与连接感
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

README 只保留概览；具体规则以这些文档和 `AGENTS.md` / `CLAUDE.md` 为准。

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
│   ├── archive/
│   └── specs/
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
- `AGENTS.md` 与 `CLAUDE.md` 是唯一开发规范，并保持同步
- `.codex/` 仅承载开发辅助配置
- `.agents/skills/superpowers/` 是本地 AI 辅助目录，已 gitignore，不纳入产品逻辑

## 配置入口

- 路径约定：[.claude/shared/paths.md](.claude/shared/paths.md)
- 共享提示词规则：[.claude/shared/prompt-rules.md](.claude/shared/prompt-rules.md)
- Hook 与权限配置：[.claude/settings.json](.claude/settings.json)

> `settings.json` 负责薄路由；分析逻辑不放在其中维护。

## 版本管理

本项目遵循语义化版本：

- 文档/规范/修复更新：修订号递增
- 向后兼容的新功能：次版本号递增
- 破坏性变更：主版本号递增

当前版本见 [`VERSION`](VERSION)。

## 贡献与适配

- 反馈问题：查看 [Issue 模板](.github/ISSUE_TEMPLATE/bug_report.md)
- 提交改进：查看 [PR 模板](.github/PULL_REQUEST_TEMPLATE.md)
- 了解开发规范：阅读 [`AGENTS.md`](AGENTS.md) / [`CLAUDE.md`](CLAUDE.md)

适配自己的使用时，通常只需要：

1. 调整 `perspectives/` 中的个人化语境
2. 通过 `/interview` 生成并补充 `关于我/core-profile.md`
3. 在 `.claude/shared/paths.md` 中修改路径约定
4. 如更换日志模板，同步更新 `prompt-rules.md`、`log.md` 与 `settings.json`

## 相关链接

- [博客文章：I let Claude Code read 14 years of my daily journals](https://vystrcil.com/blog/ai-journaling/)
- [Claude Code 官方文档](https://docs.anthropic.com/en/docs/claude-code)
