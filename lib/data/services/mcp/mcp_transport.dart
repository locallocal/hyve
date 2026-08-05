import 'package:stars/domain/models/models.dart';

final class McpTransportResponse {
  const McpTransportResponse({required this.payload, this.sessionId});

  final Map<String, Object?>? payload;
  final String? sessionId;
}

abstract interface class McpTransport {
  McpTransportType get type;

  Future<McpTransportResponse> send({
    required McpServer server,
    required Map<String, Object?> payload,
    required McpCredential? credential,
    required AgentCancellationToken cancellationToken,
    required String? protocolVersion,
    required String? sessionId,
  });

  Future<void> disconnect({
    required McpServer server,
    required McpCredential? credential,
    required String? protocolVersion,
    required String? sessionId,
  });
}
