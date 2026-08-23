# Hyve

<p align="center">
  <img src="assets/icon/app_icon.png" alt="Hyve logo" width="112" height="112">
</p>

<p align="center">
  <strong>A local-first, project-oriented AI workspace built with Flutter.</strong>
</p>

<p align="center">
  English · <a href="docs/README_zh-CN.md">简体中文</a>
</p>

Hyve brings multiple AI agents into one project workspace. Create agents for
different roles, address them with structured `@mentions`, let the project
broadcast messages when no agent is mentioned, and keep the resulting
conversations, executions, artifacts, context, and memory on your device.

> [!IMPORTANT]
> Hyve is under active development. Back up important data before upgrading and
> review provider usage and charges before running multi-agent workflows.

## What Hyve provides

### Project collaboration

- **Multi-agent projects** — add reusable agents as project members and give
  each member its own model, provider, prompt, and project permissions.
- **Deterministic routing** — use structured `@mentions` for targeted work;
  messages without a valid mention enter the project's broadcast flow.
- **Ordered execution** — work for the same agent is processed serially while
  independent agents can run concurrently.
- **Agent-to-agent delivery** — agents can hand structured messages to other
  project members without turning those messages into user chat input.
- **Observable runs** — inspect execution state, attempts, decisions, token
  usage, errors, and cancellation from the project interface.

### Artifacts, context, and memory

- **Versioned project artifacts** — create text artifacts, import files, attach
  them to messages, and retain version history under project storage rules.
- **Project context** — compact long-running conversations into summaries so
  agents can keep working within model context limits.
- **Agent memory** — preserve agent-scoped memory independently of any one
  project, with file-backed storage by default and optional external vector
  storage.

### Agents, providers, Skills, and MCP

- **Custom agents** — configure provider, model, endpoint, API key, system
  prompt, and supported capabilities per agent.
- **Broad provider support** — connect OpenAI, Anthropic, Gemini, DeepSeek,
  Ollama, OpenRouter, Moonshot, Mistral, Cohere, Perplexity, and other
  OpenAI-compatible services. The canonical registry is
  [`provider_catalog.dart`](lib/domain/models/provider_catalog.dart).
- **Skills** — install reusable instructions and resources from GitHub, an HTTPS
  ZIP, a local ZIP, or a local directory, then enable them per agent.
- **MCP tools** — connect Streamable HTTP servers or trusted desktop stdio
  servers and expose selected tools to agents.
- **Streaming and media** — stream text responses and use image, audio, or video
  workflows when the selected provider and model support them.

### Local-first interface

- **Native Flutter app** — responsive layouts for Windows, macOS, Linux,
  Android, and iOS.
- **Accessible themes** — light, dark, system, and high-contrast appearance
  options.
- **12 interface languages** — English, Simplified Chinese, Traditional Chinese,
  Japanese, French, German, Korean, Russian, Spanish, Hindi, Brazilian
  Portuguese, and Italian.
- **Local persistence** — application state lives in SQLite while project
  artifacts, summaries, audit data, and agent memory live in the application
  support directory.

## How project messaging works

```text
User message
    │
    ├── valid @mentions ──> targeted agent inboxes
    │                         │
    │                         └── same agent: serial execution
    │
    └── no valid mention ──> broadcast participation decision
                              │
                              └── eligible agents may reply or pass

Agent output ──> project event stream ──> messages / deliveries / artifacts
```

Project messages are durable. Each member has a persistent inbox and cursor, so
pending work is recoverable across view changes and application restarts.

## Supported platforms

| Platform | App | Streamable HTTP MCP | stdio MCP |
| --- | :---: | :---: | :---: |
| Windows | ✓ | ✓ | ✓ |
| macOS | ✓ | ✓ | ✓ |
| Linux | ✓ | ✓ | ✓ |
| Android | ✓ | ✓ | — |
| iOS | ✓ | ✓ | — |

The repository contains a Flutter web scaffold, but web is not currently a
supported release target.

## Getting started

### Prerequisites

