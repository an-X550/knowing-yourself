# 开发治理细则

本文件只在会修改项目文件时读取，补充根规则中的按需治理入口。

## 启动校验与发布事实

读取 `VERSION` 并与 `PROJECT_STATUS.md` 中 `**当前版本**` 对比：

- 若本次只是答疑：说明不一致即可，不为校验制造改动。
- 若本次会修改文件：以 `VERSION` 为准修正 `PROJECT_STATUS.md`，并在 `CHANGELOG.md` 追加一条 `[修复]` 记录。

`PROJECT_STATUS.md` 必含以下章节：项目概述、技术栈、架构设计、当前进度、待办事项、已知问题、关键决策记录；标题下紧跟 `**当前版本**：X.Y.Z`，并使用含 `created`、`last_updated` 的 YAML frontmatter。

`CHANGELOG.md` 采用发布视角，只记录对用户或协作者重要的变化；详细过程记录归档到 `docs/archive/`。单条记录格式：

```markdown
## [YYYY-MM-DD HH:MM] [标签] 改动简述 (vX.Y.Z -> vX.Y.Z)

- **受影响文件**: 文件路径列表
- **改动摘要**: 面向用户或协作者说明这次变化为什么重要
```

标签类型：`[功能]`、`[修复]`、`[重构]`、`[文档]`、`[配置]`、`[破坏性变更]`、`[回退]`。

## 改动追踪与文档同步

修改产品行为、运行配置、公开文档、开发规范或发布状态相关文件时，在响应结束前向 `CHANGELOG.md` 顶部追加一条发布级记录；同一任务的多文件修改合并为一条。纯信息查询、只读分析、日志存档/复盘输出、临时草稿、未采纳的 spec/plan、无语义格式化、无用户/协作者感知的内部整理及本地辅助文件改动不记录。

只有当前版本、架构/技术栈、模块进度、待办、已知问题、关键决策或维护边界发生事实变化时，才同步 `PROJECT_STATUS.md`。

| 等级 | 触发条件 | 必做检查 |
|------|---------|---------|
| 轻量 | 单文件小改动、措辞/格式修正 | 检查被改文件内链接；如记录 CHANGELOG 则追加记录；自动本地提交 |
| 标准 | 多文档、命令描述、开发规范、README/PROJECT_STATUS 事实同步 | 执行相关同步检查 + 同步验证 |
| 全量 | 版本号、路径约定、文件移动/删除、新增/删除命令/代理/视角、`settings.json`、`paths.md`、禁用词、目录结构 | 执行完整同步检查清单、高风险表和同步验证 |

同步检查：版本变更时搜索并替换旧版本；移动或重命名时修复旧路径引用；公开结构变化时检查 README 目录图；命令/代理/workflow 增删时检查 README 入口；修改 `paths.md` 时确认无旧路径；标准或全量改动时确认 `settings.json` 自定义键、`paths.md` 路径模式有消费者，且非模板 `docs/specs/` 被 README 或 PROJECT_STATUS 引用。

验证通过后才追加 CHANGELOG：版本变更时确认 `VERSION`、PROJECT_STATUS 与 README 徽章一致；Markdown 相对链接目标存在；旧名称、路径或版本零残留；标准或全量改动无死配置、死路径。

需要记录 CHANGELOG 的改动，在记录追加且验证完成后自动执行本地提交流程；不需记录的改动使用简短人工提交信息。推送始终由用户手动执行 `git push`。若 `.git` 写入受限需提权，应说明正在等待提权批准。

## 版本管理

版本号遵循语义化版本，存储在根目录 `VERSION`。用户可见行为、命令/代理/workflow/配置、开发规范、公开文档、bug 修复、兼容性或目录约定变化均为可发布变化并递增版本。纯信息查询、日志/复盘数据生成、临时草稿、未采纳 spec/plan、无语义格式化、本地辅助文件调整和个人数据目录存档不递增。

- 修复 bug、小优化、规范或文档更新：修订号 +1。
- 向后兼容的新功能：次版本号 +1，修订号归零。
- 破坏性变更：主版本号 +1，其余归零。

## 代码与目录约定

- 核心治理文档 `PROJECT_STATUS.md`、`CHANGELOG.md` 必须使用 YAML frontmatter。
- 中文内容文件用中文；配置字段和文件名用英文。中文 Markdown、治理文档与共享契约统一 UTF-8 保存；PowerShell 或脚本读取中文文件必须显式 UTF-8。
- 文件路径使用相对于项目根目录的路径；文件和目录默认英文 kebab-case；gitignored 个人数据目录可优先使用中文名。
- 表格优先用于结构化信息；评分术语使用六步法、复盘六问、六维图、加分制；agent、command、workflow、perspective 默认输出简体中文。

根目录只保留 `README.md`、`LICENSE`、`AGENTS.md`、`CLAUDE.md`、`PROJECT_STATUS.md`、`CHANGELOG.md`、`VERSION`、`.gitignore`、`.gitattributes`、`.editorconfig`、`SETUP.md` 与仓库元数据。`src/`、`docs/`、`examples/`、`zhiji-user/`、`tests/`、`.github/` 纳入版本控制；`data/`、`output/`、`关于我/` 为 gitignored 的个人数据或生成目录。

## 回退与 Spec-Before-Code

触发“回退上次修改”“撤销某改动”“回退到某版本”或“回退刚加的规则”时：读取 CHANGELOG 定位目标，选择回退方法，执行回退，回退版本号并追加 `[回退]` 记录；回退前必须与用户确认影响范围。

| 文件状态 | 回退方法 |
|---------|---------|
| git 跟踪、未 commit | `git checkout HEAD -- <file>` |
| git 跟踪、已 commit | `git revert <commit>` |
| 不在 git 跟踪 | 根据 CHANGELOG 手动反向编辑 |
| 回退特定规则 | 精确编辑删除并重新编号 |

新增功能不直接编码：默认先在 `docs/specs/` 创建 spec，高优先级需求登记到 PROJECT_STATUS，展示摘要并等待确认，确认后实施，完成后更新状态。当前环境可用 superpowers 且已产出足够详细计划时，直接复用，不重复创建 spec。
