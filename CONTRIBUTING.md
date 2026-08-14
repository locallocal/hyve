# Contributing to Stars

Thank you for contributing. Keep each change focused, explain the user-visible
impact, and add regression coverage for behavior changes.

## Development setup

Stars pins Flutter in `.fvmrc`. Install that version, then run:

```bash
flutter pub get --enforce-lockfile
dart run tool/sync_localizations.dart --check
dart run intl_utils:generate
dart run tool/check_format.dart
dart analyze --fatal-infos
flutter test
```

Linux release changes must also pass:

```bash
flutter build linux --release
```

Generated localization sources under `lib/generated/` are committed but are
excluded from the formatter. Regenerate them with `intl_utils`; do not edit
them by hand. Review the regenerated Git diff before committing it.

## Localization changes

`intl_utils` is the only localization generator. Add a message to
`lib/l10n/intl_en.arb`, provide the same key and placeholders in every catalog,
then regenerate. `tool/sync_localizations.dart --write` can add missing English
fallbacks mechanically, but translated copy should replace those fallbacks
before release. Italian uses the canonical `intl_it_IT.arb` filename.

## Architecture

Follow `docs/architecture.md`. Views and ViewModels depend on domain contracts;
only the production composition root may import data implementations. Platform
plugins remain behind data-layer services or repositories. Architecture rules
are executable tests in `test/architecture/`.

## Database and provider changes

The application supports only the current database schema. A schema change
must update the schema version, exact schema snapshot, reset/reopen tests, and
release notes. Do not add a partial migration without an approved product
decision.

Provider changes require focused adapter tests for malformed responses,
timeouts, cancellation, typed failures, usage-only events where applicable,
and secret redaction. Document provider removals, endpoint changes, and model
capability changes in `CHANGELOG.md`.

## Pull requests

- Use a focused branch and conventional commit messages.
- Keep unrelated formatting or generated changes out of the PR.
- Describe manual verification and any platform not tested.
- Update `CHANGELOG.md` for user-visible, provider, database, security, or
  release-configuration changes.
- Never include production secrets or user data.

By participating, you agree to follow `CODE_OF_CONDUCT.md`.
