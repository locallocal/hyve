# 项目优先的多智能体协作设计

> 状态：Phase 5 已完成（2026-08-22），可以进入 Phase 6。
>
> Phase 0 决策基线见第 16 节。后续若修改基线，必须同步更新对应策略默认值、数据契约和验收项。
>
> 本文定义下一版项目、智能体、消息路由、协作交付、项目产物存储和智能体长期记忆的目标架构。
> 实施时直接创建新结构，不迁移、不兼容现有项目、消息和 Memory 数据。

## 1. 目标

Hyve 的核心交互从“选择一个智能体开始聊天”调整为“进入一个项目，由项目中的多个智能体
共同工作”。项目与智能体是两个独立生命周期的领域对象：

- 项目拥有成员关系、用户与智能体之间的对话消息、运行记录和独立产物存储空间；
- 智能体拥有身份、模型配置、系统提示词、技能绑定、MCP 能力和跨项目长期记忆；
- 项目只引用智能体，不复制或拥有智能体；
- 删除项目只删除项目数据，不删除智能体及其技能、配置和长期记忆；
- 项目可以暂时没有智能体，之后再添加，不再因为最后一个智能体被移除而删除项目；
- 同一个智能体可以同时加入多个项目，并以同一身份、技能和长期记忆工作。

目标交互如下：

```text
用户进入项目
  -> 用户或智能体产生一条带项目 messageSequence 的新消息
  -> 每个智能体维护自己的 lastProcessedMessageSequence
  -> 同一智能体严格从旧到新串行处理尚未处理的可见消息
       -> 带结构化 @：只有被 @ 的智能体回复，其他智能体观察后推进游标
       -> 不带 @：广播给全部活跃成员，各自判断 reply / pass
       -> 回复必须锚定当前处理的某条消息，只使用该消息及之前的可见消息
  -> 智能体回复期间，用户仍可输入，其他智能体仍可处理和回复
  -> 回复期间到达的新消息排在该智能体队尾，当前回复完成后继续追赶
  -> 智能体可通过结构化交付把信息或任务发送给另一个项目成员
  -> 所有智能体最终把自己的处理游标追到项目最新消息索引
```

## 2. 范围与非目标

### 2.1 本次调整范围

- 重建 Project、Agent、ProjectMembership、ProjectTurn、ProjectEvent、AgentRun 等领域模型；
- 重建项目和智能体配置/运行相关 SQLite 表，不处理历史数据；AgentMemory 正文、元数据和向量
  只进入文件系统或外部向量库；
- 支持项目成员添加、移除、排序、暂停和项目存储权限配置；
- 支持明确 `@` 路由与无 `@` 广播路由；
- 支持项目消息全局递增索引，以及每个智能体独立、持久化的顺序消费游标；
- 支持智能体之间的结构化信息交付；
- 建立项目独立产物存储空间，以及受权限约束的检索、读取和写入工具；
- 把现有 conversation memory 调整为仅从会话消息派生的摘要/上下文压缩数据；项目不拥有
  Memory item，长期记忆只属于智能体；
- 调整项目工作区、消息输入、群聊消息流和运行状态展示；
- 重构当前只能承载单个可变智能体的生成协调逻辑。

### 2.2 保持不变的产品能力

以下页面和管理流程在功能与导航上保持不变，只允许为适配新领域命名和 Repository 接口做
内部调整：

- “我的”页面、个人资料、主题和语言设置；
- 智能体添加、编辑、删除、查询；
- 智能体模型、服务商、系统提示词和多模态配置；
- Skill 安装、更新、查询、删除和管理页面；
- 智能体与 Skill 的绑定管理；
- MCP Server 添加、编辑、删除、连接和工具查询；
- 智能体的 MCP Server、MCP Tool 配置；
- 反馈等其他非项目功能。

Skill 包继续由全局 Catalog 管理，MCP Server 继续由全局 MCP 管理页管理。一个智能体的
“独特技能”由它自己的 Skill 绑定集合定义，不为每个项目复制 Skill 包。项目策略只能缩小
智能体已有能力，不能为智能体静默扩大 Skill 或 MCP 权限。

### 2.3 非目标

- 不迁移 `chats`、`chat_projects`、`messages`、`conversation_memory_*` 等旧数据；
- 不保留旧 `Chat`/`Bot` 数据模型的运行时兼容层；
- 不在本轮设计中改变 AI Provider 协议实现和现有 Skill/MCP 管理产品形态；
- 不允许智能体直接访问任意系统目录、其他项目空间或其他智能体的记忆空间；
- 不让自由文本决定工具权限、存储权限或成员权限。

## 3. 现有实现与目标的差距

当前实现已经具备项目成员表、消息目标 ID、Skill 绑定、MCP 工具和项目级上下文压缩，能复用
其中的 Provider、Tool Registry、Skill 和 MCP 基础能力，但交互主干仍然是单智能体会话。

| 当前实现 | 问题 | 目标调整 |
| --- | --- | --- |
| `Chat` 同时代表会话和项目，`Project` 只是 `Chat + Bots` 包装 | 项目没有独立聚合和生命周期 | 以独立 `Project` 为聚合根，消息直接归属项目 |
| 项目必须至少包含一个 Bot | 最后一个智能体移除后项目无法存在 | 项目允许零个活跃成员 |
| 输入没有有效 `@` 时拒绝发送 | 无法广播 | 无 `@` 自动进入广播判断阶段 |
| 多个目标通过替换 `ChatWorkflowFacade._bot` 串行回复 | 共享可变状态，无法安全并发或独立取消 | 每个 AgentRun 持有不可变 Agent 快照和独立会话 |
| `ChatGenerationRegistry` 只用 `chatId` 保存一个运行实例 | 同项目多智能体运行互相覆盖 | ProjectTurn 协调多个以 `runId` 标识的 AgentRun |
| `target_bot_ids` 是消息中的 JSON 字段 | 目标查询、约束和交付关系较弱 | 使用规范化 `project_event_targets` |
| `conversation_memory_items` 把项目摘要和“记忆事实”混在一起 | 项目被赋予了不明确的记忆语义 | 项目只保留消息及可重建的 ConversationSummary；长期记忆只属于 Agent |
| 文件位于 `chats/<chatId>` | 项目空间、附件、产物边界不明确 | 使用 `projects/<projectId>/artifacts` 持久化用户和 Agent 产物 |
| 删除唯一 Bot 会连带删除项目 | Agent 与 Project 生命周期耦合 | 删除/移除成员不删除项目；删除项目不影响 Agent |
| `@名称` 在发送时通过正则重新解析 | 重名、改名和富文本编辑容易产生歧义 | 输入框保存 mention span 与稳定 `agentId` |
| 没有每个 Agent 的已处理消息索引 | 回复期间到达的新消息可能丢失、插队或污染当前上下文 | 为每个 Project-Agent 保存连续处理游标和逐消息 receipt |
| 一个 chatId 只能表示一个活跃生成状态 | 用户输入和其他 Agent 容易被当前回复阻塞 | 同 Agent 串行、不同 Agent 并行，消息写入与生成生命周期解耦 |

## 4. 术语与领域边界

### 4.1 Project

项目是工作内容和协作上下文的容器，拥有：

- 项目名称、界面元数据和响应策略；
- 当前成员及每个成员在该项目中的权限；
- 用户与智能体之间按顺序保存的对话消息和项目事件流；
- ProjectTurn、AgentRun、工具调用和 Token 用量；
- 用户添加的产物、消息附件、智能体生成产物及其版本；
- 从对话消息派生、用于缩短上下文的 ConversationSummary。

Project 没有长期记忆，也不保存独立的项目事实、偏好、目标、决策或术语 Memory item。
ConversationSummary 只是消息历史的有损压缩视图，必须能由源消息重新生成，不能被当作独立
事实来源。需要长期保留并供协作使用的文档、代码、数据或其他内容，应由用户或 Agent 写入
项目产物空间；需要跨项目演化的记忆只写入 AgentMemory。

Project 不拥有 Agent。项目删除后，成员关系失效，项目事件和项目存储被删除，但 Agent 记录
及 AgentMemory 不参与级联删除。

### 4.2 Agent

智能体是跨项目存在的独立个体，拥有：

- 稳定 ID、名称、头像和身份说明；
- Provider、模型、系统提示词和生成参数；
- 输入/输出模态和上下文窗口等能力；
- Skill 绑定与激活策略；
- MCP Server、MCP Tool 配置和授权；
- 跨项目长期记忆、记忆版本和私有记忆文件空间。

实施时领域模型统一使用 `Agent`，替换语义含混的 `Bot`。产品界面仍使用“智能体”，不改变
用户已有的添加、编辑、删除和查询入口。

### 4.3 ProjectMembership

成员关系是 Project 与 Agent 之间的关联，不是二者任一方的内嵌列表。它至少包含：

- `projectId`、`agentId`；
- `status`：`active | paused | removed`；
- `position`：群聊和回复的稳定展示顺序；
- `projectStorageAccess`：`none | read | readWrite`；
- `joinedAt`、`removedAt`；
- 可选的项目级能力限制，但只能缩小 Agent 已有权限。

移除成员只把关系改为 `removed` 并写入成员变更事件，不修改 Agent。重新添加同一 Agent 时
恢复关系并产生新的变更事件。历史消息保存发送时的名称和头像快照，不依赖当前成员状态。

### 4.4 ProjectTurn

ProjectTurn 表示一条可处理消息的直接分发范围。用户消息、公开 Agent 消息或 AgentDelivery
进入项目后，各自建立一个 ProjectTurn；它负责这条消息对项目成员的路由、运行集合、取消和
最终状态，不等同于某个 Agent 的一次模型调用。

一个 Agent 对该消息的回复会成为具有新 `messageSequence` 的消息，并建立新的 ProjectTurn。
通过 `replyToMessageId` 和 `rootTurnId` 可以把这些 Turn 关联为一条对话链。多个 ProjectTurn
允许同时处于活跃状态，但同一个 Agent 在同一个 Project 中一次只处理其中最早的一条未处理
消息。

### 4.5 ProjectEvent

ProjectEvent 是项目内按顺序记录的事实。事件类型包括：

