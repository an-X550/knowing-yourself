---
created: 2026-07-08
status: 已采纳
---

# 收紧 `.claude/` 与 `docs/` 的职责边界

> 作为这个项目的维护者，我希望减少重复权威来源、明确运行契约与说明文档的分层边界，从而降低后续结构漂移和维护成本。

# 边界约束

- 不做什么：本轮不重写 agent、command、workflow 的业务逻辑，不迁移现有数据目录，不做大规模文件移动。
- 影响范围：`.claude/shared/`、`.claude/workflows/shared.js`、`.claude/skills/log.md`、`.claude/commands/*.md`、`docs/` 分层规则、维护规范文档。
- 技术约束：保持现有命令入口、输出路径、报告文件名、workflow 编排和用户可见中文语义不变。

# 问题定义

当前项目的主问题不是缺少结构，而是同一种真相被多个载体重复表达：

1. 运行时真相重复：路径模板、禁用词、输出质量规则同时出现在 `.claude/shared/*`、`workflows/shared.js`、部分 command/skill 文档里。
2. 入口职责变宽：`log skill` 同时承担识别、导入、分析触发、验证写回，正在向隐性总入口演化。
3. 文档角色混用：`docs/` 内同时承载长期原则、方法论文档、正式 spec、开发过程记录、历史归档，但边界没有完全钉死。
4. 历史沉淀缺少阈值：`docs/superpowers/` 会持续增长，如果不定义归档规则，会从“有价值过程记录”变成“高噪音堆积”。

# 第一性原理

围绕长期维护成本，结构优化只回答四个问题：

1. 这条信息是否会被运行时直接消费？
2. 这条信息是否需要成为唯一权威来源？
3. 这条信息是给系统执行，还是给人理解？
4. 这条信息失活后是否还值得留在活跃目录？

据此，项目内所有结构元素都应归入以下四类之一：

- 运行契约：被 agent / command / workflow / hook 直接消费，放在 `.claude/`。
- 说明文档：帮助人理解原则、方法和设计，放在 `docs/`。
- 开发过程记录：服务于单次设计或实现过程，放在 `docs/superpowers/`，默认不是长期活跃真相。
- 历史归档：只保留追溯价值，不继续作为活跃上下文，进入 `docs/archive/` 或对应 `_archived/` 目录。

# 目标结构

## 1. `.claude/` 的职责

`.claude/` 只保留运行时真相与可执行入口：

- `agents/`：分析与综合代理定义。
- `commands/`：用户入口、参数解析、流程编排说明。
- `workflows/`：脚本级编排与运行时 helper。
- `skills/`：hook 或特殊入口触发时使用的运行技能。
- `shared/`：唯一共享契约层，只放跨入口、跨代理的运行真相。
- `settings.json`：薄路由层，只做 hook 匹配与转发。

判断标准：

- 如果删除它会影响运行正确性，它属于 `.claude/`。
- 如果它只是解释“为什么这么设计”，它不属于 `.claude/`。

## 2. `docs/` 的职责

`docs/` 只保留帮助人理解和维护系统的文档：

- `first-principles.md`：长期原则，不带会快速过期的当前事实。
- `methodology-*.md`：方法论文档，解释如何写日志、如何做复盘。
- `analysis-standards.md`：人类可读的质量标准说明。
- `specs/`：正式、可采纳、面向产品/结构决策的设计文档。
- `superpowers/`：开发过程 spec / plan，服务于实现阶段，不默认作为长期真相。
- `archive/`：明确失活但需保留追溯价值的文档。

判断标准：

- 如果它主要为了让维护者理解，而不是让系统执行，它属于 `docs/`。
- 如果它会随时间快速过期，就不应放进长期原则文档。

# 单一权威来源规则

## 1. `.claude/shared/` 成为唯一运行契约层

以下内容只能在 `.claude/shared/` 维护：

- 路径命名与目录契约：`.claude/shared/paths.md`
- 跨 agent 输出规则与验证契约：`.claude/shared/prompt-rules.md`
- 机器可读禁用词镜像：`.claude/shared/banned-phrases.json`
- AI 运行原则：`.claude/shared/ai-operating-principles.md`

其他文件只允许：

- 引用这些契约
- 解释如何消费这些契约
- 在运行时解析这些契约

不允许再次维护平行常量表。

## 2. `workflows/shared.js` 的角色收缩

`workflows/shared.js` 应从“共享真相副本”收缩为“共享运行 helper”：

