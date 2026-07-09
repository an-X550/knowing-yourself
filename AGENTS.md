# 开发规范 - 知己

## 元规则

**冲突解决**：具体规则优先于通用规则；编号大的规则优先于编号小的规则。

**跳过阈值**：以下情况可跳过非必要流程，直接执行：
- 纯信息查询、阅读文件回答问题
- 单文件小改动（<20 行变更）
- 用户明确说“直接改”/“跳过”/“不用走流程”
- 用户执行日志分析操作（粘贴日志、`/daily-review`、`/weekly-review`、`/monthly-review`、`/journal-coach` 等）

> ⚠️ **Superpowers 例外**：若当前环境实际提供 superpowers 技能，仍按「六、工作流控制」评估是否触发；若不可用，回退到本文件内置流程，不阻塞任务。

### 维护边界

- **唯一运行真相**：`.claude/`。产品逻辑只维护 `.claude/agents/`、`.claude/commands/`、`.claude/workflows/`、`.claude/skills/`、`.claude/settings.json` 与 `.claude/shared/`。
- **唯一开发规范**：`AGENTS.md` / `CLAUDE.md` 必须保持逐字同步。
- **Codex 边界**：`.codex/` 仅保留开发辅助配置，不承载产品逻辑。
- **本地 AI 辅助边界**：`.agents/skills/superpowers/` 仅作本地开发辅助目录，已 gitignore，不属于产品运行真相，也不纳入提交范围。
- **文档职责边界**：
  - `README.md`：项目入口与使用导航
  - `PROJECT_STATUS.md`：当前事实、进度、待办、已知问题
  - `CHANGELOG.md`：发布级变化历史
  - `AGENTS.md` / `CLAUDE.md`：执行规范
  - `docs/archive/`：不再作为当前真相，但仍需保留引用价值的历史文档

### 日志粘贴处理

当用户直接粘贴日志原文，且内容尚未被 `log` skill 预处理时，按以下契约执行：

1. 追加到对应月份日志文件：`日志/谢安的YYYY-N月日志.md`
2. 优先调用 `daily-analyzer`；如无法调用，则按 `.claude/shared/prompt-rules.md` 与 `.claude/agents/daily-analyzer.md` 的约定回退生成
3. 将分析结果写入 `复盘/每日反馈/YYYY-MM-DD.md`
4. 对话中展示与文件一致的反馈内容

---

## 一、上下文加载

### 最小足够上下文

每次对话默认按以下顺序读取：

0. `.claude/shared/ai-operating-principles.md`
1. `PROJECT_STATUS.md`
2. `CHANGELOG.md` 最近 5 条
3. `README.md` 仅在对外说明、目录结构、命令表、安装使用、版本徽章受影响时读取

`docs/first-principles.md` 是给开发者和用户看的提醒文档，不作为 AI 默认长上下文；当讨论项目初心、开发者纪律或用户纪律时再读取。

### 启动校验

读取 `VERSION` 并与 `PROJECT_STATUS.md` 中 `**当前版本**` 对比：

- 若本次只是答疑：说明不一致即可，不为校验制造改动
- 若本次会修改文件：以 `VERSION` 为准修正 `PROJECT_STATUS.md`，并在 `CHANGELOG.md` 追加一条 `[修复]` 记录

### PROJECT_STATUS.md 必含章节

1. 项目概述
2. 技术栈
3. 架构设计
4. 当前进度
5. 待办事项
6. 已知问题
7. 关键决策记录

并满足：

- 标题下紧跟 `**当前版本**：X.Y.Z`
- 使用 YAML frontmatter（`created`、`last_updated`）

### CHANGELOG.md 格式

`CHANGELOG.md` 采用**发布视角**，只记录对用户或协作者重要的变化；详细过程记录归档到 `docs/archive/`。

单条记录格式如下：

```markdown
## [YYYY-MM-DD HH:MM] [标签] 改动简述 (vX.Y.Z -> vX.Y.Z)

- **受影响文件**: 文件路径列表
- **改动摘要**: 面向用户或协作者说明这次变化为什么重要
```