- `userMessage`：用户发送的群聊消息；
- `agentMessage`：智能体公开回复；
- `participationDecision`：广播时智能体的 `reply/pass` 判断；
- `agentDelivery`：智能体向其他智能体交付信息或任务；
- `membershipChanged`：成员添加、暂停、恢复或移除；
- `projectArtifactChanged`：项目产物或版本发生可审计变更；
- `runStatusChanged`：运行状态变化；
- `systemNotice`：取消、部分失败、限制触发等系统事实。

用户消息、智能体回复和交付卡片进入群聊时间线。参与判断和细粒度运行事件默认折叠，但用户
可在执行详情中审计。不存在用户无法查看的“秘密智能体对话”。

`ProjectEvent.sequence` 为全部审计事件排序；其中可被智能体处理的消息事件另外拥有连续递增
的 `messageSequence`。参与判断、运行状态和文件审计不占用消息索引，避免 Agent 因内部状态
事件产生无意义的回复。可处理消息包括 `userMessage`、公开 `agentMessage`，以及对当前 Agent
可见的 `agentDelivery`。

### 4.6 AgentRun

AgentRun 是一个 Agent 在某个 ProjectTurn 中的一次独立执行。每个运行固定绑定：

- `projectId`、`turnId`、`runId`、`agentId`；
- 运行开始时的 Agent 配置快照；
- `decision | reply | delivery` 阶段；
- 独立取消令牌、Provider session、Tool Policy context 和 Token 用量；
- 父运行和交付链路，用于限制循环。

运行期间不再修改全局“当前 Agent”。同一项目中属于不同 Agent 的运行可独立开始、结束、
失败和取消；属于同一 Project-Agent 的运行由消息游标严格串行。

### 4.7 AgentMessageCursor

AgentMessageCursor 表示某个 Agent 在某个 Project 中已经连续处理到的位置：

- `lastProcessedMessageSequence`：已经得到终态的最大连续消息索引；
- `processingMessageSequence`：当前正在处理的索引，空值表示没有运行；
- `latestMessageSequence`：读取项目当前最新索引后得到的快照，不作为持久化真相；
- `workerState`：`idle | scheduled | processing | paused | error`；
- `activeRunId`：当前 decision/reply run；
- `leaseOwner/leaseExpiresAt`：防止重启或多个调度器重复消费同一条消息。

游标只允许连续前进，不能跳过任何没有终态 receipt 的消息索引。对于自己的消息、明确发给
其他 Agent 的消息、对当前 Agent 不可见的定向交付，或策略判定无需回复的消息，也要写入
`observed/pass/notTargeted/invisible/ownMessage` receipt 后推进游标。这样“已处理”不等于
“已回复”，而是该 Agent 已经按可见性和路由规则完成了这条消息的处理。

唯一允许没有 receipt 的游标初始化发生在创建新的 membership generation 时：游标直接设为
`joinMessageSequence`，表示更早消息属于加入前只读历史，而不是本成员周期的待处理消息。

## 5. 核心交互协议

### 5.1 输入框与 Mention

输入框需要把 `@显示名称` 和 `agentId` 作为结构化 mention span 保存，而不是只存一段文本。
发送前生成：

```dart
final class ProjectMessageDraft {
  final String text;
  final List<MentionSpan> mentions;
  final List<PendingAttachment> attachments;
}

final class MentionSpan {
  final String agentId;
  final int start;
  final int length;
  final String displayTextSnapshot;
}
```

约束如下：

- Mention 只能选择当前项目的活跃成员；
- 同一个 Agent 的重复 mention 在路由时去重，但原始文本保持不变；
- Agent 改名不改变已发送消息的目标；
- 发送前发现 Agent 已被移除时，明确提示并允许用户删除 mention 或重新选择；
- 粘贴的纯文本 `@名称` 可以在本地尝试转换为结构化 mention；重名或无法唯一匹配时不猜测；
- 数据库只信任解析完成后的 `agentId`，不在读取消息时重新解析文本。

### 5.2 明确 @ 路由

存在一个或多个有效 mention 时，路由模式为 `targeted`：

1. 持久化一条带 `messageSequence` 的消息事件和规范化目标；
2. 唤醒所有 active Agent 的 InboxWorker，但不直接抢占正在执行的 AgentRun；
3. 每个 Agent 从自己的 `lastProcessedMessageSequence + 1` 开始顺序扫描；
4. 被 mention 的 Agent 扫描到该消息时跳过参与判断，直接准备回复；
5. 未被 mention 的 Agent 仍按顺序观察这条项目公开消息，记录 `notTargeted` 并推进游标，
   不产生回复；
6. 每个目标 Agent 只使用 `messageSequence <= 当前消息索引` 的可见历史构造回复；
7. 每个运行独立完成或失败，一个失败不取消其他目标，也不阻塞新用户消息写入；
8. 回复落库后成为新的项目消息，由其他 Agent 在各自当前任务结束后按索引处理。

### 5.3 无 @ 广播路由

没有有效 mention 时，路由模式为 `broadcast`。消息先进入项目事件流；每个活跃成员在自己的
顺序游标到达这条消息时，执行一次低成本、无工具的参与判断请求：

```dart
enum ParticipationChoice { reply, pass }

final class ParticipationDecision {
  final String agentId;
  final ParticipationChoice choice;
  final String reasonCode;
  final String intendedContribution;
}
```

判断阶段只提供 Agent 身份、Skill 摘要、从会话消息生成的必要 ConversationSummary，以及
截至当前消息索引的可见历史，要求返回严格结构化结果，不允许调用 Skill Tool、MCP、项目
产物写入或长期记忆写入。无效结果、超时或判断调用失败默认记为 `pass`，并在执行详情中显示
原因，不能因为解析失败产生意外回复。

广播执行顺序：

1. 为消息分配 `messageSequence` 并唤醒每个 active Agent 的 InboxWorker；
2. 空闲 Agent 立即处理，忙碌 Agent 保持当前运行，新消息只增加它的 backlog；
3. 同一个 Agent 必须先完成索引较小的消息，不允许为较新的广播并行创建 decision；
4. 不同 Agent 可在受限并发池中并行判断同一条或不同的消息；
5. 持久化每个 Agent 的 `reply/pass` 决策；
6. 选择 `pass` 时写 receipt 并立即推进该 Agent 游标；
7. 选择 `reply` 时完成回复、把回复作为新消息落库，再写 receipt 并推进游标；
8. 当前消息处理结束后，如果游标仍小于项目最新消息索引，立即领取下一条；
9. 全部 Agent 选择 `pass` 是合法结果，UI 显示“本条消息没有智能体需要补充”，不伪造兜底
   回复。

默认项目范围的判断并发上限为 4、正式回复并发上限为 2，由项目响应策略配置。同一
Project-Agent 的 decision/reply 并发恒为 1；并发上限只控制不同 Agent 之间的资源，不减少
收到广播并进行判断的 Agent 数量。

参与判断的成本边界固定如下：

- 每条广播对消息创建时的每个 active Agent 恰好发起一次判断调用；判断不重试，失败、超时或
  非法结构直接按 `pass` 收敛；
- 每次判断的总输入上限为 4096 tokens、输出上限为 128 tokens、超时为 10 秒；组装输入时优先
  保留当前消息和 Agent 身份，再按从近到远的顺序裁剪 Skill 摘要、ConversationSummary 和历史
  消息；
- 若 active Agent 数为 `N`，一条广播最多产生 `N` 次判断调用，模型计费 Token 上界为
  `N × (4096 + 128)`；实际成本按每个 decision run 的 Provider、模型和实测 Token usage 记录；
- targeted 消息和第一阶段媒体生成不产生参与判断调用；全部 `pass` 不触发额外兜底模型调用。

### 5.4 每个智能体按消息索引顺序追赶

项目为每条用户消息、公开 Agent 消息和可见 AgentDelivery 分配不可变、连续递增的
`messageSequence`。每个 Agent 运行一个逻辑上的顺序 InboxWorker：

```text
收到唤醒信号
  -> 读取 cursor.lastProcessedMessageSequence + 1
  -> 按 messageSequence 升序查询下一条尚未得到终态 receipt 的消息
  -> 判断可见性和路由
       -> ownMessage / notTargeted / invisible：记录 receipt，推进游标
       -> broadcast：执行 reply/pass 判断
       -> targeted / accepted delivery：直接准备回复
  -> 若回复，固定 replyToMessageId 和 contextThroughMessageSequence
  -> 等待当前 AgentRun 完成
  -> 原子提交 receipt 和新 cursor
  -> cursor < projects.lastMessageSequence 时继续，否则 idle
```

回复必须明确锚定一条消息：

- `replyToMessageId` 指向当前处理的消息；
- `replyToMessageSequence` 是该消息的项目索引；
- `contextThroughMessageSequence` 固定等于该索引；
- 上下文可以包含此索引及之前的可见消息、消息摘要和允许的 AgentMemory；
- 即使更新的消息已经到达，也不能进入当前回复上下文；
- 新消息留在 backlog，当前回复进入终态后再按从旧到新的顺序处理。

这形成“同 Agent 串行、不同 Agent 并行”的模型。示例：

```text
Project 最新消息：10
Agent A cursor：7，正在回复 #8
Agent B cursor：9，正在判断 #10

用户此时发送 #11：立即保存并显示，不等待 A 或 B
Agent C 此时完成 #10 的回复：回复被保存为 #12，也不等待 A

Agent A 完成 #8 后：依次处理 #9、#10、#11、#12
Agent B 完成 #10 后：依次处理 #11、#12
```

Agent 回复自己产生的消息时记录 `ownMessage` 并推进游标，不再次判断或回复。Agent 回复和
不带目标的 Agent 主动消息默认是新的广播消息，其他 Agent 会在自己的游标到达时判断是否
需要回复。为避免多个 Agent 无限制互相应答，每条 Agent 消息记录 `rootMessageId` 和
`autonomousDepth`；达到项目配置的最大深度或单个 root 的 Agent 消息数量后，其他 Agent 仍
会按顺序观察并推进游标，但必须记录 `chainLimitReached`，不能继续自动回复。

如果处理失败，不允许游标永久卡住。系统按策略重试；超过重试上限后写入可见错误和
`failedSkipped` receipt，再推进到下一条。用户可从执行详情手动重试该消息，新重试作为显式
运行记录，不回退已经连续前进的游标。

