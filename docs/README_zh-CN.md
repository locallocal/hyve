# Hyve

<p align="center">
  <img src="../assets/icon/app_icon.png" alt="Hyve 标志" width="112" height="112">
</p>

<p align="center">
  <strong>使用 Flutter 构建、本地优先、以项目为中心的 AI 工作空间。</strong>
</p>

<p align="center">
  <a href="../README.md">English</a> · 简体中文
</p>

Hyve 将多个 AI 智能体组织在同一个项目工作空间中。你可以为智能体设置不同职责，使用结构化
`@提及` 指定处理者，也可以在未提及智能体时触发项目广播；对话、执行记录、项目产物、上下文
和智能体记忆都会持久化在本机。

> [!IMPORTANT]
> Hyve 正在积极开发中。升级前请备份重要数据；运行多智能体工作流前，请确认模型服务商的
> 用量限制与计费规则。

## 核心能力

### 项目协作

- **多智能体项目**：将可复用的智能体添加为项目成员，并为每个成员配置独立的模型、服务商、
  系统提示词和项目权限。
- **确定性路由**：通过结构化 `@提及` 定向派发任务；没有有效提及时，消息进入项目广播流程。
- **有序执行**：同一个智能体的任务串行处理，不同智能体之间可以并行执行。
- **智能体间交付**：智能体可以向其他项目成员发送结构化消息，不会将交付内容伪装成用户输入。
- **可观测运行**：在项目界面查看执行状态、尝试次数、参与决策、Token 用量、错误和取消状态。

### 项目产物、上下文与记忆

- **版本化项目产物**：新建文本产物、批量导入文件、在消息中添加附件，并按项目存储规则保留
  版本历史。
- **项目上下文**：将长对话压缩为摘要，让智能体可以在模型上下文限制内持续工作。
- **智能体记忆**：跨项目保留智能体级记忆；默认使用文件存储，也可以配置外部向量存储。

### 智能体、服务商、Skills 与 MCP

- **自定义智能体**：分别配置服务商、模型、接口地址、API 密钥、系统提示词和支持的能力。
- **广泛的服务商支持**：可接入 OpenAI、Anthropic、Gemini、DeepSeek、Ollama、
  OpenRouter、Moonshot、Mistral、Cohere、Perplexity，以及其他 OpenAI 兼容服务。
  完整注册表以 [`provider_catalog.dart`](../lib/domain/models/provider_catalog.dart) 为准。
- **Skills**：从 GitHub、HTTPS ZIP、本地 ZIP 或本地目录安装可复用的指令与资源，并按智能体启用。
- **MCP 工具**：连接 Streamable HTTP 服务器，或在桌面端运行可信的 stdio 服务器，并将选定工具
  提供给智能体。
- **流式与媒体能力**：流式接收文本；在所选服务商和模型支持时使用图片、音频或视频工作流。

### 本地优先界面

- **原生 Flutter 应用**：为 Windows、macOS、Linux、Android 和 iOS 提供响应式布局。
- **无障碍主题**：支持浅色、深色、跟随系统和高对比度外观。
- **12 种界面语言**：英语、简体中文、繁体中文、日语、法语、德语、韩语、俄语、西班牙语、
  印地语、巴西葡萄牙语和意大利语。
- **本地持久化**：结构化应用状态保存在 SQLite 中；项目产物、摘要、审计数据和智能体记忆保存在
  应用支持目录中。

## 项目消息如何工作

```text
用户消息
    │
    ├── 有效 @提及 ──> 指定智能体的收件箱
    │                    │
    │                    └── 同一智能体：串行执行
    │
    └── 无有效提及 ──> 广播参与决策
                       │
                       └── 符合条件的智能体可以回复或跳过

智能体输出 ──> 项目事件流 ──> 消息 / 智能体间交付 / 项目产物
```

项目消息采用持久化处理。每个成员都有独立的持久化收件箱和游标，因此切换页面或重启应用后，
尚未完成的工作仍然可以恢复。

## 支持的平台

| 平台 | 应用 | Streamable HTTP MCP | stdio MCP |
| --- | :---: | :---: | :---: |
| Windows | ✓ | ✓ | ✓ |
| macOS | ✓ | ✓ | ✓ |
| Linux | ✓ | ✓ | ✓ |
| Android | ✓ | ✓ | — |
| iOS | ✓ | ✓ | — |

仓库中保留了 Flutter Web 脚手架，但 Web 当前不是正式支持的发布目标。

## 快速开始

### 环境要求

