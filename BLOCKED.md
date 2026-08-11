# BLOCKED

- 飞书渠道连续三次预检失败：初始 PATH 无 `lark-cli`；`npx --no-install` 超时；官方安装升级到 1.0.86 后新 shell 仍 `CommandNotFoundException`。按任务止损规则不再重试，本轮状态为 `failed/cli_missing`，未创建飞书文档。