新 Agent 加入已有项目时，默认把游标初始化为加入时的 `projects.lastMessageSequence`：旧消息
可以作为只读历史上下文，但不会补发历史回复。暂停 Agent 不推进游标，恢复后从暂停位置按
顺序追赶；移除 Agent 终止当前运行并冻结旧游标，重新添加默认视为新的成员周期，从重新加入
时的最新索引开始，避免补发移除期间的回复。

每条消息创建时保存 active recipient snapshot，用于判断该 ProjectTurn 何时完成。暂停成员不
阻止原 Turn 完成，但恢复后仍按自己的 cursor 处理暂停期间的公开广播消息；这些 late receipt
链接原 Turn，但不把已经完成的 Turn 重新变为 active。新加入或重新加入的成员只把旧消息作为
上下文，不为加入前消息创建 receipt。

### 5.5 用户输入与其他智能体不被阻塞

消息持久化和模型生成是两条独立路径。用户发送只需要完成一次短 SQLite 事务，为消息分配
索引并发出唤醒信号；它不等待任何 Agent 当前回复、广播判断或工具调用。其他 Agent 也只受
自己的 Project-Agent 串行锁约束，不受正在回复的 Agent 影响。

- 同一个 Agent 在同一 Project 内最多一个 active AgentRun；
- 不同 Agent 可以同时回复；
- 同一个 Agent 在不同 Project 的运行可并发，但个人记忆写入继续使用 revision/CAS；
- 用户连续发送多条消息时全部立即进入事件流，并按索引进入每个 Agent 的 backlog；
- UI 不因任意 Agent 回复而禁用输入框，只单独展示每个 Agent 的运行和积压状态；
- 用户可以取消某个 Agent 当前运行、某条消息的 ProjectTurn，或一条 root 链，但不影响已经
  保存的新用户消息。

AgentInboxCoordinator 是应用级生命周期组件，不归某个项目页面所有。离开项目页面只取消 UI
订阅，不取消 inbox；应用进程仍在时继续追赶。应用退出后依靠持久化 cursor 和 receipt 在下次
启动恢复，除非用户明确暂停 Agent、取消运行或删除项目。

Agent 的流式回复在生成期间是 `messageSequence = null` 的运行草稿，只供 UI 展示，不进入
任何 Agent inbox。回复完成，或取消/失败但需要保留可见的部分内容时，才在短事务中取得当时
最新的消息索引、转为终态消息并唤醒其他 Agent。因此一个尚未完成的流式回复不会占住消息
索引，也不会阻塞其他 Agent 继续处理期间到达的用户消息。用户消息始终在发送成功时立即取得
消息索引。

### 5.6 智能体间交付

Agent 通过内建的 `project.deliver_to_agent` 工具进行交付，不通过在自然语言回复中拼接
`@名称` 来触发。请求结构建议为：

```dart
final class AgentDeliveryRequest {
  final List<String> targetAgentIds;
  final DeliveryKind kind; // information | task | question | result
  final String summary;
  final String payload;
  final List<String> projectArtifactVersionIds;
  final DeliveryVisibility visibility; // project | targets
  final bool requestPublicReply;
}
```

`visibility` 未显式提供时固定为 `project`。`targets` 是 Agent 上下文可见范围，不是对用户隐藏
的私密通道；两种值都会在项目时间线显示可折叠交付卡片，并能从执行详情审计完整链路。

交付规则：

- 发送者和目标必须是当前项目活跃成员；
- 不能交付给自己；
- `project` 交付进入所有成员后续上下文；`targets` 只进入目标 Agent 上下文；
- 两种交付都以可折叠卡片对用户可见并可审计，`targets` 不代表对用户隐藏；
- 交付引用产物时只保存 Artifact ID 和固定 Version ID，读取仍需检查目标 Agent 的项目存储
  权限；
- 交付作为一条具有 `messageSequence` 的消息进入目标 Agent 的顺序 inbox，不能抢占目标正在
  处理的旧消息；
- 目标 Agent 可 `reply` 或 `pass`；选择回复时产生子 AgentRun；
- 交付链保存 `parentRunId`、`rootTurnId`、`depth` 和 payload digest；
- 默认最大交付深度为 4、单轮最多 8 次交付；同一发送者、目标和 payload digest 不重复执行；
- 达到深度、数量、时间或 Token 上限时终止交付链，并追加可见的系统事件；
- 用户取消整个 ProjectTurn 时，取消它的判断、回复和交付子运行。

交付工具只是项目内消息路由能力，不扩大目标 Agent 的 Skill、MCP 或文件权限。

### 5.7 媒体生成

图片、语音、音乐和视频属于明确能力调用。第一阶段保持“必须明确 `@` 且只有一个目标 Agent”
的约束；广播不自动选择媒体 Agent，多个目标也不隐式选择第一个。能力不匹配时在发送前给出
清晰提示，不切换共享 Agent 状态。

## 6. 状态机与并发

### 6.1 ProjectTurn 状态

```text
created
  -> dispatching
      -> deciding          # 仅 broadcast
      -> replying
          -> delivering    # 有交付子链时
              -> completed
              -> partial
              -> failed
              -> cancelled
```

- `completed`：所有计划运行得到终态且没有失败；
- `partial`：至少一个结果成功，同时存在失败、超时或限制终止；
- `failed`：没有任何预期结果成功，且不是全部 `pass`；
- `cancelled`：用户取消整轮；
- 广播全部 `pass` 记为 `completed`，并附 `noParticipant=true`。

ProjectTurn 只汇总一条源消息的直接处理结果。它完成后，由 Agent 回复产生的新消息可以拥有
自己的 ProjectTurn 并继续在其他 Agent inbox 中排队；因此项目可以同时存在多个活跃 Turn，
不能用“是否有 active ProjectTurn”决定是否允许用户输入。

### 6.2 AgentInboxWorker 状态

```text
idle -> scheduled -> processing -> committing -> scheduled/idle
                     |     |
                     |     +-> retrying -> processing
                     +-> paused/error
```

- Worker 以 `(projectId, agentId)` 为唯一键；
- `scheduled` 表示游标落后于项目最新消息或收到唤醒；
- `processing` 期间固定 `processingMessageSequence`，新消息只能追加 backlog；
- `committing` 原子写入 receipt 并把连续游标推进一位或多位已跳过消息；
- 每次提交后重新读取 `projects.last_message_sequence`，避免错过提交期间到达的消息；
- `paused` 不领取新消息；恢复时不丢弃 backlog；
- 崩溃恢复依赖 lease 超时重新领取，`UNIQUE(project_id, agent_id, message_sequence)` receipt
  防止重复处理。

### 6.3 AgentRun 状态

```text
queued -> deciding -> passed
                 \-> preparing -> running -> delivering -> completed
                                      |            |
                                      +-> cancelled/failed/timedOut/limitExceeded
```

每个 `runId` 独立注册，不再以 `projectId` 作为唯一运行键。ProjectTurnCoordinator 维护
`turnId -> runId set`，AgentInboxCoordinator 维护 `(projectId, agentId) -> activeRunId`。
同一 Project-Agent 的判断、回复、工具调用和提交全部串行；不同 Agent 的只读判断、模型生成
和权限允许的 Tool 可并行。

### 6.4 一致性规则

- 用户或 Agent 消息、`messageSequence` 和 ProjectTurn 在一个 SQLite 事务中创建；
- `projects.last_message_sequence` 必须通过 Repository 在写事务内原子递增，多个用户/Agent
  同时提交也不能产生重复或倒序索引；
- 每个运行先持久化 `queued` 再调用外部 Provider；
- 流式内容只更新 `messageSequence = null` 的事件草稿；终态提交时才取得消息索引，进入终态
  后事件正文不可修改；
- 每个事件分配项目内单调递增 `sequence`；消息事件另分配单调递增
  `messageSequence`，UI 不以完成时间推断顺序；
- AgentRun 必须保存 `sourceMessageSequence` 和 `contextThroughMessageSequence`，二者默认
  相等，防止回复期间的新消息混入当前上下文；
- `(projectId, agentId, messageSequence)` 最多一个终态 receipt；
- receipt 和 `lastProcessedMessageSequence` 在同一事务中提交，游标只能连续前进；
- 消息提交后的唤醒可以重复、不能丢失；应用启动和每次运行结束都会扫描落后游标作为兜底；
- 取消 ProjectTurn 时立即取消 active run；尚未轮到该消息的 Agent 在游标到达时写
  `cancelled` receipt，不能越过更早索引直接移动游标；
- Provider 调用、文件 I/O 和 Tool 执行期间不持有 SQLite 事务；
- 重启后把无活动 session 的运行恢复为 `interrupted`；有副作用的 Tool 不自动重复，运行达到
  重试上限后形成 `failedSkipped` receipt，使 inbox 可以继续追赶；
- 所有落库命令以稳定 `eventId/runId/callId` 幂等。

## 7. 数据结构

### 7.1 聚合关系

```text
Agent 1 --- * ProjectMembership * --- 1 Project
  |                                      |
  |                ProjectAgentCursor * -+
  |                                      +--- * ProjectTurn
  +--- * AgentSkillBinding               |       +--- * AgentRun
  +--- 1 AgentMemoryStore                |       +--- * ProjectEvent
  |      (文件/外部向量库)                |       +--- * AgentMessageReceipt
  +--- 1 AgentStorageRoot                +--- * ProjectArtifact
                                         |       +--- * ProjectArtifactVersion
                                         +--- * ConversationSummarySegment
                                         +--- 1 ProjectStorageRoot
```

### 7.2 核心表草案

以下为 SQLite 核心表及外部存储契约的逻辑结构，字段命名在开发前可按现有规范细化。新数据库
直接创建列出的 SQLite 表，不从旧表复制数据；图中的 AgentMemoryStore 由独立 Repository 管理，
不是 SQLite 表。

#### `agents`

| 字段 | 说明 |
| --- | --- |
| `id` | Agent 稳定主键 |
| `name`, `avatar` | 当前展示信息 |
| `provider`, `base_url`, `api_key`, `api_type`, `model` | Provider 配置，凭据存储机制保持现状 |
| `system_prompt`, `parameters_json` | 身份和能力参数 |
| `memory_policy_json` | 自动记忆、跨项目复用、敏感信息和检索预算策略；不包含任何记忆正文、摘要或向量 |
| `memory_backend`, `memory_backend_ref` | `file | externalVector`；默认 `file`，外部引用不包含凭据 |
| `created_at`, `updated_at` | 生命周期 |

