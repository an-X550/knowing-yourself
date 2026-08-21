---
created: 2026-08-22
status: 已完成
scope: apps/zhiji-desktop 打包后 Agent 启动
---

# 知己桌面端 Agent 打包后启动失败：第一性原理复核

## 结论

这是打包依赖边界错误，不是 API Key 无效、thinking 模式质量问题或 DeepSeek 请求失败。Agent 第一次请求模型前，Utility Process 就因缺少外部运行时依赖退出；Main Process 只把进程退出统一显示为“知己 Agent 运行已停止”。

## 证据

- 用户在新 API 配置、保存并开启 thinking 后点击新建 Agent，会收到 `agent:start` 的“知己 Agent 运行已停止”。
- 当前仓库通过 `npm run test:e2e` 复现同一现象；失败页面状态与用户报错一致。
- 打包后的 Utility stderr 给出根因：`@deepseek-ai/dsh-token-meter` 无法导入 `zod`，错误码为 `ERR_MODULE_NOT_FOUND`。
- `vite.main.config.ts` 将 `@deepseek-ai/*` 外置，保留其 package-relative ESM 加载；`forge.config.ts` 原先只保留 `@deepseek-ai`、koffi 和 `@koromix`，没有保留 DSH 运行时依赖的 `zod`、`@standard-schema/spec`。

## 第一性原理判断

Agent 启动的必要链路是：

```text
Electron Main Process
  → Utility Process fork
  → DSH 运行时加载
  → MessagePort 发送 runtime.ready
  → agent:start 成功
  → 才开始读取 API Key / 请求模型
```

失败发生在 `runtime.ready` 之前，因此 API Key 和 thinking 参数尚未参与模型请求，继续修改请求体或关闭 thinking 都不是根因修复。真正的最小修复是让打包产物包含外置 DSH 依赖，并保留启动异常诊断。

## 修正

1. Forge asar 白名单增加 `zod` 和 `@standard-schema/spec`；它们是 DSH 外置 ESM 包的非 DSH 运行时依赖。
2. Utility 捕获启动异常并返回有限长度的错误信息。
3. Main Process 消费 Utility stderr，避免未来再次把具体兼容错误吞成“运行已停止”；诊断内容对 authorization、bearer 和 api key 做脱敏。
4. 不修改 API Key 存储、不关闭 thinking、不新增自研 Agent runtime，也不改变正式工作流安全边界。

## 验证

- `npm run test:e2e`：1 passed；打包后真实 Agent 新建会话通过。
- `npm test`：52 files / 296 tests passed。
- `npm run typecheck`：passed。
- `npm run lint`：0 errors，6 个既有 warnings。
- asar 内容检查：`zod`、`@standard-schema/spec` 均已进入生产包。

本机已有的 `app-2.0.5` 安装目录与当前仓库依赖清单不是同一构建；最终验收应安装本次重新生成的 `out/知己-win32-x64/` 或对应的新安装包。
