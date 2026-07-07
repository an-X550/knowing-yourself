# AGENTS.md — 知己

## 元规则

**冲突解决**：当多条规则冲突时，具体规则优先于通用规则，编号大的规则优先于编号小的规则。

**跳过阈值**：以下情况可跳过非必要规则（不含 Superpowers 集成，见「六、工作流控制」），直接执行：
- 纯信息查询、阅读文件回答问题
- 单文件小改动（<20 行变更）
- 用户明确说"直接改"/"跳过"/"不用走流程"
- 用户执行日志分析操作（粘贴日志、/daily-review、/weekly-review、/monthly-review、/journal-coach 等）——仅需验证目标日志文件存在，跳过上下文加载（一、上下文加载）和用户状态检测

> ⚠️ **Superpowers 例外**：即使满足以上跳过条件，superpowers 技能调用规则（「六、工作流控制 → Superpowers 集成」）不受跳过阈值影响。Superpowers 技能的判断独立于 AGENTS.md 的跳过逻辑——两者并行评估，各自触发。

### 日志粘贴处理

当用户消息中包含日志关键词（"幸福日志"、"开心的事情"、"充实的事情"等），且内容尚未被 `log` skill 预处理（即你直接收到了日志原文）时，按以下流程处理，而非自由发挥：

1. **存档**：将日志内容追加到对应月份日志文件（`日志/谢安的YYYY-N月日志.md`）
2. **分析**：遵循 `.Codex/agents/daily-analyzer.md` 的 Step 2-6（昨日检查、镜像反射、模式连接、原子行动），使用其标准输出格式（📋/⏮️/🔍/🔗/⚡/💊），总输出 ≤400 字
3. **存档反馈**：将分析结果写入 `复盘/每日反馈/YYYY-MM-DD.md`
4. **展示**：在对话中展示分析结果（与文件内容一致）

> 此规则确保无论 `UserPromptSubmit` hook 是否触发 `log` skill，日志分析输出格式始终统一。

---

## 一、上下文加载

每次对话开始时，按顺序完整阅读：

0. `docs/first-principles.md` — 第一性原理行动指南：开发者须知、用户纪律、共同原则、反模式清单
1. `PROJECT_STATUS.md` — 项目概述、架构、技术栈、当前进度、待办事项、已知问题、关键决策记录
2. `CHANGELOG.md` — 阅读最近 5 条改动记录。如需完整历史，读取 `docs/archive/changelog-archive.md`

若文件不存在，根据代码库主动扫描创建后再执行用户任务。

**启动校验**：读取后校验 `cat VERSION` 与 PROJECT_STATUS.md 中 `**当前版本**` 是否一致。不一致时以 VERSION 为准修正 PROJECT_STATUS.md，并在 CHANGELOG 追加一条 `[修复]` 记录。

### 用户状态检测（上下文加载第3步）

读取完 PROJECT_STATUS.md 和 CHANGELOG.md 后，检测用户状态：

1. Glob 检查 `日志/` 目录下是否有日志文件（≥3 天）
2. Glob 检查 `关于我/core-profile.md` 是否存在
3. Glob 检查 `output/` 目录下是否有任何分析报告

**新用户判定**：`日志/` 为空或日志 < 3 天，且 `output/` 无报告。
→ 用户发送第一条消息后，先输出欢迎面板（见下方模板），然后处理用户请求。
→ 连续对话超过 3 次后不再输出欢迎面板，改用状态面板。

**回归用户判定**：`日志/` 有 ≥ 3 天日志。
→ 用户发送第一条消息后，输出状态面板（见下方模板），然后处理用户请求。

**欢迎面板模板**（新用户）：

```
👋 欢迎使用日志分析教练！

三件事可以开始：

1️⃣ 粘贴今天的日志 → 自动存档 + 即时反馈
2️⃣ 输入 /review → 查看状态或复盘
3️⃣ 输入 /interview → 建立个人画像（可选）

📋 没有日志？复制 examples/demo/sample-journal.md 里的示例试试
```

**状态面板模板**（回归用户）：