`memory_policy_json` 是版本化、严格解码的 Agent 配置，不是记忆存储。Phase 0 固定的默认值为：

```json
{
  "schemaVersion": 1,
  "autoEvolutionEnabled": true,
  "projectFactDefaultScope": "sourceProjectOnly",
  "autoCrossProjectKinds": [
    "userPreference",
    "learnedPattern",
    "capabilityNote",
    "reflection"
  ],
  "privateCrossProject": "requireUserApproval",
  "uncertainCrossProject": "requireUserApproval",
  "secretLike": "reject",
  "retrieval": {
    "maxItems": 12,
    "tokenBudget": 2048,
    "minConfidence": 0.65
  }
}
```

`memory_backend_ref` 只引用应用安全配置中的外部向量库连接；端点凭据继续进入平台安全存储，
不能写入 SQLite 或该 JSON。文件后端不需要 `memory_backend_ref`。

#### `projects`

| 字段 | 说明 |
| --- | --- |
| `id` | Project 稳定主键 |
| `name`, `ui_metadata_json` | 项目名称和界面元数据，不承载项目记忆或隐式知识 |
| `response_policy_json` | 判断/回复并发、重试、自动消息链和交付上限等策略 |
| `last_event_sequence`, `last_message_sequence` | 审计事件和可处理消息的两个最新索引 |
| `last_message`, `last_message_at` | 列表展示 |
| `created_at`, `updated_at` | 生命周期 |

`response_policy_json` 至少固定以下 Phase 0 默认值；字段必须版本化并严格解码：

```json
{
  "schemaVersion": 1,
  "broadcastDecision": {
    "concurrency": 4,
    "maxInputTokens": 4096,
    "maxOutputTokens": 128,
    "timeoutMs": 10000,
    "maxAttempts": 1,
    "failureOutcome": "pass"
  },
  "replyConcurrency": 2,
  "autonomousChain": {
    "maxDepth": 4,
    "maxAgentMessagesPerRoot": 16
  },
  "delivery": {
    "defaultVisibility": "project",
    "maxDepth": 4,
    "maxDeliveriesPerTurn": 8
  }
}
```

#### `project_memberships`

| 字段 | 说明 |
| --- | --- |
| `project_id`, `agent_id` | 联合主键 |
| `status` | `active | paused | removed` |
| `position` | 成员顺序 |
| `project_storage_access` | `none | read | readWrite` |
| `capability_restrictions_json` | 项目对该 Agent 的能力收缩 |
| `membership_generation`, `join_message_sequence` | 重新加入周期和本周期开始处理的位置 |
| `joined_at`, `removed_at`, `updated_at` | 关系生命周期 |

`project_id` 删除时级联删除成员关系；`agent_id` 被用户明确全局删除时也删除关系，但不删除
项目。项目删除不触碰 `agents`。

#### `project_turns`

| 字段 | 说明 |
| --- | --- |
| `id`, `project_id`, `root_event_id` | 轮次标识和触发事件 |
| `initiator_type`, `initiator_id` | `user | agent | system` |
| `routing_mode` | `targeted | broadcast | delivery` |
| `source_message_id`, `source_message_sequence` | 本 Turn 直接分发的消息及其索引 |
| `recipient_count` | 消息创建时 active recipient snapshot 的数量 |
| `root_turn_id`, `autonomous_depth` | Agent 自动对话链的根和深度 |
| `status`, `no_participant` | 轮次终态 |
| `created_at`, `completed_at` | 时间 |

#### `project_events`

| 字段 | 说明 |
| --- | --- |
| `id`, `project_id`, `turn_id`, `run_id` | 事件及关联链路 |
| `sequence` | 项目内单调序号，`UNIQUE(project_id, sequence)` |
| `message_sequence` | 仅消息事件非空，`UNIQUE(project_id, message_sequence)` |
| `event_type` | 受约束的事件枚举 |
| `actor_type`, `actor_id` | 用户、Agent 或系统 |
| `actor_name_snapshot`, `actor_avatar_snapshot` | 历史展示快照 |
| `visibility` | `project | targets | audit` |
| `reply_to_event_id`, `reply_to_message_sequence` | 回复锚点 |
| `root_message_id`, `autonomous_depth` | 自动消息链和循环限制 |
| `content`, `payload_json` | 可检索正文和类型化 DTO 数据 |
| `terminal_state`, `has_partial_content` | 流式与终态 |
| `created_at`, `updated_at` | 时间 |

`payload_json` 不是任意 Map。Data 层应按 `event_type` 使用独立 record/DTO 严格解码，领域层
只暴露类型化 ProjectEvent 子类型。流式 Agent 消息在终态前允许 `message_sequence` 为空；
Inbox Repository 只返回已经取得消息索引的终态消息。

#### `project_event_targets`

| 字段 | 说明 |
| --- | --- |
| `event_id`, `agent_id` | 联合主键 |
| `target_kind` | `mention | broadcast | delivery` |
| `position` | mention/交付顺序 |

目标 Agent 删除后不应导致历史目标事实消失。这里不对 `agent_id` 使用级联外键，或使用可空
引用加发送时快照；Repository 负责只向当前有效 Agent 调度。`broadcast` target 行保存消息
创建时的 active recipient snapshot；暂停成员恢复后的补处理通过 cursor/receipt 记录，不修改
原 snapshot。

#### `project_event_artifacts`

| 字段 | 说明 |
| --- | --- |
| `event_id`, `artifact_id`, `artifact_version_id` | 消息/交付与固定产物版本的引用 |
| `relation` | `attachment | input | output | reference` |
| `position` | 展示和上下文顺序 |

历史事件必须引用固定版本；“使用当前版本”只允许作为发送前 UI 选择，持久化时解析为具体
Version ID。

#### `project_agent_cursors`

| 字段 | 说明 |
| --- | --- |
| `project_id`, `agent_id` | 联合主键，一个 Project-Agent 一个顺序 worker |
| `last_processed_message_sequence` | 已连续处理的最大消息索引 |
| `processing_message_sequence` | 当前领取的消息索引，可空 |
| `worker_state` | `idle | scheduled | processing | paused | error` |
| `active_run_id` | 当前运行，可空 |
| `lease_owner`, `lease_expires_at` | 崩溃恢复和多实例互斥 |
| `last_error`, `updated_at` | 诊断字段 |

游标归属成员关系，项目删除或 Agent 全局删除时级联删除。暂停不清除游标；移除时冻结游标。
新成员的初始值默认等于加入事务读取到的 `projects.last_message_sequence`。

#### `agent_message_receipts`

| 字段 | 说明 |
| --- | --- |
| `project_id`, `agent_id`, `message_sequence` | 联合唯一键，保证逐消息幂等 |
| `message_event_id`, `turn_id` | 被处理消息和分发范围 |
| `outcome` | `replied | passed | observed | notTargeted | ownMessage | invisible | cancelled | failedSkipped | chainLimitReached` |
| `decision_run_id`, `reply_run_id`, `reply_event_id` | 判断和回复链路 |
| `started_at`, `completed_at`, `error_code` | 执行与诊断 |

Receipt 是“已经处理”的事实。Cursor 是最大连续 receipt 的缓存和领取位置；二者必须在一个
事务中更新，不能只移动 Cursor 而没有 receipt。

#### `agent_runs`

| 字段 | 说明 |
| --- | --- |
| `id`, `project_id`, `turn_id`, `agent_id` | 运行身份 |
| `source_message_event_id`, `source_message_sequence` | 当前处理的消息锚点 |
| `context_through_message_sequence` | 本次上下文允许到达的最大消息索引 |
| `parent_run_id`, `root_run_id`, `delivery_depth` | 交付链 |
| `phase`, `status` | `decision | reply | delivery` 及运行状态 |
| `agent_snapshot_json` | 本次使用的模型、提示和能力摘要，不含明文密钥 |
| `started_at`, `completed_at`, `error_code` | 诊断字段 |

Tool invocation、Skill activation 和模型用量继续按 `run_id` 记录。用量事实不再依赖某条公开
消息存在，判断调用也以 `operation_kind=participation_decision` 计入成本。

#### `participation_decisions`

| 字段 | 说明 |
| --- | --- |
| `run_id` | 对应 decision AgentRun 的主键 |
| `agent_id`, `project_id`, `turn_id`, `message_sequence` | 查询维度和处理顺序 |
| `choice`, `reason_code`, `intended_contribution` | 结构化判断 |
| `created_at` | 时间 |

#### `agent_deliveries`

| 字段 | 说明 |
| --- | --- |
| `event_id`, `source_run_id`, `source_agent_id` | 交付来源 |
| `kind`, `summary`, `payload` | 类型化内容 |
| `visibility`, `request_public_reply` | 展示与响应策略 |
| `root_turn_id`, `depth`, `payload_digest` | 循环控制 |

多个目标继续存放在 `project_event_targets`，产物引用存放在 `project_event_artifacts`，引用应固定
到具体 artifact/version，避免文件更新后改变历史消息含义。

#### `project_artifacts`

| 字段 | 说明 |
| --- | --- |
| `id`, `project_id` | 产物身份和项目作用域 |
| `name`, `relative_path` | 用户可见名称和受控相对路径 |
| `kind` | `attachment | document | code | image | audio | video | dataset | archive | generated | other` |
| `mime_type`, `current_version_id` | 类型和当前版本 |
| `search_status`, `metadata_json` | `pending | indexed | unsupported | failed` 及类型化元数据 |
| `created_by_type`, `created_by_id`, `source_run_id` | `user | agent | system` 来源审计 |
| `created_at`, `updated_at` | 时间 |

`UNIQUE(project_id, relative_path)`，数据库只存相对路径，不存可逃逸的任意绝对路径。用户从项目
文件面板添加、拖入或选择的内容，与 Agent 写入的内容统一成为 ProjectArtifact。

#### `project_artifact_versions`

| 字段 | 说明 |
| --- | --- |
| `id`, `artifact_id`, `version_number` | 稳定版本，`UNIQUE(artifact_id, version_number)` |
| `relative_blob_path` | Project root 内的不可变内容路径 |
| `content_digest`, `byte_length`, `mime_type` | 完整性和读取策略 |
| `created_by_type`, `created_by_id`, `source_run_id` | 版本来源 |
| `created_at` | 时间 |

