# Stars 全仓库技术审计

> 审计日期：2026-08-12
> 审计基线：`5292c4e`（`main`）
> 审计范围：`lib/`、`test/`、桌面平台工程、数据库 schema/迁移、依赖与现有文档
> 报告性质：代码静态审计与本地质量门禁结果，不包含真实供应商账号联调和 Windows/macOS/Linux 实机视觉验收
> 整改记录：2026-08-13 已按产品决策关闭 HIST-01、HIST-02、HIST-03，并移除全部历史数据库升级逻辑；当前只保留单一最新 Schema，其他旧版本会在打开前整库删除并重新创建，不执行任何历史数据迁移。
> 整改记录：2026-08-14 已关闭 HIST-04 至 HIST-08：当前 v17 Schema 启用并补齐外键，所有 SQLite 记录按最新字段严格解码；启动执行完整性检查并维护仅限 v17 的数据库/会话资产滚动备份；时间类型统一为 INTEGER；消息 SQL、分页游标与内存缓存统一使用稳定的 timestamp/message_id 顺序。v16 及更早版本会连同关联会话目录和旧备份直接删除，不迁移、不导入。
> 整改记录：2026-08-14 已关闭 BIZ-01 至 BIZ-09：补齐 Bot/MCP 跨资源事务与补偿、附件原子持久化、媒体超时取消、供应商退场迁移、Bot 命令反馈、安全错误模型、启动能力报告、Bot 指标批量增量刷新，以及消息游标分页与有界缓存。
> 整改记录：2026-08-14 已关闭 BIZ-10：相对时间改为本地自然日判断，日期和时刻按当前 locale 格式化，未来时间独立显示，并通过可注入时钟覆盖午夜及未来边界测试。
> 整改记录：2026-08-14 已关闭 ARCH-01 至 ARCH-06：领域编排下沉到用例，UI/Data 依赖方向由门禁约束，平台消息操作经 Repository 注入，会话草稿改为有界仓库并随会话删除清理，所有非生成生产 Dart 文件均不超过 1000 行，Bots 不可达桌面分支已删除。
> 整改记录：2026-08-14 已关闭 ENG-02 至 ENG-08：保留 Dependabot，分离生成代码和格式检查，统一 `intl_utils` 及 12 语言契约，全平台发布标识改为 `io.github.locallocal.stars` 并迁移旧 Apple 凭证，清理 7 个无直接引用依赖，同步桌面/架构文档、公共治理文件与缓存指南。仓库级 CI 配置随后按维护者要求移除，ENG-01 重新打开。

## 1. 技术摘要

仓库的基础质量并不差：分层目录已经建立，Dart 严格分析在 `data/domain/ui` 生效，API Key 使用平台安全存储中的主密钥做 AES-GCM 加密，MCP/Skill/会话记忆等高风险模块有较完整的单元测试。本次基线下 `dart analyze` 无问题，`flutter test` 的 432 项测试全部通过。

原审计的主要风险来自“实现已经快速扩展，但约束没有同步收紧”。截至 2026-08-14，BIZ-01 至 BIZ-10、ARCH-01 至 ARCH-06、UI-01 至 UI-05 和 ENG-02 至 ENG-08 已完成整改；ENG-01 因仓库级 CI 配置被移除而重新打开。核心业务可靠性、分层依赖、桌面视觉回归和端到端流程仍有本地自动测试，破坏性数据库历史升级则以明确的单一当前 Schema 政策关闭。

本次共记录 37 项：

| 优先级 | 数量 | 含义 |
| --- | ---: | --- |
| P0 | 0 | 当前未发现必然导致全局不可用、远程代码执行或不可恢复全库损坏的阻断项 |
| P1 | 8 | 可能造成历史数据丢失、部分提交、核心功能失效或长期维护失控，应优先进入近期迭代 |
| P2 | 21 | 中期会持续放大 UI 漂移、可靠性、性能、测试和发布风险 |
| P3 | 8 | 低风险规范、文档和清理项，可随相关模块改造一并完成 |

非当前数据库版本的自动重置契约、聊天附件与 Bot/MCP 多资源写入、媒体请求超时/取消、统一错误反馈、长会话分页、桌面视觉/端到端基线、依赖清理与发布元数据均已完成。后续优先项回到未关闭的产品语义与长会话性能项。

## 2. 已有保障与正向发现

