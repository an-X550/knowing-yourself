---
created: 2026-08-22
last_updated: 2026-08-22
purpose: 可直接交给实现 Agent 的任务提示词
---

# Agent 中文历史检索与证据卡片执行提示词

以下内容可以直接作为下一轮开发 Agent 的任务提示词使用。不调用 `leader` skill，不重新做宽泛需求发散；先按指定文档和代码核实事实，再执行已确认计划。

---

你正在维护 Windows 工作区：

```text
C:\Users\panda\.claude\skills\知己
```

目标：在知己 Electron 桌面端中，先修复 `zhiji.memory.search` 对自然中文复合问题和有限同义表达的漏召回，再把同一份 Main Process 已校验结果展示为当前回合只读证据卡片。完成代码、普通测试、打包/E2E 验证、版本与项目文档同步和本地提交；不要远程 push 或正式发布。

## 一、必须先读的项目文档

按顺序完整读取：

1. `AGENTS.md`
2. `.claude/shared/ai-operating-principles.md`
3. `PROJECT_STATUS.md`
4. `CHANGELOG.md` 最近 5 条
5. `docs/development-governance.md`
6. `docs/2026-08-22-agent-capabilities-first-principles-analysis.md`
7. `docs/reviews/2026-08-22-agent-capabilities-audit.md`
8. `docs/specs/2026-08-22-agent-memory-search.md`
9. `docs/specs/2026-08-22-agent-evidence-cards.md`
10. `docs/2026-08-22-agent-evidence-cards-execution-plan.md`
11. `apps/zhiji-desktop/docs/dsh-integration-notes.md`

然后读取这些实现文件及其直接测试：

- `apps/zhiji-desktop/src/main-process/agent/agent-memory-search-service.ts`
- `apps/zhiji-desktop/src/main-process/agent/agent-tool-dispatcher.ts`
- `apps/zhiji-desktop/src/main-process/agent/dsh-runtime.ts`
- `apps/zhiji-desktop/src/main-process/agent/agent-facade.ts`（若存在）
- `apps/zhiji-desktop/src/shared/schemas/agent-tools.ts`
- `apps/zhiji-desktop/src/shared/schemas/agent-protocol.ts`
- `apps/zhiji-desktop/src/shared/schemas/agent.ts`
- `apps/zhiji-desktop/src/renderer/pages/agent-page.tsx`
- Agent 页面使用的局部样式和导航目标 Schema
- `apps/zhiji-desktop/tests/unit/agent-memory-search-service.test.ts`
- `apps/zhiji-desktop/tests/unit/agent-tool-dispatcher.test.ts`
- `apps/zhiji-desktop/tests/unit/dsh-runtime.test.ts`
- `apps/zhiji-desktop/tests/unit/agent-page.test.tsx`
- 与 Agent IPC/facade/schema 直接相关的其他现有测试

不要根据文档猜代码；如果文档与代码冲突，以当前代码为事实，并在交付中指出差异。

## 二、开始前必须检查

1. 运行 `git status --short`。工作区可能已有用户的未提交或未跟踪文件；不得覆盖、删除、移动或纳入提交。
2. 使用 `rg` 搜索；若环境中的 `rg` 无法运行，回退到 PowerShell `Get-ChildItem` + `Select-String`，不要阻塞。
3. 确认应用实际使用的 lockfile。根目录可能存在无关、未跟踪的 `package-lock.json`，不得误改。
4. 核对根 `VERSION` / `PROJECT_STATUS.md` 的 `2.5.0` 与 `apps/zhiji-desktop/package.json` / 应用 lockfile 的 `2.0.4` 冲突。查清 Electron Forge、安装包元数据和 UI 各自读取哪个版本，再按项目治理统一；不能只改一个显示字符串。
5. 先画出并在工作记录中确认现有事件流：

```text
用户消息
→ DSH AgentLoop / DeepSeek Tool Call
→ Utility Process 工具桥
→ Main Process AgentToolDispatcher / 领域服务
→ 工具结果回传模型
→ Agent Utility event / Renderer
```

## 三、已确认失败场景

权威日志：

```text
今天验证了把行动拆成更小步骤，结果更容易完成。
```

自然问题：

```text
我以前是不是经常把任务定得太大？
```

当前 `termsOf()` 把连续中文当成一个长词项，整句不在正文时可能零命中；现有测试只使用“行动”单关键词。即使命中，Agent 页也只显示“已完成：检索长期记忆”，观看者无法核实来源。

必须先用普通测试固定这个失败，再实现。不要建立独立 baseline 或质量 gate。

## 四、成熟方案与复用边界

优先查看并只依赖一手资料：

