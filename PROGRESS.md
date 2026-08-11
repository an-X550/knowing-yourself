# 飞书一次性验证进度
轮次：新验证 8/8；完成证据：远端严格为 1 文件夹/1 文档，用户可打开，13/13 测试与边界审计通过。
目标：以 application identity 将唯一脱敏 Markdown 写入用户可访问的飞书“知己”文件夹。
顺序：基线 → 官方 CLI/应用配置 → 必要时仅 Docs/Drive 用户授权 → 建夹 → dry-run → 单次导入 → 用户验收 → 收尾。
基线：main，HEAD 87bbf0b；Node v24.18.0；npm 11.16.0；lark-cli 1.0.85；13/13 测试通过。
远端预算：只新增一个“知己”文件夹和一个“知己·一次性测试”文档；不重试写操作。
开关：顶层、Feishu、TickTick 与全部 result type 始终保持 false。
最大风险：新 Secret 再次进入聊天、截图、命令参数或日志；仅允许在官方交互式 CLI 本机输入。
计划偏离：Task 7 Step 2 的重复 dispatch 与单文档限制冲突，未执行第二次导入；只验证一次 dry-run 与一次真实导入。
