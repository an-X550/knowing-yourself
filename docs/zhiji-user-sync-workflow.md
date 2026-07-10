# zhiji-user 导出与同步流程

## 第一性原理

统一更新不是“让两个目录看起来差不多”，而是先分清对象：

1. **主产品运行真相**：上级仓库根目录下的 `.claude/`、开发文档、治理文件与完整工作台入口。
2. **用户版产品变体**：给终端用户分发的精简运行树。它和主产品共享一部分能力，但入口、说明、保护机制并不完全同构。
3. **真实运行数据**：`日志/`、`复盘/`、`关于我/*.md` 等真实内容。它们既不是产品逻辑，也不应该被导出流程覆盖。

因此，当前阶段最稳的方案不是“把上级运行树全量镜像给用户版”，而是：

- 在上级仓库里**显式维护用户版变体定义**
- 用导出脚本把这份变体定义刷新到 `zhiji-user/`
- 对真实运行数据只补种子，不做覆盖

## 当前机制

- manifest：`packaging/zhiji-user-manifest.json`
- 用户版变体源：`packaging/zhiji-user-overlay/`
- 导出脚本：`scripts/export-zhiji-user.ps1`
- 目标仓库：`zhiji-user/`

manifest 中的同步任务分为三种：

- `mirrorDir`：镜像用户版受控目录，目标目录会被覆盖重建。
- `overwriteFile`：覆盖单个受控文件。
- `seedFile`：只在目标文件缺失时补种子，默认保留现有运行时文件。

## 为什么这样设计

因为经过对比可知，用户版不是简单的“删掉开发文档”：

- 它有裁剪后的入口集。
- 它有独立的隐私保护与分发说明。
- 它的运行时画像文件需要保留给真实用户，不应被导出脚本回滚。

所以第一步先把**用户版本身**收拢成上级仓库里的一个产品定义，先解决“一处维护、一次导出”的问题；后续再逐步把真正共享的能力从 overlay 里回抽到主产品共享层。

## 日常工作流

1. 用户内测收集反馈。
2. 先判断反馈类型：
   - 主产品与用户版都应变化的能力 → 先改上级仓库，再同步更新 overlay。
   - 只属于用户版分发体验的内容 → 直接改 `packaging/zhiji-user-overlay/`。
   - 真实日志、复盘、画像 → 只作为验证材料，不进入导出源。
3. 运行导出脚本刷新 `zhiji-user/`。
4. 运行 `tests/project-integrity.tests.ps1`，确认 manifest 源受主仓库跟踪、受控文件无漂移、Hook 与目录契约完整。
5. 在 `zhiji-user/` 内做 smoke check。
6. 分别提交上级仓库与用户版仓库。

## 常用命令

```powershell
powershell -ExecutionPolicy Bypass -File scripts/export-zhiji-user.ps1
```

导出后执行完整性回归：

```powershell
powershell -ExecutionPolicy Bypass -File tests/project-integrity.tests.ps1
```

如需在一个全新目标目录中补齐运行时占位文件，可加：

```powershell
powershell -ExecutionPolicy Bypass -File scripts/export-zhiji-user.ps1 -ForceSeedFiles
```

## 边界

- 不要直接把上级仓库完整 `.claude/` 全量复制到用户版。
- 共享能力的长期目标是回抽，但在真正抽离前，用户版变体先集中维护在 `packaging/zhiji-user-overlay/`。
- `关于我/current.md`、`verified-patterns.md` 等运行文件默认保留现状；如果你想刷新种子，请显式使用 `-ForceSeedFiles`。
- `日志/`、`复盘/`、`关于我/Analysis/` 属于真实使用产物，导出流程永不清空。
