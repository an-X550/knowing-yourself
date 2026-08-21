---
created: 2026-08-21
status: 目标模式执行中
spec: docs/specs/2026-08-21-desktop-agent-quality-and-context.md
analysis: docs/reviews/2026-08-21-desktop-agent-first-principles-analysis.md
---

# 知己桌面端 Agent 输出质量与上下文控制执行规划

## 1. 目标模式目标

在不破坏现有日志、复盘和安全边界的前提下，完成 Agent 输出可读性、思考模式控制和官方上下文管理的最小高性价比闭环；不自研压缩、不整体替换为 Pi runtime。

最终可判结果不是“增加了多少 Agent 选项”，而是：

```text
用户能读懂回复 → 能选择速度/思考取舍 → 能用固定样例验证质量 → 长会话问题有明确是否值得处理的证据
```

## 2. 执行原则

- 每个阶段先验证真实问题，再改对应边界。
- 优先官方 DSH 扩展、Pi agent 已验证的上下文/思考交互设计和成熟 Markdown 生态；不复制 DSH 内核、不自研 Markdown 解析器和压缩引擎。
- 先保证安全和已有正式产物，再处理体验。
- 不因“通用 Agent 应该有”而自动增加功能；Structured Output 和 compaction 均有独立停止条件。
- 不提交 API Key、个人日志、真实会话 JSONL 或截图原文件。
- 不新增 hash、冻结 contract、baseline 或质量 gate；只保留可解释的普通回归测试和人工观察记录。

## 3. 工作区边界

### 允许修改

- `apps/zhiji-desktop/src/`
- `apps/zhiji-desktop/tests/`、`apps/zhiji-desktop/e2e/`
- `apps/zhiji-desktop/package.json` 与 lockfile
- `docs/reviews/`、`docs/specs/`、本文
- 实施完成后按治理要求更新 `VERSION`、`PROJECT_STATUS.md`、`CHANGELOG.md`、`README.md`

### 保持不变

- `safeStorage`、API Key 隔离、Main/Utility/Preload/Renderer 分层。
- Agent 工具的 Zod 校验、正式工作流确认门、备份校验和会话回收站。
- 日志和复盘页面的专业入口及既有 JSON 生成链路。
- 来源不明的未提交文件；开始每阶段前重新检查 `git status --short`，不 reset、不 checkout、不覆盖。

## 4. 分阶段步骤

### 阶段 0：基线与最小复现（只读/临时目录）

1. 读取本规格、分析文档、治理规则和当前 Agent 相关文件。
2. 检查 `git status --short`，确认本任务不触碰已有未提交文件。
3. 运行现有 Agent/Markdown/provider focused tests，必要时运行全量 `npm test`、`npm run typecheck`、`npm run lint`。
4. 用脱敏字符串构造两类 fixture：
   - 合法多行 Markdown；
   - 截图式的 `###`/`---`/`|` 连行文本。
5. 记录：合法 Markdown 是否被当前组件正确解析；连行文本是否能确认来自模型 content；不把个人会话写入仓库。
6. 查询并加载精确 `@deepseek-ai/dsh-*@0.1.0-rc.8` compaction 依赖，记录 peer 版本、API、构建/导入结果；确认通过后允许修改生产 lockfile，仍不把真实会话写入仓库。

阶段 0 停止条件：若当前测试/打包已有与本任务无关的失败，只记录并不顺手修复；若无法确认截图原始 content，继续按“prompt + 成熟 renderer”最小路径，不发明确定性修复器。

### 阶段 0.5：成熟方案取舍（只选能复用的边界）

1. 对照 Pi agent 的 `transformContext`、context usage、compaction entry、model selection 和 thinking level 设计，提取交互与持久化语义，不复制其完整 runtime。
2. 选择当前 DSH 官方 `0.1.0-rc.8` compaction/token-meter 组合承载上下文管理：精确版本已存在且 peer 版本族对齐，能复用现有 Utility、会话和工具桥。
3. 不采用完整 Pi runtime 替换：这会重做当前 DSH 的会话持久化、工具安全边界、正式工作流确认和进程隔离，成本高于本次用户问题收益。
4. Markdown 采用 `react-markdown` + `remark-gfm`；thinking 继续走现有 Main Process provider 适配；Structured Output 保持现有 Zod/JSON 专用链路。

### 阶段 1：输出可读性

1. 添加经验证版本的 `react-markdown` 和 `remark-gfm`，或在阶段 0 发现现有依赖已足够时复用现有依赖。
2. 替换 `MarkdownDocument` 的有限语法解析；不启用 `rehypeRaw`，不执行模型返回的 HTML。
3. 保留 frontmatter 剥离、表格容器类名和现有安全边界；必要时通过组件映射维持现有样式。
4. 在 DSH persona 增加：标题/列表/表格/引用/代码块使用真实换行；块级结构前后留空行；不要把 Markdown 标记写成行内装饰。
5. 增加单测覆盖合法 Markdown 和截图式 fixture；若截图式 fixture 仍是非法 Markdown，不在本阶段加入高风险“猜测式修复”，而在验收中标明需要模型输出改进或另行设计。

