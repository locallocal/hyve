import 'dart:convert';
import 'dart:io';

import 'package:cryptography/cryptography.dart';
import 'package:path/path.dart' as path;
import 'package:stars/domain/models/models.dart';
import 'package:stars/domain/repositories/skill_ecosystem_repository.dart';

final class SkillSignatureVerification {
  const SkillSignatureVerification({
    required this.status,
    this.publisherId = '',
    this.publisherName = '',
    this.reason = '',
  });

  final SkillSignatureStatus status;
  final String publisherId;
  final String publisherName;
  final String reason;
}

final class SkillSignatureService {
  const SkillSignatureService({
    required SkillEcosystemRepository ecosystemRepository,
  }) : _ecosystemRepository = ecosystemRepository;

  static const int maxSignatureFileBytes = 64 * 1024;

  final SkillEcosystemRepository _ecosystemRepository;

  static String signingPayload({
    required String publisherId,
    required String keyId,
    required String contentDigest,
    required String skillName,
    required String version,
  }) {
    return 'stars-skill-v1\n$publisherId\n$keyId\n'
        '$contentDigest\n$skillName\n$version';
  }

  Future<SkillSignatureVerification> verify({
    required Directory skillRoot,
    required String contentDigest,
    required String skillName,
    required String version,
    String expectedPublisherId = '',
  }) async {
    final signatureFile = File(path.join(skillRoot.path, 'SIGNATURE.json'));
    if (!await signatureFile.exists()) {
      return const SkillSignatureVerification(
        status: SkillSignatureStatus.unsigned,
      );
    }
    if (await signatureFile.length() > maxSignatureFileBytes) {
      return const SkillSignatureVerification(
        status: SkillSignatureStatus.invalid,
        reason: 'signature_file_too_large',
      );
    }

    try {
      final decoded = jsonDecode(await signatureFile.readAsString());
      if (decoded is! Map) {
        return const SkillSignatureVerification(
          status: SkillSignatureStatus.invalid,
          reason: 'signature_document_invalid',
        );
      }
      final document = decoded.map(
        (key, value) => MapEntry(key.toString(), value),
      );
      final publisherId = document['publisherId']?.toString().trim() ?? '';
      final keyId = document['keyId']?.toString().trim() ?? '';
      final algorithm = document['algorithm']?.toString().trim() ?? '';
      final encodedSignature = document['signature']?.toString().trim() ?? '';
      if (publisherId.isEmpty ||
          keyId.isEmpty ||
          algorithm != 'ed25519' ||
          encodedSignature.isEmpty ||
          (expectedPublisherId.isNotEmpty &&
              expectedPublisherId != publisherId)) {
        return SkillSignatureVerification(
          status: SkillSignatureStatus.invalid,
          publisherId: publisherId,
          reason: 'signature_metadata_invalid',
        );
      }

      final publisher = await _ecosystemRepository.getPublisher(publisherId);
      if (publisher == null || !publisher.trusted) {
        return SkillSignatureVerification(
          status: SkillSignatureStatus.unknownPublisher,
          publisherId: publisherId,
          reason: 'publisher_not_trusted',
        );
      }
      if (publisher.keyId != keyId) {
        return SkillSignatureVerification(
          status: SkillSignatureStatus.invalid,
          publisherId: publisherId,
          publisherName: publisher.name,
          reason: 'publisher_key_mismatch',
        );
      }

      final publicKeyBytes = base64Decode(publisher.publicKey);
      final signatureBytes = base64Decode(encodedSignature);
      if (publicKeyBytes.length != 32 || signatureBytes.length != 64) {
        return SkillSignatureVerification(
          status: SkillSignatureStatus.invalid,
          publisherId: publisherId,
          publisherName: publisher.name,
          reason: 'signature_encoding_invalid',
        );
      }
      final payload = signingPayload(
        publisherId: publisherId,
        keyId: keyId,
        contentDigest: contentDigest,
        skillName: skillName,
        version: version,
      );
      final verified = await Ed25519().verify(
        utf8.encode(payload),
        signature: Signature(
          signatureBytes,
          publicKey: SimplePublicKey(publicKeyBytes, type: KeyPairType.ed25519),
        ),
      );
      return SkillSignatureVerification(
        status:
            verified
                ? SkillSignatureStatus.verified
                : SkillSignatureStatus.invalid,
        publisherId: publisherId,
        publisherName: publisher.name,
        reason: verified ? '' : 'signature_verification_failed',
      );
    } on FormatException {
      return const SkillSignatureVerification(
        status: SkillSignatureStatus.invalid,
        reason: 'signature_encoding_invalid',
      );
    } on Object {
      return const SkillSignatureVerification(
        status: SkillSignatureStatus.invalid,
        reason: 'signature_verification_failed',
      );
    }
  }
}
