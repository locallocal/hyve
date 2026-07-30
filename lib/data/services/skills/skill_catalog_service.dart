import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:cryptography/cryptography.dart';
import 'package:stars/data/services/skills/skill_catalog_endpoint_policy.dart';
import 'package:stars/domain/models/models.dart';
import 'package:stars/domain/repositories/skill_ecosystem_repository.dart';
import 'package:stars/domain/repositories/skill_repository.dart';

typedef SkillCatalogHttpClientFactory = HttpClient Function();
typedef SkillCatalogFetcher = Future<List<int>> Function(Uri uri, int maxBytes);

final class SkillCatalogService {
  SkillCatalogService({
    required SkillEcosystemRepository ecosystemRepository,
    required SkillRepository skillRepository,
    required SkillCatalogEndpointPolicy endpointPolicy,
    SkillCatalogHttpClientFactory? httpClientFactory,
    SkillCatalogFetcher? fetcher,
  }) : _ecosystemRepository = ecosystemRepository,
       _skillRepository = skillRepository,
       _endpointPolicy = endpointPolicy,
       _httpClientFactory = httpClientFactory ?? HttpClient.new,
       _fetcher = fetcher;

  static const int maxIndexBytes = 2 * 1024 * 1024;
  static const int maxArchiveBytes = 20 * 1024 * 1024;

  final SkillEcosystemRepository _ecosystemRepository;
  final SkillRepository _skillRepository;
  final SkillCatalogEndpointPolicy _endpointPolicy;
  final SkillCatalogHttpClientFactory _httpClientFactory;
  final SkillCatalogFetcher? _fetcher;
  final Map<String, List<OnlineSkillCatalogEntry>> _entries = {};

  List<OnlineSkillCatalogEntry> entriesFor(String catalogId) =>
      List.unmodifiable(_entries[catalogId] ?? const []);

  Future<void> refreshConfiguredCatalogs() async {
    final installed = await _skillRepository.getInstalled(forceRefresh: true);
    final backgroundCatalogIds = {
      for (final skill in installed)
        if (skill.catalogId.isNotEmpty &&
            (skill.updatePolicy == SkillUpdatePolicy.notify ||
                skill.updatePolicy == SkillUpdatePolicy.automatic))
          skill.catalogId,
    };
    for (final catalog in await _ecosystemRepository.getCatalogs()) {
      if (!catalog.enabled || !backgroundCatalogIds.contains(catalog.id)) {
        continue;
      }
      try {
        await refresh(catalog);
      } on Object {
        // Each source stores its own error and cannot block other catalogs.
      }
    }
    await applyAutomaticUpdates();
  }

  Future<List<OnlineSkillCatalogEntry>> refresh(
    SkillCatalogSource source,
  ) async {
    await _endpointPolicy.validate(source.indexUri);
    try {
      final bytes = await _fetch(source.indexUri, maxIndexBytes);
      final document = jsonDecode(utf8.decode(bytes));
      if (document is! Map || document['schemaVersion'] != 1) {
        throw const SkillInstallException('Skill 在线目录格式或版本无效。');
      }
      final map = document.map((key, value) => MapEntry(key.toString(), value));
      await _verifyIndex(source, map);
      final rawEntries = map['entries'];
      if (rawEntries is! List || rawEntries.length > 1000) {
        throw const SkillInstallException('Skill 在线目录条目数量无效。');
      }
      final entries = <OnlineSkillCatalogEntry>[];
      final entryIds = <String>{};
      for (final raw in rawEntries) {
        if (raw is! Map) {
          throw const SkillInstallException('Skill 在线目录条目格式无效。');
        }
        final item = raw.map((key, value) => MapEntry(key.toString(), value));
        final archiveUri = Uri.parse(_requiredText(item, 'archiveUrl'));
        await _endpointPolicy.validate(archiveUri);
        final entryId = _requiredText(item, 'id');
        if (!entryIds.add(entryId)) {
          throw const SkillInstallException('Skill 在线目录包含重复条目。');
        }
        entries.add(
          OnlineSkillCatalogEntry(
            id: entryId,
            catalogId: source.id,
            name: _requiredText(item, 'name'),
            description: item['description']?.toString() ?? '',
            version: _requiredText(item, 'version'),
            publisherId: _requiredText(item, 'publisherId'),
            archiveUri: archiveUri,
            archiveDigest: _sha256Text(item, 'archiveSha256'),
            contentDigest: _sha256Text(item, 'contentSha256'),
          ),
        );
      }
      _entries[source.id] = List.unmodifiable(entries);
      final refreshed = SkillCatalogSource(
        id: source.id,
        name: source.name,
        indexUri: source.indexUri,
        publisherId: source.publisherId,
        enabled: source.enabled,
        lastFetchedAt: DateTime.now(),
      );
      await _ecosystemRepository.saveCatalog(refreshed);
      await _audit(
        SkillComplianceEventType.catalogRefreshed,
        decision: 'allow',
        publisherId: source.publisherId,
        metadata: {'catalogId': source.id, 'entryCount': entries.length},
      );
      return List.unmodifiable(entries);
    } on Object catch (error) {
      await _ecosystemRepository.saveCatalog(
        SkillCatalogSource(
          id: source.id,
          name: source.name,
          indexUri: source.indexUri,
          publisherId: source.publisherId,
          enabled: source.enabled,
          lastError: error.toString(),
          lastFetchedAt: source.lastFetchedAt,
        ),
      );
      rethrow;
    }
  }