- 保留：路径渲染、slug 处理、视角选择、摘要校验等 helper。
- 移除：作为手写权威副本存在的路径模板、禁用词数组。

如果运行环境限制脚本直接读取 Markdown/JSON，则允许采用“生成产物”策略，但生成物必须明确标注来源，并由 `.claude/shared/*` 单向生成，而不是双向维护。

## 3. 人类说明与机器镜像分离

- `docs/analysis-standards.md` 是人类可读权威说明。
- `.claude/shared/banned-phrases.json` 是机器可读运行镜像。

两者可以并存，但关系必须是：

`docs` 负责解释规则，`.claude/shared` 负责运行消费。

不允许再出现第三份手写列表。

# 入口职责边界

## 1. `commands/`

职责：参数解释、路由、流程编排、错误提示。

不负责：

- 重复维护分析标准
- 重复维护输出格式细节
- 重新定义共享路径

## 2. `agents/`

职责：分析、综合、格式产出。

不负责：

- 再写一份共享契约
- 再决定入口路由
- 直接承担 hook 行为

## 3. `log skill`

应被定义为“日志入口编排器”，不是“总分析入口”：

- 负责：识别单日/多日、归档、调用 `daily-analyzer`、按契约写回 `verified-patterns`。
- 不负责：自己发明新的日分析格式、自己复制 `/import` 的完整细节、自己维护独立的 readiness 规则。

设计原则：

- 单日日志反馈唯一来自 `daily-analyzer`
- 多日日志导入逻辑唯一来自 `/import`
- 后续提示优先级唯一来自 `review-readiness-checker` 或共享契约

## 4. `settings.json`

只做薄 hook 路由：

- `UserPromptSubmit`：高召回匹配并转发到 `log skill`
- `Stop`：提醒未提交变更

不向其中继续扩展分析流程、路径逻辑或复杂分支。

针对 Windows 兼容性，`Stop` hook 使用 `bash -c` 属于已知风险点，应被明确记录为“兼容性债务”，而不是默认稳定基础设施。

# 文档分层规则

## 1. `docs/specs/`

存放正式采纳或待采纳的产品/结构设计，特点是：

- 面向长期维护
- 可以被 README / PROJECT_STATUS 引用
- 讨论的是“系统应如何组织”

## 2. `docs/superpowers/specs/`

存放开发过程中的设计记录，特点是：

- 服务于某次实现会话
- 可以比正式 spec 更临时、更贴近操作过程
- 默认不作为长期真相

如果同一主题同时需要保留两份文档，必须满足：

- `docs/specs/` 讲最终决策
- `docs/superpowers/specs/` 讲设计过程

否则只保留一份。

## 3. `docs/superpowers/plans/`

只保存执行计划，不保存新的权威规则。计划中可以引用 shared 契约和正式 spec，但不应替代它们。

## 4. `docs/archive/`

只保留以下文档：

- 明确失活的历史说明
- 已被新文档替代但仍需追溯的记录
- 长期不再作为默认上下文的过程材料

# 历史归档策略

为防止 `docs/superpowers/` 失控，定义以下规则：

1. 计划或过程 spec 一旦完成对应改动，且关键信息已沉淀进 `docs/specs/`、`PROJECT_STATUS.md` 或 `CHANGELOG.md`，即可从活跃集合降级为历史过程文档。
2. 连续两个版本都不再被引用的过程文档，应进入归档目录或按主题折叠整理。
3. 活跃默认上下文不读取 `docs/superpowers/`，只有在追溯设计过程或继续执行旧计划时才读取。

# 验收标准

- [ ] `.claude/shared/*` 被明确规定为唯一运行契约层，其他运行文件不再维护平行权威。
- [ ] `workflows/shared.js` 的未来职责被收紧为 helper，而不是共享真相副本。
- [ ] `log skill`、`commands`、`agents`、`settings.json` 的边界被明确写清。
- [ ] `docs/` 的五类文档角色被区分清楚：人类提醒、方法论文档、正式 spec、开发过程记录、历史归档。
- [ ] 形成一份可直接执行的 implementation plan，后续改动可以按阶段落地。

# 实施建议

1. 先处理共享权威来源：`shared.js`、`paths.md`、`banned-phrases.json`、`prompt-rules.md`
2. 再处理入口职责：`log.md`、相关 commands、`settings.json`
3. 再处理文档分层与归档：`docs/specs/`、`docs/superpowers/`、`docs/archive/`
4. 最后同步 README / PROJECT_STATUS / CHANGELOG 的结构说明与版本状态

# 当前状态：已采纳，待实施
