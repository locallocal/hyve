const mcpInstallerSkillId = 'system:mcp-installer';
const mcpInstallerSkillPromptVersion = 2;
const mcpInstallerSkillContentDigest =
    '35d088762112a59883021f5b8035ef1ac228411e32b08214753a43e58d88e82e';
const addMcpServerToolName = 'add_mcp_server';
const addMcpServerToolNames = {addMcpServerToolName};
const listInstalledMcpServersToolName = 'list_installed_mcp_servers';
const listCurrentConversationMcpToolName = 'list_current_conversation_mcp';
const mcpInventoryToolNames = {
  listInstalledMcpServersToolName,
  listCurrentConversationMcpToolName,
};
const mcpInstallerToolNames = {addMcpServerToolName, ...mcpInventoryToolNames};
