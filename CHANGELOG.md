---
created: 2026-07-05
last_updated: 2026-07-07
---

# CHANGELOG — 改动记录

## [2026-07-07 21:21] [配置] 维护文件改为影响驱动读取与更新 (v1.3.14 → v1.3.15)

- **受影响文件**: `AGENTS.md`, `CLAUDE.md`, `README.md`, `PROJECT_STATUS.md`, `CHANGELOG.md`, `VERSION`
- **改动摘要**: 将上下文加载从完整读取改为最小足够上下文，明确 README 默认按需读取；将 CHANGELOG、PROJECT_STATUS、VERSION、README 的更新规则收窄为影响驱动，避免每次改动机械触碰四类维护文件；同步版本号至 v1.3.15 并记录关键决策。

## [2026-07-07 19:25] [配置] 忽略本地 Superpowers 辅助目录并明确维护边界 (v1.3.13 → v1.3.14)

- **受影响文件**: `.gitignore`, `AGENTS.md`, `CLAUDE.md`, `README.md`, `PROJECT_STATUS.md`, `VERSION`
- **改动摘要**: 将 `.agents/skills/superpowers/` 标记为本地 AI 开发辅助目录并加入 `.gitignore`，明确其方便 AI 使用 Superpowers 技能但不属于 `.claude/` 产品运行真相；同步 AGENTS/CLAUDE 镜像规范、README、PROJECT_STATUS 与版本号至 v1.3.14。

## [2026-07-07 19:10] [重构] 提示词去重：新增共享规则并精简高重复 agent (v1.3.12 → v1.3.13)

- **受影响文件**: `.claude/shared/prompt-rules.md`, `.claude/agents/daily-analyzer.md`, `.claude/agents/weekly-synthesis.md`, `.claude/agents/monthly-synthesis.md`, `.claude/agents/yearly-synthesis.md`, `README.md`, `PROJECT_STATUS.md`, `VERSION`, `docs/superpowers/plans/2026-07-07-prompt-dedup-optimization.md`
- **改动摘要**: 新增共享提示词规则，集中维护路径、证据、输出契约和质量门槛；精简 daily/weekly/monthly/yearly 四个高重复 agent 的提示词，保留原有命令入口、输出路径、文件名和报告结构；同步 README、PROJECT_STATUS 与版本号至 v1.3.13。

> 倒序时间线。完整历史见 [docs/archive/changelog-archive.md](docs/archive/changelog-archive.md)。

---
## [2026-07-07 18:23] [配置] 规则合理化：同步检查分级、Superpowers 条件化、根目录约束校准 (v1.3.11 → v1.3.12)

- **受影响文件**: `AGENTS.md`, `CLAUDE.md`, `README.md`, `PROJECT_STATUS.md`, `docs/specs/evolution-roadmap.md`, `VERSION`
- **改动摘要**: 审查现有规则后修复三类不合理点：① 将文档同步检查从“每次全量”改为轻量/标准/全量三级，降低小改动摩擦；② 将 Superpowers 从无条件强制改为“环境提供时触发，不可用时回退内置流程”，避免不可执行规则阻塞任务；③ 将根目录规则从不符合现状的“≤8个核心文件”校准为当前允许的10个核心/元数据文件，并明确 AGENTS.md 与 CLAUDE.md 是跨工具镜像规范，修改一份必须同步另一份。

---
## [2026-07-07 18:14] [配置] 提交流程改为改动后自动本地提交，推送仍手动执行 (v1.3.10 → v1.3.11)

- **受影响文件**: `AGENTS.md`, `CLAUDE.md`, `.claude/commands/commit.md`, `.claude/settings.json`, `.codex/hooks.json`, `README.md`, `PROJECT_STATUS.md`, `docs/specs/evolution-roadmap.md`, `VERSION`
- **改动摘要**: 将提交规则从“提示用户输入 /提交”改为“CHANGELOG 记录与验证完成后自动执行 /提交 对应的本地 add/commit 流程”。`/提交` 仍只做本地提交，远程推送由用户手动运行 `git push`；Stop hook 提醒文案同步为“自动提交可能未完成时再运行 /提交”。

---
## [2026-07-07 18:07] [重构] 项目遍历优化：去硬编码目录、同步当前数据、修正审计状态 (v1.3.9 → v1.3.10)

