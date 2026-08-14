# Flutter 工程与 UI 一致性审计（2026-08-14）

## 1. 结论摘要

本次审计覆盖当前工作树中的 Flutter/Dart 生产代码、测试、工程配置、架构约束、桌面组件规范与
本地化资源。对“UI 上是不是有不统一”的结论是：

- 仓库已经建立了较完整的桌面设计系统，包括 Shad 组件入口、语义 token、44px 图标操作、
  Sonner/SnackBar 统一通知和 18 张桌面视觉基线；因此不是全局性的 UI 失控。
- 不一致主要集中在同时承载移动端与桌面端的通用文件。这些文件没有被当前的桌面静态门禁覆盖，
  已出现桌面圆角绕过 token、音频控件绕过唯一组件、移动端点击区域过小和无障碍标签缺失。
- 当前工程基线不可交付：`file_picker 12.0.0-beta.7` 的 API 与代码不兼容，导致静态分析出现
  4 个编译错误，并使 9 个测试文件在加载阶段失败。UI golden 也因此无法重新执行。
- 分层方向总体正确，15 项架构测试通过；但部分 ViewModel 已承担跨资源事务、依赖组装和异步
  生命周期管理，实际职责超过仓库自身定义的 MVVM 边界。

建议先解决唯一的 P0 编译阻断，再处理异步生命周期和桌面组件门禁；在这两类问题解决前，
“架构测试通过”和“已有 golden”都不足以证明当前版本可发布。

## 2. 审计范围与基线

| 项目 | 基线 |
| --- | --- |
| Git 基线 | `0bea02f` (`main`) |
| Dart 文件 | 405 个（`lib`、`test`、`integration_test`、`tool`） |
| 非生成生产代码 | 约 71,346 行 |
| 测试与集成代码 | 约 29,851 行 |
| 目标平台 | Windows、macOS、Linux、Android、iOS；README 未声明 Web |
| UI 规范 | `docs/desktop_component_matrix.md`、`docs/specs/windows_linux_desktop_style_adjustment_spec.md` |
| 架构规范 | `docs/architecture.md` |

审计开始时工作树已有以下未提交状态，本次审计不恢复或修改它们：

- `docs/repository_audit_2026-08-12.md` 已删除；
- `pubspec.lock` 已修改（`intl`、`matcher`、`meta`、`test_api`、`vector_math` 等版本变化）。

因此测试结论反映的是当前本地工作树和 Flutter 3.44.6 环境，而不是纯净的 `HEAD`。
本报告仅新增本文档，不修复生产代码。

## 3. 验证结果

| 检查 | 结果 | 说明 |
| --- | --- | --- |
| `dart analyze --fatal-infos` | **失败** | 4 个 error、4 个 info；4 个 error 均为 `FilePicker.platform` 不存在 |
| `flutter test --no-pub test/architecture` | **通过** | 15 项架构与发布配置测试通过 |
| `flutter test --no-pub` | **失败** | 已执行的 402 项测试通过；另有 9 个测试文件因同一编译错误无法加载 |
| `dart run tool/sync_localizations.dart --check` | **通过** | 本地化资源保持同步 |
| `dart format --output=none --set-exit-if-changed ...` | **条件通过** | 405 个文件中仅生成文件 `lib/generated/l10n.dart` 会被格式化；非生成源码未发现漂移 |
| 桌面 golden 复验 | **被阻断** | 全量测试在编译阶段失败，本次不能确认 18 张基线与当前实现一致 |

说明：`flutter test` 输出中的 402 是失败终止前已执行通过的测试数量，不能理解为全量测试总数。

## 4. 问题清单

优先级定义：P0 为阻断构建/发布；P1 为高概率缺陷或架构门禁失真；P2 为应排期治理；P3 为低风险债务。

### FLT-01（P0）依赖升级后仍调用已移除的 FilePicker API

**证据**

- `pubspec.yaml:49` 使用 `file_picker: ^12.0.0-beta.7`；
- `lib/data/repositories/platform_message_action_repository.dart:33`；
- `lib/data/services/attachment_picker_service.dart:56`；
- `lib/data/services/skills/skill_picker_service.dart:8,17`；
- 分析器均报 `Member not found: 'FilePicker.platform'`；
- `platform_message_action_repository.dart:46` 同时使用已废弃的 `Share.shareXFiles`。

