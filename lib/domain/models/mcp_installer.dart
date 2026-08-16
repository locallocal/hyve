const mcpInstallerSkillId = 'system:mcp-installer';
const mcpInstallerSkillPromptVersion = 2;
const mcpInstallerSkillContentDigest =
    '93045aad05d47584492aaaf8a2bb9444e649a170281ef07927d4f684bb986f91';
const addMcpServerToolName = 'add_mcp_server';
const addMcpServerToolNames = {addMcpServerToolName};
const listInstalledMcpServersToolName = 'list_installed_mcp_servers';
const listCurrentConversationMcpToolName = 'list_current_conversation_mcp';
const mcpInventoryToolNames = {
  listInstalledMcpServersToolName,
  listCurrentConversationMcpToolName,
};
const mcpInstallerToolNames = {addMcpServerToolName, ...mcpInventoryToolNames};