- **受影响文件**: `.claude/commands/monthly-review.md`, `perspectives/growth-dimensions.md`, `perspectives/journal-quality.md`, `perspectives/review-coach.md`, `docs/first-principles.md`, `docs/specs/evolution-roadmap.md`, `docs/specs/audit-cleanup.md`, `README.md`, `PROJECT_STATUS.md`, `VERSION`
- **改动摘要**: 优化月度复盘命令，将视角输出目录从固定6个生活视角改为按选中视角动态生成，避免 full/custom 模式文档漂移；统一3个 perspective 的 Rules 段落为中文；同步第一性原理与路线图中的日反馈/月报当前数据；修正 audit-cleanup 的验收勾选与状态，保留 workflow 禁用词内嵌项作为后续待处理；版本同步至 v1.3.10。

---
## [2026-07-07 17:57] [重构] 确立 .claude 唯一运行真相，停用 .codex/agents 手写副本 (v1.3.8 → v1.3.9)

- **受影响文件**: `AGENTS.md`, `CLAUDE.md`, `README.md`, `PROJECT_STATUS.md`, `.gitignore`, `.codex/hooks.json`, `.codex/agents/*.toml`（删除）, `docs/specs/evolution-roadmap.md`, `VERSION`
- **改动摘要**: 将维护边界固化为「唯一运行真相：.claude/；唯一开发规范：AGENTS.md / CLAUDE.md；.codex/ 不作为产品逻辑维护面」。删除 6 个 `.codex/agents` 手写 agent 副本，停用 `.codex/hooks.json` 中的日志触发入口，仅保留未提交提醒，并将 `.codex/agents/` 加入 .gitignore，避免 Claude agent、日志入口与 Codex 配置双份漂移。同步 README/PROJECT_STATUS/路线图版本号，并修正 PROJECT_STATUS 中 `/提交` 的旧 push 描述。

---
## [2026-07-07] [修复] 统一日志分析入口：CLAUDE.md 新增日志粘贴处理规则 (v1.3.7 → v1.3.8)

- **受影响文件**: `CLAUDE.md`, `VERSION`, `PROJECT_STATUS.md`, `README.md`, `docs/specs/evolution-roadmap.md`
- **改动摘要**: 用户粘贴日志时因 hook 未触发导致 Claude 自由发挥分析格式（与 daily-analyzer 模板不一致）。在 CLAUDE.md 跳过阈值与上下文加载之间新增"日志粘贴处理"规则，确保 Claude 直接收到日志原文时也遵循标准输出格式，分析结果同时写入复盘/每日反馈文件

---
## [2026-07-07] [重构] /提交 改为仅本地提交，推送由用户手动执行 (v1.3.6 → v1.3.7)

- **受影响文件**: `.claude/commands/commit.md`, `CLAUDE.md`, `README.md`, `.claude/settings.json`, `VERSION`, `PROJECT_STATUS.md`
- **改动摘要**: `/提交` 命令不再自动执行 git push，仅做本地 add/commit 并提醒用户手动推送。同步更新 CLAUDE.md 提交提示规则、README 命令表/结构树、settings.json Stop 钩子消息

---
## [2026-07-07] [修复] 项目遍历审计：修复6处跨文件矛盾与警告 (v1.3.5 → v1.3.6)

- **受影响文件**: `PROJECT_STATUS.md`, `docs/specs/evolution-roadmap.md`, `.claude/commands/monthly-review.md`, `.claude/agents/monthly-synthesis.md`, `.claude/agents/weekly-synthesis.md`, `.claude/shared/paths.md`, `docs/specs/audit-cleanup.md`, `关于我/current.md`（新建）, `README.md`, `VERSION`
- **改动摘要**: 审计修复6处问题：①PROJECT_STATUS合并重复"低优先级"段落；②evolution-roadmap版本号v1.3.3→v1.3.5；③monthly-review命令描述从硬编码"6视角"改为多模式说明；④monthly-synthesis agent视角数说明改为可变；⑤weekly-synthesis规则编号11→12/12→13/13→14；⑥paths.md新增journal-coach输出路径；⑦audit-cleanup.md标记为已完成；⑧创建current.md占位文件

---
## [2026-07-07] [重构] 项目遍历审计：死代码清理 + 功能冻结解除 + 预防机制 (v1.3.4 → v1.3.5)

- **受影响文件**: `.claude/shared/paths.md`, `docs/specs/csv-export.md→_archived/`, `README.md`, `PROJECT_STATUS.md`, `docs/first-principles.md`, `docs/specs/evolution-roadmap.md`, `CLAUDE.md`, `VERSION`, `data/.gitkeep`, `output/.gitkeep`
- **改动摘要**: ①死代码清理：paths.md移除零消费者methodology-journal、归档僵尸spec csv-export、README结构树补全paths.md、PROJECT_STATUS补全配置表+月度报告+遗漏文件、创建data/output目录；②永久解除功能冻结：README/PROJECT_STATUS/first-principles/evolution-roadmap共5处移除冻结语言，待办从"暂缓（功能冻结期）"改为"低优先级"；③预防机制：CLAUDE.md同步检查清单新增反向消费者检查（配置/路径/文件三级）+高风险管理表新增行+同步验证新增零死配置检查