**影响**

应用、widget tests 和 golden tests 无法完成编译，其他 UI 与业务回归也被遮蔽。

**建议**

1. 明确选择稳定版/兼容版 `file_picker`，或按 12.x API 一次性迁移三个适配器；
2. 同步迁移到 `SharePlus.instance.share(...)`；
3. 为文件选择、目录选择、保存和分享的 repository/service adapter 增加编译型单元测试；
4. 修复后先执行 analyzer，再执行全量测试和桌面 golden，避免用局部测试代替构建验证。

### ARC-01（P1）MCP ViewModel 承担跨资源事务与回滚

**证据**

`lib/ui/features/mcp/view_models/mcp_servers_view_model.dart:121-232` 的 `saveAndConnect` 同时负责：

- transport 和环境变量业务校验；
- 读取、写入并回滚凭据；
- 保存 MCP server；
- 发布本地状态；
- 触发远端发现并区分 warning/error。

`deleteServer`（268-300）也协调 catalog、credential store、repository 和回滚。仓库架构文档把
“跨步骤或可复用业务规则”定义在 Use Case，把事务协调定义在 Repository；ViewModel 应主要
暴露不可变 UI 状态和用户命令。

**影响**

UI 状态、持久化一致性和远端连接策略耦合在 389 行的 ViewModel 内，页面生命周期、错误展示和
事务正确性很难分别测试；未来添加认证类型或连接策略时容易产生部分提交。

**建议**

提取 `SaveAndConnectMcpServer`、`DeleteMcpServer`（或统一 application service），用明确结果类型
返回 committed/warning/failure。ViewModel 只负责 busy/error/warning 状态映射。

### STATE-01（P1）异步 ChangeNotifier 缺少统一的销毁后保护

**证据**

以下代码在 `await` 后或 `finally` 中直接修改状态并 `notifyListeners()`，没有 disposed/cancel token：

- `feedback_view_model.dart:16-34`；
- `legal_document_view_model.dart:25-45`；
- `conversation_memory_view_model.dart:41-86`；
- `mcp_servers_view_model.dart:92-118,303-331`。

静态扫描发现 12 个同时包含异步命令和通知、但没有 `_disposed`/`_isDisposed` 标记的 UI
ChangeNotifier 文件。部分 ViewModel 使用 generation token 处理请求乱序，但 generation token
并不等价于销毁保护。

**影响**

页面在请求期间关闭或应用依赖树销毁时，异步回调仍可能发布状态；debug 模式下可能触发
“disposed ChangeNotifier”断言，release 下也会留下无效状态写入和竞态。

**建议**

- 建立统一的 `DisposableChangeNotifier`/异步命令策略，或在每次 await 后检查有效 generation
  与 disposed 状态；
- dispose 时取消 stream/subscription 和可取消任务；
- 增加“发起请求 → dispose → 完成 future”测试，覆盖成功、失败和 finally 三条路径。

### UI-01（P1）桌面设计门禁存在文件名盲区，已经漏掉真实不一致

**证据**

`test/architecture/model_layering_test.dart:124-166` 只扫描路径含 `/desktop_`、文件名以
`_desktop.dart`/`_desktop_card.dart` 结尾，以及两个 Skill 文件。以下通用响应式页面不会进入扫描：

- `message_input.dart:220`：桌面输入容器直接使用圆角 12；
- `profile.dart:889,904`：桌面设置项直接使用圆角 14/12；
- `message_list_bubble.dart:315,360,426,585`：在业务文件中直接定义桌面圆角 8/6；
- `tool_approval_card.dart:144`：直接定义桌面圆角 7。

这与 `desktop_component_matrix.md:22-30` 中“业务视图不定义产品圆角、统一来自
StarsDesktopThemeSpec”的规则不一致，但现有 15 项架构测试仍全部通过。

此外，`audio_player_widget.dart` 被显式加入 `ShadIconButton` 白名单，却使用 48×48 的
`ShadIconButton` 和 Material `Icons.pause/play_arrow`（155-166）；规范要求统一使用 44×44 的
`StarsDesktopIconAction` 和 Lucide 图标。该例外没有在组件矩阵中记录退出计划。

**影响**