```
📅 [今天日期] [星期几]
📝 今日日志：[已写/未写] [如未写且有昨日日志未分析 → 输入 /daily-review 分析昨天的]
📊 上周：N天日志 | 周复盘：[已存在 / → 输入 /weekly-review]
📈 上月：N天日志 | 月复盘：[已存在 / → 输入 /monthly-review]
🗓️ 本月进度：N/30天

💡 [根据下方"行动提示生成逻辑"动态生成，只显示最高优先级的一条]
```

**注意**：面板在用户第一条消息后输出，不阻塞对话。如果用户消息本身是一个操作指令（粘贴日志/运行命令），先执行操作，面板附在结果之后。

### 行动提示生成逻辑

输出状态面板前，根据以下条件生成 `💡` 行的内容。**按优先级从上到下，只输出第一个满足条件的**：

1. **今日日志未写 + 昨日有日志 + 昨日未分析** → `💡 昨天的日志还没分析。输入 /daily-review 获取反馈，或直接粘贴今天的日志一起处理`
2. **今日日志已写 + 今日未分析** → `💡 今天的日志写好了。输入 /daily-review 花1分钟获取即时反馈`
3. **今天是周一/周二 + 上周日志 ≥3天 + 上周周报不存在** → `💡 新的一周。上周有{N}天日志，输入 /weekly-review 花3分钟看看上周的发现`
4. **今天是1-5号 + 上月日志 ≥10天 + 上月月报不存在** → `💡 新的一月。上月有{N}天日志，输入 /monthly-review 做个深度复盘（约5-8分钟）`
5. **日志 ≥3天 + 最近7天内无任何报告** → `💡 最近有{N}天日志还没复盘。输入 /review 看看近况`
6. **以上均不满足** → 省略 `💡` 行（不输出该行）

检测方法（输出面板前由 AI 执行）：
- 今日/昨日日志：Grep 对应月日志文件中的日期头
- 昨日分析：Glob `复盘/每日反馈/昨天.md` 是否存在
- 上周日志数：Grep 上周一至周日的日期头，去重计数
- 上月日志数：Grep 上月1日至月末的日期头，去重计数
- 周报/月报：Glob `复盘/每周复盘/` 和 `复盘/每月复盘/` 检查对应文件是否存在

### PROJECT_STATUS.md 必须包含的章节

1. **项目概述** — 一句话描述 + 目标用户/场景
2. **技术栈** — 运行平台、语言、框架、数据库、版本控制
3. **架构设计** — 分层架构 + 核心模块列表及职责
4. **当前进度** — 各模块完成度（✅完成 / 🔶进行中 / ❌未开始）
5. **待办事项** — 按高/中/低优先级分级
6. **已知问题** — 分类记录（性能、安全、兼容性、未完成功能等）
7. **关键决策记录** — 按日期记录重要决策及其理由

标题下紧跟 `**当前版本**：X.Y.Z`。使用 YAML frontmatter（`created`, `last_updated`）。

### CHANGELOG.md 格式

倒序时间线（最新在顶部），每条记录格式：

```markdown
## [YYYY-MM-DD HH:MM] [标签] 改动简述 (vX.Y.Z → vX.Y.Z)

- **受影响文件**: 文件路径列表
- **改动摘要**: 简要描述做了什么
```

标签类型：`[功能]` `[修复]` `[重构]` `[文档]` `[配置]` `[破坏性变更]` `[回退]`

---

## 二、改动追踪

### 自动记录（主机制，每次必执行）

每次在本对话中创建、修改或删除任何源代码文件后，在响应结束前**自动**在 `CHANGELOG.md` 顶部追加一条记录，无需等待用户提醒。同一任务的多文件修改合并为一条。未修改代码的对话不记录。

### 手动跟踪（辅机制，大型任务可选用）

对于跨越多轮对话的大型多步骤任务，可在开始前手动添加 `## [时间] [任务简述] — 待开始`，完成后更新为 `已完成` 并补充文件列表和摘要。小型任务直接用自动记录即可。

### 同步 PROJECT_STATUS

