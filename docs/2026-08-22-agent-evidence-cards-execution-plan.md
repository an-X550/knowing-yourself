---
created: 2026-08-22
last_updated: 2026-08-22
status: awaiting-implementation
---

# Agent 中文历史检索与证据卡片执行计划

## 1. 目标

先把 `zhiji.memory.search` 从整句字符串包含升级为适合自然中文问题的本地词法检索，再把同一份 Main Process 已校验命中结果展示为当前回合只读证据卡片。

需求来源：[`agent-evidence-cards`](specs/2026-08-22-agent-evidence-cards.md)；检索契约：[`agent-memory-search`](specs/2026-08-22-agent-memory-search.md)；可直接执行的任务提示词：[`agent-retrieval-evidence-execution-prompt`](2026-08-22-agent-retrieval-evidence-execution-prompt.md)。本计划只描述实施顺序，本轮不执行代码。

## 2. 已确认失败场景

权威日志：

```text
今天验证了把行动拆成更小步骤，结果更容易完成。
```

自然问题：

```text
我以前是不是经常把任务定得太大？
```

当前正则把连续中文问题当成一个长词项，整句不在日志中就可能返回空结果；现有测试只覆盖“行动”单关键词。即使命中，Agent 页也只显示“已完成：检索长期记忆”，观看者无法核实真实来源。

## 3. 成熟方案裁决

### 3.1 采用

