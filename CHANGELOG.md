# Changelog

All notable user-visible changes to Stars are documented here. The format is
based on Keep a Changelog, and the project uses semantic versioning.

## [Unreleased]

### Added

- GitHub Actions quality gates for locked dependency resolution, localization
  generation, formatting, analysis, architecture/database tests, the complete
  test suite, and a Linux release build.
- Public security, contribution, conduct, and licensing policies.
- Localization key/placeholder parity checks and a smoke test for every
  supported locale.

### Changed

- Unified the application identifier as `io.github.locallocal.stars` on all
  release platforms and added migration reads for legacy Apple secure-storage
  namespaces.
- Standardized localization generation on `intl_utils` and the Italian catalog
  name on `intl_it_IT.arb`.
- Removed unused direct dependencies identified by the engineering audit.

### Documentation

- Updated desktop architecture, quality commands, release conventions, and
  local/CI cache guidance to match the current implementation.

[Unreleased]: https://github.com/locallocal/stars/commits/main
