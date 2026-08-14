# Security Policy

## Supported versions

Security fixes are applied to the latest release and the `main` branch. Older
builds are not maintained; users should upgrade before requesting support.

## Reporting a vulnerability

Do not open a public issue for a suspected vulnerability or include API keys,
tokens, prompts, database contents, or other private data in a report.

Use the repository's **Security** tab to open a private security advisory. Add:

- the affected version and platform;
- reproduction steps or a minimal proof of concept;
- the expected impact;
- any known workaround;
- whether the report contains secrets that need immediate revocation.

Maintainers will acknowledge a complete report within seven days, provide a
status update at least every fourteen days, and coordinate disclosure after a
fix is available. If GitHub private reporting is unavailable, contact the
repository owner through the contact method listed on their GitHub profile and
ask for a private reporting channel without sending vulnerability details.

## Credential handling

Stars stores provider and MCP credentials locally. Never commit real
credentials, paste them into issues or CI logs, or add them to test fixtures.
Revoke any credential that may have been exposed before sharing diagnostics.