  Future<SkillDescriptor> install(OnlineSkillCatalogEntry entry) async {
    await _endpointPolicy.validate(entry.archiveUri);
    final bytes = await _fetch(entry.archiveUri, maxArchiveBytes);
    if (sha256.convert(bytes).toString() != entry.archiveDigest) {
      throw const SkillInstallException('Skill 下载包摘要不匹配。');
    }
    final temporary = await Directory.systemTemp.createTemp(
      'stars-skill-download-',
    );
    final archive = File('${temporary.path}/skill.zip');
    try {
      await archive.writeAsBytes(bytes, flush: true);
      final installed = await _skillRepository.install(
        SkillImportSource(
          kind: SkillImportKind.zipArchive,
          path: archive.path,
          sourceUri: entry.archiveUri.toString(),
          catalogId: entry.catalogId,
          catalogEntryId: entry.id,
          expectedContentDigest: entry.contentDigest,
          expectedArchiveDigest: entry.archiveDigest,
          publisherId: entry.publisherId,
          expectedName: entry.name,
          expectedVersion: entry.version,
        ),
      );
      await _audit(
        SkillComplianceEventType.catalogUpdateInstalled,
        decision: 'allow',
        skillId: installed.id,
        contentDigest: installed.contentDigest,
        publisherId: installed.publisherId,
        metadata: {'catalogId': entry.catalogId, 'entryId': entry.id},
      );
      return installed;
    } finally {
      if (await temporary.exists()) await temporary.delete(recursive: true);
    }
  }

  Future<List<OnlineSkillCatalogEntry>> availableUpdates() async {
    final installed = await _skillRepository.getInstalled(forceRefresh: true);
    final updates = <OnlineSkillCatalogEntry>[];
    for (final skill in installed) {
      if (skill.catalogId.isEmpty ||
          skill.catalogEntryId.isEmpty ||
          skill.updatePolicy == SkillUpdatePolicy.pinned) {
        continue;
      }
      for (final entry
          in _entries[skill.catalogId] ?? const <OnlineSkillCatalogEntry>[]) {
        if (entry.id == skill.catalogEntryId &&
            entry.contentDigest != skill.contentDigest &&
            _isNewerVersion(entry.version, skill.version)) {
          updates.add(entry);
        }
      }
    }
    return List.unmodifiable(updates);
  }

  Future<void> applyAutomaticUpdates() async {
    final policy = await _ecosystemRepository.getOrganizationPolicy();
    if (!policy.allowAutomaticUpdates) return;
    final installed = await _skillRepository.getInstalled(forceRefresh: true);
    final byEntry = {
      for (final skill in installed)
        '${skill.catalogId}:${skill.catalogEntryId}': skill,
    };
    for (final update in await availableUpdates()) {
      final skill = byEntry['${update.catalogId}:${update.id}'];
      final publisher = await _ecosystemRepository.getPublisher(
        update.publisherId,
      );
      if (skill?.updatePolicy == SkillUpdatePolicy.automatic &&
          skill?.signatureStatus == SkillSignatureStatus.verified &&
          skill?.publisherId == update.publisherId &&
          publisher?.trusted == true &&
          (policy.allowedPublisherIds.isEmpty ||
              policy.allowedPublisherIds.contains(update.publisherId))) {
        try {
          await install(update);
        } on Object catch (error) {
          await _audit(
            SkillComplianceEventType.catalogUpdateInstalled,
            decision: 'deny',
            skillId: skill!.id,
            contentDigest: skill.contentDigest,
            publisherId: update.publisherId,
            metadata: {
              'catalogId': update.catalogId,
              'entryId': update.id,
              'errorType': error.runtimeType.toString(),
            },
          );
        }
      }
    }
  }

  Future<void> _verifyIndex(
    SkillCatalogSource source,
    Map<String, Object?> document,
  ) async {
    final publisherId = _requiredText(document, 'publisherId');
    final keyId = _requiredText(document, 'keyId');
    final algorithm = _requiredText(document, 'algorithm');
    final signatureText = _requiredText(document, 'signature');
    if (publisherId != source.publisherId || algorithm != 'ed25519') {
      throw const SkillInstallException('Skill 在线目录签名元数据无效。');
    }
    final publisher = await _ecosystemRepository.getPublisher(publisherId);
    if (publisher == null || !publisher.trusted || publisher.keyId != keyId) {
      throw const SkillInstallException('Skill 在线目录发布者不受信任。');
    }
    final policy = await _ecosystemRepository.getOrganizationPolicy();
    if (policy.allowedPublisherIds.isNotEmpty &&
        !policy.allowedPublisherIds.contains(publisherId)) {
      throw const SkillInstallException('Skill 在线目录发布者不在组织允许列表中。');
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
      throw const SkillInstallException('Skill 在线目录签名无效。');
    }
  }