- [MiniSearch](https://github.com/lucaong/minisearch)：内存全文索引、BM25+、字段存储、自定义 tokenizer、prefix/fuzzy 选项；
- [Pi](https://github.com/earendil-works/pi)：只参考 Agent runtime/tool/state 分层，不整体替换 DSH，不引入其文件/进程/网络权限面；
- [Hermes Memory Providers](https://github.com/NousResearch/hermes-agent/blob/main/website/docs/user-guide/features/memory-providers.md)：只参考 provider 生命周期、prefetch 和来源边界；
- [Reasonix Context Engine](https://github.com/esengine/DeepSeek-Reasonix/blob/main-v2/docs/SESSION_MEMORY_RETRIEVAL.md)：参考指令/背景事实分离、BM25 保守召回、来源和预算；
- [MCP TypeScript SDK](https://github.com/modelcontextprotocol/typescript-sdk)：本任务不接 MCP，仅在解释未来边界时引用；
- [DeepSeek Tool Calls](https://api-docs.deepseek.com/guides/tool_calls/) 与 [JSON Output](https://api-docs.deepseek.com/guides/json_mode/)：工具参数走 Function Calling；普通回答不启用全局 JSON。

默认采用：

```text
MiniSearch 内存 BM25+
+ Intl.Segmenter('zh-CN', word)
+ 连续 CJK 二元词片
+ query + 最多 3 个受限 alternates
→ 同一记录合并取最高相关性
→ Main Process 安全摘录
→ 当前回合证据卡片
```

MiniSearch 只是一个新的直接依赖。实施前核对当前稳定版本、许可证、包内容、维护状态和传递依赖；使用应用现有 lockfile 固定解析结果。不要自研 BM25/TF-IDF，也不要增加 SQLite、embedding、向量库、外部记忆服务或持久化索引。

## 五、实现顺序

### 阶段 A：普通失败测试

在现有测试文件中添加：

1. 中文复合问题命中“行动拆成更小步骤”；
2. 原始“任务定得太大”加候选“行动 拆解 步骤”命中；
3. 没有候选时不能伪造语义命中；
4. 只有“以前、是不是、经常”等泛词时不返回大量无关记录；
5. 相关性优先，平分才按日期和 ID；
6. 摘录来自真实原文命中位置；
7. `alternates` 数量、长度、空值、去重和未知字段；
8. 旧版 `{ query, limit }` 输入保持兼容；
9. 原有单关键词、空结果、limit、三数据源召回不回归。

先确认新增测试在旧实现上按预期失败，不要为了“红灯”破坏其他测试。

### 阶段 B：中文词法检索

1. 从现有三类 repository/service 读取最新权威数据。
2. 每次 `search()` 构建 MiniSearch 内存索引，调用结束后释放；不写索引文件。
3. 文档和查询使用同一个 tokenizer：
   - `Intl.Segmenter` word-like 词项；
   - 连续 CJK 二元词片；
   - 规范化英文和数字；
   - 小而明确的虚词过滤。
4. 中文不开通用 Levenshtein fuzzy，避免单字误召回。
5. 完整原始短语可以额外加权，但相关性基础使用 MiniSearch BM25+。
6. 原始查询与最多 3 个 `alternates` 分别搜索；按 ID 合并并取最高分。
7. 保留实际命中词，用它在权威原文中重新定位摘录；不要把标准化字符串偏移直接用于原文。
8. 分数相同再按日期倒序、稳定 ID 排序。

### 阶段 C：受限同义候选契约

1. `query` 保持必填和 1–200 字符。
2. 新增可选 `alternates`，最多 3 项，每项 1–80 字符；trim、去重、严格拒绝未知字段。
3. 更新 DSH 工具描述/persona：候选只用于词汇差异，不得填入未经证实的事实、结论或日期；空结果最多重试一次。
4. 不改变 DeepSeek reasoning/tool-call 回放，不启用普通回复全局 JSON。

### 阶段 D：证据事件

1. 增加最小 `tool.evidence`（或符合现有命名的等价事件）Schema：`sessionId`、`callId`、固定来源、最多 8 个安全 hit。
2. 事件必须复用 Dispatcher 已通过 Zod 和 `safeText` 的同一份结果；不得重新读取仓储或复制脱敏逻辑。
3. 空结果、失败、取消不生成卡片。
4. 不发送绝对路径、URL、原始仓储对象、API Key、hidden reasoning 或工具内部 JSON。

### 阶段 E：Renderer 卡片

1. 按会话保存当前运行期证据组。
2. 默认 3 条，展开最多 8 条；显示类型、日期、有限摘录。
3. 只用既有白名单导航；无详情页的验证模式不增加新页面。
4. 切换会话不串卡，删除会话清理，应用重启不恢复。
5. 不增加写入、修改、删除记忆按钮。

### 阶段 F：脱敏演示

使用独立临时数据目录或现有 repository 夹具，覆盖：

1. 事实查询；
2. 中文复合/有限同义查询；
3. 跨日期模式查询；
4. 日志与复盘冲突；
5. 空结果。

不得把真实私人日志写入仓库、截图或录屏；不得给正式 UI 增加“导入演示数据”。

## 六、安全与治理硬约束

默认不新增 hash、冻结 contract、baseline 或 gate。只有能同时做到以下三点才允许加入：

1. 明确说出一个当前、具体、可复现的失败事故；
2. 逐项说明 Git、版本号、主键、事务、唯一约束、类型和普通测试为什么都不足以防止该事故；
3. 证明新增机制是最小方案，并说明其使用摩擦与维护成本。

如果无法完整说明，禁止新增。

同时保留安全边界：

- 不删除或弱化已有 API Key Main Process 隔离；
- 不放宽 Renderer 网络、文件、Shell 和 IPC 权限；
- 不绕过 Zod、错误脱敏、路径/URL 过滤和来源绑定；
- 不绕过日志/复盘预览—确认—执行；
- 不破坏数据目录迁移、备份损坏校验、会话删除到回收站和不可逆操作确认；
- 不执行正式发布、npm publish、GitHub Release、远程 push 或外部消息发送，除非用户另行授权；
- 不使用 `git reset --hard`、`git checkout --` 覆盖用户改动或其他破坏性清理。

## 七、禁止作弊

- 不硬编码测试问题、答案、命中记录或证据卡片。
- 不用模型手写“来源”替代结构化证据事件。
- 不让 Renderer 直接读取日志。
- 不把候选查询词展示成日志原文或用户事实。
- 不以“返回最近记录”冒充相关性召回。
- 不自研一个简化打分函数却称为 BM25。
- 不把本任务包装成 RAG、向量检索、语义记忆或 MCP。
- 不无条件每轮扫描/预取所有历史资料。
- 不创建第二份持久记忆、索引数据库或隐藏缓存。

## 八、验证命令与验收结果

先运行聚焦测试，再执行完整验证：

```powershell
Set-Location 'C:\Users\panda\.claude\skills\知己\apps\zhiji-desktop'
npm test -- --run tests/unit/agent-memory-search-service.test.ts tests/unit/agent-tool-dispatcher.test.ts tests/unit/dsh-runtime.test.ts tests/unit/agent-page.test.tsx
npm test
npm run typecheck
npm run lint
npm run package
npm run test:e2e
```

还必须检查：

- MiniSearch 被正确打入生产包，Agent Utility 新建会话仍能启动；
- 应用包版本、根 `VERSION`、项目状态和 lockfile 一致；
- 未产生持久索引文件或默认数据目录污染；
- 证据卡片长文本布局正常，默认 3 条、展开最多 8 条；
- 工具空结果、错误、取消和会话切换没有伪卡片或串卡；
- `git diff --check` 和新增/修改 Markdown 相对链接通过。

交付时给出实际结果，不写“应该通过”。如果某项无法运行，说明准确命令、错误和影响，不伪造通过。

## 九、文档、版本和提交

实施完成后：

1. 将两个 Spec 和执行计划状态改为 completed。
2. 更新 `PROJECT_STATUS.md` 当前能力、待办、已知问题和关键决策。
3. 更新能力报告/审计中“待实现”部分；仍不得称为完整 RAG。
4. 按 `docs/development-governance.md` 统一根 `VERSION`、Electron package 版本、应用 lockfile 和安装包事实。
5. 在 `CHANGELOG.md` 顶部记录实际功能、依赖、边界和真实验证结果。
6. 仅 stage 本任务白名单文件；工作区原有未跟踪/未提交内容保持不动。
7. 本地 commit 信息从最新 CHANGELOG 提取；不要 push。

## 十、最终交付格式

结论先行，至少包含：

1. 实际完成了什么；
2. 使用了什么成熟方案，为什么没有采用 SQLite/向量/MCP；
3. 中文复合查询、有限同义候选和证据卡片的实际行为；
4. 所有验证命令与真实结果；
5. 版本统一结果和安装包事实；
6. 修改文件清单；
7. 本地 commit hash；
8. 仍存在的限制：不是完整 RAG、同义候选依赖模型、卡片不持久化；
9. 提醒用户手动 `git push`，但不要代为执行。

遇到阻塞时，先穷尽白名单内的只读检查和成熟替代；若必须扩大权限、修改数据生命周期、执行不可逆操作或正式发布，停止并向用户说明需要的新授权。
