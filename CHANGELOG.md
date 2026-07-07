---
created: 2026-07-05
last_updated: 2026-07-07
---

# CHANGELOG — 改动记录

> 倒序时间线。完整历史见 [docs/archive/changelog-archive.md](docs/archive/changelog-archive.md)。

---

## [2026-07-07] [重构] 第一性原理文档审计清理 (v1.0.4 → v1.1.0)

- **受影响文件**: 25+个文件（README, CLAUDE, PROJECT_STATUS, CHANGELOG, yearly-synthesis, weekly-synthesis, log.md, first-principles.md, analysis-standards.md, 9个perspective, 3个command, 3个workflow）
- **改动摘要**: 基于完整第一性原理审计，执行三阶段清理：
  - Phase 1 修复矛盾：README版本号同步、PROJECT_STATUS代理计数修正、analysis-standards过时指导更新、yearly-synthesis模板中文化+旧路径清理
  - Phase 2 消除重复：聊天摘要质量门集中到analysis-standards、log.md输出格式引用daily-analyzer、9个perspective文件删除冗余语言声明、切记.md浓缩并入first-principles、README与first-principles重叠内容精简
  - Phase 3 清理死内容：journal-coach/yearly-review/update-current清理过期英文路径、PROJECT_STATUS待办归类整理、CHANGELOG归档（274→40行）、5个perspective添加对比职责说明、CHANGELOG上下文加载优化（完整阅读→最近5条）
- **净效果**: ~400行删除，CHANGELOG上下文加载从~7,000 tokens降至~1,500 tokens

## [2026-07-06 23:30] [配置] 规划目录文件命名规则优化：降低用户摩擦 (v1.0.3 → v1.0.4)

- **受影响文件**: `规划/2026-07-06~12.md`（新建）, `CLAUDE.md`, `.gitignore`, `VERSION`
- **改动摘要**: 规划文件从英文周号改为ISO日期范围命名，个人数据目录豁免英文kebab-case规则

## [2026-07-06 23:00] [重构] 月度分析管道效率优化：删除不产生洞察的文件读取 (v1.0.2 → v1.0.3)

- **受影响文件**: `.claude/agents/monthly-synthesis.md`, `.claude/agents/monthly-processor.md`, `.claude/workflows/monthly-review.js`, 等
- **改动摘要**: 删除 synthesis agent 对用户洞察无贡献的4类文件读取，修复6处过期路径引用。预计每次月度分析节省21-33k tokens

## [2026-07-06 22:00] [数据] 5月+7月月度分析完成 + 核心画像跨月更新 (v1.0.1 → v1.0.2)

- **受影响文件**: `关于我/core-profile.md`, `PROJECT_STATUS.md`, `CHANGELOG.md`, `VERSION`
- **改动摘要**: 5月（31天）和7月（5天）月度分析完成；核心画像新增跨月对比表和7条持续模式

## [2026-07-06] [修复] 日志分析操作跳过上下文加载，减少80%等待时间 (v1.0.0 → v1.0.1)

- **受影响文件**: `CLAUDE.md`, `VERSION`, `PROJECT_STATUS.md`
- **改动摘要**: 日志分析操作跳过上下文加载和用户状态检测，仅验证目标日志文件存在

## [2026-07-06] [发布] 首个正式版本 v1.0.0 (v0.19.2 → v1.0.0)

- **受影响文件**: VERSION, PROJECT_STATUS.md, CHANGELOG.md
- **改动摘要**: 项目达到首个稳定发布版本。核心功能完整：9个视角、8个命令、6个代理、3个生命周期工作流、3层分析架构全部就绪。
