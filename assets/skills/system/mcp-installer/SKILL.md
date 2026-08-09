---
name: mcp-installer
description: Install a Stars MCP server from user-provided Streamable HTTP or stdio connection details, store credentials securely, and optionally connect it. Use when the user asks to add, configure, register, or install an MCP server in Stars.
allowed-tools: add_mcp_server
metadata:
  scope: system
  prompt-version: 1
---

# Install an MCP server

Install exactly one MCP server with `add_mcp_server`. Use only connection
details the user supplied or explicitly confirmed.

## Workflow

1. Determine whether the transport is `streamable_http` or `stdio`.
2. Ask for any required value that is missing. Do not invent endpoints,
   commands, arguments, credentials, or environment variables.
3. Call `add_mcp_server` once after the user confirms the configuration and
   approves the write/process/network action.
4. Report the returned server ID, transport, connection status, discovered
   Tool count, and any connection error code. If the server was saved but its
   connection failed, say that it remains configured; do not add it again.

## Input fields

Always pass:

- `name`: the user-facing server name.
- `transport_type`: `streamable_http` or `stdio`.
- `connect`: whether Stars should connect and discover Tools immediately;
  default to `true` unless the user asks to save the configuration only.

For `streamable_http`, pass:

- `endpoint`: an absolute public HTTPS endpoint.
- `auth_type`: `none` or `oauth_access_token`; default to `none`.
- `access_token`: required when `auth_type` is `oauth_access_token`.

For `stdio`, pass:

- `command`: the executable name or absolute executable path.
- `arguments`: an ordered string array; never combine arguments into a shell
  command.
- `environment`: a string-to-string map containing only variables explicitly
  supplied by the user.

The Tool refuses duplicate server names and never overwrites an existing
server. Credentials are written to secure credential storage and are never
returned. Never place credentials in the server name, endpoint URL, command,
arguments, or final response.