- [Flutter 3.44.6](https://docs.flutter.dev/get-started/install), pinned in
  [`.fvmrc`](.fvmrc), with Dart 3.7 or later
- A configured Flutter toolchain for the target platform
- An API key for a cloud provider, or a reachable local service such as Ollama
- On Linux, `libsecret-1-dev` at build time and `libsecret-1-0` at runtime for
  secure credential storage

### Run Hyve

```bash
git clone https://github.com/locallocal/hyve.git
cd hyve
flutter pub get --enforce-lockfile
flutter run
```

After the app opens:

1. Create an agent and configure its provider, model, endpoint, API key, and
   system prompt.
2. Create a project and add one or more agents as members.
3. Send a normal message to use broadcast routing, or type `@` and select
   specific agents for targeted routing.
4. Open the project inspector to review members, artifacts, and execution
   details.

Provider availability, model capabilities, and billing are controlled by the
provider. A configured API key may incur charges when a request is sent.

## Data and security model

Hyve is local-first, not end-to-end encrypted collaboration software.

- SQLite stores agents, projects, messages, routing state, execution records,
  preferences, and other structured application state.
- Project artifacts and summaries are stored under `projects/<project-id>`;
  agent memory is stored under `agents/<agent-id>` in the application support
  directory.
- Agent API keys are encrypted with AES-256-GCM before they are written to
  SQLite. The master key, MCP access tokens, and MCP process environment values
  are kept in the operating system's secure credential store.
- Requests, selected context, attachments, and tool inputs leave the device
  when they are sent to a configured AI provider or MCP server. Review those
  services' privacy policies before using sensitive data.
- stdio MCP servers and locally installed Skills are trusted local extensions.
  Inspect their source and grant only the access they require.
- Hyve maintains rolling database backups and stages supported deletions for
  recovery, but this is not a substitute for an independent backup.

The application support directory is organized approximately as follows:

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

Exact locations depend on the operating system and installation type.

## Development

Install locked dependencies and run the repository checks:

```bash
flutter pub get --enforce-lockfile
dart run tool/sync_localizations.dart --check
dart run intl_utils:generate
dart run tool/check_format.dart
dart analyze --fatal-infos
flutter test
flutter build linux --release
```

Run the desktop workflow integration test on a configured Linux host with:

```bash
flutter test integration_test/desktop_workflow_test.dart -d linux
```

### Localization

`intl_utils` is the only localization generator. Generated files under
`lib/generated/` are committed and intentionally excluded from the formatter.
Every locale must contain the same message keys and placeholders as
`lib/l10n/intl_en.arb`.

To add explicit English fallbacks for new keys before translating them:

```bash
dart run tool/sync_localizations.dart --write
dart run intl_utils:generate
```

Review generated changes together with the ARB catalogs. Format only changed,
non-generated Dart files, for example:

```bash
dart format lib/ui/features/example.dart test/example_test.dart
```

### Local build caches

`build/` and `.dart_tool/` are generated and ignored by Git. If the cache is
stale or consumes too much disk space, run `flutter clean`, then restore locked
dependencies with `flutter pub get --enforce-lockfile`.

## Architecture

Hyve follows a layered Flutter architecture with dependencies pointing inward:

```text
View → ViewModel → Use Case → Repository contract
                                   ↑
                    Repository implementation → Service / SQLite / filesystem
```

```text
lib/
├── data/       # Repository implementations, SQLite, provider and storage services
├── domain/     # Business models, repository contracts, and use cases
├── ui/         # Views, view models, dependency injection, and shared widgets
├── l10n/       # Source ARB catalogs
└── generated/  # Generated localization code
```

See [Architecture](docs/architecture.md) for the enforced dependency rules and
design decisions.

## Documentation

| Document | Purpose |
| --- | --- |
| [Architecture](docs/architecture.md) | Layering, dependency direction, and state ownership |
| [Project and agent collaboration](docs/project_agent_collaboration_design.md) | Routing, inboxes, executions, artifacts, and memory |
| [Conversation context compression](docs/conversation_context_compression_design.md) | Summary and context-window strategy |
| [Agent Skill support](docs/agent_skill_support_design.md) | Skill lifecycle, bindings, and execution model |
| [Skill sandbox implementation](docs/skill_sandbox_implementation.md) | Local Skill isolation and security boundaries |
| [Model token usage](docs/model_token_usage_design.md) | Usage accounting and display design |
| [Provider capability inventory](docs/model_providers_and_capabilities_2026-08-03.md) | Provider adapters and capability snapshot |
| [Desktop component matrix](docs/desktop_component_matrix.md) | Desktop UI component coverage |

## Contributing

Contributions are welcome. Read [CONTRIBUTING.md](CONTRIBUTING.md) and the
[Code of Conduct](CODE_OF_CONDUCT.md), then open a focused pull request. Report
security issues privately according to [SECURITY.md](SECURITY.md). User-visible
changes are tracked in [CHANGELOG.md](CHANGELOG.md).

## License

Hyve is licensed under the [GNU Affero General Public License v3.0 only](LICENSE)
(`AGPL-3.0-only`). See [NOTICE](NOTICE) for copyright information. If you modify
Hyve and let users interact with that version over a network, review the
source-code offer requirements in section 13 of the license.
