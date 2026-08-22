---
created: 2026-08-22
last_updated: 2026-08-22
---

# Agent 联网失败：第一性原理分析与执行规划

## 结论

这次问题不是 DeepSeek V4-Flash 本身“不会联网”，而是模型发起的 `web.search` 工具调用依赖 Node/Undici 直接访问 DuckDuckGo HTML；本机对该路径实际复现为连接超时，且旧链路没有 provider 级错误分类或同轮重复调用限制。仅替换网络栈不足以解决搜索源稳定性和模型重试循环，因此 v2.6.4 将搜索/读源收敛到官方 `@tavily/core@0.7.7` 的 keyless `search/extract`，并保留 Main Process 的会话绑定和正文上限。

本轮不新增天气专用工具、用户 API Key 配置、MCP、通用 URL 读取或新的 hash/baseline/gate。Tavily keyless 方案已用脱敏查询完成真实 search→extract smoke；Agent 工具错误统一为结构化 `code/message/retryable/retryAfterSeconds?`，同一 query 每轮最多自动重试一次，非重试错误后不再重复请求。

## 第一性原理复核

### 真实问题

Agent 能否联网，取决于完整链路：

```text
DeepSeek 生成工具调用
  -> DSH 注册 zhiji.web.search
  -> Main Process Zod 契约
  -> WebSearchService
  -> 桌面网络栈访问搜索源
  -> 结果回传 Agent
```

截图中的“未完成：搜索公开来源”说明模型已经走到工具调用阶段，失败边界在搜索服务或其网络请求，不是提示词是否写了“请联网”。模型 API 的工具调用能力也不会自动替知己访问网页；访问网页必须由宿主提供并执行工具。

### 已知事实

| 事实 | 证据 |
|---|---|
| Agent 已尝试搜索公开来源 | 用户截图显示先说“我帮你查一下”，随后状态为“未完成：搜索公开来源” |
| 现有搜索服务使用 Node 全局 `fetch` | `apps/zhiji-desktop/src/main-process/infrastructure/web/web-search-service.ts` |
| Node `fetch` 访问 DuckDuckGo 失败 | 本机复现 `html.duckduckgo.com:443` 的 `UND_ERR_CONNECT_TIMEOUT` |
| Electron `net.fetch` 能直接修复该链路 | 受支持启动方式下同一 DuckDuckGo 请求仍超时；不能把 HTTP 200 当成 Agent 工具回合已完成 |
| Tavily keyless 可提供通用搜索与读源 | `@tavily/core@0.7.7` 临时 ASCII 路径下真实 search 返回非空结构化结果，随后 extract 成功；不读取或提交 API Key |
| 现有工具桥和来源会话绑定正常 | `web.search` / `web.read-source` 单元测试已覆盖；截图中的错误是联网内容不可用 |

### 约束与取舍

- 保留 Main Process 独占 API Key 和受控工具桥，不向 renderer 开放任意网络能力。
- 保留 `sourceId` 只能读取当前搜索会话来源的安全边界。
- 不把模型提示词当网络实现，不让模型凭空生成实时天气。
- 不为了一个天气问题引入新的工具契约、API Key 配置、结构化输出协议或自研搜索引擎。
- 不向 renderer 或 Utility Process 暴露任意 URL、provider 原始错误或凭据。
- 需要在 keyless 共享额度、网络超时和来源不可读时给模型一条可执行且不循环的错误结果。

## 成熟方案比较

| 方案 | 能解决的真实问题 | 成本与风险 | 决策 |
|---|---|---|---|
| 只改 Agent persona 或要求模型重试 | 不能修复网络请求失败 | 零代码但无效，可能诱导模型假装联网 | 不采用 |
| 增加天气专用 Open-Meteo 工具 | 适合结构化天气，官方 API 无需 Key（非商业公平使用） | 新增工具/共享契约/测试和模型路由；只能覆盖天气 | 暂不新增 |
| 接入付费或需 Key 的搜索 API | 通用搜索稳定性可能更高 | 新增供应商配置、费用、凭据和迁移成本 | 当前不采用 |
| 继续 Node `fetch`，增加重试 | 可能掩盖而非解决运行时代理差异 | 延迟变长，DuckDuckGo 仍可能不可达 | 不采用 |
| 使用 Electron 官方 `net.fetch` | 复用 Chromium 网络栈 | 不能改变 DuckDuckGo 源可用性，且仍缺 provider 级 search/extract 语义 | 不足以单独采用 |
| 官方 Tavily SDK keyless `search/extract` | 直接提供结构化搜索与来源提取，免用户 Key | 有共享额度，需要明确错误分类、正文上限和同轮重试限制 | 采用 |

Electron 官方文档说明 `net.fetch` 使用 Chromium 网络栈，与 Node `fetch` 不同，并提供系统代理、WPAD、HTTPS 隧道和代理认证支持：
<https://www.electronjs.org/docs/latest/api/net>

天气 API 的成熟备选是 Open-Meteo 官方 API/开源仓库：
<https://github.com/open-meteo/open-meteo>

## 最小执行计划

1. 以 `WebSearchProvider` 接口隔离 provider，在 Main Process 使用官方 Tavily SDK keyless `search/extract`。
2. `WebSearchService` 只保存当前搜索会话的来源、域名、时间和最多 2000 字正文；读源只能取已保存内容或调用该来源的 Tavily extract。
3. 将 provider 失败收敛为不可用、超时、共享限额、空结果和来源不可读；跨进程错误只传结构化安全字段。
4. DSH 对同一 query 每轮最多自动重试一次；非重试错误或重试失败后抑制同 query，避免模型循环和多条重复失败活动。
5. 执行离线单测、显式 keyless provider smoke、类型检查、lint、生产打包、app.asar 依赖检查和安装版 Agent 搜索→读源→最终回答 E2E。

## 验收标准

- 脱敏查询可完成 Tavily keyless `search`→`extract`，并返回非空正文。
- Agent 询问普通公开信息时，搜索结果能通过当前 `sourceId` 会话读取来源，最终至少列出来源标题和域名。
- provider 不可用、超时、空结果、共享限额和来源不可读都返回受限结构化错误；同 query 不形成重复调用循环。
- `npm test`、`npm run typecheck`、`npm run lint`、`npm run package` 通过；打包版 Agent 启动、provider 依赖和联网工具回合不回归。