门禁提供了错误的通过信号。通用文件越多，桌面视觉 token、交互尺寸和图标体系越容易分叉。

**建议**

1. 门禁覆盖所有包含桌面分支的 UI 文件，而不是依赖文件名；更稳妥的做法是把桌面实现拆入可枚举
   的 desktop part/widget；
2. 将上述圆角提升为 `StarsDesktopThemeSpec` 语义值；
3. 删除音频控件白名单，迁移到 `StarsDesktopIconAction`；确需例外时在规范中写明原因和退出条件；
4. 为门禁增加一个故意放入通用文件的违规 fixture，证明测试能失败。

### UI-02（P1）移动端点击目标与无障碍名称不完整

**证据**

- `message_input.dart:920-927` 把移动端圆形 IconButton 的最小/最大尺寸都固定为 34×34，且使用
  `MaterialTapTargetSize.shrinkWrap`，低于 Material 常用的 48×48 最小触摸目标；
- `bots.dart:210-213` 和 `chats.dart:104-107` 的 AppBar 新增按钮没有 tooltip/semanticLabel；
- `attachment_bars.dart:47-50,75-78,103-106` 的三个 IconButton 没有 tooltip；视觉文本是按钮的
  兄弟节点，不能保证读屏时成为按钮名称；
- `audio_player_widget.dart:174-183` 的移动端播放按钮没有 tooltip/semanticLabel。

**影响**

小屏和运动控制困难用户更容易误触；读屏用户可能只听到“button”而不知道动作。桌面统一组件已经
处理 Tooltip、Focus 和 Semantics，但移动端没有同等约束。

**建议**

- 视觉图标可以保持 34px，但可点击区域至少扩展到 48×48；
- 所有纯图标按钮提供本地化 tooltip/semanticLabel；
- 增加 semantics widget tests，断言按钮角色、名称、enabled 状态和点击区域。

### ARCH-02（P2）ChatViewModel 在构造器中组装 Use Case，依赖面过大

**证据**

`chat_view_model.dart:21-62` 接收多个 repository、inventory、registry 和其他 ViewModel，并在构造器
内部创建 `PersistConversationAssets`、`GenerateMediaTurn`、`CreateUserMessage`。生产依赖组合本应由
`AppDependencies` 完成。

**影响**

构造器测试替身多，生命周期归属不清；Use Case 的替换、缓存和 telemetry 策略无法在组合根统一。

**建议**

由组合根创建并注入全部 Use Case；把 message action 和 generation 之间的协调收敛为明确 facade，
降低 ChatViewModel 的 repository 直连数量。

### STATE-02（P2）“不可变 UI 快照”只在部分 ViewModel 中成立

**证据**

架构文档要求 ViewModel 对列表状态使用不可变快照，但多个公开 getter 直接返回 `List<T>`：

- `chat_view_model.dart:89,116-119`；
- `conversation_memory_view_model.dart:36,48-51`；
- `mcp_servers_view_model.dart:62,98-105`；
- `chat_list_view_model.dart:31-33`；
- `skill_library_view_model.dart:61-62,89`。

部分写入路径会使用 `List.unmodifiable`/`toList(growable: false)`，部分直接保存 repository 返回值，
接口层没有强制不可变性，行为不一致。

**影响**

调用方可以在不触发通知的情况下修改列表，导致 UI 与缓存状态悄悄分叉；是否安全取决于 repository
恰好返回何种列表实现。

**建议**

统一在状态发布边界复制为不可变列表，或返回 `UnmodifiableListView`/不可变 state object；用测试
断言外部修改失败且旧快照不会随新加载变化。

### UI-03（P2）仍有绕过 l10n 的用户可见文本

**证据**

- `stars_app.dart:64,71,208,213`：启动、失败和重试固定为中文；
- `audio_player_widget.dart:155`：桌面播放/暂停 tooltip 固定为中文；
- `video_player_widget.dart:45,70`：视频错误固定为中文；
- `common.dart:15,18`：数据库兼容性错误固定为中文；
- `message_list_process.dart:809-814`：持续时间直接拼接 `ms`/`s`，没有 locale-aware 格式。

语言名称、Markdown 语法标题和 debug 日志不计入此问题。资源同步检查已经通过，问题是调用点没有使用
现有本地化入口，而不是 ARB 键缺失。