修改产物创建新版本并原子更新 `current_version_id`，不在原路径覆盖已被消息或运行引用的版本。
删除、覆盖和历史版本回收继续经过 Tool Policy 与引用检查。

#### `project_artifact_search_documents`

该逻辑索引保存可检索的名称、路径、标签和从当前版本提取的文本。实现可使用 SQLite FTS 或
等价本地索引，但 Repository 契约不暴露具体搜索引擎。纯文本、Markdown、代码、JSON、CSV
等可以直接索引；PDF、Office、图片 OCR、音视频转录等只有在对应提取器可用且用户允许时才
索引。无法提取正文的二进制产物仍可按名称、类型、来源和时间检索。

### 7.3 会话摘要表（不是项目记忆）

项目不创建 `project_memory_items`。现有 `conversation_memory_*` 中只有“从消息派生的上下文
压缩”语义被保留，并直接调整为：

- `conversation_summary_state(project_id, revision, active_summary_set_id,
  covered_through_message_sequence, compaction_status, ...)`；
- `conversation_summary_segments(id, project_id, source_start_message_sequence,
  source_end_message_sequence, summary_kind, source_event_ids_json, source_digest,
  summary_file_name, summary_content_digest, estimated_token_count, provider, model, prompt_version,
  status, ...)`。

ConversationSummary 必须满足：

- 只总结实际存在的用户/Agent 会话消息，不独立新增目标、决策、术语或偏好；
- 每个 segment 覆盖一个确定且连续的消息范围，并保存来源 digest；
- `rolling` summary 用于自动压缩较早消息；`rangeExtract` summary 用于用户或 Agent 对选定
  消息范围发起的摘要提取，二者都必须保留来源范围和 digest；
- 是有损、可失效、可删除、可由源消息重新生成的派生数据，不是权威事实或长期记忆；
- 消息编辑、删除或 digest 不匹配时标记 `stale/invalid`，在重建前不得作为可信摘要注入；
- 摘要只用于减少模型上下文长度和帮助定位历史消息，不直接授予工具、文件或成员权限；
- 清空会话时一并删除；删除摘要不影响原始消息和项目产物；
- 摘要文件若放入 Project root，应位于系统管理的 `context/summaries`，不能被当作用户产物，
  也不通过普通项目写入工具修改。

如果用户希望把某次 rangeExtract 结果作为可编辑、可检索的长期项目成果，应执行明确的
“保存为项目产物”，创建新的 ProjectArtifact/Version 并记录来源 summary/message range；原
ConversationSummary 仍保持只读派生数据语义。

### 7.4 智能体长期记忆存储契约

AgentMemory 是系统中唯一具有长期记忆语义的数据，但实际记忆不属于 SQLite 数据结构。
SQLite 不创建 `agent_memory_items`、`agent_memory_state` 或其他保存记忆正文、摘要、Embedding、
候选内容和演化版本的等价字段。`agents.memory_policy_json` 只是配置，
`memory_backend/memory_backend_ref` 只是存储路由。

`AgentMemoryRepository` 对上暴露统一的逻辑记录，以下字段整体保存到 Agent 私有文件空间或外部
向量库：

| 逻辑字段 | 说明 |
| --- | --- |
| `id`, `agentId`, `memoryKey` | 身份；同一 Agent 内 `memoryKey` 唯一 |
| `kind` | `userPreference | learnedPattern | capabilityNote | relationship | fact | reflection` |
| `content`, `state` | 正文和 `candidate | active | superseded | forgotten` |
| `reuseScope` | `crossProject | sourceProjectOnly | userApproved` |
| `sensitivity` | `normal | private`；检测为 `secretLike` 的内容在所有写入路径持久化前拒绝 |
| `importance`, `confidence` | 检索与演化依据 |
| `sourceProjectId` | 可空溯源标识，不是 SQLite 外键 |
| `sourceEventIds`, `sourceMessageSequence`, `sourceDigest` | 证据标识、项目内顺序和摘要，不复制项目消息正文 |
| `version`, `supersedesId` | 冲突和演化链 |
| `createdAt`, `updatedAt`, `lastUsedAt` | 生命周期 |

文件后端以 `manifest.revision` 做 CAS，记忆版本写入 staging 后通过原子 rename 提交；索引可以
重建，不能成为唯一正文来源。外部向量库后端必须使用等价的 revision/version 条件更新，并把
正文、元数据和向量都放在外部存储中。两种后端都以 `(agentId, memoryKey)` 保证逻辑唯一，
不得用 SQLite 事务冒充跨存储事务。

`sourceProjectOnly` 只是注入范围限制，所有权仍属于 Agent；它不会创建项目记忆或把该记录放入
Project 聚合。删除来源 Project 后保留不可解引用的 `sourceProjectId` 审计标识；上下文组装器
发现来源 Project 已不存在时必须拒绝注入，而不是把它隐式提升为跨项目记忆。

SQLite 可以保留 `agent_memory_evolution_runs` 作为无正文的运行审计，字段只包含 run/agent/
project/event ID、Provider、模型、提示版本、Token usage、输入 digest/数量、结果数量、状态、
错误码和时间。它不得保存输入来源摘要、候选正文、现有记忆正文或 Embedding，也不作为记忆
恢复来源。

### 7.5 Skill 与 MCP 表

- `skills`、Skill Catalog、发布者、签名和合规表保持现有语义；
- `bot_skill_bindings` 直接重命名为 `agent_skill_bindings`，以 `agent_id` 为归属；
- `skill_activations` 增加 `project_id/turn_id/run_id/agent_id` 查询维度；
- `mcp_servers`、`mcp_tools` 和 MCP 管理流程保持不变；
- Agent 的 MCP 选择第一阶段仍可保存在 `parameters_json`，后续可规范化为
  `agent_mcp_server_bindings` 和 `agent_mcp_tool_bindings`；
- ProjectMembership 的限制和 Tool Policy 只能从 Agent 已配置能力中做交集。

### 7.6 删除语义

| 操作 | 删除内容 | 明确保留 |
| --- | --- | --- |
| 删除 Project | membership、cursor、receipt、turn、event、run、ConversationSummary、ProjectArtifact 元数据/版本和项目目录 | Agent、Agent Skill/MCP 配置、AgentMemory、Agent 目录 |
| 从 Project 移除 Agent | 取消当前运行、冻结 cursor 并写成员变更事件 | Project、历史事件、receipt、Agent 和 AgentMemory |
| 删除 Agent | 所有 membership/cursor、Agent Skill 绑定、AgentMemory 和 Agent 目录 | Project、带发送者快照的历史事件和历史 receipt |
| 清空项目聊天 | 项目事件、运行、receipt 和 ConversationSummary；把消息计数及所有保留的 cursor 原子重置为 0；回收仅被已清消息引用的临时附件 | Project、membership、用户/Agent 正式产物及版本、AgentMemory |
| 忘记一条 AgentMemory | 指定记忆或演化版本 | Agent、Project 和项目历史 |

删除项目采用文件暂存、SQLite 事务、提交文件删除的现有安全思路。AgentMemory 位于独立文件
空间或外部向量库，`sourceProjectId` 只是不可级联的稳定审计标识，从存储边界上保证项目删除
不能删除智能体记忆。若用户希望同时清除由该项目产生的跨项目记忆，应提供单独、明确的清理
操作，不能捆绑在普通项目删除中。

## 8. 存储空间

### 8.1 目录布局

```text
<application-support>/
├── app.db
├── projects/
│   └── <project-id>/
│       ├── artifacts/
│       │   ├── blobs/
│       │   │   └── <artifact-id>/<version>/
│       │   ├── index/
│       │   └── staging/
│       ├── context/
│       │   └── summaries/          # 从消息派生的系统数据，不是 Memory/Artifact
│       ├── audit/
│       └── tmp/
├── agents/
│   └── <agent-id>/
│       ├── memory/
│       │   ├── manifest.json
│       │   ├── items/
│       │   │   └── <memory-id>/<version>.json
│       │   ├── blobs/
│       │   ├── index/
│       │   └── staging/
│       └── state/
└── skills/
    └── bundles/
```

项目目录和 Agent 目录是不同根。项目 Agent 不能因为知道路径而读取另一个项目或另一个
Agent 的数据。Project 的持久化业务内容全部通过 ProjectArtifact 管理；物理 blob、索引和系统
摘要目录不直接暴露给模型或 UI。

### 8.2 项目产物存储与权限

项目存储空间是用户和项目成员 Agent 共享的持久化产物空间，不是项目记忆。它支持文档、
Markdown、代码、结构化数据、图片、音频、视频、压缩包、模型生成结果及平台允许的其他类型。
产物不会因为对话上下文被压缩而丢失，也不会自动整体注入模型上下文。

用户可以：

- 从项目文件面板选择文件、拖放、批量导入或新建文本类产物；
- 把消息附件保存为项目正式产物；
- 查看名称、类型、来源、版本、大小、摘要 digest 和修改时间；
- 搜索、预览、下载、重命名、创建新版本或删除产物；
- 在消息中引用某个产物或固定版本，使指定 Agent 可以按权限检索和读取。

Agent 可以在权限允许时：

- 按关键词、名称、路径、类型、来源和时间检索产物；
- 查询元数据，分块读取文本或受支持类型的提取内容；
- 创建代码、文档、数据、图片、音视频等新产物；
- 基于当前版本写入新版本、移动或重命名产物；
- 在回复或 AgentDelivery 中引用产物及固定版本。

项目成员权限定义为：

- `none`：看不到项目产物 Tool；仍可看到群聊中用户明确附加给消息且允许查看的内容；
- `read`：可检索、列出、查询元数据和读取项目产物；
- `readWrite`：可创建、导入、修改并产生新版本；删除、移动、覆盖当前版本等操作仍需
  Tool Policy 审批。

新成员默认权限固定为 `read`，写权限由用户在项目成员设置中明确开启。权限检查同时发生在 Tool
暴露阶段和实际执行阶段，防止运行期间权限被收回后仍可操作。

内建工具建议为：

- `project.artifacts.search`；
- `project.artifacts.list`；
- `project.artifacts.stat`；
- `project.artifacts.read`；
- `project.artifacts.create`；
- `project.artifacts.write_version`；
- `project.artifacts.move`；
- `project.artifacts.delete`。