标签类型：`[功能]` `[修复]` `[重构]` `[文档]` `[配置]` `[破坏性变更]` `[回退]`

---

## 二、改动追踪

### 自动记录

凡是修改了产品行为、运行配置、公开文档、开发规范或发布状态相关文件，都必须在响应结束前自动向 `CHANGELOG.md` 顶部追加一条**发布级**记录。同一任务的多文件修改合并为一条。

不记录 CHANGELOG 的情况：

- 纯信息查询
- 只读分析
- 日志存档/复盘输出
- 临时草稿
- 未被采纳的 spec / plan
- 无语义变化的格式化
- 纯内部过程性整理，且对用户/协作者无感知
- 本地辅助文件改动

### 同步 PROJECT_STATUS

仅当以下事实变化时同步更新 `PROJECT_STATUS.md`：

- 当前版本
- 架构/技术栈
- 模块进度
- 待办
- 已知问题
- 关键决策
- 维护边界

### 文档同步等级

| 等级 | 触发条件 | 必做检查 |
|------|---------|---------|
| 轻量 | 单文件小改动、措辞/格式修正 | 检查被改文件内链接；如记录 CHANGELOG 则追加记录；自动本地提交 |
| 标准 | 多文档、命令描述、开发规范、README/PROJECT_STATUS 事实同步 | 执行相关同步检查 + 同步验证 |
| 全量 | 版本号、路径约定、文件移动/删除、新增/删除命令/代理/视角、`settings.json`、`paths.md`、禁用词、目录结构 | 执行完整同步检查清单、高风险表和同步验证 |

### 同步检查清单

1. 若涉及版本号变更：全局搜索并替换旧版本号
2. 若涉及文件移动/重命名：搜索并修复旧路径引用
3. 若涉及公开结构变化：检查 `README.md` 目录结构图
4. 若涉及命令/代理/工作流增删：检查 `README.md` 对应入口说明
5. 若涉及 `paths.md`：确认无旧路径残留
6. 标准/全量改动执行反向消费者检查：
   - `settings.json` 自定义键必须有消费者
   - `paths.md` 路径模式必须有消费者
   - `docs/specs/` 非模板 spec 必须被 `README.md` 或 `PROJECT_STATUS.md` 引用

### 同步验证

验证通过后方可追加 CHANGELOG：

1. 涉及版本变更时，确认 `VERSION`、`PROJECT_STATUS.md`、README 徽章一致
2. 检查 Markdown 相对链接目标存在
3. 若有旧名称/旧路径/旧版本号，确认零残留
4. 标准/全量改动时确认无死配置、死路径

### 提交与推送

- 需要记录 CHANGELOG 的改动：在记录追加且验证完成后，自动执行 `/提交` 对应的本地提交流程
- 不需要记录 CHANGELOG 的改动：使用简短人工 commit message 本地提交
- 推送始终由用户手动执行 `git push`

若 `.git` 写入受限导致需要提权，应直接说明“正在等待提权批准”。

---

## 三、版本管理

版本号遵循语义化版本，存储在根目录 `VERSION` 文件。

### 递增触发

只有可发布变化才递增版本号，包括：

- 用户可见行为改变
- 命令 / 代理 / workflow / 配置变更
- 开发规范变更
- 公开文档变更
- bug 修复
- 兼容性或目录约定变化

### 不递增

- 纯信息查询
- 日志/复盘数据生成
- 临时草稿
- 未采纳 spec / plan
- 无语义格式化
- 本地辅助文件调整
- 仅对个人数据目录的存档操作

### 递增规则

- 修复 bug、小优化、规范/文档更新 -> 修订号 +1
- 新增功能且向后兼容 -> 次版本号 +1，修订号归零
- 破坏性变更 -> 主版本号 +1，其余归零

---

## 四、代码风格