- [Flutter 3.44.6](https://docs.flutter.dev/get-started/install)，版本由
  [`.fvmrc`](../.fvmrc) 固定，并包含 Dart 3.7 或更高版本
- 已为目标平台配置好的 Flutter 开发工具链
- 所选云服务商的 API 密钥，或可以访问的 Ollama 等本地服务
- Linux 构建时需要 `libsecret-1-dev`，运行时需要 `libsecret-1-0`，用于安全凭据存储

### 运行 Hyve

```bash
git clone https://github.com/locallocal/hyve.git
cd hyve
flutter pub get --enforce-lockfile
flutter run
```

应用启动后：

1. 创建智能体，并配置服务商、模型、接口地址、API 密钥和系统提示词。
2. 创建项目，将一个或多个智能体添加为项目成员。
3. 直接发送消息以使用广播路由；输入 `@` 并选择智能体以使用定向路由。
4. 打开项目检查器，查看项目成员、项目产物和执行详情。

模型是否可用、具体能力和费用由服务商控制。配置 API 密钥后，发出请求可能产生费用。

## 数据与安全模型

Hyve 是本地优先应用，但不是端到端加密的协作软件。

- SQLite 保存智能体、项目、消息、路由状态、执行记录、偏好设置及其他结构化应用状态。
- 项目产物和摘要保存在应用支持目录的 `projects/<project-id>` 下；智能体记忆保存在
  `agents/<agent-id>` 下。
- 智能体 API 密钥在写入 SQLite 前使用 AES-256-GCM 加密；主密钥、MCP 访问令牌和 MCP
  进程环境变量保存在操作系统安全凭据存储中。
- 向 AI 服务商或 MCP 服务器发送请求时，所选上下文、附件和工具输入会离开本机。处理敏感数据
  前，请确认相关服务的隐私政策。
- stdio MCP 服务器和本地安装的 Skills 属于可信本地扩展。安装前请检查源码，只授予必要权限。
- Hyve 会维护滚动数据库备份，并暂存支持恢复的删除操作，但不能替代独立备份。

应用支持目录大致采用以下结构：

```text
Hyve/
├── app.db
├── projects/<project-id>/
│   ├── artifacts/
│   ├── context/summaries/
│   ├── audit/
│   └── tmp/
└── agents/<agent-id>/memory/
```

具体路径取决于操作系统和安装方式。

## 开发

安装锁定版本的依赖并运行仓库检查：

```bash
flutter pub get --enforce-lockfile
dart run tool/sync_localizations.dart --check
dart run intl_utils:generate
dart run tool/check_format.dart
dart analyze --fatal-infos
flutter test
flutter build linux --release
```

在已经配置好桌面环境的 Linux 主机上运行工作流集成测试：

```bash
flutter test integration_test/desktop_workflow_test.dart -d linux
```

### 本地化

`intl_utils` 是项目唯一的本地化代码生成器。`lib/generated/` 下的生成文件会提交到仓库，
并且有意排除在格式化工具之外。每种语言必须包含与 `lib/l10n/intl_en.arb` 相同的消息键和占位符。

为新增消息键生成明确的英文回退内容，然后再进行翻译：

```bash
dart run tool/sync_localizations.dart --write
dart run intl_utils:generate
```

请将生成文件和 ARB 语言目录的变更一起检查，并且仅格式化发生改动的非生成 Dart 文件，例如：

```bash
dart format lib/ui/features/example.dart test/example_test.dart
```

### 本地构建缓存

`build/` 和 `.dart_tool/` 都是生成目录，已经被 Git 忽略。如果缓存过期或占用空间过大，请运行
`flutter clean`，然后使用 `flutter pub get --enforce-lockfile` 恢复锁定版本的依赖。

## 项目架构

Hyve 采用依赖向内的 Flutter 分层架构：

```text
视图 → ViewModel → 用例 → 仓库接口
                           ↑
              仓库实现 → 服务 / SQLite / 文件系统
```

```text
lib/
├── data/       # 仓库实现、SQLite、服务商和存储服务
├── domain/     # 业务模型、仓库接口和用例
├── ui/         # 视图、ViewModel、依赖注入和共享组件
├── l10n/       # ARB 语言源文件
└── generated/  # 生成的本地化代码
```

有关强制执行的依赖规则和设计决策，请参阅[架构文档](architecture.md)。

## 设计文档

| 文档 | 内容 |
| --- | --- |
| [项目架构](architecture.md) | 分层、依赖方向和状态所有权 |
| [项目与智能体协作](project_agent_collaboration_design.md) | 路由、收件箱、执行、项目产物和记忆 |
| [对话上下文压缩](conversation_context_compression_design.md) | 摘要和上下文窗口策略 |
| [智能体 Skill 支持](agent_skill_support_design.md) | Skill 生命周期、绑定和执行模型 |
| [Skill 沙箱实现](skill_sandbox_implementation.md) | 本地 Skill 隔离和安全边界 |
| [模型 Token 用量](model_token_usage_design.md) | 用量统计和展示设计 |
| [服务商能力清单](model_providers_and_capabilities_2026-08-03.md) | 服务商适配与能力快照 |
| [桌面组件矩阵](desktop_component_matrix.md) | 桌面界面组件覆盖情况 |

## 参与贡献

欢迎参与贡献。请阅读 [`CONTRIBUTING.md`](../CONTRIBUTING.md) 和
[`CODE_OF_CONDUCT.md`](../CODE_OF_CONDUCT.md)，然后提交范围明确的 Pull Request。
安全问题请按照 [`SECURITY.md`](../SECURITY.md) 私下报告；面向用户的变更记录在
[`CHANGELOG.md`](../CHANGELOG.md) 中。

## 开源许可

Hyve 按 [GNU Affero General Public License v3.0 only](../LICENSE)（`AGPL-3.0-only`）授权。
版权信息请参阅 [`NOTICE`](../NOTICE)。如果你修改 Hyve 并通过网络让用户与修改后的版本交互，
请阅读许可证第 13 节关于提供源代码的要求。