- [MiniSearch](https://github.com/lucaong/minisearch)：内存索引、BM25+、字段存储、自定义 tokenizer、零传递依赖；不自研 BM25。
- `Intl.Segmenter('zh-CN', { granularity: 'word' })`：使用运行时标准中文分词能力。
- CJK 二元词片：补充分词边界差异和短中文片段；参考 Hermes 使用 trigram FTS5 改善 CJK 召回的方向，但不引入 SQLite。
- DeepSeek Tool Calls：通过可选、受限 `alternates` 提供最多 3 个候选查询，处理“任务过大/行动拆解”这类有限同义表达。
- Reasonix 原则：词法优先、来源可追踪、背景事实不能覆盖指令，召回文本保持低权限。

### 3.2 不采用

- 不整体替换 DSH 为 Pi；
- 不接 Hermes Python Runtime、Memory Provider 或外部 SaaS；
- 不接 MCP；
- 不引入 SQLite FTS5、embedding、向量库或混合检索；
- 不维护大规模手写同义词表；
- 不持久化搜索索引；Markdown repository/service 仍是唯一权威真相。

## 4. 白名单范围

允许修改：

- `apps/zhiji-desktop/package.json` 与该应用现有 lockfile：仅添加 MiniSearch 并同步正确版本事实；
- `apps/zhiji-desktop/src/main-process/agent/agent-memory-search-service.ts`；
- `apps/zhiji-desktop/src/shared/schemas/agent-tools.ts`；
- `apps/zhiji-desktop/src/shared/schemas/agent-protocol.ts` 或现有 Agent 事件契约；
- `apps/zhiji-desktop/src/main-process/agent/agent-tool-dispatcher.ts`、`dsh-runtime.ts`、必要的 facade/IPC 桥；
- `apps/zhiji-desktop/src/renderer/pages/agent-page.tsx` 及必要的局部样式/组件；
- 与上述行为直接对应的 unit/integration/E2E 测试；
- 脱敏演示夹具和说明；
- 实施完成后的 `VERSION`、`PROJECT_STATUS.md`、`CHANGELOG.md`、相关 Spec/README。

禁止扩展：

- 向量库、MCP、多模态、Computer Use、自改、通用 Planner；
- Renderer 文件读取、Shell、任意 URL 或 API Key；
- DSH JSONL 会话事件格式和备份生命周期；
- 正式日志/复盘写入确认边界；
- 新的用户入口、后台任务或持久化索引；
- 默认新增 hash、冻结 contract、baseline 或 gate。

## 5. 阶段 0：实施前事实与依赖复核

1. 读取本计划、两个 Spec、能力审计、开发治理和 AI 运行原则。
2. 检查 `git status --short`，只处理白名单文件；不覆盖其他未提交/未跟踪内容。
3. 核对 MiniSearch 当前稳定版本、许可证、包内容、传递依赖和 Electron/TypeScript 兼容性。
4. 使用应用现有包管理目录和 lockfile 安装依赖；不修改根目录无关 `package-lock.json`。
5. 解决根项目 `2.5.0` 与 Electron `2.0.4` 的版本来源冲突；先查清 Forge、安装包元数据和 UI 实际读取哪个版本，再按项目治理统一，不能只改显示文本。
6. 核对 Agent Utility event、Preload IPC、Renderer 订阅和安全导航的现有边界。

完成条件：能画出“用户问题 → Tool Call → Main Process 检索 → 模型结果 + 证据事件 → Renderer”的精确链路，并列出实际修改文件。

## 6. 阶段 A：先写普通失败测试

在现有测试结构内添加，不创建独立 baseline/gate：

1. 中文复合问题命中“行动拆成更小步骤”；
2. 原始查询失败、受限候选“行动 拆解 步骤”成功；
3. 只有泛词时不返回大量无关记录；
4. 相关性优先，平分时日期和 ID 稳定；
5. 摘录来自真实正文命中位置；
6. 既有单关键词、空结果和 limit 行为不回归；
7. `alternates` 的数量、长度、空值、去重和未知字段校验；
8. 只传旧版 `{ query, limit }` 保持兼容。

完成条件：新增测试在旧实现上出现预期失败，且失败直接对应本计划的具体场景。

## 7. 阶段 B：MiniSearch 中文词法召回

1. 用 MiniSearch 为一次搜索调用构建内存索引；索引字段来自现有三类权威数据。
2. tokenizer 同时产生：
   - `Intl.Segmenter` 的 word-like 词项；
   - 连续 CJK 片段的二元词片；
   - 规范化英文和数字词项。
3. 小范围过滤明显虚词；不得使用会吞掉业务关键词的大停用词表。
4. 不对中文启用通用 fuzzy；英文 fuzzy/prefix 只有出现具体需要时再评估。
5. 原始完整短语作为额外加权；基础相关性使用 MiniSearch BM25+。
6. 搜索原始 `query` 和最多 3 个 `alternates`，按记录 ID 合并并取最高分。
7. 实际命中词只用于从权威原文定位摘录；不能把候选词伪装成原文。
8. 相关性相同再按日期倒序和稳定 ID 排序。
9. 不写索引文件、不缓存跨调用状态；当前 repository 每次已全量读取，先保持简单一致。

完成条件：阶段 A 测试通过，既有 service API 输出字段不变。

## 8. 阶段 C：工具契约与有限同义候选

1. 在共享 Zod 输入 Schema 中新增可选 `alternates`：最多 3 项，每项 1–80 字符，严格对象仍拒绝未知字段。
2. 更新 DSH 工具定义：
   - `query` 使用用户原始问题或其忠实压缩；
   - 只有存在词汇差异时提供少量候选；
   - 候选不得包含未经证实的日期、结论或用户事实；
   - 空结果最多重试一次，不进行无限检索循环。
3. 保持 DeepSeek 工具名映射、thinking/reasoning 回放和 Main Process 执行边界不变。
4. 不启用全局 JSON Output；工具参数继续使用 Function Calling Schema。

完成条件：模型可以在一次受控调用中表达有限查询候选，宿主仍只返回权威记录。

## 9. 阶段 D：共享证据事件

1. 在现有 Agent Utility event 联合类型中增加只读证据结果事件，例如：

```text
tool.evidence
  sessionId
  callId
  source: memory.search
  hits[]: id / kind / date / excerpt
```

2. 复用 `AgentToolResultSchema` 已校验、已脱敏的同一份结果，不重新读取仓储。
3. 限制命中数最多 8、摘录最多 800 字符；不发送路径、URL、仓储对象或 reasoning。
4. 工具空结果、错误或取消不产生证据卡片。
5. 事件绑定 `sessionId` 和 `callId`，防止并发会话串卡。

完成条件：模型结果和 Renderer 卡片来源于同一份 Main Process 安全对象。

## 10. 阶段 E：Renderer 证据卡片

1. Agent 页按 `sessionId` 保存当前运行期证据组。
2. 每组默认显示 3 条，允许展开至最多 8 条。
3. 显示类型、日期和有限摘录；空日期显示“日期未知”。
4. 日志/复盘仅在能映射到既有白名单导航目标时显示“查看记录”。
5. 已验证模式无详情目标时只展示，不新增页面。
6. 切换会话不串卡；删除会话清理对应卡片；应用重启不恢复卡片。
7. 不展示 hidden reasoning、工具 JSON、路径或 URL。

完成条件：观看者无需相信模型复述，就能核实本次回答使用的本地记录。

## 11. 阶段 F：脱敏演示数据与验收

复用 repository 临时目录方式，准备固定脱敏夹具；不得覆盖默认数据目录。至少验收：

1. 直接事实查询：显示正确日期/日志，不强制行动；
2. 中文复合与有限同义查询：自然问题命中不同措辞的日志，候选词不冒充证据；
3. 模式查询：跨两个日期展示证据，只给一个可验证行动；
4. 冲突查询：日志与复盘同时展示，日志事实优先；
5. 空结果：明确未找到，不生成伪卡片或伪记忆。

如现场演示需要初始化，只提供开发/演示专用独立数据目录流程，不向正式 UI 增加“导入演示数据”。

## 12. 阶段 G：验证

聚焦测试至少覆盖：

- memory search service/tokenizer/ranking/excerpt；
- shared Agent tool/event schema；
- dispatcher/facade/runtime 工具桥；
- Agent Page 卡片显示、展开、会话隔离、删除清理和安全导航。

完整验证：

```text
cd apps/zhiji-desktop
npm test
npm run typecheck
npm run lint
npm run package
npm run test:e2e
```

还要检查：

- 打包产物包含 MiniSearch 运行代码且 Agent Utility 正常启动；
- Electron/根项目版本在实际安装包元数据、状态文档和 lockfile 中一致；
- 长摘录不撑破页面，默认 3 条不淹没对话；
- 真实 API 只做必要的脱敏演示，不输出 chain-of-thought；
- 不产生索引文件、第二份记忆或默认数据目录污染。

完成条件：普通测试和项目现有发布验证通过；不新增独立质量 gate。

## 13. 文档、版本与提交

1. 将两个 Spec 和本计划状态改为 completed。
2. 更新能力报告、审计、`PROJECT_STATUS.md`、README 中受影响的当前事实。
3. 统一 `VERSION`、Electron `package.json`、应用 lockfile 和安装包元数据；按语义化版本处理。
4. 更新 `CHANGELOG.md`，记录用户可见能力、成熟方案、明确边界和真实验证结果。
5. 只提交白名单文件，不纳入工作区原有无关改动；推送由用户手动执行。
6. 不执行正式发布、npm publish、GitHub Release 或远程 push，除非用户另行明确授权。

## 14. 特殊治理约束

默认不新增 hash、冻结 contract、baseline 或 gate。只有同时满足以下条件才允许加入：

1. 能指出一个当前、具体、可复现的事故；
2. 能说明 Git、版本号、主键、事务、唯一约束、类型和普通测试为什么都不能防止该事故；
3. 新机制是防止该事故的最小方案，并且不会增加更大的维护摩擦。

安全边界不受此限制：不得删除或弱化已有认证、API Key 隔离、数据脱敏、IPC 校验、写入确认、备份校验、不可逆操作确认和正式发布要求。

## 15. 防作弊验收

- 不能只在模型最终回答中手写“来源”替代结构化证据事件。
- 不能硬编码测试问题、固定命中结果或截图。
- 不能让 Renderer 直接读取本地数据。
- 不能把候选查询当成事实、原文或已确认记忆。
- 不能为通过测试而无条件返回最近记录或放宽到泛词全匹配。
- 不能自研一个名字叫 BM25 的简化打分器替代成熟库。
- 不能把改进后的词法检索宣称为完整 RAG、语义记忆或向量检索。
- 不能覆盖默认数据目录、删除用户数据或绕过确认门。

## 16. 回退

回退顺序：

1. 移除证据事件和 Renderer 卡片，保留检索优化；
2. 若 MiniSearch 集成自身有回归，再恢复原 `memory.search` 实现和输入 Schema，并移除直接依赖；
3. 不触碰日志/复盘仓储、DSH JSONL、API Key、备份和正式写入链；
4. 按项目 CHANGELOG 和 Git 流程执行可审计回退，不使用破坏性工作区重置。