所有路径先规范化再验证仍位于 Project root；拒绝 `..`、绝对路径、根外符号链接和大小超限；
写入使用 staging、内容 digest、fsync 和原子提交；每次变更生成 `projectArtifactChanged` 与 Tool
invocation 记录。Artifact ID 和 Version ID 是模型可引用的稳定身份，绝对路径不进入模型
上下文。搜索结果默认只返回小型元数据和片段；Agent 必须显式读取所需版本，防止整个项目
空间无边界进入上下文。

搜索索引是由 Artifact 当前版本派生的可重建数据，不是 Memory。索引失败不能损坏原产物；
不支持正文提取的类型仍可通过元数据检索。用户导入与 Agent 写入共用相同的大小、类型、安全
扫描、版本和审计规则。

添加或修改产物只产生 `projectArtifactChanged` 审计事件，不占用 `messageSequence`，也不自动
触发所有 Agent 回复。用户希望 Agent 处理新产物时，应在消息中引用具体 Version；Agent 在既有
任务中主动检索到产物时，也必须把实际读取的 Version 记录到 run report。

### 8.3 智能体记忆空间

Agent 只通过 `agent.memory.search/read/propose/forget` 等领域工具访问自己的记忆，ToolPolicy
从当前 `run.agentId` 注入作用域，不接受模型传入任意 agentId。一般项目成员和其他 Agent
不能读取此空间。

默认使用文件后端，全部记忆正文、逻辑元数据、版本链和 CAS revision 位于
`agents/<agent-id>/memory/`；`index/` 只是可重建索引。用户显式配置外部向量库后，正文、逻辑
元数据和向量全部进入该后端，本地只保留不含凭据的后端引用和恢复状态。外部连接凭据使用平台
安全存储。两种后端均不得把记忆正文或向量回写 SQLite。

长期记忆文件使用不可变版本名、内容摘要和 CAS 提交；项目会话摘要也使用不可变文件、来源
digest 和孤儿文件恢复，但二者属于不同 Repository，不能互相读写。

## 9. 会话摘要与智能体记忆

### 9.1 项目没有记忆

项目内只有对话消息、由消息派生的 ConversationSummary、持久化 ProjectArtifact 和成员关系。
只有 AgentMemory 具有“记忆、遗忘、演化、跨项目复用”的语义：

| 类型 | 所有者/来源 | 作用 | 生命周期 | 是否是记忆 |
| --- | --- | --- | --- | --- |
| ConversationMessage | 用户或 Agent | 项目对话的原始事实 | 随会话保留策略 | 否，原始消息 |
| ConversationSummary | 从消息范围派生 | 压缩历史、降低上下文 Token | 可重建；随源消息失效或删除 | 否，派生摘要 |
| ProjectArtifact | 用户或有权限的 Agent | 持久化文档、代码、数据和多媒体产物 | 随项目/用户操作 | 否，共享存储内容 |
| AgentMemory | Agent | 长期偏好、经验、反思和跨项目能力演化 | 随 Agent 长期存在 | 是 |

系统不得从会话摘要中创建 `project_memory_key`，也不得把摘要段落自动提升为项目事实。摘要与
原始消息冲突时以原始消息为准；产物与消息需要进入上下文时必须通过明确引用、检索或读取，
不能以“项目记忆”名义自动注入。

### 9.2 演化流程

```text
项目运行产生可观察事实
  -> 本地敏感信息过滤
  -> 提取 AgentMemory candidate
  -> 按 memory_key/source_digest 去重
  -> 与 active 版本比较：新增 / 合并 / 冲突 / 忽略
  -> 应用 reuse_scope 与用户记忆策略
  -> CAS 提升为 active，新版本指向 supersedes_id
  -> 后续项目按相关性和 Token 预算检索
```

规则如下：

- 自动记忆提取不调用工具，不生成新权限；
- 每个 Agent 只从自己实际参与、观察或接收交付的内容中形成候选记忆，不把未向它开放的项目
  事件写入个人记忆；
- `autoEvolutionEnabled=false` 时停止自动提取和提升，但不删除已有记忆，手动查看、纠正和忘记
  仍然可用；
- 新事实不原地覆盖旧事实，使用 version/supersedes 形成可回溯演化链；
- 用户可以查看、纠正、忘记、冻结自动演化；
- 删除 Project 不删除已形成的 AgentMemory，但 `sourceProjectOnly` 记忆在来源项目删除后不再
  注入任何项目，直到用户明确改为可复用；
- 长期记忆进入模型前仍被视为不可信数据，系统规则、当前会话消息和用户明确指令优先级更高。

自动演化和用户确认边界固定为：

| 候选类型 | 自动持久化 | 初始状态/复用范围 | 是否需要用户确认 |
| --- | --- | --- | --- |
| API Key、Token、私钥、认证材料及 `secretLike` 内容 | 否，过滤后只记无正文错误码 | 不创建记录 | 所有 propose/create/import 路径都拒绝，凭据应进入平台安全存储 |
| 来源于某个项目的事实、目标、关系或决策 | 是 | `active / sourceProjectOnly` | 仅在提升为跨项目时需要 |
| 普通用户偏好、方法反思、已验证的能力经验 | 是 | `active / crossProject` | 否，用户可事后纠正或忘记 |
| private 或置信度低于策略阈值的跨项目候选 | 是，存于文件/向量库 | `candidate / userApproved` | 是；批准前不得注入其他项目 |
| 用户明确创建或纠正的记忆 | 是 | 使用用户明确选择的范围 | 用户操作本身即为确认 |

记忆检索默认最多返回 12 条、使用 2048 tokens、最低置信度 0.65；三项都由
`memory_policy_json.retrieval` 覆盖。作用域、敏感度和来源消息顺序过滤先于相关性排序和 Token
裁剪，不能为了填满预算放宽安全边界。

### 9.3 上下文组装顺序

每个 AgentRun 独立执行以下组装：

```text
应用安全规则
  -> Agent 身份和系统提示词
  -> Agent Skill 目录及本轮激活指令
  -> 相关 AgentMemory（按 reuse scope、敏感度和 Token 预算过滤）
  -> 项目成员与当前路由信息
  -> 覆盖范围不超过回复锚点的 ConversationSummary
  -> 摘要未覆盖的可见消息，按 messageSequence 排序且不超过回复锚点
  -> replyToMessageId 指向的当前用户消息、Agent 消息或 AgentDelivery
  -> 当前消息明确引用或 Agent 本轮检索/读取的 ProjectArtifact 片段
  -> 当前运行允许的 Tool definitions
```

组装器不得读取 `contextThroughMessageSequence` 之后的消息，即使 Repository 查询时项目已经有
了更新消息。被 Token 预算裁剪的历史仍保持原始先后顺序；ConversationSummary 的
`coveredThroughMessageSequence` 不能超过回复锚点，当前锚点消息必须保留原文。AgentMemory
如果来源于当前 Project，也要过滤掉 `sourceMessageSequence` 大于锚点的条目；来自其他项目
或无项目顺序的长期记忆继续按既有 reuse scope 处理。

ProjectArtifact 不自动全量加入上下文。只有消息固定引用的产物、用户明确选择的产物，或 Agent
通过受权限约束的 search/read Tool 得到的必要片段才进入本轮上下文，并受独立 Token/字节预算
限制。ConversationSummary 也不能代替产物存储：需要长期保存的生成内容必须写为 Artifact。

运行报告只记录使用的 ConversationSummary segment ID、ProjectArtifact/Version ID、AgentMemory
ID、Skill digest 和 Tool 名，不记录密钥、完整产物正文或敏感记忆内容。

## 10. 权限与安全

一次运行可见能力为以下交集：

```text
应用硬限制
  ∩ 平台能力
  ∩ 用户全局授权
  ∩ Agent 已配置的 Skill/MCP 能力
  ∩ Project 策略
  ∩ ProjectMembership 权限
  ∩ 本轮用户审批
```

必须遵守：

- Mention、Delivery 和广播只负责路由，不授予能力；
- AgentDelivery payload、会话消息/摘要、ProjectArtifact、Skill 内容、AgentMemory 和 Tool 输出
  都视为不可信数据；
- `targets` 交付对非目标 Agent 不进入上下文，但用户始终可以审计；
- 项目产物工具从可信运行上下文取得 `projectId/agentId`，不接受模型自行切换；
- Agent 记忆工具从可信运行上下文取得 `agentId`；
- 文件写入、外部写操作、发送远程消息和破坏性操作继续经过 Tool Policy；
- 判断阶段完全禁用 Tool，防止一条广播为每个 Agent 触发副作用；
- 日志只记录 ID、状态、摘要和错误码，不记录 API Key、完整记忆和敏感文件正文；
- 重放和重试不能自动重复已经成功的非幂等 Tool 调用。

## 11. 分层代码设计

本设计继续遵守 Hyve 的分层架构和 MVVM 约束。复杂群体路由、消息摘要、产物权限和 Agent
记忆演化属于 Domain Use Case，不进入 ViewModel。

### 11.1 Domain

建议模型：

```text
lib/domain/models/
├── agent.dart
├── project.dart
├── project_membership.dart
├── project_event.dart
├── project_turn.dart
├── agent_run.dart
├── agent_message_cursor.dart
├── agent_message_receipt.dart
├── agent_delivery.dart
├── conversation_summary.dart
├── project_artifact.dart
├── agent_memory.dart
└── project_storage.dart
```

建议 Repository 契约：

```text
AgentRepository
ProjectRepository
ProjectMembershipRepository
ProjectEventRepository
ProjectTurnRepository
AgentRunRepository
ProjectAgentCursorRepository
AgentMessageReceiptRepository
ProjectStorageRepository
ProjectArtifactRepository
ProjectArtifactImportRepository
ConversationSummaryRepository
AgentMemoryRepository
ModelUsageRepository
```

建议 Use Case：

```text
CreateProject
DeleteProject
AddProjectAgent
RemoveProjectAgent
RouteProjectMessage
WakeAgentInbox
ProcessNextAgentMessage
CatchUpAgentInbox
RunBroadcastParticipation
ExecuteAgentReply
DeliverToProjectAgent
CancelProjectTurn
AssembleAgentRunContext
SearchProjectArtifacts / ReadProjectArtifact / WriteProjectArtifact
ImportProjectArtifacts / CreateProjectArtifactVersion
CompactConversationMessages
EvolveAgentMemory
ResolveAgentCapabilities
```

