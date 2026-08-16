const skillInstallerSkillId = 'system:skill-installer';
const skillInstallerSkillPromptVersion = 2;
const skillInstallerSkillContentDigest =
    '0ed0013e4d4f6ba3700a4967691bca70bae594bd1bba2da5d810f46f8484eb2e';
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
