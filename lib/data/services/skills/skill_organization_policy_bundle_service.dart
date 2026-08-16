import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:hyve/data/services/skills/skill_catalog_service.dart';
import 'package:hyve/domain/models/models.dart';
import 'package:hyve/domain/repositories/skill_ecosystem_repository.dart';

final class SkillOrganizationPolicyBundleService {
  const SkillOrganizationPolicyBundleService({
    required SkillEcosystemRepository ecosystemRepository,
  }) : _ecosystemRepository = ecosystemRepository;

  final SkillEcosystemRepository _ecosystemRepository;

  String exportUnsignedPayload(SkillOrganizationPolicy policy) {
    return canonicalSkillJson({
      'schemaVersion': 1,
      'algorithm': 'ed25519',
      'policy': _policyMap(policy),
    });
  }

  Future<SkillOrganizationPolicy> importSigned(String source) async {
    try {
      final decoded = jsonDecode(source);
      if (decoded is! Map || decoded['schemaVersion'] != 1) {
        throw const SkillInstallException('组织策略包格式或版本无效。');
      }
      final document = decoded.map(
        (key, value) => MapEntry(key.toString(), value),
      );
      final publisherId = document['publisherId']?.toString() ?? '';
      final keyId = document['keyId']?.toString() ?? '';
      final algorithm = document['algorithm']?.toString() ?? '';
      final signatureText = document['signature']?.toString() ?? '';
      final publisher = await _ecosystemRepository.getPublisher(publisherId);
      if (publisher == null ||
          !publisher.trusted ||
          publisher.keyId != keyId ||
          algorithm != 'ed25519') {
        throw const SkillInstallException('组织策略发布者不受信任。');
      }
      final unsigned = Map<String, Object?>.of(document)..remove('signature');
      final verified = await Ed25519().verify(
        utf8.encode(canonicalSkillJson(unsigned)),
        signature: Signature(
          base64Decode(signatureText),
          publicKey: SimplePublicKey(
            base64Decode(publisher.publicKey),
            type: KeyPairType.ed25519,
          ),
        ),
      );
      if (!verified) {
        throw const SkillInstallException('组织策略签名无效。');
      }
      final rawPolicy = document['policy'];
      if (rawPolicy is! Map) {
        throw const SkillInstallException('组织策略内容无效。');
      }
      final policy = SkillOrganizationPolicy(
        allowUnsignedSkills: rawPolicy['allowUnsignedSkills'] == true,
        allowUnknownPublishers: rawPolicy['allowUnknownPublishers'] == true,
        allowScriptExecution: rawPolicy['allowScriptExecution'] == true,
        allowAutomaticUpdates: rawPolicy['allowAutomaticUpdates'] == true,
        allowedPublisherIds:
            rawPolicy['allowedPublisherIds'] is List
                ? (rawPolicy['allowedPublisherIds'] as List)
                    .map((item) => item.toString())
                    .toSet()
                : const {},
        updatedAt: DateTime.now(),
      );
      await _ecosystemRepository.saveOrganizationPolicy(policy);
      final now = DateTime.now();
      try {
        await _ecosystemRepository.appendComplianceEvent(
          SkillComplianceEvent(
            id: '${now.microsecondsSinceEpoch}:policy:$publisherId',
            type: SkillComplianceEventType.policyChanged,
            publisherId: publisherId,
            decision: 'allow',
            reason: 'signed_policy_import',
            timestamp: now,
          ),
        );
      } on Object {
        // A verified policy remains installed if local audit I/O fails.
      }
      return policy;
    } on FormatException {
      throw const SkillInstallException('组织策略包不是有效的 JSON。');
    }
  }

  Map<String, Object?> _policyMap(SkillOrganizationPolicy policy) => {
    'allowUnsignedSkills': policy.allowUnsignedSkills,
    'allowUnknownPublishers': policy.allowUnknownPublishers,
    'allowScriptExecution': policy.allowScriptExecution,
    'allowAutomaticUpdates': policy.allowAutomaticUpdates,
    'allowedPublisherIds': policy.allowedPublisherIds.toList()..sort(),
  };
}