`RouteProjectMessage` 只负责确定模式、分配消息索引和创建持久化分发计划；
`AgentInboxCoordinator` 负责按 `(projectId, agentId)` 串行领取消息、写 receipt、推进游标和
持续追赶；`ProjectTurnCoordinator` 只收敛一条源消息在多个 Agent 上的直接状态；
`AgentRunCoordinator` 继续负责单个 Agent 的模型/Tool 循环，但请求对象改用
`projectId/turnId/runId/agentId/sourceMessageSequence/contextThroughMessageSequence` 和
作用域明确的 Tool context。

AgentInboxCoordinator 由 `AppDependencies` 以应用级单例组装，不能由
`ProjectWorkspaceViewModel.dispose()` 销毁。ViewModel 只订阅 Repository 快照，因此页面退出
和重新进入不会改变后台消息处理顺序。

### 11.2 Data

```text
lib/data/
├── models/
│   ├── project_records.dart
│   ├── project_event_records.dart
│   ├── agent_run_records.dart
│   ├── agent_inbox_records.dart
│   ├── project_artifact_records.dart
│   ├── conversation_summary_records.dart
│   └── agent_memory_records.dart
├── repositories/
│   ├── sqlite_project_repository.dart
│   ├── sqlite_project_event_repository.dart
│   ├── sqlite_agent_run_repository.dart
│   ├── sqlite_project_agent_cursor_repository.dart
│   ├── sqlite_agent_message_receipt_repository.dart
│   ├── file_project_storage_repository.dart
│   ├── project_artifact_repository_impl.dart
│   ├── sqlite_conversation_summary_repository.dart
│   ├── file_agent_memory_repository.dart
│   ├── vector_agent_memory_repository.dart
│   └── agent_memory_repository_factory.dart
└── services/
    ├── project_storage/
    ├── artifact_import/
    ├── artifact_index/
    ├── agent_memory_storage/
    └── database_service.dart
```

SQLite、文件路径、Provider、MCP 和平台插件仍只位于 Data/Service。Repository 向上返回
不可变领域对象，事件 payload 在 Data record 中严格解码。`agent_memory_records.dart` 映射文件
或向量库记录，不对应 SQLite 表；禁止实现 `sqlite_agent_memory_repository.dart`。

### 11.3 UI

项目相关 UI 调整为：

```text
lib/ui/features/projects/
├── view_models/
│   ├── project_list_view_model.dart
│   ├── project_workspace_view_model.dart
│   ├── project_members_view_model.dart
│   └── project_artifacts_view_model.dart
└── views/
    ├── project_list_page.dart
    ├── project_workspace_page.dart
    ├── project_members_sheet.dart
    ├── project_message_composer.dart
    ├── project_event_list.dart
    └── project_artifacts_panel.dart
```

`ProjectWorkspaceViewModel` 只暴露不可变快照，例如：

- 当前 Project 和 active memberships；
- 已加载的 ProjectEvent 页面；
- 每个 Agent 的 `idle/deciding/replying/catchingUp/paused/failed` 展示状态；
- 每个 Agent 的 `lastProcessedMessageSequence/latestMessageSequence` 和 backlog 数量；
- 当前可取消的 ProjectTurn、AgentRun 和 root 消息链；
- Mention 候选和已选 mention ID；
- 可呈现错误，不暴露 Data 异常或 Provider 原始错误。

View 只处理布局、输入焦点、mention 浮层、滚动、拖放/选择意图和弹窗；实际文件选择、导入和
持久化通过注入 ViewModel 的 Repository/Use Case 完成。发送路由、广播判断、Inbox 顺序消费、
游标提交、交付循环、产物索引/版本、存储权限和记忆策略不能放进 View 或 ViewModel。

### 11.4 需要替换的现有组件

| 现有组件 | 目标组件/处理 |
| --- | --- |
| `Chat` | 独立 `Project` |
| `Bot` | 独立 `Agent` |
| `ChatRepository` | `ProjectRepository` + membership/event repositories |
| `Message`/`MessageRepository` | 类型化 `ProjectEvent`/`ProjectEventRepository` |
| `ConversationMemoryRepository` | `ConversationSummaryRepository` + `AgentMemoryRepository`；不创建 ProjectMemory |
| `ResolveProjectMentions` 的纯文本结果 | Composer mention span + 发送前领域校验 |
| `ChatWorkflowFacade` 的可变 `_bot` | 无 Agent 状态的 ProjectWorkflow + 独立 AgentRun 请求 |
| `generateMentionedReplies` 串行切 Agent | `AgentInboxCoordinator` + `ProjectTurnCoordinator` |
| `ChatGenerationRegistry[chatId]` | `AgentRunRegistry[runId]` + Project-Agent 串行游标 |
| `chats/<chatId>` | `projects/<projectId>` 和 `agents/<agentId>` 两类根目录 |

`AppDependencies.production()` 仍是唯一生产组合根，负责组装 Repository、Use Case、
AgentInboxCoordinator、ProjectTurnCoordinator、Tool Registry 和项目 ViewModel。

## 12. 项目工作区交互调整

### 12.1 项目列表与创建

- 创建项目时可选择零个或多个 Agent；
- 项目列表预览最后一条公开消息和活跃 Agent 头像；
- 没有 Agent 的项目仍可打开，输入后提示当前仅保存消息、不会产生回复；
- 删除项目的确认文案明确说明“不会删除智能体及其长期记忆”。

### 12.2 成员管理

- 项目标题区提供成员入口；
- 支持搜索并添加现有 Agent，不在项目内创建 Agent 副本；
- 支持拖动排序、暂停、恢复、移除；
- 支持为每个成员配置 `none/read/readWrite` 项目存储权限；
- 移除正在运行的 Agent 前提示取消该 Agent 当前运行，其他 Agent 继续；
- Agent 全局删除后，项目中的历史头像和名称快照继续显示。

### 12.3 输入与消息流

- 输入 `@` 打开当前 active Agent 选择器；
- mention 作为可删除、可导航的原子范围，发送时持久化目标 ID；
- 没有 mention 时输入框提示“将广播给项目内全部智能体”；
- 输入框在任意 Agent 回复期间保持可用，连续发送的新消息立即显示；
- 广播后头像状态显示“判断中 / 将回复 / 已跳过 / 回复中 / 追赶中 / 已跟上 / 失败”；
- Agent 状态可显示“已处理 18 / 最新 23”和 backlog 数量，但不把内部审计事件计入消息总数；
- `pass` 不生成普通气泡，只在本轮状态和执行详情中展示；
- AgentDelivery 显示来源、目标、摘要、产物版本引用和后续状态；
- 每条 Agent 回复显示它所回复的消息引用，点击可定位 `replyToMessageId`；
- 同时有多个回复时每个气泡明确展示 Agent 身份，不用切换页面级当前 Agent；
- 停止按钮不占用或禁用输入框；执行详情提供取消单个 AgentRun、某条消息 ProjectTurn 或
  root 消息链的入口。

### 12.4 项目产物

- 项目工作区提供产物面板，支持搜索、类型筛选、预览、版本历史和来源追踪；
- 用户可通过选择文件、拖放、批量导入或新建文本，把各种类型的产物加入项目空间；
- 消息附件可以仅随消息保存，也可以由用户明确提升为项目正式产物；
- Agent 生成或修改的产物显示具体 Agent、run、版本和引用它的消息；
- 用户和 Agent 看到相同的逻辑 Artifact/Version，不直接接触内部绝对路径；
- 权限不足的 Agent 不展示相关 search/read/write Tool，失败时也不能回退到系统文件路径访问；
- 删除会话不会删除项目正式产物；删除项目才删除整个产物空间。

## 13. 不处理历史数据的实施策略

用户已明确不处理历史数据，因此采用一次性新结构：

1. Phase 1 的目标 schema version 固定为 19，数据库目标位置为
   `<application-support>/app.db`；`createSchema` 只创建新的
   `agents/projects/project_* /agent_*` 运行与审计表，不创建任何 AgentMemory 内容表；
2. 首次启动 version 19 时不打开或解析 version 18 业务表，不编写从
   `bots/chats/messages/conversation_memory_*` 到新表的转换，也不保留 version 18 的项目 mention
   修复逻辑作为兼容路径；
3. 一次性重建明确清理旧 `<application-documents>/app.db`、`chats/`，以及目标根中不兼容的
   `app.db`、`projects/`、`agents/`、`.pending_deletions` 和当前 schema 备份/暂存目录；不得递归
   删除整个 Documents、Application Support、用户选择的外部目录或外部向量库；
4. `<application-support>/skills/bundles` 不属于项目/Agent 数据，予以保留；新数据库从已验证的
   bundle manifest 重建 Skill inventory，但不恢复旧 Agent 绑定、激活记录或组织策略；
5. 旧 Bot/Agent、Provider 配置、MCP 配置、Profile 设置、消息、用量、附件、摘要、草稿及 Memory
   均不迁移。旧外部向量库内容不会自动删除，但因后端引用重置而与新 Agent 断开；发布说明和
   首次启动提示必须完整列出这一数据丢失范围，不能只提示“旧消息”；
6. 发现低于 19 的 schema 执行上述一次性重建；发现高于 19 的 schema 继续拒绝打开且不删除；
   version 19 数据损坏时只允许恢复通过完整性校验的 version 19 备份，不能回退解析 version 18；
7. 重建先把精确目标 rename 到独立 reset staging，成功创建并通过 `quick_check`、
   `foreign_key_check` 后再清理；创建失败则恢复 staging，避免数据库和目录只删除一半；
8. 项目附件、摘要、草稿和 AgentMemory 目录不导入新 `projects/` 或 `agents/`；测试 fixture 全部
   按 version 19 新结构创建，只验证重建、回滚和高版本拒绝，不验证旧业务数据升级。

“不迁移历史数据”只取消旧数据转换，不降低新结构内部的数据完整性、事务、删除安全和崩溃
恢复要求。

## 14. 开发阶段

### Phase 0：确认设计（已完成）

- [x] 广播参与判断策略、Token/调用次数上界和失败收敛规则已在 5.3 节锁定；
- [x] 新成员默认项目产物权限 `read`、写权限显式开启已在 8.2 节锁定；
- [x] AgentMemory 自动演化、用户确认边界及文件/外部向量库存储约束已在 7.4、8.3 和 9.2 节
  锁定；
