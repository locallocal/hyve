enum StartupCapabilityState { available, degraded, failed }

final class StartupCapabilityStatus {
  const StartupCapabilityStatus({
    required this.id,
    required this.required,
    required this.state,
    this.diagnosticCode = '',
    this.retryable = false,
  });

  final String id;
  final bool required;
  final StartupCapabilityState state;
  final String diagnosticCode;
  final bool retryable;

  bool get hasIssue => state != StartupCapabilityState.available;
}

final class StartupCapabilitiesReport {
  StartupCapabilitiesReport(Iterable<StartupCapabilityStatus> capabilities)
    : capabilities = List<StartupCapabilityStatus>.unmodifiable(capabilities);

  const StartupCapabilitiesReport._(this.capabilities);

  static const empty = StartupCapabilitiesReport._(<StartupCapabilityStatus>[]);

  final List<StartupCapabilityStatus> capabilities;

  List<StartupCapabilityStatus> get issues => List.unmodifiable(
    capabilities.where((capability) => capability.hasIssue),
  );

  bool get isDegraded => issues.isNotEmpty;
}