- **核心治理文档**必须使用 YAML frontmatter：`PROJECT_STATUS.md`、`CHANGELOG.md`
- 中文内容文件用中文；配置字段和文件名用英文
- 中文 Markdown、治理文档与共享契约统一使用 UTF-8 编码保存；在 PowerShell 或脚本中读取中文文件时，必须显式使用 UTF-8 方式（如 `Get-Content -Encoding utf8` 或 Python `encoding='utf-8'`），不能仅凭终端乱码现象判断源文件损坏
- 文件路径使用相对于项目根目录的路径
- 文件名与目录名默认使用英文 kebab-case
- gitignored 个人数据目录可使用中文命名，以直观可读优先
- 表格优先用于结构化信息
- 评分体系使用项目术语：六步法、复盘六问、六维图、加分制
- 所有 agent、command、workflow、perspective 输出默认使用简体中文

---

## 五、目录管理

根目录仅保留以下核心文件与仓库元数据：

`README.md`、`LICENSE`、`AGENTS.md`、`CLAUDE.md`、`PROJECT_STATUS.md`、`CHANGELOG.md`、`VERSION`、`.gitignore`、`.gitattributes`、`.editorconfig`、`SETUP.md`

其他文件按类型归入子目录：

| 目录 | 用途 | 版本控制 |
|------|------|---------|
| `src/` | 源代码 | 纳入 |
| `docs/` | 文档、方法论、模板、spec | 纳入 |
| `examples/` | 脱敏示例 | 纳入 |
| `zhiji-user/` | 用户版分发包，用于小范围内测 | 纳入 |
| `tests/` | 测试代码 | 纳入 |
| `.github/` | Issue/PR 模板、CI | 纳入 |
| `data/` | 个人数据、原始输入 | gitignore |
| `output/` | 生成的分析、报告 | gitignore |
| `关于我/` | 个人画像、快照 | gitignore |

---

## 六、工作流控制

### Superpowers 集成

当用户执行开发任务且当前环境实际提供对应 superpowers 技能时，按任务类型自动调用；若技能不可用，则回退到本文件内置流程。

| 用户场景 | 自动调用的技能 |
|---------|----------------|
| 新增功能/需求 | `superpowers:brainstorming` -> `superpowers:writing-plans` -> `superpowers:executing-plans` |
| Bug 修复 | `superpowers:systematic-debugging` |
| 代码重构 | `superpowers:writing-plans` -> `superpowers:verification-before-completion` |
| 测试 | `superpowers:test-driven-development` |
| 请求代码审查 | `superpowers:requesting-code-review` |
| 接收审查反馈 | `superpowers:receiving-code-review` |
| 并行任务 | `superpowers:dispatching-parallel-agents` |
| 完成分支 | `superpowers:finishing-a-development-branch` |
| Git 工作树隔离 | `superpowers:using-git-worktrees` |

以下情况不强制调用：

- 纯信息查询
- 已处于某个 superpowers 技能上下文中
- 仅文档/注释/格式修正
- 用户明确说“不用 superpowers”

### 回退与撤销

触发词：回退上次修改、撤销某改动、回退到某版本、回退刚加的规则。

流程：

1. 读取 `CHANGELOG.md` 定位目标
2. 选择回退方法
3. 执行回退
4. 回退版本号
5. 追加 `[回退]` 记录

| 文件状态 | 回退方法 |
|---------|---------|
| git 跟踪、未 commit | `git checkout HEAD -- <file>` |
| git 跟踪、已 commit | `git revert <commit>` |
| 不在 git 跟踪 | 根据 CHANGELOG 手动反向编辑 |
| 回退特定规则 | 精确编辑删除并重新编号 |

回退前必须先与用户确认影响范围。

### Spec-Before-Code

收到新增功能需求时，不直接编码。默认流程：

1. 在 `docs/specs/` 创建 spec
2. 高优先级需求在 `PROJECT_STATUS.md` 中登记
3. 展示摘要并等待确认
4. 确认后进入实施
5. 完成后更新状态

若当前环境可用 superpowers 且已产出足够详细的计划，则直接复用，不重复创建 spec。