- [x] 交付默认 `project` 且所有交付对用户可审计已在 5.6 节锁定；
- [x] version 19 数据库、旧数据精确清理、失败回滚和高版本拒绝策略已在第 13 节锁定。

Phase 0 的产物是确认后的设计契约，不修改生产 schema 或运行时行为；业务代码从 Phase 1 开始。

### Phase 1：新领域和持久化骨架（已完成）

- [x] 创建 Agent、Project、Membership、Event、Turn、Run 模型和 Repository；
- [x] 创建新 SQLite schema 和文件目录服务；
- [x] 实现项目/智能体独立删除语义；
- [x] 保持智能体、Skill 和 MCP 管理页面功能不变；
- [x] 补齐 Repository、事务、级联和架构门禁测试。

### Phase 2：明确 @ 与广播（已完成）

- [x] 实现结构化 mention composer；
- [x] 实现 RouteProjectMessage 和 ProjectTurnCoordinator；
- [x] 实现项目消息索引、Project-Agent Cursor、逐消息 Receipt 和 AgentInboxCoordinator；
- [x] 实现同 Agent 串行、不同 Agent 并行，以及启动/运行结束时的 backlog 恢复扫描；
- [x] 实现广播 ParticipationDecision；
- [x] 替换共享可变 Bot 和单 chatId generation registry；
- [x] 实现多运行状态、取消、失败隔离和 Token 记录。

### Phase 3：智能体交付（已完成）

- [x] 实现 `project.deliver_to_agent`；
- [x] 实现交付目标、可见性、父子运行和循环限制；
- [x] 实现交付卡片和审计详情；
- [x] 覆盖超时、取消、重复交付和成员被移除场景。

### Phase 4：项目存储（已完成）

- [x] 创建 ProjectStorageRepository、ProjectArtifactRepository 和受控 Tool；
- [x] 实现用户导入、新建、预览、搜索和版本历史；
- [x] 实现 Agent 检索、分块读取、创建产物和写入新版本；
- [x] 实现成员读写权限、路径隔离、原子写、内容索引和变更审计；
- [x] 把需要持久化的附件和生成产物统一纳入 ProjectArtifact；
- [x] 实现项目删除的文件暂存与恢复。

### Phase 5：会话摘要与长期记忆（已完成）

- [x] 把现有 ConversationMemory 调整为只有 ConversationSummary，不创建项目 Memory item；
- [x] 实现按消息范围汇总、摘要提取、来源 digest、失效和重建；
- [x] 实现候选提取、敏感过滤、版本化合并和作用域策略；
- [x] 实现 AgentMemory 跨项目检索、Token 预算和上下文报告；
- [x] 实现用户查看、纠正、忘记和冻结 AgentMemory。

### Phase 6：完整体验和观测

- 完成项目成员、状态、事件流和产物面板；
- 补齐中英文文案、无障碍和响应式布局；
- 增加运行链、交付链、用量和错误诊断；
- 完成端到端、并发、重启恢复、安全和性能验证。

## 15. 测试与验收标准

### 15.1 核心需求验收

1. Project 可独立创建并保持零到多个 Agent，成员可添加、暂停、恢复、排序和移除；
2. 两个以上 Agent 能在同一项目事件流中公开回复并使用结构化 Delivery 交付信息；
3. 有 `@` 只创建目标 AgentRun，无 `@` 时全部 active Agent 完成 reply/pass 判断；
4. 每个 Agent 持久化自己的消息游标，严格按索引从旧到新处理，直到追上项目最新消息；
5. Agent 回复期间的新用户消息和其他 Agent 回复可以立即进入项目，不阻塞输入或彼此运行；
6. 项目不存在 Memory item；ConversationSummary 只能由消息派生、可失效和重建；
7. 用户能向项目空间添加多类型产物，有权限的 Agent 能检索、读取、创建和写入新版本；
8. 只有具备相应权限的 Agent 能读取或写入当前项目产物，不能越界；
9. 删除 Project 后 Agent 仍存在，配置、技能和 AgentMemory 完整；
10. 同一 Agent 加入另一个 Project 时仍使用自己的 Skill/MCP 配置；
11. AgentMemory 跨项目存在、可版本化演化，并防止 sourceProjectOnly 内容泄露；
12. “我的”、Agent CRUD/查询、Skill 管理和 MCP 管理回归测试全部通过。

### 15.2 路由和并发

- 同名 Agent 的 mention 仍通过 ID 精确路由；
- 发送前成员被移除时不会产生悬空运行；
- 多目标回复互不替换配置、取消令牌或流式文本；
- 广播判断失败只影响对应 Agent，全部 pass 不被视为错误；
- 广播 decision 输入/输出预算分别不超过 4096/128 tokens，10 秒超时或非法结果不重试并按
  `pass` 收敛；targeted 和媒体定向消息不创建 decision run；
- 同一 Agent 不会同时处理两个消息索引，不会跳过没有终态 receipt 的可见消息；
- 回复只读取不超过 `contextThroughMessageSequence` 的历史，回复期间的新消息不会混入上下文；
- 当前回复完成后自动处理积压消息，最终 cursor 等于项目最新消息索引；
- 自己的消息和明确发给其他 Agent 的消息会推进游标，但不会触发回复；
- 用户连续输入不会等待 AgentRun，其他 Agent 也不等待当前正在回复的 Agent；
- Agent 公开回复产生的新消息按全局索引被其他 Agent 后续处理；
- 自动 Agent 消息链达到深度或数量限制后仍推进游标，但不继续回复；
- 新加入/重新加入的 Agent 不补发加入前回复；暂停后恢复的 Agent 会从暂停位置顺序追赶；
- 交付链不会自发循环，达到限制后有可见终态；
- 交付请求未指定 visibility 时保存为 `project`；显式 `targets` 对非目标 Agent 不可见，但用户
  仍能查看和审计卡片；
- 取消整轮和取消单个运行均不留下永远 running 的记录；
- 重启不会重复已执行的写 Tool，也不会丢失落后 Cursor 的 backlog；
- 超过重试上限的消息形成 `failedSkipped` receipt，不会永久阻塞整个 inbox。

### 15.3 存储和生命周期

- Project A 的 Agent 无法通过路径构造访问 Project B；
- 用户添加的文档、代码、数据和多媒体产物重启后仍存在并可按元数据搜索；
- Agent 能读取受支持类型的内容或提取文本，不能把整个项目空间自动塞入上下文；
- 修改产物创建新版本，历史消息固定引用的旧版本不被覆盖；
- 新成员未显式指定产物权限时持久化为 `read`；只有用户明确开启后才成为 `readWrite`；
- `read` 成员不能执行创建版本、移动或删除；
- 权限在运行中被收回后，执行时二次校验会拒绝操作；
- 清空对话会删除 ConversationSummary，但保留正式 ProjectArtifact；
- 删除摘要不影响原始消息，源消息变化后 stale 摘要不会注入模型；
- 数据库中不存在 `project_memory_items`、`agent_memory_items`、`agent_memory_state`，也不存在
  保存项目/Agent 记忆正文、摘要或 Embedding 的等价字段；
- 文件后端和外部向量库后端均通过同一 `AgentMemoryRepository` 契约，并通过 CAS 冲突、索引
  重建、敏感过滤和 Agent 作用域隔离测试；
- 项目删除失败可以回滚文件暂存和数据库状态；
- 删除 Project 不级联 AgentMemory；
- 删除 Agent 不级联 Project，历史事件仍可展示快照；
- AgentMemory 文件/外部记录缺失或 digest 不一致时不进入模型上下文；
- version 18 启动 version 19 时只清理已列明的数据库/数据根并保留 Skill bundles；创建失败能
  恢复 reset staging，高于 19 的数据库保持原样并拒绝打开。

### 15.4 工程门禁

- Domain 不依赖 Flutter、Data 或 UI；
- View/ViewModel 不导入 Data 实现或直接访问 SQLite/文件系统；
- 新 record 的 JSON 解码启用严格类型检查；
- 定向单元、Repository、ViewModel、Widget 和 integration tests 通过；
- `dart analyze`、`flutter test test/architecture`、`git diff --check` 通过。

## 16. Phase 0 已确认的产品决策

以下选择于 2026-08-20 确认为实施基线：

1. **广播判断**：每个 active Agent 执行一次低 Token、无 Tool 的模型判断；无效或超时按
   `pass` 处理且不重试；单次最多 4096 输入、128 输出 tokens，超时 10 秒；
2. **顺序与并发**：每个 Project-Agent 严格串行处理消息；不同 Agent 可并行，项目判断最多
   并发 4 个、正式回复最多并发 2 个；用户输入不等待任何 Agent；
3. **项目产物权限**：新成员默认 `read`，`readWrite` 由用户显式开启；
4. **交付可见性**：默认 `project`；`project/targets` 都向用户展示可折叠卡片并可审计，
   `targets` 只限制非目标 Agent 的上下文；
5. **AgentMemory**：普通用户偏好和方法反思可自动跨项目；来源于某个项目会话的事实默认只在
   来源项目使用，private 或不确定跨项目候选需用户确认，凭据和 `secretLike` 内容拒绝保存；
   所有实际记忆只存文件系统或外部向量库，SQLite 只保存策略、后端引用和无正文运行审计；
6. **零成员项目**：允许存在和保存用户消息，但不自动回复；
7. **历史数据**：目标 schema 为 version 19，直接重建数据库和精确的数据目录，不迁移旧
   Agent/Bot、配置、项目、消息、摘要或 Memory；保留并重新校验 Skill bundle 文件；
8. **媒体生成**：第一阶段必须明确 @ 单个 Agent，不参与广播自动判断；
9. **新成员和失败恢复**：新 Agent 从加入时的最新索引开始；暂停后恢复会追赶 backlog；单条
   消息超过重试上限后记录 `failedSkipped` 并继续处理下一条；
10. **自动对话链**：Agent 公开消息会被其他 Agent 按顺序处理；默认最大自动深度为 4、单个
    root 最多产生 16 条 Agent 消息，达到限制后只观察和推进游标。

上述决策已经满足 Phase 1 的进入条件。若任一项调整，必须先修改本节及对应策略、数据契约和
验收项，再开始受影响的实现；不得改变 Project 与 Agent 独立、ProjectEvent 事实流、每个 Agent
的顺序消息游标，以及“项目无记忆、摘要仅由消息派生、长期记忆只属于 Agent”的基础边界。
