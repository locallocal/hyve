import 'package:stars/data/services/skills/skill_script_manifest_parser.dart';
import 'package:stars/data/services/skills/skill_script_tool.dart';
import 'package:stars/domain/models/models.dart';
import 'package:stars/domain/repositories/skill_ecosystem_repository.dart';
import 'package:stars/domain/repositories/skill_repository.dart';
import 'package:stars/domain/repositories/skill_script_sandbox.dart';

final class SkillScriptCatalogService {
  const SkillScriptCatalogService({
    required SkillRepository skillRepository,
    required SkillEcosystemRepository ecosystemRepository,
    required SkillScriptManifestParser manifestParser,
    required SkillScriptSandbox sandbox,
    required DynamicToolRegistry toolRegistry,
  }) : _skillRepository = skillRepository,
       _ecosystemRepository = ecosystemRepository,
       _manifestParser = manifestParser,
       _sandbox = sandbox,
       _toolRegistry = toolRegistry;

  final SkillRepository _skillRepository;
  final SkillEcosystemRepository _ecosystemRepository;
  final SkillScriptManifestParser _manifestParser;
  final SkillScriptSandbox _sandbox;
  final DynamicToolRegistry _toolRegistry;

  Future<SkillSandboxStatus> sandboxStatus() => _sandbox.probe();

  Future<bool> isEnabled(SkillDescriptor skill) async {
    final grant = await _ecosystemRepository.getScriptGrant(skill.id);
    return grant?.enabled == true &&
        grant?.contentDigest == skill.contentDigest;
  }

  Future<void> setEnabled(SkillDescriptor skill, bool enabled) async {
    final policy = await _ecosystemRepository.getOrganizationPolicy();
    if (enabled &&
        (!skill.hasScripts ||
            !skill.isUsable ||
            skill.signatureStatus == SkillSignatureStatus.invalid)) {
      throw const SkillInstallException('当前 Skill 不允许启用脚本。');
    }
    if (enabled && !await _isTrustAllowed(skill, policy)) {
      throw const SkillInstallException('当前 Skill 的签名或发布者不再受信任。');
    }
    if (enabled && !policy.allowScriptExecution) {
      throw const SkillInstallException('组织策略已禁用 Skill 脚本。');
    }
    if (enabled && !(await _sandbox.probe()).isAvailable) {
      throw const SkillInstallException('当前桌面系统没有可用的脚本隔离环境。');
    }
    if (enabled) {
      List<SkillScriptToolManifest> manifests;
      try {
        manifests = await _manifestParser.parse(skill);
      } on Object {
        await _appendRejectedEvent(skill, 'script_manifest_invalid');
        rethrow;
      }
      if (manifests.isEmpty) {
        throw const SkillInstallException('Skill 没有 scripts/tools.json 工具清单。');
      }
      final undeclared = manifests.where(
        (manifest) => !skill.requestedToolNames.contains(manifest.name),
      );
      if (undeclared.isNotEmpty) {
        throw SkillInstallException(
          '脚本工具未在 allowed-tools 声明：${undeclared.first.name}',
        );
      }
    }
    await _ecosystemRepository.saveScriptGrant(
      SkillScriptGrant(
        skillId: skill.id,
        contentDigest: skill.contentDigest,
        enabled: enabled,
        approvedAt: DateTime.now(),
      ),
    );
    await _appendGrantEvent(skill, enabled);
    await hydrateFromCache();
  }

  Future<void> hydrateFromCache() async {
    final policy = await _ecosystemRepository.getOrganizationPolicy();
    final status = await _sandbox.probe();
    if (!policy.allowScriptExecution || !status.isAvailable) {
      _toolRegistry.replaceDynamicSource('skill-scripts', const []);
      return;
    }
    final tools = <ExecutableTool>[];
    for (final skill in await _skillRepository.getInstalled(
      forceRefresh: true,
    )) {
      if (!skill.hasScripts ||
          !skill.isUsable ||
          skill.signatureStatus == SkillSignatureStatus.invalid ||
          !await _isTrustAllowed(skill, policy) ||
          !await isEnabled(skill)) {
        continue;
      }
      List<SkillScriptToolManifest> manifests;
      try {
        manifests = await _manifestParser.parse(skill);
      } on Object {
        await _appendRejectedEvent(skill, 'script_manifest_invalid');
        continue;
      }
      for (final manifest in manifests) {
        if (!skill.requestedToolNames.contains(manifest.name)) continue;
        tools.add(
          SkillScriptTool(
            skill: skill,
            manifest: manifest,
            sandbox: _sandbox,
            authorizationCheck: () => _isStillAuthorized(skill),
            ecosystemRepository: _ecosystemRepository,
          ),
        );
      }
    }
    _toolRegistry.replaceDynamicSource('skill-scripts', tools);
  }

  Future<void> _appendGrantEvent(SkillDescriptor skill, bool enabled) async {
    final now = DateTime.now();
    await _appendAuditBestEffort(
      SkillComplianceEvent(
        id: '${now.microsecondsSinceEpoch}:grant:${skill.id}',
        type:
            enabled
                ? SkillComplianceEventType.scriptEnabled
                : SkillComplianceEventType.scriptDisabled,
        skillId: skill.id,
        contentDigest: skill.contentDigest,
        publisherId: skill.publisherId,
        decision: enabled ? 'allow' : 'deny',
        reason: enabled ? 'user_approved' : 'user_disabled',
        timestamp: now,
      ),
    );
  }

  Future<bool> _isStillAuthorized(SkillDescriptor skill) async {
    final policy = await _ecosystemRepository.getOrganizationPolicy();
    return policy.allowScriptExecution &&
        await _isTrustAllowed(skill, policy) &&
        await isEnabled(skill);
  }

  Future<bool> _isTrustAllowed(
    SkillDescriptor skill,
    SkillOrganizationPolicy policy,
  ) async {
    switch (skill.signatureStatus) {
      case SkillSignatureStatus.invalid:
        return false;
      case SkillSignatureStatus.unsigned:
        return policy.allowUnsignedSkills;
      case SkillSignatureStatus.unknownPublisher:
        return policy.allowUnknownPublishers;
      case SkillSignatureStatus.verified:
        final publisher = await _ecosystemRepository.getPublisher(
          skill.publisherId,
        );
        return publisher?.trusted == true &&
            (policy.allowedPublisherIds.isEmpty ||
                policy.allowedPublisherIds.contains(skill.publisherId));
    }
  }

  Future<void> _appendRejectedEvent(
    SkillDescriptor skill,
    String reason,
  ) async {
    final now = DateTime.now();
    await _appendAuditBestEffort(
      SkillComplianceEvent(
        id: '${now.microsecondsSinceEpoch}:script-rejected:${skill.id}',
        type: SkillComplianceEventType.scriptRejected,
        skillId: skill.id,
        contentDigest: skill.contentDigest,
        publisherId: skill.publisherId,
        decision: 'deny',
        reason: reason,
        timestamp: now,
      ),
    );
  }

  Future<void> _appendAuditBestEffort(SkillComplianceEvent event) async {
    try {
      await _ecosystemRepository.appendComplianceEvent(event);
    } on Object {
      // Registration and fail-closed decisions do not depend on audit I/O.
    }
  }
}