- 静态分析通过，且 [`lib/data/analysis_options.yaml`](../lib/data/analysis_options.yaml)、[`lib/domain/analysis_options.yaml`](../lib/domain/analysis_options.yaml)、[`lib/ui/analysis_options.yaml`](../lib/ui/analysis_options.yaml) 已启用 `strict-casts`、`strict-inference` 和 `strict-raw-types`。
- 原审计基线共有 88 个测试文件、432 项通过的测试，覆盖 AI provider、MCP endpoint policy、MCP tool adapter、Skill 包路径穿越、签名、沙箱、会话压缩和 Repository 缓存；整改后数据库测试改为当前 Schema 与旧版本整库重置契约，BIZ-01 至 BIZ-09 整改后的全量测试为 448 项通过。
- Bot API Key 使用 AES-GCM、随机 256 位主密钥和 Bot ID 关联数据；旧明文 Key 会在读取时懒迁移。证据见 [`bot_api_key_cipher.dart`](../lib/data/services/bot_api_key_cipher.dart#L14-L109) 和 [`sqlite_bot_repository.dart`](../lib/data/repositories/sqlite_bot_repository.dart#L119-L138)。
- MCP access token/stdio 环境变量进入平台安全存储而不是 SQLite，且服务 ID 经过格式约束。证据见 [`secure_mcp_credential_store.dart`](../lib/data/services/mcp/secure_mcp_credential_store.dart#L7-L85)。
- 会话摘要文件删除已经采用 stage/commit/rollback，消息缓存也有限制为最近 5 个会话。这两处说明仓库已有可复用的补偿事务和有界缓存思路，见 [`sqlite_chat_repository.dart`](../lib/data/repositories/sqlite_chat_repository.dart#L79-L101) 与 [`sqlite_message_repository.dart`](../lib/data/repositories/sqlite_message_repository.dart#L15-L74)。
- 桌面壳已经支持键盘快捷键、可调侧栏/检查器、焦点恢复和语义化图标按钮；不是简单放大的移动布局。证据见 [`desktop_layout.dart`](../lib/ui/features/app/views/desktop_layout.dart#L208-L477) 和 [`desktop_chat_primitives.dart`](../lib/ui/core/widgets/desktop_chat_primitives.dart#L177-L394)。

## 3. 优先问题总表

| ID | 优先级 | 状态 | 问题 | 主要影响 |
| --- | --- | --- | --- | --- |
| HIST-01 | P1 | 已按策略关闭 | v13/v14 MCP 迁移曾直接删除并重建表；现已移除全部升级逻辑 | 历史数据库不再受支持，旧库会被整库重置 |
| HIST-02 | P1 | 已关闭 | 升级库与新装库约束不一致；v17 只存在最新 Schema 创建路径 | v16 及更早 Schema 会被删除，不会被误认为当前结构 |
| HIST-03 | P1 | 已关闭 | 迁移测试不能代表真实旧库；迁移实现和伪历史 Schema fixture 均已删除 | 只验证当前 Schema 精确快照与版本重置策略 |
| BIZ-01 | P1 | 已关闭 | Bot+Skill 使用数据库事务；Bot+Chat 文件和 MCP 凭证使用 stage/rollback 补偿 | 故障注入验证失败后不产生半完成状态 |
| BIZ-02 | P1 | 已关闭 | 附件由 Repository 内容寻址、保留扩展名并整批原子复制 | 复制失败阻止消息发送并清理暂存文件 |
| BIZ-03 | P1 | 已关闭 | 媒体请求具备统一 overall timeout、可取消注册和隔离任务终止 | 挂起请求可取消且不会永久阻断导航 |
| BIZ-04 | P1 | 已关闭 | Nebius/Tencent 已迁移；Kluster/Lambda/Search1Api 已从新建入口隐藏 | 历史 Bot 保留迁移或退场提示 |
| ARCH-01 | P1 | 已关闭 | Chat/AddBot/EditBot 领域编排已下沉到可测试用例 | View 仅收集输入、调用命令并渲染结果 |
| HIST-04 | P2 | 已关闭 | v17 启用外键并补齐 Bot/Chat/Message/Skill/Pin 级联关系 | `foreign_key_check` 必须为空，孤儿写入直接失败 |
| HIST-05 | P2 | 已关闭 | SQLite 记录只接受最新字段、类型和 JSON 结构 | 损坏值抛出格式错误，不再回落为空值或 epoch |
| HIST-06 | P2 | 已关闭 | 当前版本启动检查、两级滚动备份和自动恢复 | 备份含 v17 数据库与 `chats/`，高版本数据库明确拒绝降级 |
| HIST-08 | P2 | 已关闭 | SQL、分页游标和缓存统一 timestamp/message_id 顺序 | 同毫秒消息顺序稳定且分页无重叠 |
| BIZ-05 | P2 | 已关闭 | Bot create/update/delete 共享命令状态与页面内错误反馈 | 写操作失败可见、可关闭且不会成为未处理回调 |
| BIZ-06 | P2 | 已关闭 | 引入类型化 `AppFailure`，UI 仅展示本地化安全文案 | 原始异常只保留在诊断 cause，不再作为产品文案 |
| BIZ-07 | P2 | 已关闭 | 启动返回 required/optional 能力报告并提供可见诊断和重试 | MCP/Skill 降级不再静默 |
| BIZ-08 | P2 | 已关闭 | 指标改为数据库批量聚合和按 Bot ID 增量刷新 | 卡片刷新不再访问 provider 或回写 Bot |
| BIZ-09 | P2 | 已关闭 | Repository 提供稳定 cursor 分页、50 条窗口与 5 会话缓存 | UI 首次只加载最近页，上滚再取历史 |
| ARCH-02 | P2 | 已关闭 | UI ViewModel 仅依赖 domain contract/use case | architecture test 禁止非组合根 UI 导入 data |
| ARCH-03 | P2 | 已关闭 | MessageList 通过 MessageActionViewModel 调用平台能力 | 保存取消、失败和不支持链接可独立测试 |
| ARCH-04 | P2 | 已关闭 | 草稿由有界 LRU Repository 管理并校验附件 | 删除 Chat/Bot 时同步清理草稿 |
| ARCH-05 | P2 | 已关闭 | 超大文件已按职责拆为 library parts | 非生成生产 Dart 文件全部不超过 1000 行 |
| UI-01 | P2 | 已关闭 | 桌面组件、Lucide 图标与通知入口已统一并形成 component matrix | 架构测试阻止重新混用 |
| UI-02 | P2 | 已关闭 | 桌面 icon action 全部复用 44×44 共享命中区 | Tooltip、Focus、Semantics 与 disabled 状态统一 |
| UI-03 | P2 | 已关闭 | 颜色状态收敛至 ThemeExtension，尺寸/形状收敛至最新 spec | 旧 token 与 compatibility facade 已删除 |
| UI-04 | P2 | 已关闭 | 已建立 108 个桌面视觉组合和完整桌面交互流 | 可发现主题、本地化、宽度与 overlay 回归 |
| ENG-01 | P2 | 待处理 | 仓库级 CI 配置已按维护者要求移除 | PR/`main` 当前不会自动执行质量门禁 |
| ENG-02 | P2 | 已关闭 | 非生成 Dart 由跨平台脚本执行 format check | `lib/generated/**` 改由重新生成 diff 门禁管理 |
| ENG-03 | P2 | 已关闭 | 本地化统一为 `intl_utils`，12 语言键/占位符与 UI smoke 必过 | 生成结果、文件命名和文档可自动复核 |
| ENG-04 | P2 | 已关闭 | 全平台与安全存储统一 `io.github.locallocal.stars` | Apple 旧凭证首次读取时迁移并清理 |
| HIST-07 | P3 | 已关闭 | v17 时间字段统一为 `INTEGER NOT NULL` | Schema 快照验证声明类型 |
| BIZ-10 | P3 | 已关闭 | 按本地自然日判断并使用 locale-aware 日期/时刻 | 未来时间不再显示“刚刚”，午夜边界有稳定测试 |
| ARCH-06 | P3 | 已关闭 | Bots 桌面 Grid 与移动 List 已显式分离 | 不可达 MenuAnchor 分支已删除 |
| UI-05 | P3 | 已关闭 | 平台判断统一为 `isDesktopPlatform` | 响应式尺寸继续由 breakpoint 判断 |
| ENG-05 | P3 | 已关闭 | 7 个零直接引用依赖已移除，锁文件已更新 | Dependabot 每月检查 pub 与 Actions 更新 |
| ENG-06 | P3 | 已关闭 | 桌面 Spec 与架构文档已对齐当前路径、token、breakpoint 和例外 | 强制依赖方向与桌面组件规则由测试固化 |
| ENG-07 | P3 | 已关闭 | 已补 MIT LICENSE、SECURITY、CONTRIBUTING、CHANGELOG 与 CODE_OF_CONDUCT | 贡献、漏洞报告和发布记录有稳定入口 |
| ENG-08 | P3 | 已关闭 | README 明确本地清理和可再生边界 | 仓库不跟踪或配置缓存 `build/`、`.dart_tool/` |

## 4. 历史数据与数据库兼容审计

### HIST-01：MCP 迁移明确丢弃用户数据（P1）

审计基线中的 `DatabaseService.migrateSchema` 会在所有 `<13` 的升级以及 `13 -> 14` 升级中调用 `_resetMcpSchema`，直接 `DROP TABLE` 后重建；测试也明确断言升级后两张表为空。

该问题已按“停止历史数据库兼容”的产品策略关闭，而不是实施数据保留迁移：[`database_service.dart`](../lib/data/services/database_service.dart) 已移除 `onUpgrade`、`migrateSchema`、`_resetMcpSchema` 和所有按版本补列/建表逻辑，只保留当前 v17 `createSchema`。打开数据库前会只读检查版本；低于 v17 时会删除数据库、关联 `chats/` 和旧备份，再通过 `createSchema` 创建 v17；高于 v17 时明确拒绝降级。

对应测试已改为校验当前 Schema 完整创建、当前版本数据库正常重开，以及旧版本数据库被删除后只生成最新表且原始记录消失，见 [`database_service_test.dart`](../test/data/services/database_service_test.dart)。这一决策意味着旧数据库不会升级或导入，全部历史数据都会被丢弃。

### HIST-02：新装与升级后的消息 schema 不等价（P1）

该问题在原审计基线成立：新装库将 `message_id` 和 `turn_id` 定义为 `NOT NULL`，旧迁移却只增加可空 `TEXT` 列，因此相同版本号下可能出现不同约束。

当前已经删除该升级路径和回填表达式，只通过最新 [`createSchema`](../lib/data/services/database_service.dart) 创建 `NOT NULL` 结构。当前 schema 世代为 v17；v16、v15 及更早数据库都会在打开前删除并重新创建。应用不会迁移、回填或导入其中的数据，HIST-02 至此关闭。

后续若调整 Schema，必须继续遵守“只支持单一当前版本”的决策：提高 `databaseVersion` 会触发整库删除并创建新结构；只有重新取得产品授权后才能另行设计数据迁移。

### HIST-03：迁移测试未还原真实历史 schema（P1）

原迁移测试用当前 Schema 人工删表/删列来模拟旧版本，确实不能证明真实用户库可以升级。

由于当前明确不支持任何历史 Schema，所有逐版本迁移测试和专门拼造旧消息表的 fixture 已删除，替换为两个契约：v17 Schema 的表、索引、关键列顺序和约束必须与精确快照一致；任意更旧数据库只按版本删除当前数据目录并重建，不检查、不解析也不迁移其内部结构。HIST-03 至此关闭。

### HIST-04：外键声明未启用（P2，已关闭）

schema 仅在 `mcp_tools.server_id` 上声明 `ON DELETE CASCADE`，见 [`database_service.dart`](../lib/data/services/database_service.dart#L568-L607)，但打开数据库时没有 `onConfigure` 执行 `PRAGMA foreign_keys = ON`，见 [`database_service.dart`](../lib/data/services/database_service.dart#L45-L55)。SQLite 默认不会执行该级联。

当前 Repository 手工先删 Tools 再删 Server，所以常规路径大多正常；但迁移、调试脚本或未来新入口绕开 Repository 时会留下孤儿数据。建议启用外键，补齐 bots/chats/messages/skills/pins 的关系，并在迁移测试中执行 `PRAGMA foreign_key_check`。

整改：v17 在 `onConfigure` 中强制开启 `PRAGMA foreign_keys = ON`，并为 Bot→Chat→Message、Bot/Skill binding、Chat/Skill pin、会话记忆和 MCP Tool 补齐 `ON DELETE CASCADE`。父记录 upsert 改为 update-or-insert，避免 SQLite `REPLACE` 触发误级联；测试覆盖孤儿写入拒绝、聚合删除和 `foreign_key_check`。

### HIST-05：兼容读取过于静默（P2，已关闭）

[`local_records.dart`](../lib/data/models/local_records.dart#L232-L243) 将损坏的 Bot parameters JSON 直接变成空 Map；图片/文件列表损坏时变成空列表，见 [`local_records.dart`](../lib/data/models/local_records.dart#L352-L364)；缺失或非法时间被转换为 epoch，见 [`local_records.dart`](../lib/data/models/local_records.dart#L378-L405)。这种策略保证页面“不崩”，但会把 MCP/模型能力配置、附件和时间信息悄悄抹掉。

建议保留容错读取，同时返回结构化 migration warning/diagnostic；原始值不要在首次读取时覆盖。对可修复值执行显式一次性迁移，对不可修复值在 UI 显示“历史数据部分损坏”，并支持导出原始记录。

整改：根据“不保留历史兼容”的产品决策，没有实现 warning 或一次性迁移。Bot、Message、Profile、Skill、Memory 等当前记录只接受 v17 定义的字段类型、枚举和 JSON 结构；损坏或缺字段直接抛出 `FormatException`。明文 Bot API Key 的读时迁移也已删除，只接受空值或当前加密 envelope。

### HIST-06：缺少恢复和降级策略（P2，已关闭）

当前只打开固定 `app.db`，不再执行 upgrade/downgrade；非当前版本会被整库删除并重建。系统仍没有数据库备份、完整性检查或用户导出/导入能力。对纯本地 AI 客户端而言，SQLite、会话附件和摘要 Markdown 是用户的核心资产。

建议至少提供：升级前滚动备份、`quick_check`/关键表计数、备份版本元数据、手动导出、失败自动回滚、明确的“不支持降级”错误页。数据库与 `chats/`、摘要目录应使用同一备份 manifest。

整改：每次打开已有 v17 数据前执行 `quick_check` 与 `foreign_key_check`，验证通过后轮换 current/previous 两级快照；manifest 固定标记 v17，并同时复制 `app.db` 与完整 `chats/`（含附件和摘要）。主库损坏时只尝试恢复这两个 v17 快照；无有效快照则显示明确恢复失败，高于 v17 的数据库显示“不支持降级”且不修改原文件。旧版本不会进入备份恢复或导入路径。

### HIST-07：schema 类型拼写错误（P3，已关闭）

[`database_service.dart`](../lib/data/services/database_service.dart) 将两个时间列声明为 `INTERGER`。SQLite 的动态类型使它通常仍能保存整数，但这会造成 schema snapshot 噪声，并可能影响外部迁移/检查工具。应在下一次发布新 Schema 时统一为 `INTEGER NOT NULL`，并同步调整版本重置策略。

整改：v17 将 Chat 的 `create_timestamp`、`modify_timestamp` 统一声明为 `INTEGER NOT NULL`，Schema snapshot 直接验证声明类型；旧 v16 数据库按版本重置，不执行修列迁移。

### HIST-08：消息顺序没有稳定 tie-breaker（P2，已关闭）

数据库已经建立 `(chat_id, timestamp, message_id)` 索引，见 [`database_service.dart`](../lib/data/services/database_service.dart#L559-L565)，但读取只使用 `ORDER BY timestamp ASC`，见 [`local_database_service.dart`](../lib/data/services/local_database_service.dart#L678-L685)，内存缓存也只比较 timestamp，见 [`sqlite_message_repository.dart`](../lib/data/repositories/sqlite_message_repository.dart#L153-L179)。同一毫秒写入的消息或时间为 0 的历史消息顺序不稳定。

建议统一使用 `timestamp ASC, message_id ASC`；如果业务必须保持 user/assistant 因果次序，应持久化单调的 `sequence`，而不是依赖字符串 ID。

整改：完整历史查询使用 `timestamp ASC, message_id ASC`，最近页及游标使用对应的 DESC/复合比较，内存窗口使用相同二级比较器。当前消息 ID 由 Repository 生成且唯一，测试覆盖同毫秒的 55 条消息跨页顺序，因此本阶段无需新增 sequence 字段。

## 5. 业务逻辑与可靠性审计

### BIZ-01：跨资源操作会部分提交（P1，已关闭）

已确认的路径包括：

- `BotListViewModel.addBot` 先写 Bot，再逐个写 Skill binding；任一 binding 失败后 Bot 已存在，见 [`bot_list_view_model.dart`](../lib/ui/features/bots/view_models/bot_list_view_model.dart#L137-L150)。
- 删除 Bot 先逐个删除其 Chat/文件，再删除 Bot；中途失败会形成“部分 Chat 已删、Bot 仍在”，见 [`sqlite_bot_repository.dart`](../lib/data/repositories/sqlite_bot_repository.dart#L93-L103) 和 [`sqlite_chat_repository.dart`](../lib/data/repositories/sqlite_chat_repository.dart#L104-L114)。
- 保存 MCP Server 依次写 SQLite、凭证、刷新目录；凭证或刷新失败时 Server 已提交。删除则先删数据库再删凭证，后者失败会留下 secret，见 [`mcp_servers_view_model.dart`](../lib/ui/features/mcp/view_models/mcp_servers_view_model.dart#L156-L185) 和 [`mcp_servers_view_model.dart`](../lib/ui/features/mcp/view_models/mcp_servers_view_model.dart#L220-L230)。

建议为单数据库操作增加 LocalDatabaseService 事务 API；跨 SQLite/文件/安全存储采用明确的 saga：stage、commit、rollback、recovery journal。会话摘要已有 stage/commit/rollback，可抽为通用模式。刷新远端目录不应决定本地保存是否成功，应返回“已保存，刷新失败”的部分成功状态。

整改：Bot 与 Skill binding 由同一 SQLite transaction 写入；删除 Bot 时 Chat、消息、Memory、Skill、usage 和 Bot 在同一 transaction 删除，整个会话目录先 stage，失败 rollback、成功 commit。MCP 凭证先写并在数据库失败时恢复，删除时凭证失败不会删除数据库记录；远端 Tool 刷新失败改为部分成功 warning。相关测试覆盖数据库触发器和凭证读写删除故障。

### BIZ-02：附件复制可能静默丢失或覆盖（P1，已关闭）

Chat View 将目标名写成 `${fileName}_$timestamp`，例如 `photo.png_123`，扩展名不再位于结尾；同毫秒、同 basename 的文件还可能互相覆盖。每个复制异常仅 `debugPrint` 后继续，最终用户消息仍会被发送，只是附件路径缺失，见 [`chat.dart`](../lib/ui/features/chat/views/chat.dart#L966-L1005)。上游 `createChatDirectory` 也吞掉目录创建异常，见 [`utils.dart`](../lib/utils/utils.dart#L34-L45)。

建议将附件持久化下沉到 `AttachmentRepository/ConversationAssetStore`，使用内容摘要或 UUID 命名，并保留原扩展名；全部复制成功后再持久化消息。若允许部分成功，必须在发送前列出失败文件并让用户确认。

整改：附件复制已下沉到 `ConversationAssetRepository`，目标名使用 SHA-256 内容摘要和原始小写扩展名；同一消息的图片与文件作为一个批次先写临时文件，全部完成后再 rename。任一来源缺失或复制失败会清理整批暂存/新提交文件并阻止消息发送，目录创建错误不再被吞掉。

### BIZ-03：不可取消媒体任务缺少统一超时（P1，已关闭）

图片、语音、音乐、视频流程在 View 中注册为 non-cancellable run，见 [`chat.dart`](../lib/ui/features/chat/views/chat.dart#L1538-L1582)。AI adapter 中仍有大量顶层 `http.get/post` 未统一包裹 timeout，例如 [`nebius.dart`](../lib/data/services/ai/nebius.dart#L184-L226) 和 [`volcano_engine.dart`](../lib/data/services/ai/volcano_engine.dart#L200-L230)。本次静态计数为 48 个 provider/service 文件、54 处顶层 HTTP 调用，而 `.timeout(...)` 仅 26 处，且多数是模型列表或 Tool session，并非所有媒体请求。

结果是网络半开或服务端不结束响应时，用户既不能取消，也会被导航守卫阻止切换/删除。建议统一注入 `http.Client` 与请求策略，定义 connect/read/overall timeout、取消 token、轮询上限和可重试错误；媒体任务应该可取消或可后台化，而不是永久阻塞当前会话。

整改：图片、语音、音乐、视频统一经过媒体请求策略，默认 overall timeout 为 2 分钟；生产请求运行在可终止 isolate，取消或超时会直接终止包括 HTTP/轮询在内的任务。媒体运行已注册为可取消外部 run，导航、删除和退出守卫可先停止任务；超时和取消返回类型化错误。

### BIZ-04：仓库已记录但尚未修复的 provider 失效项（P1，已关闭）

仓库自己的 2026-08-03 专项审计已指出 Nebius AI Studio 迁移、Kluster 退场、Tencent 旧平台即将关闭等问题，见 [`model_providers_and_capabilities_2026-08-03.md`](model_providers_and_capabilities_2026-08-03.md#L333-L418)。当前代码仍将 Nebius 默认地址设为 `api.studio.nebius.com`，见 [`provider_catalog.dart`](../lib/domain/models/provider_catalog.dart#L131-L134) 和 [`nebius.dart`](../lib/data/services/ai/nebius.dart#L8-L13)，Kluster 也仍作为可选 provider 请求旧端点。

这项结论沿用仓库现有专项审计，本轮未使用真实账号重新验证外部 API。建议将专项文档中的“退场/迁移”状态真正接入 provider registry：默认隐藏不可用入口，为历史 Bot 保留只读迁移提示，使用 capability metadata 代替旧模型 ID 字符串判断。

整改：Nebius 默认地址和图片端点迁至 Token Factory，Tencent 迁至 TokenHub 并实现 `/models`；两者移除旧模型 ID 能力猜测，改读 Bot 持久化能力元数据。Kluster、Lambda 和 Search1Api 从新建 provider 列表隐藏，但 adapter 仍可读取历史 Bot，并在详情页显示稳定的迁移/退场信息。

### BIZ-05：Bot 写操作失败没有稳定反馈（P2，已关闭）

新增 Bot 已改为 `StarsInlineErrorAlert`，但编辑保存的 `try/finally` 没有 `catch`，见 [`edit_bot.dart`](../lib/ui/features/bots/views/edit_bot.dart#L1306-L1391)；详情删除同样只有 `finally`，见 [`edit_bot.dart`](../lib/ui/features/bots/views/edit_bot.dart#L1782-L1868)；卡片删除直接 await Repository，见 [`bots.dart`](../lib/ui/features/bots/views/bots.dart#L117-L159)。异常可能成为未处理的异步回调，页面只恢复按钮状态，用户不知道数据是否写入。

建议为 Bot create/update/delete 共享一个表单命令状态：idle/submitting/succeeded/failed，错误统一经过 domain error mapper，再用同一个 inline alert 呈现；成功提示和“部分成功”也使用统一组件。

整改：Bot 列表 ViewModel 的 create/update/delete 共用 `CommandState`；新增、编辑、详情删除、卡片和移动端滑动删除均捕获失败，并通过同一 `StarsInlineErrorAlert` 呈现可关闭的安全错误。提交期间清除旧错误，失败不会再成为未处理的异步回调。

### BIZ-06：异常字符串直接成为产品文案（P2，已关闭）

UI 层有 38 处 `error.toString()`/`e.toString()`，ViewModel 普遍暴露 `Object? error`；provider 层大量重新抛出通用 `Exception('...$e')`。这会出现 `Exception:`、`Bad state:`、英文/中文混杂、嵌套异常等内容，也无法可靠判断是否可重试、是否鉴权失败、是否需要保留表单。

建议建立 `AppFailure`/sealed error：`validation`、`authentication`、`networkTimeout`、`rateLimited`、`providerRejected`、`storage`、`migration`、`unknown`，携带安全的 code、用户文案参数、debug cause 和 retryability。UI 只展示本地化安全文案，完整 cause 进入受控诊断日志。

整改：已建立上述类型化 `AppFailure`（另含 `cancelled`），ViewModel 暴露稳定错误类型和 code，原始 cause 仅保留在 `debugCause`。所有 UI 异常展示统一经过 `safeFailureMessage`，生成终止事件、Agent Loop、Skill 资源读取和会话压缩也只持久化安全 code；MCP 的稳定领域错误码仍可映射为专用本地化文案。

### BIZ-07：启动时静默吞掉能力初始化失败（P2，已关闭）

[`AppDependencies.createStartupViewModel`](../lib/ui/core/dependency_injection/app_dependencies.dart#L464-L503) 对系统 Skill 校验、MCP cache、脚本 catalog 和在线 catalog 的所有异常均 `on Object` 后忽略。安全上“失败关闭”是合理的，但当前没有持久化诊断或用户可见的降级清单。

建议返回 `StartupCapabilitiesReport`，区分 required/optional、available/degraded/failed；安全能力继续 fail closed，同时在设置页提供不含 secret 的诊断、重试和修复入口。

整改：启动初始化现在返回 `StartupCapabilitiesReport`，逐项记录系统 Skill、MCP cache、脚本 catalog 和在线 catalog 的 available/degraded/failed、required、diagnostic code 与 retryability。异常能力继续 fail closed；应用顶部展示不含 secret 的诊断清单和重试入口。

### BIZ-08：Bot 卡片指标存在 N+1 与重复加载（P2，已关闭）

Bot、消息、Skill binding、MCP 任一变化都会调度整批指标刷新，见 [`bot_list_view_model.dart`](../lib/ui/features/bots/view_models/bot_list_view_model.dart#L53-L63)。刷新对所有 Bot 执行 `Future.wait`，每个 Bot 又读取 usage、binding、model info，见 [`bot_list_view_model.dart`](../lib/ui/features/bots/view_models/bot_list_view_model.dart#L204-L242)；缺少模型元数据时还可能访问 provider 并逐条回写 Bot。

Bot 数量增大后会形成无上限并发、供应商限流和列表抖动。建议数据库侧批量聚合 usage/binding/MCP 数量；模型元数据使用带 TTL 的独立 cache；只刷新受事件影响的 Bot，并限制网络并发。

整改：usage 和 Skill binding 改为按 Bot ID 集合执行数据库聚合查询，Repository 事件携带受影响 Bot ID；MCP 只在名称/存在性变化时刷新绑定该 server 的 Bot。卡片刷新不再查询 provider，也不再隐式回写模型元数据，因此消除了该路径的网络并发、限流和重复写入问题。

### BIZ-09：长会话没有数据分页（P2，已关闭）

[`LocalDatabaseService.loadMessages`](../lib/data/services/local_database_service.dart#L678-L685) 一次返回一个 chat 的全部记录，Repository 和 ChatPage 随后全部转为领域对象并常驻列表。`ListView.builder` 只解决 Widget 懒构建，不会降低数据库读取、JSON 解码和内存中的消息数量。

建议 Repository 提供 cursor/sequence 分页：首次加载最近 N 条，向上滚动加载更早页；上下文压缩 use case 直接按需要查询，不依赖 UI 已加载的全部记录。缓存也应以窗口而不是完整会话为单位。

整改：消息 Repository 新增 `(timestamp, message_id)` 稳定 cursor，首次读取最近 50 条，反向滚动到阈值后加载更早页；缓存仅保存 5 个会话的 50 条窗口，窗口增长仍保留前页 cursor。用于上下文组装/压缩的完整历史查询与 UI 分页接口分离，不依赖 UI 当前窗口。

### BIZ-10：时间展示的自然日语义不准确（P3，已关闭）

[`formatTimestamp`](../lib/utils/time.dart#L4-L17) 使用 `difference.inDays` 判断日期。昨晚到今早不足 24 小时会只显示时分；未来时间会进入“刚刚”；日期字符串没有补零也没有按 locale 格式化。

建议注入 clock 便于测试，按本地自然日比较，未来时间单独处理，并使用 `intl` 的 locale-aware formatter。

整改：`formatTimestamp` 新增可注入时钟，将输入和当前时间统一转换为本地时间后按年月日比较；跨自然日使用 `DateFormat.yMd`，同日较早小时和未来同日使用 `DateFormat.jm`，未来跨日使用本地化日期，不再回退到“刚刚”。专项测试覆盖午夜不足 24 小时、同日分钟/小时、未来同日/跨日和中英文日期顺序。

## 6. 架构与代码组织审计

### ARCH-01：核心 View 仍在执行领域编排（P1，已关闭）

[`chat.dart`](../lib/ui/features/chat/views/chat.dart) 有 1748 行，直接复制附件、构造 user/assistant/failed Message、控制 run registry、调用媒体 provider、更新 chat preview 并处理补偿；图片、语音、音乐、视频四条流程高度重复。AddBot/EditBot 也在 View 中组装完整 Bot parameters、读取 MCP catalog、创建 provider 并判断能力，证据见 [`add_bot.dart`](../lib/ui/features/bots/views/add_bot.dart#L402-L495) 和 [`add_bot.dart`](../lib/ui/features/bots/views/add_bot.dart#L1822-L1906)。

这与 [`docs/architecture.md`](architecture.md) 中“View 只负责渲染、布局、焦点、动画、路由和弹窗”直接冲突。建议新增 `CreateBot`、`UpdateBot`、`DeleteBot`、`GenerateMediaTurn`、`PersistConversationAssets` use case；ViewModel 暴露不可变 state 和命令，View 仅采集表单输入与渲染。

整改：新增 Bot command/build、媒体 turn、用户消息创建与会话附件持久化用例。四类媒体消息的构造、附件落盘、provider 调用、终态持久化、预览更新和失败补偿均由 `GenerateMediaTurn` 统一处理；AddBot/EditBot 只提交语义化 `BotDraft`，不再自行拼装持久化参数结构。

### ARCH-02：UI ViewModel 直接依赖 data service（P2，已关闭）

下列非组合根文件直接 import data 实现：

- [`mcp_servers_view_model.dart`](../lib/ui/features/mcp/view_models/mcp_servers_view_model.dart#L1-L8) 依赖 `McpCatalogService`。
- [`skill_library_view_model.dart`](../lib/ui/features/skills/view_models/skill_library_view_model.dart#L1-L9) 依赖两个 Skill data service。
- [`chat_view_model.dart`](../lib/ui/features/chat/view_models/chat_view_model.dart#L1-L12) 依赖三种 data tool service。

建议在 domain 定义 capability/repository contract，把具体 service 留在 `AppDependencies`。同时扩展 architecture test，禁止 `lib/ui/**` 导入 `package:stars/data/`，仅允许组合根白名单。

整改：MCP/Skill catalog 通过 domain controller contract 注入；会话历史、Skill inventory、MCP inventory tool session 移入 domain use case。新增 architecture test，除 `AppDependencies` 组合根外，`lib/ui/**` 直接导入 data 会使测试失败。

### ARCH-03：展示组件直接调用平台插件（P2，已关闭）

[`message_list.dart`](../lib/ui/features/chat/views/message_list.dart#L1-L20) 直接依赖 file picker、gallery saver、share_plus 和 url_launcher，并在 View 内执行保存/分享/外链操作，见 [`message_list.dart`](../lib/ui/features/chat/views/message_list.dart#L1260-L1325)。仓库架构文档却声明平台选择器应通过 Repository 注入。

建议建立 `MessageActionViewModel` 或 `PlatformShareRepository`、`MediaExportRepository`、`ExternalLinkRepository`；UI 只发出 action。这样可以测试权限失败、取消保存、平台不支持和错误映射。

整改：新增 `MessageActionRepository`、平台实现和 `MessageActionViewModel`。MessageList 不再导入 file picker、gallery saver、share_plus 或 url_launcher；保存取消、平台异常、安全链接校验均有独立测试和架构门禁。

### ARCH-04：草稿状态是无界进程级静态 Map（P2，已关闭）

[`ChatPageState`](../lib/ui/features/chat/views/chat.dart#L41-L50) 用静态 Map 保存文本、图片、文件和 pending draft。文本清空时会移除当前 key，但删除 Chat 没有调用统一清理 API，Map 也没有容量或生命周期；File 对象可能长期指向已删除路径。

建议抽成有界 `DraftRepository`，监听 Chat 删除，定义每会话容量和附件有效性检查；若需要重启恢复则持久化文本和安全的临时文件引用，否则至少在 app lifecycle/删除时清理。

整改：新增容量为 20 的内存 LRU `ConversationDraftRepository`，仅保存路径并在读取时过滤失效附件。ChatPage 不再持有静态草稿 Map；单个 Chat 删除和 Bot 聚合删除完成后都会清理对应草稿。本阶段按产品范围不提供跨重启草稿兼容或持久化。

### ARCH-05：超大文件成为主要变更热点（P2，已关闭）

排除生成代码后，生产代码约 69,245 行；17 个文件超过 1000 行，32 个超过 500 行。最大的变更热点包括：

| 文件 | 行数 | 建议拆分方向 |
| --- | ---: | --- |
| `message_list.dart` | 2,554 | 消息行、Markdown、过程卡、媒体预览、导出/分享 action |
| `edit_bot.dart` | 2,329 | 只读详情、编辑表单、Skill/MCP 区域、保存命令 |
| `mcp_servers_page.dart` | 2,191 | 页面、卡片、详情、编辑表单、transport 字段 |
| `add_bot.dart` | 1,929 | 表单 state/validation、provider selector、model loader、desktop/mobile view |
| `profile.dart` | 1,869 | profile、appearance、general、legal/about dialogs |
| `theme.dart` | 1,860 | Material mobile、desktop semantic tokens、Shad themes、兼容 facade |
| `chat.dart` | 1,748 | composer state、history state、text generation、media use cases |
| `desktop_layout.dart` | 1,731 | shell、sidebar、toolbar、overlay、inspector、resize/shortcuts |
| `chat_generation_view_model.dart` | 1,369 | run state machine、tool approval、persistence、error mapping |

拆分应按职责和状态边界进行，不建议只按 Widget 数量机械切文件。先把副作用移出 View，再拆纯展示组件。

整改：在副作用下沉后，按消息 action/bubble/process、Bot 表单/命令/Skill、MCP 卡片/详情/编辑器、主题 token/组件/facade、数据库能力区、生成状态机事件/持久化/registry 等职责拆分。新增 1000 行架构门禁；当前排除生成代码后没有生产 Dart 文件超过该阈值。

### ARCH-06：Bots 列表存在不可达代码（P3，已关闭）

[`_buildBotsList`](../lib/ui/features/bots/views/bots.dart#L226-L258) 在 `isDesktop` 时已经直接返回 Grid；后面的 ListView itemBuilder 又判断 `if (isDesktop)` 并构建另一套 MenuAnchor 桌面 item，见 [`bots.dart`](../lib/ui/features/bots/views/bots.dart#L259-L331)，该分支永远不可达。

建议删除死分支并让方法显式拆为 `_buildDesktopGrid`/`_buildMobileList`。这也能避免未来修复错误地落在无效实现上。

整改：`_buildBotsList` 仅负责选择 `_buildDesktopGrid` 或 `_buildMobileList`，移动列表中不可达的 desktop `MenuAnchor` 实现已删除。

## 7. 桌面端 UI 一致性审计

### UI-01：组件与反馈体系仍处于混用状态（P2）

桌面代码已经大量使用 Shad，但同一功能区仍可看到 Material `MenuAnchor/MenuItemButton` 与 `ShadPopover/ShadButton` 两套菜单、Material `Icons` 与 Lucide 两套图标、`SnackBar` 与 `ShadSonner` 两套临时反馈。主题代码也明确说明仍有“compatibility widgets”，见 [`theme.dart`](../lib/utils/theme.dart#L684-L687) 和 [`theme.dart`](../lib/utils/theme.dart#L799-L806)。

全 UI 静态计数显示 246 处 Material Icon、180 处 Lucide Icon、47 处 SnackBar/Sonner/inline error 入口。数量本身不等于缺陷，但 AddBot 已统一为 inline alert，而 EditBot/Skill 子流程仍直接 SnackBar，证明相同业务语义没有统一反馈组件。

建议建立桌面 component matrix：primary/secondary/destructive button、icon action、menu/context menu、dialog/sheet、form field、inline error、toast、empty/loading state。每种语义只保留一个桌面实现，并明确哪些 Material 组件仅供移动端使用。

整改：已新增 [`desktop_component_matrix.md`](desktop_component_matrix.md)，桌面点击菜单统一为 `StarsDesktopMenu`，右键菜单统一为 `StarsContextMenu`，按钮/弹层使用 Shad，图标使用 Lucide。临时反馈全部经 `showStarsNotice` 分流，业务视图不再直接调用 Sonner 或 ScaffoldMessenger；架构测试防止重新混用。

### UI-02：桌面小按钮未遵循共享命中区（P2）

共享 [`StarsDesktopIconAction`](../lib/ui/core/widgets/desktop_chat_primitives.dart#L283-L394) 明确提供 44×44 命中区和统一 Semantics/Tooltip/Focus；但 Skill/MCP 错误关闭按钮为 28×28，EditBot 的移除、分页、输入 action 为 28–32，删除为 34，例见 [`edit_bot.dart`](../lib/ui/features/bots/views/edit_bot.dart#L1642-L1654) 和 [`edit_bot.dart`](../lib/ui/features/bots/views/edit_bot.dart#L1739-L1755)。

建议视觉图标可保持 16–18px、背景可保持 28–36px，但外层命中区统一 40/44px；菜单 trailing action 也复用共享 primitive，补齐 hover、focus ring、disabled semantics。

整改：桌面小图标动作已迁移到 `StarsDesktopIconAction`，外层命中区固定为 44×44，视觉按钮保持 36px，并统一 Tooltip、焦点环、Semantics 和禁用状态。输入框 trailing action 使用同一 primitive，同时以共享 form padding 保持 48px 输入框高度。

### UI-03：主题来源过多（P2）

UI 层静态计数有 346 处 `Theme.of`、49 处 `ShadTheme.of`、60 处直接 `BorderRadius.circular`、48 处直接 `Colors.*`。同时存在 `StarsDesktopTokens`、`DesktopThemeTokens` 兼容 facade、`StarsDesktopTheme` 和局部 Shad override。单个用法往往合理，但总体上没有自动约束哪些值可以在桌面分支直接出现。

建议将 `DesktopThemeTokens` 从“大型静态工具类”收敛为 ThemeExtension/语义 token；新增代码禁止桌面分支直接写产品颜色和圆角，允许 `Colors.transparent` 等少量白名单。完成迁移后删除 compatibility facade，而不是无限期保留双入口。

整改：颜色、对比度和透明度状态已统一到 `StarsDesktopTokens` ThemeExtension；稳定尺寸和形状统一到 `StarsDesktopThemeSpec`。`DesktopThemeTokens`、`StarsDesktopTheme` facade 与旧文件已删除，架构测试禁止桌面专用视图直接写产品色、圆角或恢复旧入口。

### UI-04：缺少视觉和完整交互回归（P2）

现有 widget tests 对桌面 token、部分语义、按钮和布局有较多断言，这是正向保障；但仓库没有 `matchesGoldenFile`、golden 资产或 `integration_test/`。因此无法发现字号/本地化导致的溢出、Shad/Material 弹层层级、实际 hover/focus 视觉、Windows 与 Linux 字体差异。

建议先为 6 个关键场景建立稳定截图基线：桌面壳、会话列表、Bot grid、Bot 新增/编辑、长消息+工具状态、设置页；覆盖 light/dark/high-contrast、中文/英文、1024/1280/1600 三档。再用 integration test 覆盖新建 Bot→新建会话→发送→取消→删除流程。

整改：`desktop_visual_regression_test.dart` 已覆盖上述六个真实场景，在 3 个宽度、3 种外观、2 种语言下形成 18 张组合基线、108 个场景组合；`desktop_workflow_test.dart` 使用生产组件验证新增 Bot→新建会话→发送→取消→删除的完整流程。矩阵、更新命令与宿主字体约束记录于 [`desktop_component_matrix.md`](desktop_component_matrix.md)。

### UI-05：平台判定命名已失真（P3）

[`isDesktopOrTabletPlatform`](../lib/utils/utils.dart#L68-L82) 目前只是 `isDesktopPlatform` 的别名，注释也说明仅 Windows/Linux/macOS 生效。继续保留旧名会让调用者误以为平板会走桌面布局。

建议批量改名为 `isDesktopPlatform`，响应式尺寸由 `LayoutBuilder`/breakpoint 单独决定；平台能力与窗口尺寸不要混在同一个 bool 中。

整改：已删除 `isDesktopOrTabletPlatform`，全部调用统一为 `isDesktopPlatform`；窗口宽度相关行为继续由布局约束和 breakpoint 控制，架构测试禁止旧别名回归。

## 8. 工程化、测试与发布规范审计

### ENG-01：质量门禁没有进入 CI（P2，待处理）

仓库没有 `.github/workflows` 或其他 CI 配置。虽然 README 要求 `dart analyze`、`flutter test`、`dart format`，但无法保证 PR/主分支实际执行。

建议最小 CI 包含：固定 Flutter 版本、`flutter pub get --enforce-lockfile`、analyze、非生成代码 format check、全量 test、Linux desktop build；数据库迁移矩阵和 architecture dependency test 设为必过。供应商真实 API 测试应使用手动/定时、无 secret 输出的独立工作流。

状态：曾增加固定 Flutter 3.44.6 的 GitHub Actions 工作流，但随后按维护者要求删除；当前只保留本地检查命令，不再宣称 PR/主分支有自动质量门禁。

### ENG-02：当前格式门禁失败（P2，已关闭）

本次执行 README 中的 `dart format --output=none --set-exit-if-changed .` 返回 exit code 1，共报告 9 个生成文件需格式化，包括 `lib/generated/l10n.dart` 和多个 `messages_*.dart`；工作树未被修改。Analyzer 已排除生成目录，但 formatter 没有。

建议选择一个明确策略：要么生成器产物不入库并在构建时生成；要么入库但 CI 重新生成后只检查 diff；要么 format check 显式排除 `lib/generated/**`。不要让开发文档给出的标准命令天然失败。

整改：`tool/check_format.dart` 跨平台收集生产、测试、集成和 tool Dart 文件，显式排除 `lib/generated/**`；生成目录在本地重新生成后通过 Git diff 复核。README 和 CONTRIBUTING 均使用这两个入口。

### ENG-03：本地化生成和文档不一致（P2，已关闭）

[`pubspec.yaml`](../pubspec.yaml#L98-L145) 同时启用 Flutter `generate: true` 和 `flutter_intl/intl_utils`，生成代码又被提交。README 仍写“English and Simplified Chinese”，但 [`app_localizations.dart`](../lib/l10n/app_localizations.dart#L3-L16) 与设置页实际支持 12 个 locale。

建议只保留一种生成链路，补 `l10n.yaml`/明确命令与 CI diff 检查；统一 locale 文件命名（当前 `intl_it_it.arb` 大小写也与 `it_IT` 不一致）；更新 README，并为每种语言检查 key parity 和最小 UI smoke test。

整改：移除 Flutter gen-l10n 入口，保留项目既有 `S` API 的 `intl_utils` 作为唯一生成器；意大利语文件改为 `intl_it_IT.arb`。12 个 catalog 现与英文模板保持 485 个消息键及占位符一致，未完成翻译的新键使用显式英文回退；新契约测试为每个 locale 构建最小 UI。README 列出全部 12 种语言和唯一生成命令。

### ENG-04：发布标识仍是模板值（P2，已关闭）

Android applicationId/namespace、iOS/macOS bundle ID、Linux application ID、Windows CompanyName 均仍使用 `com.example.stars`/`com.example`。平台安全存储 accountName 也沿用该命名，见 [`bot_api_key_cipher.dart`](../lib/data/services/bot_api_key_cipher.dart#L20-L29) 与 [`secure_mcp_credential_store.dart`](../lib/data/services/mcp/secure_mcp_credential_store.dart#L7-L19)。

正式发布后再变更 bundle/application ID 通常会被平台视为不同应用，也会影响安全存储访问和升级路径。建议在发布前确定组织反向域名，形成一次性迁移清单，并验证旧测试包凭证是否需要导入/清理。

整改：仓库所有者对应的稳定反向标识确定为 `io.github.locallocal.stars`，已同步 Android namespace/applicationId 与 Kotlin 路径、iOS/macOS app 和 test bundle ID、Linux application ID、Windows CompanyName/copyright 以及两类安全存储 accountName。iOS/macOS 首次读取新账户未命中时会从 `com.example...` 旧账户迁移并尝试清理；回归测试验证 Bot 主密钥和 MCP 凭证迁移。发布配置测试阻止模板标识回归。

### ENG-05：依赖可清理候选（P3，已关闭）

对 `lib/` 和 `test/` 的直接 package import 扫描中，下列依赖为零引用候选：`cupertino_icons`、`dart_openai`、`google_generative_ai`、`flex_color_scheme`、`dot_curved_bottom_nav`、`elegant_nav_bar`、`sidebarx`。`sqlite3` 虽无直接 import，但 pubspec 注释说明用于桌面 build hook，不列入移除候选。

零直接引用不等于一定可删；应逐个执行移除、`flutter pub get`、全平台 build/test，并检查插件注册和资产用途。完成后启用依赖更新机器人或定期 `flutter pub outdated` 审查。

整改：七个候选均已从直接依赖移除并重新解析锁文件；`sqlite3` 仍作为桌面 build hook 的显式依赖保留。`.github/dependabot.yml` 每月检查 pub 与 GitHub Actions 依赖。

### ENG-06：架构和桌面 Spec 已漂移（P3，已关闭）

[`windows_linux_desktop_style_adjustment_spec.md`](specs/windows_linux_desktop_style_adjustment_spec.md) 仍引用已删除的 `lib/pages/*`，并把 20–24px 大圆角、外层 gap 作为目标；当前桌面 token 实际以 6–8px 圆角、零 shell gap 为主，见 [`theme.dart`](../lib/utils/theme.dart#L688-L751)。架构文档声称 View 不直接调用选择器、ViewModel 不导入 data 实现，也与现状不符。

建议不要简单把文档改成“现状即正确”：先确认当前桌面视觉方向，再更新组件规范、路径、breakpoint 和验收截图；架构文档中的强制约束应转成自动测试，否则降级为“目标状态/迁移中”并列出例外。

整改：桌面 Spec 已重写为当前实现基线，明确 UI 分层路径、6–8px 形状、零 shell gap、960/1200/1500 断点、overlay/focus 行为、组件矩阵和 108 场景视觉验收。架构文档新增自动门禁与唯一组合根例外；测试新增 data/domain→ui 禁止并扩展 View 平台插件列表。

### ENG-07：公共仓库治理文件缺失（P3，已关闭）

当前 Git 跟踪文件中没有 LICENSE、SECURITY.md、CONTRIBUTING.md、CHANGELOG.md、CODE_OF_CONDUCT.md。README 却明确邀请贡献。建议至少补许可证、漏洞报告渠道、开发/测试/迁移约定和用户可见变更日志；provider 与数据库变更尤其需要 release note。

整改：已添加 MIT `LICENSE`、私密漏洞报告和时效约定、包含 l10n/架构/数据库/provider/release note 规则的贡献指南、`CHANGELOG.md` 以及 Contributor Covenant 2.1 行为准则；README 提供统一入口。

### ENG-08：本地构建缓存体积较大（P3，已关闭）

审计环境中仓库目录约 3.2 GB，其中 `build/` 约 2.1 GB、`.dart_tool/` 约 933 MB；两者均被 `.gitignore` 排除且没有被 Git 跟踪，不属于仓库污染。可在开发文档增加按需 `flutter clean`、CI cache key 和磁盘排障说明，避免每次 CI 无差别缓存整个 build 目录。

整改：README 已区分可安全再生的 `build/` 与 `.dart_tool/`，说明 `flutter clean`、深度清理和 enforce-lockfile 恢复步骤；仓库不跟踪这些目录，也未配置仓库级 CI 构建缓存。

## 9. 测试与验证缺口

当前测试数量可观，但需要补的是“风险导向”的覆盖，而不是继续堆普通 widget 断言。

| 风险面 | 当前覆盖 | 建议新增 |
| --- | --- | --- |
| 数据库版本 | 已覆盖当前 Schema 精确快照、当前库重开、任意非当前版本删除并重建 | 增加空文件、损坏库和未来版本的重置覆盖 |
| 跨资源写入 | 已覆盖 Bot+Skill transaction、Bot+Chat 文件 rollback、MCP credential 读写删与数据库故障注入 | 进一步增加进程中断后的持久化 recovery journal 测试 |
| 附件/媒体 | 已覆盖同名文件、扩展名、批次回滚、overall timeout 和取消 | 增加目录只读和媒体任务重启恢复 |
| 桌面 UI | 大量 widget/semantics 测试 | golden、焦点 traversal、context menu 键盘入口、多语言溢出、三个 breakpoint |
| 架构规则 | 已检查 UI→data、View→plugin、data/domain→ui、组合根白名单和桌面组件 | 新例外必须在架构文档说明边界和退出计划 |
| Provider | 多个 adapter 单测和 catalog test | 统一 contract test：timeout、typed error、取消、非法 JSON、usage-only event、secret redaction |
| 长会话性能 | 已覆盖稳定 cursor、同时间戳、窗口增长和前页连续性；尚无基准 | 1k/10k 消息的读取、首帧、滚动、内存和压缩 benchmark |
| 正式构建 | 本地 analyze/test | Linux/Windows/macOS 至少 build smoke；签名前校验 bundle ID、权限和 secure storage |

## 10. 建议治理路线

### 阶段 A：数据安全与立即止损（1 个迭代）

1. 已移除会触发 MCP 局部 reset 的迁移和所有历史升级逻辑；非当前版本直接整库删除。
2. 固化 v17 Schema 快照和版本重置契约。
3. 修复附件命名、复制失败反馈和稳定消息排序。
4. 将已退场 provider 从新建入口隐藏；历史 Bot 显示迁移说明。
5. 为媒体 HTTP 增加统一超时和取消，不再使用不可退出的无限等待。

### 阶段 B：业务事务与错误模型（1–2 个迭代）

1. 引入 Create/Update/DeleteBot、Save/DeleteMcpServer、GenerateMediaTurn use case。
2. 对 SQLite 内多表写入使用事务；对文件/安全存储使用 stage/commit/rollback/recovery journal。
3. 建立 typed failure 和统一 inline error/toast 规则，覆盖 Bot/MCP/Skill/Chat。
4. 为每个 fault point 编写失败注入测试。

### 阶段 C：桌面设计系统收敛（1–2 个迭代）

1. 确认当前 6–8px 桌面视觉方向，更新过期 Spec 和组件 matrix。
2. 统一 Shad 菜单、按钮、弹窗、错误、图标和命中区；Material 仅保留移动端或基础布局能力。
3. 把直接颜色/圆角迁入 semantic tokens，完成后删除 compatibility facade。
4. 建立 6 个核心页面、3 个宽度、3 种主题、2 种语言的 golden 基线。

### 阶段 D：性能与工程化（持续）

1. 消息分页、Bot 指标批量查询、模型元数据 TTL cache 和并发限制。
2. 按职责拆分 1000+ 行热点文件，先移副作用、后拆 Widget。
3. 已配置架构依赖测试、当前 Schema 契约测试和 desktop build smoke 的本地入口；仓库级 CI 已移除。
4. 已清理候选依赖、统一 l10n 生成、替换平台占位 ID 并补齐治理文件。

## 11. 完成定义与复核指标

建议用以下可量化条件判断治理是否完成：

- 新数据库只创建 v17 Schema；v17 数据库经检查与备份后重开；更旧版本删除数据库和关联会话数据后创建空的 v17 Schema，更高版本明确拒绝降级。
- 数据库、文件、安全存储任一步失败后，要么全部回滚，要么 recovery journal 能在下次启动完成恢复。
- 媒体请求都有 overall timeout 和取消路径；导航不再被无限期阻断。
- `lib/ui/**` 除组合根外不导入 `lib/data/**`，View 不直接 import 平台插件。
- 桌面交互组件全部来自约定 matrix；图标 action 命中区、焦点环、tooltip、semantics 有统一测试。
- 关键桌面 golden 在 light/dark/high-contrast、中文/英文、1024/1280/1600 下稳定。
- CI 的 analyze、format、test、Schema/version policy、architecture test 和 desktop build 全部为必过。
- 生产代码中不再有承担多个业务流程的 1500+ 行 View；长会话 10k 消息的首屏读取不随总历史线性加载。

## 12. 审计方法、限制与待确认项

### 方法

- 盘点 Git 跟踪文件、Dart 文件规模、依赖、文档和平台工程。
- 执行 `dart analyze`、`flutter test`、README 中的 format check。
- 按桌面 UI、依赖方向、异步状态、文件副作用、SQLite schema/迁移、历史记录 decode、Provider HTTP、测试与发布配置进行静态追踪。
- 对每项结论标记“已确认”“设计风险”“缺口”“候选”，避免把推测写成已发生故障。

### 本地验证结果

| 检查 | 结果 |
| --- | --- |
| `git status --short`（审计前） | clean |
| `dart analyze` | 通过，No issues found |
| `flutter test` | 通过，432 tests |
| `dart format --output=none --set-exit-if-changed .` | 失败；9 个 `lib/generated` 文件与 formatter 输出不一致 |
| 生产 Dart（排除 generated） | 约 69,245 行 |
| 测试 Dart | 约 26,505 行 |
| Git 跟踪文件 | 581 |

### ENG-02 至 ENG-08 本地整改复核（2026-08-14）

| 检查 | 结果 |
| --- | --- |
| `flutter pub get --enforce-lockfile` | 通过 |
| `dart run tool/sync_localizations.dart --check` | 通过；12 个 catalog 均为 485 个消息键 |
| `dart run intl_utils:generate` 二次重生成 | 通过；14 个生成 Dart 文件 checksum 无变化 |
| `dart run tool/check_format.dart` | 通过；391 个非生成 Dart 文件无格式漂移 |
| `dart analyze --fatal-infos` | 通过，No issues found |
| `flutter test` | 通过，513 tests |
| `flutter build linux --release` | 通过，生成 x64 release bundle |
| `git diff --check` | 通过 |

### 限制

- 未连接真实 OpenAI/Anthropic/国内外 provider 账号，因此 provider 的外部可用性沿用仓库 2026-08-03 专项审计，仍需发布前联调复核。
- 未在真实 Windows/macOS/Linux 窗口中进行截图和辅助技术测试；UI 结论来自组件树、token、widget tests 和代码路径。
- 未运行覆盖率工具和 1k/10k 消息性能 benchmark，因此性能项标记为设计风险或缺口，没有伪造百分比/耗时。
- 原审计未实际制造用户数据库迁移失败；整改后不再伪造历史 Schema，只用更旧版本数据库验证原始记录和关联会话目录被删除并创建完整 v17 Schema。

### 待产品/维护者确认

1. 当前按测试阶段决策自动删除非当前版本数据库；进入正式发布前是否继续采用该策略，需要再次确认。
2. 当前决策不提供旧库离线导出或恢复能力；如需改变，必须作为新的显式能力单独立项。
3. 会话删除后 token usage 被保留到删除 Bot 是明确产品需求，还是历史实现？现有测试将其视为预期行为。
4. 草稿是否需要跨重启恢复？答案会决定 DraftRepository 使用内存、有界临时目录还是 SQLite。

本轮已确认两项工程决策：桌面继续采用紧凑 6–8px 视觉基线；正式应用标识与安全存储命名空间为 `io.github.locallocal.stars`。
