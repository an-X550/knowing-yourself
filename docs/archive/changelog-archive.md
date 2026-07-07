---
created: 2026-07-07
description: CHANGELOG 历史存档 — 2026-07-05 至 2026-07-06 v1.0.0 之前的开发冲刺记录
---

# CHANGELOG 存档

> 以下为 v1.0.0 发布前的所有改动记录。当前活跃记录见项目根目录 `CHANGELOG.md`。

## [2026-07-06] [配置] Superpowers 集成：自动调用开发流程技能 (v0.19.1 → v0.19.2)

- **受影响文件**: `CLAUDE.md`, `VERSION`, `PROJECT_STATUS.md`, `docs/project-status-template.md`
- **改动摘要**:
  - CLAUDE.md「跳过阈值」新增 Superpowers 例外条款——即使满足跳过条件，superpowers 技能调用规则独立评估
  - CLAUDE.md「六、工作流控制」新增「Superpowers 集成」章节——10 种开发场景 → superpowers 技能映射表
  - Spec-Before-Code 与 superpowers 对齐——superpowers 产出计划时不再重复创建 spec 文件


## [2026-07-07] [文档] README 全面重写 (v0.19.0 → v0.19.1)

- **受影响文件**: `README.md`, `VERSION`, `PROJECT_STATUS.md`, `CHANGELOG.md`
- **改动摘要**: 从33行极简 README 重写为完整的项目文档

## [2026-07-07] [文档] 第一性原理文档重大扩展 (v0.18.0 → v0.19.0)

- **受影响文件**: `docs/first-principles.md`, `切记.md`（新建）, `VERSION`, `PROJECT_STATUS.md`, `CHANGELOG.md`
- **改动摘要**: 新增"零、为什么存在这个项目"章节、诚实检查、恢复行动计划；新建 切记.md

## [2026-07-07] [功能] 用户触达优化：状态面板行动化 + 粘贴日志格式对齐 (v0.17.1 → v0.18.0)

- **受影响文件**: `CLAUDE.md`, `.claude/skills/log.md`
- **改动摘要**: 状态面板从静态数据升级为行动面板，新增6级优先级行动提示

## [2026-07-07 00:30] [功能] 执行反馈闭环引擎 (v0.17.1 → v0.18.0)

- **受影响文件**: `docs/analysis-standards.md`, `.claude/agents/daily-analyzer.md`, `.claude/commands/daily-review.md`, 等
- **改动摘要**: Phase 1 日分析闭环——昨日检查、原子行动+可验证预测、D4+/D5标准

## [2026-07-07 00:10] [修复] 目录整理 + .gitignore 修复 (v0.17.0 → v0.17.1)

- **受影响文件**: `QUICKSTART.md`（删除）, `.vscode/`（删除）, `.gitignore`, 等
- **改动摘要**: 删除 QUICKSTART.md，修复 .gitignore 内容严重缺失问题

## [2026-07-06 23:59] [功能] 新增第一性原理行动指南 + 上下文加载集成 (v0.16.1 → v0.17.0)

- **受影响文件**: `docs/first-principles.md`（新建）, `CLAUDE.md`, 等
- **改动摘要**: 创建第一性原理行动指南，插入上下文加载序列为第0步

## [2026-07-06 23:45] [功能] 生成 2026-W27 编年史视角周度分析 (v0.16.0 → v0.16.1)

- **受影响文件**: `07 Context/Analysis/chronicle/2026-W27-chronicle.md`
- **改动摘要**: 处理 W27 5篇日志的 chronicle 视角分析

## [2026-07-06 23:00] [重构] 目录中文化：用户可见目录改为中文 (v0.15.0 → v0.16.0)

- **受影响文件**: 全部 .md/.js/.json（28个文件，118处引用）
- **改动摘要**: `data/journals/`→`日志/`, `output/`→`复盘/`, `context/`→`关于我/`

## [2026-07-06 22:30] [功能] 零配置分发：新手引导、自愈项目、双视图 (v0.14.0 → v0.15.0)

- **受影响文件**: `CLAUDE.md`, `QUICKSTART.md`, `.vscode/settings.json`, 等
- **改动摘要**: Phase 1-4 新手引导→项目自愈→双视图→分发就绪

## [2026-07-06 21:00] [功能] UX大优化：统一入口、零配置默认、聊天优先输出 (v0.13.0 → v0.14.0)

- **受影响文件**: `.claude/commands/review.md`, `.claude/agents/review-readiness-checker.md`, 等
- **改动摘要**: Phase 1-5 统一入口、零配置默认、聊天优先输出、主动提议、Skill注册

## [2026-07-06 13:15] [功能] 日志导入支持智能识别单日/多日批量粘贴

- **受影响文件**: `.claude/skills/log.md`
- **改动摘要**: 新增多日检测逻辑——扫描日期头数量自动分流

## [2026-07-06 13:30] [功能] 新增 /import 命令：导入根目录日志文件

- **受影响文件**: `.claude/commands/import.md` (新建)
- **改动摘要**: 支持扫描根目录→识别→拆分→去重→清理

## [2026-07-06 13:00] [功能] 周度复盘重构：复用月志体系，做减法 (v0.12.0 → v0.13.0)

- **受影响文件**: `.claude/agents/weekly-synthesis.md` (新建), `.claude/workflows/weekly-review.js`, 等
- **改动摘要**: 周度从3方法论视角改为3核心生活视角 + weekly-synthesis综合引擎

## [2026-07-06 12:00] [功能] 月度分析多模式支持 + 中文视角选择 (v0.11.0 → v0.12.0)

