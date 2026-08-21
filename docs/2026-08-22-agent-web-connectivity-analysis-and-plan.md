---
created: 2026-08-22
last_updated: 2026-08-22
---

# Agent 联网失败：第一性原理分析与执行规划

## 结论

这次问题不是 DeepSeek V4-Flash 本身“不会联网”，而是模型发起的 `web.search` 工具调用在知己 Main Process 的网络适配器中失败。当前适配器使用 Node/Undici 的全局 `fetch` 请求 DuckDuckGo HTML 搜索页；在本机实际复现为 `UND_ERR_CONNECT_TIMEOUT`。桌面端应复用 Electron 官方 `net.fetch`，让受控联网走 Chromium 网络栈及系统代理配置。

本次只修复现有通用联网链路，不新增天气专用工具、额外 API Key、搜索供应商或新的质量门禁。天气专用 API 作为后续备选保留，不在当前根因已明确且有更小修复时扩大契约。

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
| PowerShell 可访问同一 DuckDuckGo URL | 本机 HTTP 200，HTML 正常返回 |
| Node `fetch` 可访问 Open-Meteo | 地理编码 API 返回广州坐标；说明不是整机断网 |
| 现有工具桥和来源会话绑定正常 | `web.search` / `web.read-source` 单元测试已覆盖；截图中的错误是联网内容不可用 |

### 约束与取舍

- 保留 Main Process 独占 API Key 和受控工具桥，不向 renderer 开放任意网络能力。
- 保留 `sourceId` 只能读取当前搜索会话来源的安全边界。
- 不把模型提示词当网络实现，不让模型凭空生成实时天气。
- 不为了一个天气问题引入新的工具契约、API Key 配置、结构化输出协议或自研搜索引擎。
- 需要兼容 Windows 系统代理、WPAD、HTTPS 隧道等桌面运行环境。

## 成熟方案比较

| 方案 | 能解决的真实问题 | 成本与风险 | 决策 |
|---|---|---|---|
| 只改 Agent persona 或要求模型重试 | 不能修复网络请求失败 | 零代码但无效，可能诱导模型假装联网 | 不采用 |
| 增加天气专用 Open-Meteo 工具 | 适合结构化天气，官方 API 无需 Key（非商业公平使用） | 新增工具/共享契约/测试和模型路由；只能覆盖天气 | 暂不新增 |
| 接入付费或需 Key 的搜索 API | 通用搜索稳定性可能更高 | 新增供应商配置、费用、凭据和迁移成本 | 当前不采用 |
| 继续 Node `fetch`，增加重试 | 可能掩盖而非解决运行时代理差异 | 延迟变长，DuckDuckGo 仍可能不可达 | 不采用 |
| 使用 Electron 官方 `net.fetch` | 复用 Chromium 网络栈、系统代理和 HTTPS 能力，保留现有搜索契约 | 只需在 Electron ready 后注入 fetch 实现；单元测试仍可注入 fake | 采用 |

Electron 官方文档说明 `net.fetch` 使用 Chromium 网络栈，与 Node `fetch` 不同，并提供系统代理、WPAD、HTTPS 隧道和代理认证支持：
<https://www.electronjs.org/docs/latest/api/net>

天气 API 的成熟备选是 Open-Meteo 官方 API/开源仓库：
<https://github.com/open-meteo/open-meteo>

## 最小执行计划

1. 在 `bootstrap` 的 Electron `ready` 生命周期内，把 `net.fetch.bind(net)` 注入现有 `WebSearchService`。
2. 不改变 `web.search`、`web.read-source` 的输入输出契约和来源会话边界。
3. 增加一个回归测试，确认 bootstrap 使用 Electron 网络实现的接线；保留已有服务 fake fetch 测试。
4. 执行单元测试、类型检查、lint、生产打包和打包桌面端的联网冒烟验证。
5. 如果 Electron 网络栈仍无法访问指定公开源，再以实测证据评估替换搜索源或新增 Open-Meteo 天气工具；当前不预先建设。

## 验收标准

- Agent 询问“广州今天的天气如何”时，`zhiji.web.search` 不再因 `NETWORK_TIMEOUT` 直接失败。
- Agent 询问普通公开信息时，搜索结果仍能通过原有 `sourceId` 会话读取来源。
- 网络不可用时仍返回现有中文错误，不泄露 API Key、文件路径或任意 URL。
- `npm test`、`npm run typecheck`、`npm run lint`、`npm run package` 通过；打包版 Agent 启动和联网路径不回归。