**影响**

非中文 locale 会在启动、媒体播放和数据库异常等关键路径看到混合语言；时长缩写也无法按语言调整。

**建议**

为 bootstrap shell 提供可在 Profile 加载前使用的平台 locale 文案；其余文本进入 `S` 资源。时长由
本地化方法接收数值和单位，不在 View 内拼接英文缩写。

### UI-04（P2）视觉矩阵覆盖代表宽度，但没有验证断点边界

**证据**

- 实际布局断点是 960、1200、1500（`desktop_layout.dart:218-271`）；
- golden 只覆盖 1024、1280、1600（`desktop_visual_regression_test.dart:27`）；
- 现有矩阵覆盖 light/dark/high contrast 和 zh_CN/en，共 18 张组合图、108 个场景；
- 全仓只有一处明确的 2× text scale 页面测试，位于 `widget_test.dart:4123-4159`，主要覆盖 Add Bot。

**影响**

959/960、1199/1200、1499/1500 的模式切换、overlay/inspector 行为和文本溢出可能回归，而代表宽度
golden 仍保持通过。移动端、大字体和长翻译的组合覆盖也明显少于桌面正常字体。

**建议**

- 用行为型 widget tests 覆盖每个断点的前一像素、断点值和后一像素，不必把所有边界都扩成 golden；
- golden 保留代表宽度，新增至少一个窄移动端和一个 2× text scale 的关键流程；
- 将最长翻译或伪本地化加入表单、AppBar、消息输入和弹窗溢出测试。

### PERF-01（P2）MCP 桌面列表使用嵌套 shrinkWrap Grid

**证据**

`mcp_servers_page.dart:97` 使用外层 `SingleChildScrollView`，内部
`GridView.builder`（273-282）设置 `shrinkWrap: true` 和 `NeverScrollableScrollPhysics`。

**影响**

Grid 会为完整列表计算高度并倾向于一次构建所有卡片；MCP server 数量增加后，builder 的懒加载收益
消失。当前 Skill 页的类似结构受分页限制，而 MCP 页没有同等的显式上限。

**建议**

改为 `CustomScrollView` + `SliverGrid`/`SliverList`，让标题、状态和列表共享一个滚动视口；或为数据量
设置分页/虚拟化上限。

### SIZE-01（P2）1000 行门禁避免了极端文件，但未形成可维护的职责边界

**证据**

排除生成代码后仍有 15 个生产文件达到 750 行以上，其中包括：

- `compose_chat_turn.dart` 997 行；
- `profile.dart` 980 行；
- `message_input.dart` 954 行；
- `conversation_memory_panel.dart` 930 行；
- `desktop_layout.dart` 845 行；
- `chat_generation_view_model.dart` 835 行；
- `chat.dart` 827 行；
- `message_list_process.dart` 815 行；
- `agent_run_coordinator.dart` 794 行；
- `message_list_bubble.dart` 782 行；
- `skill_library.dart` 779 行；
- `theme_components.dart` 777 行；
- `mcp_server_editor.dart` 771 行。

`widget_test.dart` 约 4,606 行。当前架构测试只验证每个生产文件不超过 1000 行，因此 997 行仍是“通过”。

**影响**

大文件同时包含状态、布局和交互分支，正是 UI token 漏扫和生命周期问题容易隐藏的区域；单体测试文件
也增加定位和并行执行成本。

**建议**

不要机械降低行数阈值，优先按职责拆分：页面壳/section/widget、command/state、协调器/策略、
测试 feature group。为复杂度、构造依赖数量和 build method 规模补充 review checklist。

### QUAL-01（P3）分析器仍有 4 个非阻断信息项

除 FLT-01 的 4 个 error 外：

- `platform_message_action_repository.dart:46` 有 2 个 `Share.shareXFiles` 废弃提示；
- `compact_conversation.dart:69` 使用不必要的多下划线参数；
- `dot_curved_bottom_nav.dart:204` 缺少类型注解。

仓库要求 `--fatal-infos`，因此这些 info 即使不影响编译也会让质量命令失败。建议随 P0 一并清零。

### GOV-01（P2）质量命令有文档但没有自动执行入口，文档仍残留 CI 描述

**证据**

