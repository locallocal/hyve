# 模型供应商、模型目录与代码能力清单（2026-08-03）

本文以 Hyve 当前代码为边界，记录截至 2026-08-03 的供应商入口、公开模型目录、
模型能力和适配器实现状态。它同时是一份模型目录维护规范：新增模型或供应商时，应按
“模型元数据”和“运行时能力”两个层次更新，而不能仅凭模型名称开放功能。

## 1. 范围与口径

- 当前 UI 注册了 **47 个供应商入口**，对应
  [`Bot.getAllApiTypes()`](../lib/domain/models/bot.dart) 中 **44 种可实例化 API 类型**。
- `AIStudio` 与 `Gemini` 共用 `gemini` 适配器；`OpenAI`、`ChatGLM`、
  `SiliconFlow` 共用 `openai` 适配器，所以入口数大于 API 类型数。
- `apiTypeAzure` 只有常量，没有供应商入口和工厂分支，不计入“当前支持”。
- 本文的“模型列表”只覆盖 Hyve 有调用契约的模型类型：对话/推理、多模态输入、
  图片、语音、音乐和视频生成。Embedding、Rerank、Moderation 等模型即使被
  `/models` 返回，也不代表 Hyve 可以正确调用。为完整说明 OpenAI 目录，第 4.1 节
  额外收录其全部官方模型条目，包括 Hyve 尚无调用契约的 Embedding 和 Moderation。
- 第一方、数量稳定的目录列出明确模型 ID；聚合平台、模型市场、本地部署和账号授权
  目录不复制可能随时变化的数百个 ID，而记录官方目录接口，并以其在
  **2026-08-03 的账号返回结果**为准。
- “当前模型”指官方仍公开可调用或标为 Preview/Labs 的模型。已退役模型只在代码
  兼容性问题中出现，不作为推荐模型。

代码事实来源：

- 供应商入口与默认地址：
  [`provider_catalog.dart`](../lib/domain/models/provider_catalog.dart)
- API 类型与助手能力开关：[`bot.dart`](../lib/domain/models/bot.dart)
- 适配器工厂：
  [`ai_provider_repository_impl.dart`](../lib/data/repositories/ai_provider_repository_impl.dart)
- 内置模型元数据：
  [`built_in_model_catalog.dart`](../lib/data/services/ai/built_in_model_catalog.dart)
- 在线目录通用映射：
  [`provider_service.dart`](../lib/data/services/ai/provider_service.dart)
- 结构化工具能力：
  [`ai_provider_repository.dart`](../lib/domain/repositories/ai_provider_repository.dart)

## 2. 代码中的模型能力

### 2.1 `AiModelInfo` 必须维护的模型级字段

| 字段 | 含义 | 代码要求 |
| --- | --- | --- |
| `inputModalities` | `text/image/audio/video/file` 输入 | 决定附件选择和消息序列化；不能只用“Vision”名称猜测 |
| `outputModalities` | `text/image/audio/video` 输出 | 非文本输出必须有对应的 `generate*` 实现 |
| `supportsWebSearch` | 供应商原生联网搜索 | 适配器必须发送供应商要求的 tool/search 参数，单有布尔值无效 |
| `supportsDeepThinking` | 推理/思考模式 | 适配器必须发送 reasoning/thinking 参数，并解析 reasoning delta |
| `supportsDeepResearch` | 长时间、多轮深度研究 | 需要专用异步/轮询或流式协议；目前只有 Perplexity 元数据有该标记 |
| `supportsMcp` | 可在客户端 MCP Agent Loop 中调用工具 | 还必须满足供应商运行时支持结构化工具调用和工具结果回传 |
| `supportsSkills` | 可应用本地 Skill 提示/上下文 | 不等于模型可自动选择 Skill |
| `supportsAutomaticSkillActivation` | 可通过结构化工具调用自动激活 Skill | 还必须满足运行时 Agent Loop 能力 |
| `supportsHostedSkills` | 供应商可托管不可变 Skill 包 | 当前没有适配器实现 |
| `contextWindowTokens` | 输入与输出共享上下文上限 | 未知必须保留 `null`，不能当作 0 |
| `maxOutputTokens` | 单次最大输出 | 未知必须保留 `null` |
| `releaseDate` | 模型发布日期 | 用于目录排序和快照审计 |

在线 `/models` 响应会从 `architecture`、`supported_parameters`、
`capabilities`、`top_provider` 等常见字段映射这些元数据；精确第一方模型再由内置
目录补齐缺失值。在线响应显式给出的值优先，内置值只补空缺。

### 2.2 模型能力不等于适配器能力

`AiProviderCapabilities` 还要求适配器实现：

1. 结构化工具调用事件；
2. 工具结果回传；
3. 可选的并行工具调用；
4. 可选的 Hosted Skills。

当前只有 `OpenAI` 和 `Anthropic` 两个适配器实现类声明了结构化工具调用、工具结果
回传和并行工具调用。因此：

- 第一方 **OpenAI、Anthropic** 内置模型已同时具备模型标记和运行时能力，可直接使用
  MCP Agent Loop 与 Skill 自动激活；
- `ChatGLM`、`SiliconFlow` 因复用 `OpenAI` 实现类也会继承运行时能力，但默认没有
  第一方内置模型标记。只有具体兼容端点确实支持相同工具协议，并由在线元数据或用户
  配置明确开启时才可能运行，不能视作全平台保证；
- 其他在线目录即使返回 `tools`/`tool_calling`，通用映射可以记录模型原生能力，
  但运行时门禁仍会关闭 MCP 和自动激活；
- Hosted Skills 当前对所有供应商都不可用；
- 内置目录目前把所有内置模型的 `supportsSkills` 和
  `supportsAutomaticSkillActivation` 设为 `true`，但后者仍受上述运行时门禁限制。

### 2.3 已实现的非文本调用

| 能力 | 当前覆盖的适配器 |
| --- | --- |
| 图片生成 | AlibabaCloud、Baidu、DeepInfra、Flux、Grok、HuggingFace、MiniMax、ModelScope、Monica、Nebius、Novita、OpenAI（GPT Image，兼容旧 DALL·E）、Stability、StepFun、TogetherAI、VolcanoEngine、XingHe、ZhiPu |
| 语音生成 | MiniMax、OpenAI |
| 音乐生成 | MiniMax |
| 视频生成 | MiniMax、OpenAI、VolcanoEngine |

这张表表示“代码存在覆写”，不保证旧模型 ID、旧地址和请求参数在快照日期仍可用。

## 3. Hyve 内置模型元数据

以下 23 个 ID 会在第一方 `/models` 结果缺失或分阶段发布时被补入目录。`T/I/A/V/F`
分别表示文本、图片、音频、视频和文件输入；输出均为文本。

