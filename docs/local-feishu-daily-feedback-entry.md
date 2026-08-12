# 本地飞书每日反馈入口

这是面向单人真实使用的本地验证入口：电脑在线时，在手机飞书私聊“知己 CLI”机器人发送 `日志：<当天日志原文>`，本机按现有知己日志与日反馈契约处理，并把最终反馈回复到原消息。它不提供云端常驻、离线补偿、多人使用、周/月复盘或附件入口。

## 使用边界

- 只接受配置中唯一 `allowed_open_id` 发来的 `p2p` 文本。
- 只接受全角或半角前缀 `日志：` / `日志:`；日志正文只作为数据传给 Codex，不作为命令执行。
- 消息的北京时间日期是 confirmed 日期；本地日志与反馈仍是权威记录，现有结果分发规则保持不变。
- 同一飞书 `message_id` 只分析一次。状态文件只保存消息 ID、日期、状态和错误码，不保存日志或反馈正文。
- 电脑休眠、关机、断网或监听进程退出时不可用，也没有离线队列。恢复后请把日志重新发送为一条新消息。

## 一次性准备

1. 安装官方飞书 CLI：

   ```powershell
   npm install -g @larksuite/cli
   lark-cli --version
   ```

2. 复用现有“知己 CLI”应用并确认 bot 身份可用：

   ```powershell
   lark-cli auth status --json --verify
   ```

   应用只需具备私聊消息事件 `im.message.receive_v1` 所需的只读消息能力，以及机器人回复消息能力。不要新建第二个应用，也不要扩大到群聊或通讯录权限。

3. 确认可执行的独立 Codex CLI 已登录：

   ```powershell
   codex --version
   codex exec --sandbox read-only --ephemeral "只读取当前项目名称并只输出 zhiji_runtime_ready，不修改文件。"
   ```

4. 将 [配置示例](../.claude/shared/local-feishu-daily-feedback-config.example.json) 复制为 `复盘/.local-feishu-daily-feedback-config.json`，写入本人已验证的 `open_id`、`lark-cli` 和 Codex 可执行文件路径。配置不保存 App Secret 或访问令牌；`state_path` 必须位于本仓库内。

5. 在 Windows 电源设置中关闭自动睡眠。屏幕可以关闭；电脑、网络和监听进程必须保持在线。

## 启动与停止

先运行完整预检：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .claude/workflows/local-feishu-daily-feedback.ps1 -Mode Preflight
```

只有看到 `lark=ready codex=ready config=ready` 才启动监听：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .claude/workflows/local-feishu-daily-feedback.ps1 -Mode Run
```

窗口保持打开；按 `Ctrl+C` 停止。不要把它安装成 Windows 服务或开机任务，本轮只验证真实使用频率。

## 受控验收与观察门

首次启动依次验证：普通文本只返回格式说明；本人私聊 `日志：<包含事实、状态和明确意图的样本>` 只生成一次本地日反馈并沿用现有分发；重放同一事件不重新调用 Codex，也不新增本地报告、飞书文档或滴答任务。其他用户、群聊和非文本消息不得触发分析。

接下来观察 14 天：至少 10 天真实写日志，并至少 7 次直接通过本入口获得日反馈，且没有造成明显额外负担，才值得评估云服务器。未达到时保留本地手动方案，不继续开发后台、队列或更多入口。