如果改动影响了 PROJECT_STATUS.md 中的信息（进度、待办、已知问题等），同步更新 PROJECT_STATUS.md 并将其 `last_updated` 设为当前日期。

### 文档自动同步

改动完成后、追加 CHANGELOG 之前，按以下顺序执行同步检查。

#### 同步检查清单（按优先级排序）

0. **版本号全局搜索**（优先级最高）：
   - 如果本次涉及版本号变更：`grep -rn "旧版本号" --include="*.md"` 搜索全项目 Markdown 中的硬编码版本号
   - 包括：徽章 URL、inline 文本、代码注释、frontmatter
   - 替换为新版本号后，再次 grep 确认零残留

1. **路径变更**：如果本次涉及文件移动/重命名，grep 全项目 .md 文件搜索旧路径，自动修复过期引用

2. **结构变更**：如果本次新增/删除了文件或目录，检查 README.md 目录结构图是否反映最新状态

3. **功能变更**：如果本次新增了命令/代理/工作流，检查 README.md 的对应表格是否包含该项

4. **路径约定同步**：如果本次变更了 `.Codex/shared/paths.md` 中定义的路径，grep 全项目确认无其他文件残留旧路径硬编码。paths.md 是路径的**单一权威来源**——所有 agent 应通过它获取路径，而非硬编码

5. **反向消费者检查**（每次改动后必执行，防止死代码积累）：
   - **配置消费者**：对于 settings.json 中每个非标准顶级键（非 hooks/permissions/env），grep 全项目确认 settings.json 自身外至少有一个消费者文件引用该键名
   - **路径消费者**：对于 paths.md「输入路径」和「输出路径」节中每个路径模式，grep 全项目 agent/command/workflow 文件确认至少有一个引用其静态前缀
   - **文件消费者**：对于 docs/specs/ 下每个非模板 spec 文件，确认其被 README 或 PROJECT_STATUS 引用
   - 零消费者的定义 → 本次改动中清理或标记废弃

#### 同步验证（必执行）

上述检查全部完成后，执行以下验证。任一失败则修复后重新验证：

1. **版本一致性**：`cat VERSION` = `grep "当前版本" PROJECT_STATUS.md` = README.md 徽章中的版本号
2. **路径有效性**：grep 所有 .md 文件中的相对链接 `[text](path.md)`，确认目标文件存在
3. **无残留旧引用**：如有旧名称/旧路径/旧版本号，`grep -r "旧值" --include="*.md"` 确认全项目零残留
4. **零死配置**：grep settings.json 中每个自定义键名和 paths.md 中每个路径模式，确认 settings.json/paths.md 自身外至少有一个消费者文件

验证通过后方可追加 CHANGELOG。

#### 高风险管理表

以下跨文件引用点在历史提交中多次遗漏，每次相关改动后必须逐项核对：

| 变更类型 | 必须同步的文件 |
|---------|--------------|
| 版本号递增 | `VERSION` → `PROJECT_STATUS.md`(当前版本) → `README.md`(徽章) |
| 路径约定变更 | `.Codex/shared/paths.md` → grep 全项目确认无旧路径残留 |
| 新增/删除命令 | `README.md`(命令表+结构树) → `PROJECT_STATUS.md`(命令进度表) |
| 新增/删除代理 | `README.md`(代理表+结构树) → `PROJECT_STATUS.md`(代理进度表) |
| 新增/删除视角 | `README.md`(视角表+结构树) → `PROJECT_STATUS.md`(视角进度表) → `perspectives/README.md` |
| 禁用词变更 | `docs/analysis-standards.md` → `.Codex/shared/banned-phrases.json` → 3个workflow JS（提交前验证一致性） |
| 文件移动/重命名 | grep 全项目旧路径 → 修复所有引用 → grep 确认零残留 |
| 新增/修改配置键或路径 | `settings.json`自定义键 / `paths.md`路径 → grep 全项目确认消费者存在 |

> 表格是"最少必须检查"——如果发现其他引用点，一并修复。

