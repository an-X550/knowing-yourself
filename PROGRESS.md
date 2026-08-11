# distribute 飞书幂等闭环进度
目标：同一开发样本首次 success、再次 skipped_duplicate，远端严格 N→N+1→N+1。
顺序：任务 0 基线 → 路径契约 RED/GREEN → 临时启用 → 两次 distribute → 恢复/提交。
任务 0：main，HEAD 081cdf6；仅有无关未跟踪教程文件，保持不触碰。
基线：13/13 测试通过；lark-cli 1.0.85；bot/user 均 ready。
远端：N=1；现有标题“知己·一次性测试”。
任务 1：路径断言先 RED（11 项、exit 1）后 GREEN（exit 0）；相对 fixture dry-run exit 0。
任务 2：样本与状态均被忽略；SHA-256 已写状态；仅顶层/飞书/daily_feedback.feishu 临时为 true。
任务 3：首次 success；第二次调用前命中相同 SHA 并 skipped_duplicate；远端最终 1→2→2。
任务 4：配置原样恢复且全部开关 false；13/13 测试通过；Task 7 Step 2 已满足并勾选。