---
## [2026-07-07] [重构] 清理 settings.json 死配置：移除 journaling 块 (v1.3.3 → v1.3.4)

- **受影响文件**: `.claude/settings.json`, `README.md`, `PROJECT_STATUS.md`, `VERSION`
- **改动摘要**: 删除 settings.json 中整个 journaling 块（含 fallback_paths）——该配置自 v1.2.0 创建以来无任何代码消费；README 配置说明替换为 paths.md 引用；PROJECT_STATUS 已知问题 #1/#7 和决策记录同步更新

---
## [2026-07-07] [文档] 审计修复：9处跨文件不一致 (v1.3.2 → v1.3.3)

- **受影响文件**: `PROJECT_STATUS.md`, `.claude/agents/daily-analyzer.md`, `docs/analysis-standards.md`, `README.md`, `.claude/workflows/monthly-review.js`, `.claude/skills/log.md`, `.claude/commands/import.md`, `.claude/agents/monthly-processor.md`, `VERSION`
- **改动摘要**: 项目审计修复9处不一致——PROJECT_STATUS命令计数9→10并补/import行、删除重复banned-phrases行；daily-analyzer标准引用扩展至D0-D6+职责边界注释；README补全weekly/monthly fallback路径；monthly-review.js移除废弃focus-personal引用；analysis-standards新增D0定义+D4+→D5重新编号；硬编码"谢安"替换为glob发现模式

## [2026-07-07] [配置] 修复 GitHub 语言标签：添加 .gitattributes 让 Markdown 参与统计 (v1.3.1 → v1.3.2)

- **受影响文件**: `.gitattributes`（新建）, `VERSION`, `PROJECT_STATUS.md`
- **改动摘要**: 新建 .gitattributes，将 Markdown 标记为 linguist-detectable 以参与语言统计，workflow JS 标记为 vendored 排除统计；修复 GitHub 语言标签从 100% JavaScript 变为 Markdown 为主

## [2026-07-07] [文档] README 项目状态同步：版本号/命令数/代理表/结构树修复 (v1.3.0 → v1.3.1)

- **受影响文件**: `README.md`, `VERSION`, `PROJECT_STATUS.md`
- **改动摘要**: README 版本号从 1.1.0 同步至 1.3.0；命令数量从 8→10 并补回 commit.md；代理表格删除重复的 monthly-processor 行；项目结构树补回 shared/、archive/、perspectives/README.md；命令系统表新增 /提交；Git忽略规则表新增 规划/

## [2026-07-07] [功能] Git 自动化：/提交 命令 + 未提交改动提醒 (v1.2.0 → v1.3.0)

- **受影响文件**: `.claude/commands/commit.md`（新建）, `.claude/settings.json`, `CLAUDE.md`, `VERSION`, `PROJECT_STATUS.md`
- **改动摘要**: 新增 /提交 斜杠命令实现 git add/commit/push 一键操作，提交信息自动提取自 CHANGELOG 最新条目；新增 Stop 钩子在会话结束时提醒未提交改动；CLAUDE.md 改动追踪章节新增提交与推送提示规则

---

## [2026-07-07] [重构] 两轮第一性原理审计清理：消除冗余、统一格式、建立单一权威来源 (v1.1.0 → v1.2.0)

- **受影响文件**: 40+个文件（5 agent + 5 command + 3 workflow + 9 perspective + 7 文档 + 4 新建）
- **改动摘要**: 基于两轮全项目第一性原理审计，执行5阶段系统清理：
  - 阶段0 安全基线：36个未跟踪核心文件入Git
  - 阶段1 单一权威来源：创建 `.claude/shared/banned-phrases.json` + `perspectives/README.md`，禁用词列表引用链统一
  - 阶段2 W-格式管道同步：6文件×16处 `YYYY-Www` → `YYYY-Www（M月D日-M月D日）`，修复 weekly-synthesis/yearly-synthesis mkdir bug，修复 W27-coach frontmatter month→week
  - 阶段3 消除重复：12处语言要求→CLAUDE.md全局规则，log.md 131→85行，切记引用清理
  - 阶段4 统一格式：weekly-processor幽灵代理清理（README+PROJECT_STATUS共5处），growth-dimensions/journal-quality Rules中文化
  - 阶段5 上下文精简：values-meaning去硬编码，first-principles诚实检查动态化，PROJECT_STATUS文件清单压缩，weekly/monthly-synthesis模板 ~250→~50行
- **净效果**: ~250行冗余删除，~200行上下文加载节省，0个未跟踪文件

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