以上检查与 CHANGELOG 追加一同在响应结束前完成，无需用户提醒。

### 提交与推送

改动记录追加到 CHANGELOG 且文档同步检查完成后，提示用户可运行 `/提交` 一键本地提交。推送需用户手动执行 `git push`。提示格式：

💡 改动已记录到 CHANGELOG。输入 /提交 即可本地提交。推送运行 `git push`。

此提示应在每次有代码改动的响应末尾自动输出，无需用户提醒。

---

## 三、版本管理

版本号遵循语义化版本：`主版本.次版本.修订号`，存储在根目录 `VERSION` 文件（纯文本）。

**递增规则**（修改代码并更新 CHANGELOG 后自动执行）：
- 修复 bug、小优化、文档更新 → 递增修订号（1.2.3 → 1.2.4）
- 新增功能且向后兼容 → 递增次版本号，修订号归零（1.2.3 → 1.3.0）
- 破坏性变更 → 递增主版本号，次版本和修订号归零（1.2.3 → 2.0.0）

**同步**：在 CHANGELOG 记录标题中标注 `(v旧 → v新)`，同步更新 PROJECT_STATUS.md 的 `**当前版本**`。

---

## 四、代码风格

- 所有 Markdown 文件使用 YAML frontmatter
- 中文内容文件（视角、方法论、命令、代理）用中文编写；配置字段和文件名用英文
- 文件路径使用相对于项目根目录的路径
- 文件名和目录名使用英文 kebab-case（`methodology-journal.md`）；gitignored 的个人数据目录可用中文，其下文件名以用户直观可读为优先，日期用 ISO 格式（`YYYY-MM-DD`）保证排序，不强制英文 kebab-case
- 表格优先用于结构化信息展示
- 评分体系使用项目术语（六步法、复盘六问、六维图、加分制）
- **全局语言规则**：所有 agent、command、workflow、perspective 的输出必须使用简体中文（面向中国用户）。引用日志原文可保留原语言。此规则为全局默认，各文件不再单独声明。

---

## 五、目录管理

根目录仅保留核心文件（≤8个）：`README.md`、`LICENSE`、`AGENTS.md`、`PROJECT_STATUS.md`、`CHANGELOG.md`、`VERSION`、`.gitignore`。其他文件按类型归入子目录。

| 目录 | 用途 | 版本控制 |
|------|------|---------|
| `src/` 或源码目录 | 源代码 | 纳入 |
| `docs/` | 文档、方法论、模板、spec | 纳入 |
| `examples/` | 脱敏示例 | 纳入 |
| `tests/` | 测试代码 | 纳入 |
| `.github/` | Issue/PR 模板、CI | 纳入 |
| `data/` | 个人数据、原始输入 | **gitignore** |
| `output/` | 生成的分析、报告 | **gitignore** |
| `关于我/` | 个人画像、快照 | **gitignore** |

**新增文件时**：检查是否属于根目录 → 文件名是否英文化（gitignored 个人数据目录 `日志/` `复盘/` `关于我/` `规划/` 下的文件不强制，以用户直观可读优先） → 个人数据是否在 .gitignore 中 → 公开示例是否已脱敏。

**目录不符合规范时**：标记归属 → 创建目录 → 移动文件 → 更新路径引用 → 更新 .gitignore → 删除空目录 → 验证无残留。

---

## 六、工作流控制

### Superpowers 集成

当用户执行开发任务（需求增删改测试等）时，**自动**根据任务类型调用对应的 superpowers 技能，无需用户手动输入 skill 名。Superpowers 调用独立于 AGENTS.md 的「跳过阈值」——即使改动 <20 行，仍须评估是否需要 superpowers 技能。

#### 场景 → 技能映射