- **受影响文件**: `.claude/workflows/monthly-review.js`, 等
- **改动摘要**: fast/standard/full三档模式 + 自定义视角

## [2026-07-05 18:30] [重构] 架构重构：方法论为中心的月度认知复盘引擎 (v0.10.1 → v0.11.0)

- **受影响文件**: `docs/analysis-standards.md`, `perspectives/*.md` (9个重写), 等
- **改动摘要**: 以复盘六问为报告主干，9视角降为数据提供者，新建认知修正引擎

## [2026-07-05 17:30] [修复] 月度分析输出中文化 + 单文件输出 (v0.10.0 → v0.10.1)

- **受影响文件**: `CLAUDE.md`, `perspectives/*.md` (9个), 等
- **改动摘要**: 9个视角添加中文输出规则，消灭中间文件

## [2026-07-05 16:45] [功能] 完成 2026-06 月度综合报告 (v0.9.3 → v0.10.0)

- **受影响文件**: `复盘/每月复盘/2026-06.md`, 等
- **改动摘要**: 综合9个视角生成2026年6月月度报告

## [2026-07-05 13:05] [重构] 精简 docs/project-status-template.md 为纯指令格式 (v0.4.0 → v0.4.1)

- **受影响文件**: `docs/project-status-template.md`, 等
- **改动摘要**: 从221行精简至~100行

## [2026-07-05 16:30] [功能] 新增文档自动同步规则 (v0.9.2 → v0.9.3)

- **受影响文件**: `CLAUDE.md`, `docs/project-status-template.md`, `SETUP.md`, 等
- **改动摘要**: 代码修改后自动检查路径引用/目录结构/功能列表

## [2026-07-05 16:15] [文档] 遍历项目更新过期文档引用 (v0.9.1 → v0.9.2)

- **受影响文件**: README, perspectives 等
- **改动摘要**: 更新目录结构图、快速开始路径、methodology文件路径

## [2026-07-05 16:00] [文档] SETUP.md 改为中文版本 (v0.9.0 → v0.9.1)

- **受影响文件**: SETUP.md, 等
- **改动摘要**: SETUP.md 全文英译中

## [2026-07-05 15:30] [重构] 模板三阶段重构 + 提取独立 SETUP.md (v0.8.0 → v0.9.0)

- **受影响文件**: `docs/project-status-template.md`, `SETUP.md`, 等
- **改动摘要**: 模板从10步序列重构为三阶段

## [2026-07-05 15:00] [功能] monthly/weekly/yearly review 迁移到 Workflow 工具 (v0.7.1 → v0.8.0)

- **受影响文件**: `.claude/workflows/monthly-review.js`, `.claude/workflows/weekly-review.js`, `.claude/workflows/yearly-review.js` (新增)
- **改动摘要**: 用 parallel() 编排多视角并行分析

## [2026-07-05 14:30] [修复] 机制完整性修复 (v0.7.0 → v0.7.1)

- **受影响文件**: `CLAUDE.md`, `docs/project-status-template.md`, 等
- **改动摘要**: 修复模板引用断裂、新增启动校验、版本一致性检查

## [2026-07-05 14:00] [重构] CLAUDE.md 第一性原理重构：12条平铺→6组分群 (v0.6.0 → v0.7.0)

- **受影响文件**: `CLAUDE.md`, `docs/project-status-template.md`, 等
- **改动摘要**: 240行→160行，12条规则合并为6组

## [2026-07-05 13:30] [功能] 新增 Spec-Before-Code 需求规范流程 (v0.5.0 → v0.6.0)

- **受影响文件**: `CLAUDE.md`, `docs/specs/_TEMPLATE.md` (新增), 等
- **改动摘要**: 新需求先创建 spec → 用户确认 → 编码

## [2026-07-05 13:10] [功能] 新增回退/撤销机制 (v0.4.0 → v0.5.0)

- **受影响文件**: `CLAUDE.md`, `docs/project-status-template.md`, 等
- **改动摘要**: 四种回退方法 + 安全约束

## [2026-07-05 12:50] [功能] 将目录管理规范记录到 CLAUDE.md (v0.3.0 → v0.4.0)

- **受影响文件**: `CLAUDE.md`, `docs/project-status-template.md`, 等
- **改动摘要**: 新增规则10（目录管理规范）

## [2026-07-05 12:35] [重构] 项目目录重组为 GitHub 规范结构 (v0.2.1 → v0.3.0)

- **受影响文件**: 全项目重组
- **改动摘要**: 根目录精简为6个核心文件，methodology移至docs/，新增LICENSE/.github

## [2026-07-05 12:25] [重构] 将状态管理模板重构为AI直接执行指令文档 (v0.2.0 → v0.2.1)

- **受影响文件**: `项目状态管理模板-可复用提示词.md`, 等
- **改动摘要**: 移除面向人类用户的框架，改为AI可执行指令

## [2026-07-05 12:15] [功能] 生成项目状态管理可复用模板文档 (v0.1.0 → v0.2.0)

- **受影响文件**: `项目状态管理模板-可复用提示词.md` (新增)
- **改动摘要**: 创建可复用提示词文档

## [2026-07-05 12:05] [配置] 启用自动更新记录与语义化版本管理 (v0.0.0 → v0.1.0)

- **受影响文件**: `VERSION` (新增), `CLAUDE.md`, `PROJECT_STATUS.md`, `CHANGELOG.md`
- **改动摘要**: 新增自动CHANGELOG + 语义化版本规则

## [2026-07-05] 已完成 项目初始化

- **受影响文件**: `PROJECT_STATUS.md`, `CHANGELOG.md`, `CLAUDE.md` (新增)
- **改动摘要**: 扫描代码库后生成初始文档