- `.github/` 目前只有 `dependabot.yml`，没有 workflow；
- README 已列出 lockfile、analyzer、test、release build 的手动命令；
- `pubspec.yaml:134` 仍写着生成本地化代码“verified by CI”；
- 当前依赖编译错误和生成文件格式差异没有自动阻止进入工作树。

如果移除 CI 是明确的仓库策略，这不是功能 bug，但属于需要接受的发布治理风险。

**建议**

至少提供一个本地 `tool/verify.dart` 或 Make target，顺序执行 enforce-lockfile、format、analyze、
architecture、unit/widget、golden 和目标平台 build；发布前保存可审计结果。同步删除或改写过期的 CI 文案。

## 5. 已符合最佳实践的部分

- Domain model 不依赖 Flutter/data/UI，data/domain 不反向依赖 UI；对应架构测试通过。
- UI 访问 data implementation 仅通过 `AppDependencies` 组合根，文件/图片选择、分享等动作已下沉到
  repository/service adapter。
- 桌面端已有清晰的 Shad 组件矩阵、语义 token、统一通知入口和高对比度主题约束。
- `showStarsNotice` 集中封装 Sonner 与 SnackBar，业务 UI 没有直接散落两套瞬时通知实现。
- 已有 1024/1280/1600 × light/dark/high contrast × zh_CN/en 的 18 张 golden 资产，覆盖
  108 个桌面场景组合。
- 本地化资源同步检查通过，12 个已生成 locale 的键结构保持一致。
- 多处动画尊重 `MediaQuery.disableAnimationsOf`，Add Bot 已有 2× text scale 回归测试。
- ViewModel 普遍把异常转换为 `AppFailure`，而不是把原始异常直接交给页面。

## 6. 推荐整改顺序

### 第一阶段：恢复可验证基线（立即）

1. 修复 FLT-01 并清除全部 analyzer error/info；
2. 全量测试、桌面 golden 和至少一个目标平台 build 全部通过；
3. 固化 `pubspec.lock` 与 Flutter SDK 版本，确认本地脏 lockfile 是否应提交。

### 第二阶段：补强正确性门禁（1 个迭代）

1. 迁移 MCP 跨资源事务到 Use Case/application service；
2. 统一异步 ViewModel 的销毁与竞态策略，并补 lifecycle tests；
3. 强制不可变列表快照；
4. 扩大桌面组件静态门禁，使通用响应式文件也受约束。

### 第三阶段：统一 UI 与回归矩阵（1—2 个迭代）

1. 收敛桌面圆角、音频图标操作和媒体错误状态；
2. 修复 34px 触摸目标与纯图标按钮语义；
3. 清理用户可见硬编码文本；
4. 增加断点边界、窄移动端、大字体和长翻译测试；
5. 把 MCP 列表迁移为 sliver/虚拟化布局。

### 持续治理

- 按职责拆分接近 1000 行的生产文件与 4600 行的 widget test；
- 以单一验证脚本替代依赖个人记忆的命令集合；
- 任何组件白名单都记录原因、负责人和退出条件。

## 7. 完成标准

整改完成应同时满足：

- `dart analyze --fatal-infos` 零诊断；
- 全量 `flutter test --no-pub` 与桌面 golden 通过，不再有测试文件加载失败；
- 目标发布平台至少一次 release build 通过；
- 通用响应式文件中的桌面分支也能被 token/component 门禁捕获；
- 所有纯图标按钮有本地化无障碍名称，移动端触摸目标不小于 48×48，桌面动作遵循 44×44 规范；
- 断点 960/1200/1500 的边界行为、2× text scale 和窄移动端关键流程有自动测试；
- ViewModel 在异步任务完成前被 dispose 时不会再发布状态；
- 对外暴露的列表状态不能由调用方修改；
- 用户可见启动、媒体、数据库错误和时长文本不再绕过 l10n。

## 8. 审计限制

本次没有修改业务代码，也没有在真实 Windows/macOS/Linux/Android/iOS 设备上做人工交互验收。
由于 FLT-01 阻断编译，现有 golden 和集成流程无法复验；因此 UI 判断来自源码、现有规范、测试资产和
静态检查。修复 P0 后仍需进行一次真实渲染与键盘/读屏验收，才能关闭 UI 一致性与无障碍问题。
