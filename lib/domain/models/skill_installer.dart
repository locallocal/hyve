const skillInstallerSkillId = 'system:skill-installer';
const skillInstallerSkillPromptVersion = 2;
const skillInstallerSkillContentDigest =
    '5ee0c3e5a92deef8142d09ba76f2ae990a26dc5c5003b2ab588430b10b638d0b';
const installSkillToolName = 'install_skill';
const listInstalledSkillsToolName = 'list_installed_skills';
const listCurrentConversationSkillsToolName =
    'list_current_conversation_skills';
const skillInventoryToolNames = {
  listInstalledSkillsToolName,
  listCurrentConversationSkillsToolName,
};
const skillInstallerToolNames = {
  installSkillToolName,
  ...skillInventoryToolNames,
};