| 供应商 | 模型 ID | 输入 | 上下文 / 最大输出 | Web | 思考 | 深研 | MCP / 自动 Skill（当前有效） |
| --- | --- | --- | ---: | :---: | :---: | :---: | :---: |
| OpenAI | `gpt-5.6-sol` | T/I | 1,050,000 / 128,000 | 是 | 是 | 否 | 是 / 是 |
| OpenAI | `gpt-5.6`（别名） | T/I | 1,050,000 / 128,000 | 是 | 是 | 否 | 是 / 是 |
| OpenAI | `gpt-5.6-terra` | T/I | 1,050,000 / 128,000 | 是 | 是 | 否 | 是 / 是 |
| OpenAI | `gpt-5.6-luna` | T/I | 1,050,000 / 128,000 | 是 | 是 | 否 | 是 / 是 |
| Anthropic | `claude-fable-5` | T/I | 1,000,000 / 128,000 | 是 | 是 | 否 | 是 / 是 |
| Anthropic | `claude-opus-5` | T/I | 1,000,000 / 128,000 | 是 | 是 | 否 | 是 / 是 |
| Anthropic | `claude-sonnet-5` | T/I | 1,000,000 / 128,000 | 是 | 是 | 否 | 是 / 是 |
| Anthropic | `claude-haiku-4-5-20251001` | T/I | 200,000 / 64,000 | 是 | 是 | 否 | 是 / 是 |
| Anthropic | `claude-haiku-4-5`（别名） | T/I | 200,000 / 64,000 | 是 | 是 | 否 | 是 / 是 |
| Gemini | `models/gemini-3.6-flash` | T/I/A/V/F | 1,048,576 / 65,536 | 是 | 是 | 否 | 否 / 否 |
| Gemini | `models/gemini-3.5-flash` | T/I/A/V/F | 1,048,576 / 65,536 | 是 | 是 | 否 | 否 / 否 |
| Gemini | `models/gemini-3.5-flash-lite` | T/I/A/V/F | 1,048,576 / 65,536 | 是 | 是 | 否 | 否 / 否 |
| Gemini | `models/gemini-3.1-pro-preview` | T/I/A/V/F | 1,048,576 / 65,536 | 是 | 是 | 否 | 否 / 否 |
| xAI | `grok-4.5` | T/I | 500,000 / 未公开 | 是 | 是 | 否 | 否 / 否 |
| DeepSeek | `deepseek-v4-flash` | T | 1,000,000 / 384,000 | 否 | 是 | 否 | 否 / 否 |
| DeepSeek | `deepseek-v4-pro` | T | 1,000,000 / 384,000 | 否 | 是 | 否 | 否 / 否 |
| Mistral | `mistral-medium-3-5` | T/I | 256,000 / 未公开 | 否 | 是 | 否 | 否 / 否 |
| Mistral | `mistral-small-2603` | T/I | 256,000 / 未公开 | 否 | 是 | 否 | 否 / 否 |
| Mistral | `mistral-small-latest`（别名） | T/I | 256,000 / 未公开 | 否 | 是 | 否 | 否 / 否 |
| Perplexity | `sonar` | T | 128,000 / 未公开 | 是 | 否 | 否 | 否 / 否 |
| Perplexity | `sonar-pro` | T | 200,000 / 未公开 | 是 | 否 | 否 | 否 / 否 |
| Perplexity | `sonar-reasoning-pro` | T | 128,000 / 未公开 | 是 | 是 | 否 | 否 / 否 |
| Perplexity | `sonar-deep-research` | T | 128,000 / 未公开 | 是 | 是 | 是 | 否 / 否 |