| 用户场景 | 触发词示例 | 自动调用的 Superpowers 技能（按顺序） |
|---------|-----------|-------------------------------------|
| **新增功能/需求** | "加一个X"、"实现X"、"新增X" | `superpowers:brainstorming` → `superpowers:writing-plans` → `superpowers:executing-plans` |
| **Bug 修复** | "修bug"、"这个不对"、"报错"、"有问题" | `superpowers:systematic-debugging` |
| **代码重构** | "重构"、"整理"、"优化结构" | `superpowers:writing-plans` → `superpowers:verification-before-completion` |
| **写完代码/修改后** | 任何代码改动完成后（自动触发） | `superpowers:verification-before-completion` |
| **测试** | "测试"、"写测试"、"验证" | `superpowers:test-driven-development` |
| **请求代码审查** | "帮我review"、"审查代码" | `superpowers:requesting-code-review` |
| **接收审查反馈** | 收到 review 意见后 | `superpowers:receiving-code-review` |
| **并行任务** | 多个独立任务同时进行 | `superpowers:dispatching-parallel-agents` |
| **完成分支** | "合并"、"提交PR"、"这个分支做完了" | `superpowers:finishing-a-development-branch` |
| **Git 工作树隔离** | "用工作树"、"隔离开发" | `superpowers:using-git-worktrees` |

#### 与 Spec-Before-Code 的关系

- `superpowers:brainstorming` + `superpowers:writing-plans` ≈ Spec-Before-Code 流程。两者目标一致（先规划再编码）。
- **优先级**：superpowers 先触发。brainstorming 阶段产出方案方向 → writing-plans 产出实施计划。如果 writing-plans 产出的计划与 Spec-Before-Code 的 spec 文件格式兼容，直接复用为 spec 文件。
- **不重复**：如果 superpowers 已产出完整计划，不再重复走 Spec-Before-Code 的 spec 创建流程。两者合并为一条路径。

#### 何时不调用

以下情况不强制调用 superpowers 技能（由 AI 判断）：
- 纯信息查询（"这个文件干什么的"、"XX 在哪里"）
- 已经在一个 superpowers 技能的上下文中（避免嵌套）
- 改动仅为文档/注释/格式修正，不涉及逻辑变更
- 用户明确说"不用 superpowers"

### 回退与撤销

触发词："回退上次修改"/"撤销对X的改动"/"回退到 vX.Y.Z"/"回退刚才添加的规则"。

流程：读取 CHANGELOG 定位目标 → 选择回退方法 → 执行 → 版本号回退 → 追加 `[回退]` 记录。

| 文件状态 | 回退方法 |
|---------|---------|
| git 跟踪、未 commit | `git checkout HEAD -- <file>` |
| git 跟踪、已 commit | `git revert <commit>` |
| 不在 git 跟踪 | 根据 CHANGELOG 记录手动反向编辑 |
| 回退特定规则 | Edit 工具精确删除并重新编号 |

回退前必须向用户确认影响范围。git 未跟踪文件的回退可能不完整需告知用户。回退后验证内容、版本号、CHANGELOG 完整。

### Spec-Before-Code

收到新功能需求时，不得直接编码。触发条件：用户提出"新增/添加/实现"需求、需创建新文件、需修改核心行为逻辑。Bug 修复/文档更新/小改动可跳过。

> 🔗 **与 Superpowers 的协作**：新功能需求先走 `superpowers:brainstorming` → `superpowers:writing-plans`（见上方「Superpowers 集成」）。若 writing-plans 产出计划足够详细，直接以此计划替代下方 spec 文件流程——不重复创建 spec。若 superpowers 因故未触发，则回退到以下标准流程。

流程：
1. 在 `docs/specs/` 创建 `<功能名>.md`（需求目标 + 边界约束 + 验收标准 + 实施计划 + 状态），参考 `docs/specs/_TEMPLATE.md`
2. 高优先级需求在 PROJECT_STATUS.md 添加 `- [ ] [标题](docs/specs/<文件>.md) — 规划中`
3. 展示 spec 摘要，等待用户确认。若否定，移至 `docs/specs/_archived/`
4. 确认后状态改为"开发中"，按改动追踪规则开始实施
5. 完成后状态改为"已完成"，勾选 PROJECT_STATUS.md 对应条目

spec 文件本身（不含实现代码）不触发改动追踪和版本递增。需求模糊时先澄清再写 spec。
