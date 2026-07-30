import 'tool.dart';

enum SkillSignatureStatus { unsigned, verified, unknownPublisher, invalid }

enum SkillUpdatePolicy { manual, notify, automatic, pinned }

enum SkillScriptInterpreter { python3, bash }

enum SkillSandboxAvailability {
  available,
  unsupportedPlatform,
  helperUnavailable,
  probeFailed,
  disabledByPolicy,
}

enum SkillComplianceEventType {
  installed,
  updated,
  uninstalled,
  signatureVerified,
  signatureRejected,
  catalogRefreshed,
  catalogUpdateInstalled,
  scriptEnabled,
  scriptDisabled,
  scriptExecuted,
  scriptRejected,
  toolInvoked,
  policyChanged,
}

final class SkillPublisher {
  const SkillPublisher({
    required this.id,
    required this.name,
    required this.keyId,
    required this.publicKey,
    this.organization = '',
    this.trusted = true,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final String keyId;
  final String publicKey;
  final String organization;
  final bool trusted;
  final DateTime createdAt;
  final DateTime updatedAt;
}

final class SkillCatalogSource {
  const SkillCatalogSource({
    required this.id,
    required this.name,
    required this.indexUri,
    required this.publisherId,
    this.enabled = true,
    this.lastError = '',
    this.lastFetchedAt,
  });

  final String id;
  final String name;
  final Uri indexUri;
  final String publisherId;
  final bool enabled;
  final String lastError;
  final DateTime? lastFetchedAt;
}

final class OnlineSkillCatalogEntry {
  const OnlineSkillCatalogEntry({
    required this.id,
    required this.catalogId,
    required this.name,
    required this.description,
    required this.version,
    required this.publisherId,
    required this.archiveUri,
    required this.archiveDigest,
    required this.contentDigest,
  });

  final String id;
  final String catalogId;
  final String name;
  final String description;
  final String version;
  final String publisherId;
  final Uri archiveUri;
  final String archiveDigest;
  final String contentDigest;
}

final class SkillOrganizationPolicy {
  SkillOrganizationPolicy({
    this.allowUnsignedSkills = true,
    this.allowUnknownPublishers = false,
    this.allowScriptExecution = true,
    this.allowAutomaticUpdates = false,
    Set<String> allowedPublisherIds = const {},
    this.updatedAt,
  }) : allowedPublisherIds = Set<String>.unmodifiable(allowedPublisherIds);

  static final defaults = SkillOrganizationPolicy();

  final bool allowUnsignedSkills;
  final bool allowUnknownPublishers;
  final bool allowScriptExecution;
  final bool allowAutomaticUpdates;
  final Set<String> allowedPublisherIds;
  final DateTime? updatedAt;
}

final class SkillScriptGrant {
  const SkillScriptGrant({
    required this.skillId,
    required this.contentDigest,
    required this.enabled,
    required this.approvedAt,
  });

  final String skillId;
  final String contentDigest;
  final bool enabled;
  final DateTime approvedAt;
}

final class SkillComplianceEvent {
  SkillComplianceEvent({
    required this.id,
    required this.type,
    this.skillId = '',
    this.contentDigest = '',
    this.publisherId = '',
    this.decision = '',
    this.reason = '',
    Map<String, Object?> metadata = const {},
    required this.timestamp,
  }) : metadata = Map<String, Object?>.unmodifiable(metadata);

  final String id;
  final SkillComplianceEventType type;
  final String skillId;
  final String contentDigest;
  final String publisherId;
  final String decision;
  final String reason;
  final Map<String, Object?> metadata;
  final DateTime timestamp;
}

final class SkillSandboxStatus {
  const SkillSandboxStatus({required this.availability, this.reason = ''});

  final SkillSandboxAvailability availability;
  final String reason;

  bool get isAvailable => availability == SkillSandboxAvailability.available;
}

final class SkillScriptLimits {
  const SkillScriptLimits({
    this.wallTime = const Duration(seconds: 15),
    this.cpuSeconds = 10,
    this.memoryBytes = 256 * 1024 * 1024,
    this.maxProcesses = 8,
    this.maxOpenFiles = 64,
    this.maxFileBytes = 8 * 1024 * 1024,
    this.maxOutputBytes = 256 * 1024,
  });

  final Duration wallTime;
  final int cpuSeconds;
  final int memoryBytes;
  final int maxProcesses;
  final int maxOpenFiles;
  final int maxFileBytes;
  final int maxOutputBytes;
}

final class SkillScriptToolManifest {
  SkillScriptToolManifest({
    required this.name,
    this.title = '',
    required this.description,
    required this.entry,
    required this.interpreter,
    required Map<String, Object?> inputSchema,
    Map<String, Object?>? outputSchema,
    this.riskLevel = ToolRiskLevel.readOnly,
    Set<ToolCapability> capabilities = const {ToolCapability.compute},
  }) : inputSchema = Map<String, Object?>.unmodifiable(inputSchema),
       outputSchema =
           outputSchema == null
               ? null
               : Map<String, Object?>.unmodifiable(outputSchema),
       capabilities = Set<ToolCapability>.unmodifiable({
         ...capabilities,
         ToolCapability.process,
       });

  final String name;
  final String title;
  final String description;
  final String entry;
  final SkillScriptInterpreter interpreter;
  final Map<String, Object?> inputSchema;
  final Map<String, Object?>? outputSchema;
  final ToolRiskLevel riskLevel;
  final Set<ToolCapability> capabilities;
}

final class SkillScriptExecutionRequest {
  SkillScriptExecutionRequest({
    required this.skillRootPath,
    required this.contentDigest,
    required this.entry,
    required this.interpreter,
    Map<String, Object?> arguments = const {},
    this.limits = const SkillScriptLimits(),
  }) : arguments = Map<String, Object?>.unmodifiable(arguments);

  final String skillRootPath;
  final String contentDigest;
  final String entry;
  final SkillScriptInterpreter interpreter;
  final Map<String, Object?> arguments;
  final SkillScriptLimits limits;
}

final class SkillScriptExecutionResult {
  const SkillScriptExecutionResult({
    required this.exitCode,
    required this.stdout,
    required this.stderr,
    required this.duration,
    this.timedOut = false,
    this.outputTruncated = false,
  });

  final int exitCode;
  final String stdout;
  final String stderr;
  final Duration duration;
  final bool timedOut;
  final bool outputTruncated;
}