官方核对来源：
[OpenAI Models](https://developers.openai.com/api/docs/models)、
[Anthropic Models Overview](https://platform.claude.com/docs/en/about-claude/models/overview)、
[Gemini Models](https://ai.google.dev/gemini-api/docs/models)、
[xAI Grok 4.5](https://docs.x.ai/developers/models/grok-4.5)、
[DeepSeek Models & Pricing](https://api-docs.deepseek.com/quick_start/pricing/)、
[Mistral Models](https://docs.mistral.ai/models/overview)、
[Perplexity Sonar Models](https://docs.perplexity.ai/docs/sonar/models)。

## 4. 全部供应商与模型目录

状态说明：

- **内置 + 在线**：合并 Hyve 内置快照和供应商在线目录；
- **在线**：调用 `/models` 或供应商等价接口，模型 ID 以账号返回为准；
- **静态/手填**：代码不读取模型目录，需要用户输入或代码内判断；
- **本地**：模型由用户部署决定；
- **迁移/退场**：默认地址或产品状态已变化，不应继续按正常供应商展示。

### 4.1 OpenAI 完整模型目录与特性

本节依据 OpenAI Developer Docs 的[完整模型目录](https://developers.openai.com/api/docs/models)
及各模型卡核对。这里的“完整”指该目录在 2026-08-03 展示的 **93 个主模型 ID**；
日期快照只在关键表格中列出，不把每个历史快照重复计为独立模型。`gpt-5.6` 是额外的
路由别名，指向 `gpt-5.6-sol`。Hyve 的实际支持状态按当前
[`openai.dart`](../lib/data/services/ai/openai.dart) 请求路由、消息序列化和响应解析判断。

#### 4.1.1 当前推荐的 GPT-5.6

| 模型 ID | 定位 | 上下文 / 最大输入 / 最大输出 | 知识截止 | 输入 → 输出 | API |
| --- | --- | ---: | --- | --- | --- |
| [`gpt-5.6-sol`](https://developers.openai.com/api/docs/models/gpt-5.6-sol)（`gpt-5.6` 别名） | 复杂专业工作、推理和编码的旗舰 | 1,050,000 / 922,000 / 128,000 | 2026-02-16 | T/I → T | Responses、Chat Completions、Batch |
| [`gpt-5.6-terra`](https://developers.openai.com/api/docs/models/gpt-5.6-terra) | 智能与成本平衡 | 1,050,000 / 922,000 / 128,000 | 2026-02-16 | T/I → T | Responses、Chat Completions、Batch |
| [`gpt-5.6-luna`](https://developers.openai.com/api/docs/models/gpt-5.6-luna) | 低成本、高吞吐 | 1,050,000 / 922,000 / 128,000 | 2026-02-16 | T/I → T | Responses、Chat Completions、Batch |

三者共同支持 Streaming、Structured Outputs、Function Calling、File Search、图片输入、
Web Search 和 Prompt Caching；官方原生工具为 `web_search`、`file_search`、
`image_generation`、`code_interpreter`、`hosted_shell`、`apply_patch`、`skills`、
`computer_use`、`mcp`、`tool_search`。Hyve 当前只接通文本/图片输入、推理、
Web Search、Function Calling，以及由客户端执行的 MCP/Skill Agent Loop；并未接通
OpenAI 托管的 Skills、MCP、Shell、Computer Use、Code Interpreter、File Search、
Image Generation 或 Tool Search。

#### 4.1.2 官方完整主模型 ID

以下列表与官方模型目录逐项对应。

**GPT、推理与编码模型（50 个）**

```text
gpt-5.6-sol              gpt-5.6-terra             gpt-5.6-luna
gpt-5.5                  gpt-5.5-pro
gpt-5.4                  gpt-5.4-mini               gpt-5.4-nano
gpt-5.4-pro              gpt-5.3-codex
gpt-5.2                  gpt-5.2-pro                gpt-5.2-codex
gpt-5.1                  gpt-5.1-codex              gpt-5.1-codex-mini
gpt-5.1-codex-max        gpt-5                      gpt-5-mini
gpt-5-nano               gpt-5-pro                  gpt-5-codex
codex-mini-latest
gpt-4.1                  gpt-4.1-mini               gpt-4.1-nano
gpt-4o                   gpt-4o-mini
o1                       o1-mini                    o1-pro
o1-preview               o3                         o3-mini
o3-pro                   o4-mini                    computer-use-preview
gpt-3.5-turbo            gpt-4                      gpt-4-turbo
gpt-4-turbo-preview      gpt-4.5-preview            babbage-002
davinci-002
chat-latest              gpt-5-chat-latest          gpt-5.1-chat-latest
gpt-5.2-chat-latest      gpt-5.3-chat-latest        chatgpt-4o-latest
```

此外 `gpt-5.6` 是 `gpt-5.6-sol` 的别名，不是独立模型卡。

**搜索与深度研究（4 个）**

```text
gpt-4o-search-preview             gpt-4o-mini-search-preview
o3-deep-research                  o4-mini-deep-research
```

**图片与视频生成（7 个）**

```text
gpt-image-2              gpt-image-1.5             gpt-image-1
gpt-image-1-mini         chatgpt-image-latest
sora-2                   sora-2-pro
```

**音频对话与实时模型（15 个）**

```text
gpt-audio-1.5                    gpt-audio
gpt-audio-mini                   gpt-4o-audio-preview
gpt-4o-mini-audio-preview
gpt-realtime-2.1                 gpt-realtime-2.1-mini
gpt-realtime-2                   gpt-realtime-1.5
gpt-realtime                     gpt-realtime-mini
gpt-realtime-translate           gpt-realtime-whisper
gpt-4o-realtime-preview          gpt-4o-mini-realtime-preview
```

**转写与语音生成（9 个）**

```text
gpt-transcribe                   gpt-live-transcribe
gpt-4o-transcribe                gpt-4o-mini-transcribe
gpt-4o-transcribe-diarize        whisper-1
gpt-4o-mini-tts                  tts-1
tts-1-hd
```

**Embedding、Moderation 与开放权重（8 个）**

```text
text-embedding-3-large           text-embedding-3-small
text-embedding-ada-002
omni-moderation-latest           text-moderation-latest
text-moderation-stable
gpt-oss-120b                     gpt-oss-20b
```

#### 4.1.3 模型家族特性

`R`、`C`、`B`、`A`、`I`、`V`、`E`、`M` 分别代表 Responses、Chat Completions、
Batch、Audio、Images、Videos、Embeddings、Moderation API。“Hyve”列表示当前代码的
实际执行能力，而不是 OpenAI 原生能力。

| 模型/家族 | 模态 | API | 上下文 / 最大输出 | OpenAI 原生特性 | Hyve 当前状态 |
| --- | --- | --- | ---: | --- | --- |
| GPT-5.6 Sol/Terra/Luna | T/I → T | R/C/B | 1.05M / 128K | 推理、结构化输出、Functions、Web/File Search、图片输入、缓存及完整托管工具集 | **可用**：文本、图片、推理、Web、MCP/自动 Skill；托管工具未接 |
| GPT-5.5 | T/I → T | R/C/B | 1.05M / 128K | `none/low/medium/high/xhigh` 推理、Functions、Web、File、Computer、Skills、MCP 等 | **可用**：Responses 文本/图片/推理/Web、客户端 Functions/MCP/自动 Skill；托管工具未接 |
| GPT-5.5 Pro | T/I → T | R/B | 1.05M / 128K | `medium/high/xhigh`，长任务建议 Background；无 Chat Completions | **可用**：按元数据走 Responses；Background 和托管工具未接 |
| GPT-5.4 | T/I → T | R/C/B | 1.05M / 128K | `none/low/medium/high/xhigh`，工具集接近 5.6 | **可用**：模型元数据、Responses 路由、推理/Web 和客户端工具已接 |
| GPT-5.4 mini/nano | T/I → T | R/C/B | 400K / 128K | 高吞吐推理、Functions、Web、File、图片输入、缓存；mini 另有 Computer/Tool Search | **可用**：图片/推理/Web/客户端工具按型号元数据开放；托管 Computer/Tool Search 未接 |
| GPT-5.4 Pro | T/I → T | R | 1.05M / 128K | `medium/high/xhigh`、Functions、Web、File、Image、Computer、MCP | **可用**：Responses 文本、推理、Web 和客户端工具；托管工具未接 |
| GPT-5.3-Codex | T/I → T | R | 400K / 128K | Agentic coding、Functions、Web、Hosted Shell、Skills | **部分可用**：Responses 文本/推理/Web 和客户端工具；Hosted Shell/Hosted Skills 未接 |
| GPT-5.2 / 5.1 / 5 | T/I → T | R/C/B | 400K / 128K | 可配置推理、Functions、Web/File Search、图片输入、缓存；具体工具随代际不同 | **可用**：按完整元数据选择 Responses/Chat，并开放图片、推理、Web 和客户端工具 |
| GPT-5.2/5 Pro | T/I → T | R（部分含 B） | 400K / 128K；5 Pro 最大输出 272K | 高算力推理、Background、Functions、Web/File/MCP | **可用**：Responses 文本/推理/Web 和客户端工具；Background 未接 |
| GPT-5.3/5.2 Chat | T/I → T | R/C | 128K / 16,384 | ChatGPT Instant 快照、结构化输出、Functions、图片输入 | 已标 Deprecated 并从新增选择器过滤 |
| GPT-5.1/5 Chat、`chat-latest` | T/I → T | R/C | 128K 或 400K / 16K 或 128K | ChatGPT/Instant 浮动快照 | 可用；按生命周期标为 Previous，浮动快照不作为可复现默认值 |
| GPT-5.x Codex 与 `codex-mini-latest` | T/I → T | R | 200K–400K / 100K–128K | Agentic coding、Functions；新代际含 Web、Shell、Skills | **部分可用**：Responses 文本/推理和客户端工具；Codex 托管 Shell/Skills 未接 |
| GPT-4.1 / mini / nano | T/I → T | R/C/B/Assistants | 1,047,576 / 32,768 | 非推理、低延迟、Functions、结构化/预测输出、File、微调；Web 支持因型号不同 | **可用**：按型号元数据区分图片、Web 和端点；托管 File Search 等未接 |
| GPT-4o / mini | T/I → T | R/C/B/Assistants | 128K / 16,384 | Functions、结构化/预测输出、File、图片输入、Web、微调 | **可用**：文本/图片、Web 和客户端工具按元数据路由；非推理模型 |
| o3 / o3-pro / o4-mini | T/I → T | R/C/B（Pro 为 R/B） | 200K / 100K | 推理、Functions、Web/File、Code Interpreter、MCP；Pro 高算力 | **可用**：图片、推理、Web 和 Responses/Chat 路由已修正；托管 File/Code 未接 |
| o3-mini | T → T | R/C/B/Assistants | 200K / 100K | 小型推理、结构化输出、Functions、File/Code/MCP | **可用**：文本/推理/客户端工具；元数据明确不接受图片 |
| o1 / o1-pro | T/I → T | R/C/B（Pro 为 R/B） | 200K / 100K | 推理、Functions、File、MCP；Pro 高算力 | **可用**：o1 按支持端点路由，Pro 正确走 Responses |
| o1-mini / o1-preview | T → T | C/Assistants | 128K / 65,536 或 32,768 | 早期推理；能力有限 | 可发 Chat；属于旧模型，不应作为新默认值 |
| GPT-4o Search Preview | T → T | C | 128K / 16,384 | 模型内建 Web Search、Streaming、结构化输出 | **可用**：固定走 Chat Completions 并发送 `web_search_options` |
| o3/o4 Deep Research | T/I → T | R/B | 200K / 100K | 多步研究、Web Search、Code Interpreter、MCP | **不可用并过滤**：尚无 Deep Research 长任务与托管 Code Interpreter 契约 |
| GPT Image 2 / 1.5 / 1 / mini | T/I → I（1.5 还可 T） | I/B；1 另有 R | 不适用 | 图片生成、编辑、Inpainting；GPT Image 2 为当前推荐 | **可用**：Images API 生成、参考图编辑、Base64 解码和本地文件写入已接 |
| Sora 2 / Pro | T/I → V/A | V | 不适用 | 带同步音频的视频生成 | **可用**：创建任务、参考图上传、状态轮询、失败处理和 MP4 下载已接 |
| GPT Audio / 4o Audio | T/A → T/A | C | 128K / 16,384 | 音频输入输出、Streaming、Functions | **不可用**：消息只序列化图片，响应只解析文本 delta |
| GPT-Realtime 2.x | T/A/I → T/A | Realtime | 128K / 32K | 可配置推理、Functions、缓存、WebRTC/WebSocket/SIP | **不可用**：没有 Realtime 项目层 |
| GPT-Realtime 1.x / 4o Preview | T/A/I 或 T/A → T/A | Realtime | 16K–32K / 4,096 | 实时语音、Functions、缓存 | **不可用** |
| Realtime Translate / Whisper | A（Whisper 可 T）→ A/T 或 T | 专用 Realtime | 16K / 2K | 流式同传或流式转写 | **不可用** |
| GPT Transcribe / Live Transcribe / GPT-4o Transcribe / Whisper | A/T → T | Transcription/Realtime/Translation | 新模型未公开；4o 为 16K / 2K | 文件或实时转写、语言提示；Diarize 可区分说话人 | **不可用**：无转写仓库契约 |
| GPT-4o mini TTS / TTS-1 / TTS-1 HD | T → A | Speech | 不适用 | 文本转语音；分别偏新模型、低延迟和高质量 | **可用**：Speech API、按模型限制声音列表、MP3 下载和本地写入已接 |
| Embedding 3 large/small、Ada 002 | T → 向量 | E/B | 未在模型卡列出 | 搜索、聚类、推荐、异常检测、分类 | **不可用**：无 Embeddings 契约，必须从对话选择器过滤 |
| Omni/Text Moderation | T/I 或 T → 分类 | M/B | 不适用 | 有害内容检测；Omni 支持图片并为推荐默认值 | **不可用**：无 Moderation 契约，必须过滤 |
| GPT-OSS 120B / 20B | T → T | R/B | 131,072 / 131,072 | Apache 2.0、可调推理、完整 CoT、可微调、Functions/Web/Code/MCP | OpenAI 云端可走 Responses 文本/推理/客户端工具；本地兼容部署仍独立探测协议 |
| Computer Use Preview | T/I → T | R/B | 8,192 / 1,024 | Computer Use 专用、Function Calling | **不可用**：无 computer action/event loop |
| GPT-3.5、GPT-4/Turbo、GPT-4.5、Babbage/Davinci | T 或 T/I → T | C/R/Legacy Completions | 8K–128K / 4K–16K | Legacy、Preview 或 Deprecated；Babbage/Davinci 仅旧 Completions + 微调 | 部分 Chat 模型可发；Legacy Completions 不可用，均不应作为新默认值 |

#### 4.1.4 生命周期与选择器规则

- 新项目默认使用 GPT-5.6：复杂任务选 Sol，成本/能力平衡选 Terra，高吞吐低成本选 Luna。
- `gpt-5.3-chat-latest`、`gpt-5.2-chat-latest`、`gpt-4.5-preview` 已标为
  Deprecated；`chatgpt-4o-latest` 已从 API 移除。
- `chat-latest` 和 ChatGPT `*-chat-latest` 是浮动快照，适合体验 ChatGPT 当前行为，
  不适合要求固定回归结果的生产助手。
- GPT-5.5/5.4/5.2/5.1/5、GPT-4.1/4o 和 o-series 仍出现在完整目录中，但大多已被
  新一代模型取代；选择器应显示“Previous/Legacy”，而不是与 GPT-5.6 同级推荐。
- DALL·E 2/3 已不在当前完整模型目录中。Hyve 已迁到 GPT Image
  2/1.5/1/mini 的生成和编辑接口；DALL·E 2/3 只保留旧配置兼容，不再补入当前目录。

#### 4.1.5 已补齐的代码特性与剩余边界

`AiModelInfo` 已新增以下字段，用来承载 OpenAI 完整目录，并与 `/models` 返回的账号
可用性合并：

| 所需字段 | 用途 |
| --- | --- |
| `taskType` | 区分 Chat、Image、Video、Audio、Realtime、Transcription、Embedding、Moderation、Legacy Completion |
| `lifecycle`、`currentSnapshot` | 标记 Recommended/Previous/Preview/Deprecated/Removed，并支持固定快照 |
| `maxInputTokens`、`knowledgeCutoff` | 展示 1.05M 模型的 922K 输入上限及知识截止日期 |
| `supportedEndpoints` | 在 Responses、Chat Completions、Realtime、Images 等正确端点间路由 |
| `reasoningEfforts` | 避免给只支持 `medium/high/xhigh` 的 Pro 模型发送无效档位 |
| `supportedFeatures` | 精确表达 Streaming、Structured/Predicted Outputs、Fine-tuning、Prompt Caching、Background 等 |
| `nativeTools` | 将 OpenAI 托管工具与 Hyve 客户端 MCP/Skill Agent Loop 分开表示 |

本次实现结果与剩余边界：

1. 对话选择器已按 `taskType` 和生命周期过滤专用任务、Deprecated 与 Removed 模型。
2. 请求已按 `supportedEndpoints` 选择 Responses 或 Chat Completions；Web 开关不再决定
   主端点，Search Preview 仍固定使用 Chat Completions。
3. 93 个官方主 ID、`gpt-5.6` 别名和旧 DALL·E 兼容项已进入静态元数据，并与第一方
   `/models` 合并；兼容 OpenAI 协议的第三方供应商不会继承该目录和能力。
4. GPT-5.x、GPT-4.x、o-series、Codex 与 GPT-OSS 的图片、推理、Web、端点和工具能力
   已由目录元数据驱动，客户端 Function/MCP/自动 Skill 使用统一 Responses Agent Loop。
5. GPT Image 的生成/编辑、Sora 的创建/轮询/下载、TTS 的 Speech API 已实现。Realtime、
   完整音频输入输出、Transcription、Embedding、Moderation、Deep Research 和 Computer
   Use 仍缺少对应领域契约，因此继续从对话选择器过滤。
6. 已添加 Responses-only、Chat-only、专用生成、函数调用回传、兼容供应商隔离和生命周期
   过滤的离线测试；由于本次未创建 API Key，未执行真实账号接口验证。

### 4.2 第一方模型供应商

| UI 入口（API 类型） | 截至 2026-08-03 的模型列表 | 目录状态 | Hyve 当前特性与需要补齐的代码 |
| --- | --- | --- | --- |
| **OpenAI** (`openai`) | 第 4.1 节已列出官方目录的 93 个主模型 ID 和 `gpt-5.6` 别名；账号实际可用范围以 `/v1/models` 为准 | 内置 + 在线 | GPT-5.x、GPT-4.x、o-series、Codex 与 GPT-OSS 已按 Responses/Chat 元数据路由，客户端 MCP/自动 Skill 已接；GPT Image 生成/编辑、Sora 和 TTS 已接。Realtime/完整音频、转写、Embedding、Moderation、Deep Research、Computer Use 仍不可用并过滤 |
| **Anthropic** (`anthropic`) | `claude-fable-5`、`claude-opus-5`、`claude-sonnet-5`、`claude-haiku-4-5-20251001`、`claude-haiku-4-5` | 内置 + 在线 | T/I、Web、thinking、MCP、自动 Skill 已接通；继续从模型卡维护上下文和输出上限 |
| **AIStudio / Gemini** (`gemini`) | 稳定：`gemini-3.6-flash`、`gemini-3.5-flash`、`gemini-3.5-flash-lite`、`gemini-3.1-flash-lite`；Preview：`gemini-3.1-pro-preview`、`gemini-3-flash-preview`；图片：`gemini-3.1-flash-image`、`gemini-3-pro-image`；Live/TTS/Omni 以[官方列表](https://ai.google.dev/gemini-api/docs/models)为准 | 内置 + 在线 | T/I/A/V/F、Web、thinking 已有调用路径；图片输出、Live/TTS 与结构化工具事件未接到统一契约，MCP/自动 Skill 不可用；应补入 `gemini-3.1-flash-lite` 及生成模型元数据 |
| **DeepSeek** (`deepseek`) | `deepseek-v4-flash`、`deepseek-v4-pro`；旧 `deepseek-chat`、`deepseek-reasoner` 已于 2026-07-24 退役，见[更新日志](https://api-docs.deepseek.com/updates/) | 内置 + 在线 | 两者均为 T、thinking、JSON、tool calls；只有 Flash 当前支持 Responses API。旧代码仍保留 `deepseek-reasoner` 判断，应删除；若要启用 MCP/自动 Skill，需实现结构化工具项目和工具结果回传，而非只读目录字段 |
| **Grok / xAI** (`grok`) | `grok-4.5` 及别名 `grok-4.5-latest`、`grok-build-latest`；其他当前文本、推理和 `grok-imagine-image` 模型以[模型接口](https://docs.x.ai/developers/rest-api-reference/inference/models)为准 | 内置 + 在线 | `grok-4.5` 的 T/I、Web、thinking 已标注，图片生成有实现；代码中的 `grok-3-mini-beta` 判断已过期；工具调用未接入 Agent Loop |
| **Mistral** (`mistral`) | 通用：`mistral-medium-3-5`、`mistral-small-2603`/`mistral-small-latest`、Mistral Large 3、Ministral 3（14B/8B/3B）；专项：`voxtral-tts-2603`、`labs-leanstral-1-5`、`mistral-ocr-4-0`、OCR 3、Voxtral Mini Transcribe 2/Realtime、Codestral、Codestral Embed、Voxtral Small、`mistral-moderation-2603` | 内置 + 在线 | 对话主线 T/I、reasoning、256K 已标注；在线模型卡能返回 function calling，但适配器未实现工具事件；OCR/TTS/转录/Embedding/Moderation 不应出现在对话选择器 |
| **Perplexity** (`perplexity`) | Search：`sonar`、`sonar-pro`；Reasoning：`sonar-reasoning-pro`；Research：`sonar-deep-research`，见[官方 Sonar 模型表](https://docs.perplexity.ai/docs/sonar/models) | 内置 + 在线 | 四个模型的 Web、thinking、deep research 元数据已覆盖；当前适配器没有结构化工具项目，MCP/自动 Skill 不可用。Agent API 的第三方模型预设不应混入 Sonar Chat 目录 |
| **Cohere** (`cohere`) | Live Chat：`command-a-plus-05-2026`、`command-a-03-2025`、`command-r7b-12-2024`、`command-a-translate-08-2025`、`command-a-reasoning-08-2025`、`command-a-vision-07-2025`、`command-r-08-2024`、`command-r-plus-08-2024`；另有 Aya 系列，旧无日期 `command`/`command-r`/`command-r-plus` 已 Deprecated，见[官方模型页](https://docs.cohere.com/v1/docs/models) | 在线 | 当前代码统一当作 T、无 Web/思考；应读取模型卡的 Vision、Reasoning、tool use、上下文和输出上限，并实现 Cohere 原生工具结果协议后再开放 MCP |
| **AlibabaCloud / Model Studio** (`alibabacloud`) | 当前主线：Qwen 3.7（Plus/Max）、Qwen 3.6、Qwen 3.5、Qwen3-Coder；视觉/图片/音视频模型以[模型发布页](https://help.aliyun.com/zh/model-studio/newly-released-models)和[视觉模型表](https://help.aliyun.com/zh/model-studio/vision-model)为准 | 在线 | Chat、部分 VL 和图片生成已实现；Web、thinking、模态判断仍主要匹配 Qwen Max/Plus、DeepSeek R1、Qwen2.5-VL 等旧 ID，必须改为目录元数据或新家族规则 |
| **Baidu / 千帆** (`baidu`) | 官方推荐：ERNIE 5.0、ERNIE 5.1、ERNIE 4.5 Turbo 128K、DeepSeek V4 Pro；完整模型由[千帆模型列表](https://cloud.baidu.com/doc/qianfan-docs/s/7m95lyy43)维护 | 静态/手填 | 代码拒绝拉取目录，但官方已经提供 [`GET /v2/models`](https://cloud.baidu.com/doc/qianfan-api/s/Dmba8k71y)；应实现目录、更新 ERNIE 5.x 的 Web/思考/视觉元数据，并按端点区分图片模型 |
| **BaiChuan** (`baichuan`) | 公开 API 文档仍列 `Baichuan2-Turbo`、`Baichuan2-Turbo-192k`，见[官方 API 文档](https://platform.baichuan-ai.com/docs/api?activity=true) | 静态/手填 | 仅 T 文本，代码不拉目录；不要推测未公开的新 ID，若产品无可用模型应在 UI 隐藏 |
| **MiniMax** (`minimax`) | 文本：`MiniMax-M2.7`、`MiniMax-M2.7-highspeed`、`MiniMax-M2.5`、`MiniMax-M2.5-highspeed`、`MiniMax-M2.1`、`MiniMax-M2.1-highspeed`、`MiniMax-M2`；图片：`image-01`、`image-01-live`；音乐：`music-2.6`；另有 Speech 2.8、Hailuo 2.3、M2-her，见[官方 API 概览](https://platform.minimaxi.com/docs/api-reference/api-overview) | 静态/手填 | 图片、语音、音乐、视频调用均有实现，但特性判断仍使用 `MiniMax-Text-01`、`music-01`、`I2V-01` 等旧 ID；需整体迁移模型路由和输入/输出模态 |
| **Moonshot** (`moonshot`) | Moonshot 公共文档明确展示 `kimi-k2.5` 多模态模型；账号可用模型以 `/v1/models` 为准，见[官方文档](https://platform.moonshot.ai/docs/guide/prompt-best-practice) | 在线 | 当前只用模型名是否含 `thinking`/`vision` 推断能力，无法覆盖 Kimi 新命名；应优先解析在线元数据并为图像输入、reasoning、tool call 建立显式映射 |
| **StepFun** (`stepfun`) | 文本/推理：`step-3.5-flash`、`step-3`、`step-2-mini`、`step-2-16k`、`step-1-8k`、`step-1-32k`、`step-r1-v-mini`；视觉：`step-1o-turbo-vision`、`step-1o-vision-32k` 等；图片：`step-image-edit-2`、`step-2x-large`、`step-1x-edit`、`step-1x-medium`，见[模型总览](https://platform.stepfun.com/docs/zh/guides/models/overview) | 在线 | 文本、视觉和图片生成已有实现；Web 规则仍含大量 Step 1 旧 ID，`step-3.5-flash`/`step-3` 的工具、思考和上下文需补元数据 |
| **Spark / 讯飞星火** (`spark`) | Spark X2、Spark X2 Flash、Spark Ultra、Spark Pro、Spark Lite，见[星火 API](https://xinghuo.xfyun.cn/sparkapi) | 静态/手填 | 代码不拉目录，Web 判断只识别 `pro-128k`、`max-32k`、`4.0Ultra`；需要新 ID、上下文、推理和多模态映射 |
| **SenseNova / 商汤日日新** (`sensenova`) | SenseNova V6.5 Pro、V6.5 Omni、V6.5 Miaohua、V6.5 Character，见[官方 API 服务](https://platform.sensenova.cn/product/APIService/document) | 在线 | 现有逻辑仍围绕 SenseChat Vision 和 DeepSeek R1/V3；需要为 V6.5 的 Omni 输入、图片输出、thinking/Web 能力建模 |
| **Tencent** (`tencent`) | 新 TokenHub 主线含 `hy3`、`hy3-preview`、`hy-mt2-pro`、`hy-mt2-plus`，同时聚合 DeepSeek V4、GLM 5.1、Kimi K2.6、MiniMax M2.7 等；以[TokenHub 模型列表](https://cloud.tencent.com/document/product/1823/130051)和 [`GET /v1/models`](https://cloud.tencent.com/document/product/1823/130078)为准 | 迁移 | 代码仍指向旧 `api.hunyuan.cloud.tencent.com` 且拒绝拉目录；应迁到 `https://tokenhub.tencentmaas.com/v1`，替换 Hunyuan T1/旧 Vision 判断。旧平台计划于 2026-09-30 关闭 |
| **VolcanoEngine / 火山方舟** (`volcanoengine`) | 当前主线包括 Doubao Seed 2.0、Seedance 2.0、Seedream 5.0；账号模型/接入点以[方舟模型广场](https://www.volcengine.com/docs/82379/1795150)为准 | 静态/手填 | 图片和视频生成有实现，但代码不拉目录，且视觉/思考仍匹配 Doubao 1.5 的日期 ID；需要按 Endpoint ID 与 Foundation Model ID 分开建模 |
| **ZhiPu / 智谱** (`zhipu`) | GLM 5.2、GLM-5V-Turbo、GLM-Image；另有 GLM-4.6V、GLM-OCR、AutoGLM-Phone、GLM-4.1V-Thinking-FlashX、GLM-4.6V-Flash、GLM-4V-Flash、CogView 4/3 Flash，见[官方模型总览](https://docs.bigmodel.cn/cn/guide/start/model-overview) | 静态/手填 | 文本和图片生成有实现，但代码不拉目录；思考仍判断 `glm-zero`/`glm-z1`，视觉只识别旧 GLM-4V ID，必须更新并区分 Chat、OCR、Agent、图片端点 |
| **InternLM** (`internlm`) | `intern-latest` → `intern-s2-preview-397b`、`internvl3.5-latest` → `internvl3.5-241b-a28b`、`intern-s2-preview-397b`、`intern-s2-preview-35b`、`intern-s2-preview`、`intern-s1-pro`、`intern-s1`、`intern-s1-mini`、`internvl3.5-241b-a28b`，见[官方模型列表](https://internlm.intern-ai.org.cn/doc/docs/%E6%A8%A1%E5%9E%8B%E5%88%97%E8%A1%A8/) | 在线 | 代码视觉判断仍是 InternVL 2.5，且所有模型都标为无思考；需更新 InternVL 3.5 模态及 Intern S2/S1 reasoning 能力 |
| **Jina** (`jina`) | `jina-deepsearch-v1`，见[Jina DeepSearch](https://jina.ai/deepsearch/) | 静态/手填 | 模型本身包含搜索、推理和研究流程；代码却标为无 Web、仅 thinking，并拒绝目录。应内置唯一模型并标记 Web/Deep Research，核对其流式事件和引用格式 |
| **ZeroOneAI / 零一万物** (`zerooneai`) | `yi-lightning`、`yi-vision-v2`，见[官方平台](https://platform.lingyiwanwu.com/) | 在线 | 代码注释已列这两个 ID，但所有模型仍统一 T、无思考；必须给 `yi-vision-v2` 添加 I 输入并避免把非 Chat 模型暴露给对话选择器 |

### 4.3 聚合平台、推理云与模型市场

这些供应商的“完整模型列表”必须在运行时读取；静态复制会在发布后很快失真。

| UI 入口（API 类型） | 2026-08-03 模型目录 | 目录状态 | Hyve 当前特性与需要补齐的代码 |
| --- | --- | --- | --- |
| **AiHubMix** (`aihubmix`) | 官方新目录 [`GET /api/v1/models`](https://docs.aihubmix.com/en/api/Models-API) 返回类型、features、输入模态、上下文和最大输出；账号可用列表另见 `/api/user/available_models` | 在线 | 代码仍请求 Legacy `/v1/models`，只能拿 ID，且把 Web 对所有模型设为 true；应迁新目录并直接映射 `thinking/tools/web/deepsearch`，再按适配器能力关闭无实现功能 |
| **AiMass** (`aimass`) | 公共官方目录不可稳定核对；代码已知文本/推理 ID：`taichu_o1`、`deepseek_r1`、三个 DeepSeek R1 Distill；视觉：`taichu_vl`、`taichu_vl_2b`、`taichu_vlr_7b`、`taichu_vlr_3b`；语音：`taichu_tts` | 静态/手填 | 代码拒绝目录；以上只能作为“代码兼容列表”，不能视作 2026 官方在售保证。应接入账号目录或在无法验证时隐藏入口 |
| **Cerebras** (`cerebras`) | Serverless Production：`gpt-oss-120b`；Preview：`gemma-4-31b`、`zai-glm-4.7`（计划 2026-08-17 下线）；Dedicated 另有更多家族，以[官方模型页](https://inference-docs.cerebras.ai/models/overview)和 `/v1/models` 为准 | 在线 | 当前统一 T、无思考/工具；应读取图片输入、上下文、reasoning/tool 元数据，并注意已退役的 Llama 3.1 8B/Qwen 旧 ID |
| **DeepInfra** (`deepinfra`) | 100+ 文本、视觉、图片、语音模型，以[官方模型目录](https://docs.deepinfra.com/models)和[列表 API](https://docs.deepinfra.com/api-reference/models/models-list)为准 | 在线 | Chat 与若干图片模型有实现；思考统一 false、图片输出靠旧 ID 白名单。应按任务类型过滤目录，并把视觉/推理/上下文映射到 `AiModelInfo` |
| **Fireworks** (`fireworks`) | Serverless、On-demand、Fine-tuned 模型以[官方模型总览](https://docs.fireworks.ai/models/overview)和[列表 API](https://docs.fireworks.ai/api-reference/list-models)为准 | 在线 | 当前所有模型统一 T、无思考；需要读取模型 kind、context、supports tools/vision，并过滤非 Chat 部署 |
| **HuggingFace** (`huggingface`) | Hugging Face Inference Providers 的模型与后端组合由[官方目录](https://huggingface.co/docs/inference-providers/en/index)动态决定；Hyve 预置 Cerebras、Cohere、Fal-AI、Fireworks-AI、Hyperbolic、HF-Inference、Nebius、Novita、Replicate、SambaNova、Together 11 个路由 | 在线 | 当前存在大量 Qwen2/LLaVA 等名称规则，Web/思考均 false；应优先使用统一 Router 元数据，按后端能力处理 Chat、Vision、Whisper、图片生成，不能把同一请求格式用于所有后端 |
| **InfiniGence** (`infinigence`) | 无问芯穹 MaaS 的可用模型随账号和区域变化，以 `GET https://cloud.infini-ai.com/maas/v1/models` 返回为准 | 在线 | 思考与视觉规则仍匹配 DeepSeek R1、QwQ、Qwen2.5-VL；应以在线目录为准补 DeepSeek V4/Qwen 新家族，无法公开核对的字段保持 `null` |
| **ModelScope** (`modelscope`) | API-Inference 可调用的社区模型动态变化；模型页明确支持 OpenAI 兼容地址 `https://api-inference.modelscope.cn/v1`，例如 `Qwen/Qwen3-VL-235B-A22B-Instruct`，见[API-Inference 文档](https://www.modelscope.cn/docs/model-service/API-Inference/intro) | 在线 | Chat 和图片生成有实现，但模型类型过滤与模态规则停留在 Qwen2/2.5；应读取任务类型，支持 Qwen3/3.5 VL/Thinking，并避免把任意社区仓库当作在线可调用模型 |
| **Monica** (`monica`) | 模型由[官方 Models & Pricing](https://platform.monica.im/docs/en/models-and-pricing)和账号 `/v1/models` 动态给出，覆盖 OpenAI、Anthropic、Gemini、xAI、Llama、Mistral 等 | 在线 | Chat 和图片生成有实现，但 Vision 白名单与 Web/思考判断过旧；聚合模型能力必须来自目录，不能继承底层厂商名称猜测 |
| **Nebius** (`nebius`) | 原 AI Studio 已迁至 Token Factory，模型以[Token Factory `/models`](https://docs.tokenfactory.nebius.com/api-reference/models/list-models)为准 | 迁移 | 代码仍使用 `api.studio.nebius.com`，而[官方迁移指南](https://docs.tokenfactory.nebius.com/other-capabilities/migration-guide)要求改为 `https://api.tokenfactory.nebius.com/v1`，旧 Key 已在 2026-01-31 后失效；迁移鉴权后还需替换旧 Qwen/LLaVA/DeepSeek R1 规则和图片端点 |
| **Novita** (`novita`) | 语言、图片等模型以[官方 `GET /models`](https://novita.ai/docs/api-reference/model-apis-llm-list-models)及账号权限为准 | 在线 | Chat 和图片生成已实现；当前只有名称含 DeepSeek R1 才标思考，视觉一律 T，应直接映射目录模型类型与能力 |
| **OpenRouter** (`openrouter`) | 全量模型以[官方 `GET /api/v1/models`](https://openrouter.ai/docs/api/api-reference/models/get-models)为准，响应包含 architecture、context、`supported_parameters` | 在线 | 通用元数据映射最完整；但 OpenRouter adapter 未实现结构化工具事件，目录中的 `tools` 只能表示模型原生能力，MCP/自动 Skill 仍必须关闭 |
| **PPIO** (`ppio`) | 当前模型以[官方 LLM Models API](https://ppio.com/docs/models/reference-llm-list-models)的 `GET /openai/v1/models` 为准 | 静态/手填 | 官方已有目录但代码仍抛出“不提供目录”，默认 `api.ppinfra.com/v3` 也与新文档不同；应迁地址、实现目录并移除仅识别 DeepSeek R1 的旧规则 |
| **SambaNova** (`sambanova`) | Production：`MiniMax-M2.7`、`DeepSeek-V3.1`、`Meta-Llama-3.3-70B-Instruct`、`gpt-oss-120b`；Preview：`DeepSeek-V3.2`、`gemma-3-12b-it`、`Llama-4-Maverick-17B-128E-Instruct`，见[官方模型表](https://docs.sambanova.ai/docs/en/models/sambacloud-models) | 在线 | 当前所有模型 T，只有 DeepSeek R1 名称才标思考；应更新当前 ID、Vision、上下文与工具能力 |
| **SiliconFlow** (`openai`) | 文本、图片、音频、视频模型以[官方 `GET /v1/models`](https://docs.siliconflow.cn/cn/api-reference/models/get-model-list)为准，可用 `type=text/image/audio/video` 筛选 | 在线 | 因复用 OpenAI adapter，`provider != openai` 会阻止注入 OpenAI 内置目录，这是正确的；但结构化工具能力会被 OpenAI adapter 整体声明为可用，必须改为按 SiliconFlow 具体模型/协议验证后开放 |
| **TogetherAI** (`togetherai`) | 当前 Serverless Chat：`thinkingmachines/Inkling`、`thinkingmachines/Inkling-Small`、`MiniMaxAI/MiniMax-M3`、`Qwen/Qwen3.7-Max`、`Qwen/Qwen3.7-Plus`、`Qwen/Qwen3.6-Plus`、`Qwen/Qwen3.5-9B`、`moonshotai/Kimi-K3`、`moonshotai/Kimi-K2.7-Code`、`moonshotai/Kimi-K2.6`、`zai-org/GLM-5.2`、`openai/gpt-oss-120b`、`openai/gpt-oss-20b`、`deepseek-ai/DeepSeek-V4-Pro`、`nvidia/nemotron-3-ultra-550b-a55b`、`meta-llama/Llama-3.3-70B-Instruct-Turbo`、`Qwen/Qwen2.5-7B-Instruct-Turbo`、`google/gemma-4-31B-it`、`pearl-ai/gemma-4-31b-it`、`deepcogito/cogito-v2-1-671b`、`google/gemma-3n-E4B-it`、`LiquidAI/LFM2.5-8B-A1B`；图片/视频/音频等见[官方 Serverless Models](https://docs.together.ai/docs/serverless/models) | 在线 | Chat 和图片生成已实现；Vision/思考规则仍大量匹配 Llama 3.2、Qwen2.5、DeepSeek R1，需改用目录元数据并补当前模型；还需按任务端点过滤图片、视频、音频模型 |

### 4.4 本地、账号部署和退场入口

| UI 入口（API 类型） | 模型列表 | 目录状态 | Hyve 当前特性与需要补齐的代码 |
| --- | --- | --- | --- |
| **Ollama** (`ollama`) | 完全取决于本机已安装模型；权威列表是本机 [`GET /api/tags`](https://docs.ollama.com/api/tags) | 本地 | 代码能读取本机模型，但目录只提供 family/量化等有限信息；Vision、thinking、tools 应结合 `/api/show` 的 capabilities，而不是仅返回 ID |
| **ChatGLM** (`openai`) | 取决于 `localhost:8000` 上的 OpenAI 兼容部署，不存在统一列表 | 本地 | 复用 OpenAI adapter，但不能因此注入 OpenAI 第一方模型；当前 `_builtInProviderId` 已避免注入，仍需按部署 `/models` 与实际 tool protocol 决定能力 |
| **XingHe / 百度星河** (`xinghe`) | 取决于 AI Studio 账号的部署/授权模型；代码默认 `aistudio.baidu.com/llm/lmapi/v3` | 静态/手填 | 代码拒绝目录且仍使用 ERNIE 3.5/4.0/4.5 Preview 判断；应接账号部署列表，无法验证正常目录前不应展示固定模型 |
| **Stability** (`stability`) | 当前生成服务：Stable Image Ultra、Core、Stable Diffusion 3.5 Large、3.5 Large Turbo、3.5 Medium、3.5 Flash；SDXL 1.0 为 Legacy，见[官方平台](https://platform.stability.ai/)和[API Reference](https://platform.stability.ai/docs/api-reference) | 静态/手填 | v2beta 是“服务端点”而非统一 `/models`；现有 Ultra/SD3/SD3.5 路由需补 Core、Flash，并按 `generate/core`、`generate/ultra`、`generate/sd3` 选择端点，不能假设通用模型目录 |
| **Flux / Black Forest Labs** (`flux`) | `flux-2-max`、`flux-2-pro-preview`、`flux-2-pro`、`flux-2-flex`、`flux-2-klein-4b`、`flux-2-klein-9b-preview`、`flux-2-klein-9b`、`flux-kontext-max/pro`、`flux-pro-1.1-ultra`、`flux-pro-1.1`、`flux-pro`、`flux-dev`，见[官方生成模型列表](https://docs.bfl.ai/quick_start/generating_images) | 静态/手填 | 代码只识别四个 Flux 1.x ID；需要补 Flux 2/Kontext 的参考图、尺寸、轮询和输出元数据 |
| **Search1Api** (`search1api`) | 官方已说明 Reasoning 模型和 `/v1/models` **永久停止**，当前产品只提供 search/crawl，见[官方 Models 说明](https://www.search1api.com/docs/utility/models) | 退场 | 现有 Chat provider 已失效，应从供应商 UI 隐藏/删除；如果保留 Search1API，应改造成 Web Search 工具而不是模型供应商 |
| **Lambda** (`lambda`) | Lambda Hosted Inference API 正在退场，已无可长期维护的公共 Serverless 模型清单，见[官方 Inference 页面](https://lambda.ai/inference) | 退场 | 应从默认供应商隐藏；仅在用户明确配置仍存活的兼容端点时作为自定义 OpenAI provider 使用 |
| **Kluster** (`kluster`) | Kluster 官方站已公告团队加入 MITO 并结束原产品，见[官方公告](https://docs.kluster.ai/)；`api.kluster.ai/v1` 不再有可维护的公共模型目录 | 退场 | 代码仍请求旧 `/models`；应从默认供应商隐藏/删除，已有自定义兼容部署应迁为通用 OpenAI 端点 |

## 5. 目录实现现状

以下 13 个适配器的 `fetchModels()` 当前明确抛出“不提供外部模型目录”：

`AiMass`、`BaiChuan`、`Baidu`、`Flux`、`Jina`、`MiniMax`、`PPIO`、`Spark`、
`Stability`、`Tencent`、`VolcanoEngine`、`XingHe`、`ZhiPu`。

其中并非都真的没有官方目录：Baidu、PPIO、Tencent 已有公开列表接口，应改为在线目录；
Flux、Stability 更适合维护官方静态“服务/端点”清单；Jina 只有一个明确模型，可直接内置。

其余适配器会尝试在线拉取，但“能请求 `/models`”不等于目录正确：

- 模型市场可能混入 Embedding、Rerank、图片、音频、微调或不可调用仓库；
- 聚合平台返回的 `tools` 是底层模型能力，不代表 Hyve adapter 已实现工具结果回传；
- 账号权限、区域和部署 Endpoint 会使同一供应商返回不同列表；
- 旧基础地址可能仍返回 200，但目录已经冻结或产品正在迁移。

## 6. 建议的代码调整优先级

### P0：避免向用户展示失效入口

1. 隐藏或移除 Search1Api 的 Chat provider；如需保留，改为搜索工具。
2. 将 Tencent 迁移到 TokenHub 地址和模型目录，赶在旧平台关闭前完成。
3. 隐藏 Lambda，删除 Kluster 默认供应商入口。
4. 迁移 Nebius AI Studio 到 Token Factory。

### P1：让模型目录成为能力真源

1. 为 Baidu、PPIO、Tencent 实现官方 `/models`；为 Jina、Flux、Stability 维护小型官方静态目录。
2. 给目录结果增加任务类型过滤，只把可对话模型放入助手的对话模型选择器；图片、
   音频、视频分别进入对应选择器。
3. 扩展通用映射，支持供应商实际返回的字符串数字、嵌套 capabilities、任务类型、
   endpoint/deployment ID，同时未知字段保持 `null`。
4. 将供应商文件中不断增长的 model-name `switch` 迁到可测试的模型目录元数据。

### P1：修正工具与 Skill 能力边界

1. `supportsMcp` 和 `supportsAutomaticSkillActivation` 不应仅由在线目录的 `tools`
   自动推导为可运行；应分别保存“模型原生 tool use”和“Hyve 已实现 Agent Loop”。
2. 为 Gemini、Mistral、Cohere、OpenRouter、SiliconFlow 等逐个实现并测试
   `openModelSession`、tool-call delta、tool result 和终止原因后，再开启运行时门禁。
3. OpenAI 兼容不代表工具事件完全兼容；ChatGLM、SiliconFlow 等必须做协议级能力探测。

### P2：更新模型能力规则

优先更新 DeepSeek V4、Qwen 3.7/3.6/3.5、ERNIE 5.x、GLM 5.x、Kimi 新模型、
MiniMax M2.7、Intern S2/InternVL 3.5、Spark X2、SenseNova V6.5、Flux 2、
Doubao Seed 2.0 等新家族，删除 DeepSeek R1、Qwen2.5-VL、GLM-Z1、Doubao 1.5
等已不能代表当前目录的硬编码判断。

## 7. 后续维护规则

每次更新此快照或 `BuiltInModelCatalog` 时：

1. 只使用供应商官方模型页、API Reference、Changelog 或真实账号 `/models` 响应；
2. 记录核对日期，区分 Stable、Preview/Labs、Deprecated/Retired 和 Alias；
3. 同时核对模型 ID、输入/输出模态、上下文、最大输出、Web、Thinking、Research、
   Tool Use 和发布日期；
4. 对 Web、Thinking、多模态、Tool Call 至少增加一个请求序列化测试和一个响应解析测试；
5. 对动态目录保存脱敏 fixture，测试任务过滤和 `AiModelInfo` 映射；
6. 供应商宣布迁移或退场时，先在 UI 停止新增配置，再提供已有助手的迁移路径。

聚合平台的模型列表不应在本文中人工全量展开；官方目录接口及 Hyve 运行时过滤逻辑才是
可维护的真源。