阶段 1 验收：页面 DOM 有 `h*`、`ul/ol`、`table`、`blockquote`、`pre/code` 等对应元素；同一 content 的流式和完成态表现一致；原始 HTML 不执行。

### 阶段 2：模型与 thinking 控制

1. 复用现有 provider/model 设置，增加最小 Agent thinking 配置，默认值保持关闭。
2. 通过现有 Main Process `ConfigureAi` 读取配置；不把 Key 或完整 provider secret 放入 shared/Renderer/session。
3. 在 `OpenAiCompatibleProvider.streamAgent()` 中只对支持的 DeepSeek 路由发送 thinking 参数；普通复盘生成不被意外改变。
4. 为请求体增加 enabled/disabled focused tests；对工具回合补一条失败/降级边界测试，避免 reasoning replay 不完整时静默成功。
5. Agent 页面显示当前 provider/model/thinking，并提供打开设置的入口；不在 Agent 内复制一套 provider 保存流程。

阶段 2 验收：同一假服务端可观察到两种请求体；保存后重启读取一致；现有 DeepSeek 关闭模式回归保持通过；无 Key 时仍走既有中文恢复入口。

### 阶段 3：官方上下文管理 POC 与最小接入

1. 使用精确 `0.1.0-rc.8` 组合 `dsh-token-meter`、`dsh-compaction`、`dsh-compaction-basic` 及官方要求的工具结果裁剪包，先验证 API 导入、Utility 启动、一次会话、工具回合、JSONL 持久化/恢复和打包加载。
2. 若官方组合可用，将其接入现有 DSH runtime 的官方扩展点，使用可解释的 token/阈值配置；不做按消息条数截断，不改变现有会话事件语义。
3. 用脱敏会话验证 token 统计、工具回合和恢复；由于 DeepSeek V4 官方上下文窗口为 1M，本轮不强行制造真实超长压力调用，因此不把摘要内容质量写成已验证事实。
4. 若宿主 API、事件顺序或打包仍有具体缺口，记录精确缺口并停止该阶段，不升级或 fork 整套 DSH；只有后续确有必要时再单独评估小范围 Pi core 适配，不引入第二套 runtime。

### 阶段 4：验证与文档同步

1. 运行 focused tests。
2. 运行 `npm run typecheck`、`npm run lint`、`npm test`、`npm run package`；若产品行为改变，再运行打包后的 `npm run test:e2e`。
3. 做一次人工脱敏验收：普通回答、格式请求、thinking 关闭/开启、工具调用、重启恢复、停止和删除会话。
4. 记录固定问题对照：Flash + 关闭、Flash + 开启（若可用）；不输出虚假的综合分数，只记录事实、明显差异、失败和未验证项。
5. 实现被采纳且验证通过后，按 `docs/development-governance.md` 更新版本、项目状态和 CHANGELOG；未接入的探索不记录发布变化。

## 5. 文件地图

| 阶段 | 主要文件 | 目的 |
|---|---|---|
| 0 | 临时目录、现有测试、`package.json` 只读检查 | 复现和兼容性判断 |
| 1 | `renderer/components/markdown-document.tsx`、`main-process/agent/dsh-runtime.ts`、Markdown/Agent 测试 | 渲染和生成契约 |
| 2 | provider/config/shared schema、设置页、Agent 页及测试 | thinking 控制和状态可见性 |
| 3 | 仅在兼容时新增 DSH compaction 依赖与 Utility composition | 官方上下文管理 |
| 4 | `VERSION`、`PROJECT_STATUS.md`、`CHANGELOG.md`、README/验收记录 | 发布级事实同步 |

## 6. 停止条件

- Markdown 真实问题无法从脱敏 fixture 复现时，不扩大为重写 UI。
- thinking enabled 导致工具回合无法安全重放时，保持关闭默认并记录兼容缺口。
- compaction 依赖版本族不兼容，或只能通过修改/fork DSH 源码接入时，停止该阶段。
- 既有正式写入、安全、备份、重启恢复或打包测试回退时，停止当前改动并保留失败证据。
- 不为了“功能清单完整”增加自研压缩系统；官方组合通过普通验证即可接入，组合失败则保留具体缺口。

## 当前状态：已完成；目标模式执行完成

## 7. 执行结果

阶段 0、0.5、1、2、3、4 已完成主线闭环：

- 采用 `react-markdown` + `remark-gfm` 替换有限解析器，并保留 raw HTML 不执行的安全边界；Agent persona 明确要求真实换行。
- 增加 DeepSeek Agent thinking 开关、reasoning 流和工具回合重放；设置页可保存，Agent 页显示 provider/model/thinking。
- 接入官方 `dsh-token-meter`、`dsh-compaction-basic`、`dsh-compaction-tool-result-pruner`，精确版本均为 `0.1.0-rc.8`；不替换为 Pi runtime、不自研压缩、不强制自由回复 JSON。
- 自动回归结果：52 个测试文件、296 个测试通过；typecheck 通过；lint 0 错误、6 个既有警告；桌面端打包通过。

仍保留两个有边界的后续观察项：真实 API Key 下对同一问题做 Flash thinking 关闭/开启的质量对照；使用真实超长会话观察官方摘要是否在实际上下文压力下触发。两项都不应在没有数据时新增质量分数或 gate。