  Future<List<int>> _get(Uri uri, int limit) async {
    final client = _httpClientFactory();
    client.connectionTimeout = const Duration(seconds: 10);
    try {
      final request = await client
          .getUrl(uri)
          .timeout(const Duration(seconds: 10));
      request.followRedirects = false;
      final response = await request.close().timeout(
        const Duration(seconds: 10),
      );
      if (response.isRedirect || response.statusCode != HttpStatus.ok) {
        throw SkillInstallException(
          'Skill 在线请求失败（HTTP ${response.statusCode}）。',
        );
      }
      final bytes = <int>[];
      await for (final chunk in response.timeout(const Duration(seconds: 10))) {
        if (bytes.length + chunk.length > limit) {
          throw const SkillInstallException('Skill 在线响应超过大小限制。');
        }
        bytes.addAll(chunk);
      }
      return bytes;
    } finally {
      client.close(force: true);
    }
  }

  Future<List<int>> _fetch(Uri uri, int limit) {
    final fetcher = _fetcher;
    return fetcher == null ? _get(uri, limit) : fetcher(uri, limit);
  }

  String _requiredText(Map<String, Object?> value, String key) {
    final text = value[key]?.toString().trim() ?? '';
    if (text.isEmpty) throw SkillInstallException('Skill 在线目录缺少 $key。');
    return text;
  }

  String _sha256Text(Map<String, Object?> value, String key) {
    final text = _requiredText(value, key).toLowerCase();
    if (!RegExp(r'^[a-f0-9]{64}$').hasMatch(text)) {
      throw SkillInstallException('Skill 在线目录的 $key 无效。');
    }
    return text;
  }

  Future<void> _audit(
    SkillComplianceEventType type, {
    required String decision,
    String skillId = '',
    String contentDigest = '',
    String publisherId = '',
    Map<String, Object?> metadata = const {},
  }) {
    final now = DateTime.now();
    return _appendAuditBestEffort(
      SkillComplianceEvent(
        id: '${now.microsecondsSinceEpoch}:${type.name}:$skillId',
        type: type,
        skillId: skillId,
        contentDigest: contentDigest,
        publisherId: publisherId,
        decision: decision,
        metadata: metadata,
        timestamp: now,
      ),
    );
  }

  Future<void> _appendAuditBestEffort(SkillComplianceEvent event) async {
    try {
      await _ecosystemRepository.appendComplianceEvent(event);
    } on Object {
      // Catalog state and signature decisions do not depend on audit I/O.
    }
  }

  bool _isNewerVersion(String candidate, String installed) {
    if (installed.isEmpty) return true;
    final pattern = RegExp(
      r'^(\d+)\.(\d+)\.(\d+)(?:-([0-9A-Za-z.-]+))?(?:\+[0-9A-Za-z.-]+)?$',
    );
    final next = pattern.firstMatch(candidate);
    final current = pattern.firstMatch(installed);
    if (next == null || current == null) return false;
    for (var group = 1; group <= 3; group += 1) {
      final comparison = int.parse(
        next.group(group)!,
      ).compareTo(int.parse(current.group(group)!));
      if (comparison != 0) return comparison > 0;
    }
    final nextPreRelease = next.group(4);
    final currentPreRelease = current.group(4);
    if (nextPreRelease == currentPreRelease) return false;
    if (nextPreRelease == null) return true;
    if (currentPreRelease == null) return false;
    final nextParts = nextPreRelease.split('.');
    final currentParts = currentPreRelease.split('.');
    final sharedLength =
        nextParts.length < currentParts.length
            ? nextParts.length
            : currentParts.length;
    for (var index = 0; index < sharedLength; index += 1) {
      final nextNumber = int.tryParse(nextParts[index]);
      final currentNumber = int.tryParse(currentParts[index]);
      final comparison =
          nextNumber != null && currentNumber != null
              ? nextNumber.compareTo(currentNumber)
              : nextNumber != null
              ? -1
              : currentNumber != null
              ? 1
              : nextParts[index].compareTo(currentParts[index]);
      if (comparison != 0) return comparison > 0;
    }
    return nextParts.length > currentParts.length;
  }
}

String canonicalSkillJson(Object? value) {
  if (value is Map) {
    final entries =
        value.entries
            .map((entry) => MapEntry(entry.key.toString(), entry.value))
            .toList()
          ..sort((left, right) => left.key.compareTo(right.key));
    return '{${entries.map((entry) => '${jsonEncode(entry.key)}:${canonicalSkillJson(entry.value)}').join(',')}}';
  }
  if (value is List) {
    return '[${value.map(canonicalSkillJson).join(',')}]';
  }
  return jsonEncode(value);
}
