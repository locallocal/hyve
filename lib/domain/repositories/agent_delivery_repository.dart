import 'package:hyve/domain/models/agent_delivery.dart';

abstract interface class AgentDeliveryRepository {
  Stream<String> get changes;

  Future<AgentDelivery?> getForEvent(String eventId);

  /// Atomically validates the live membership snapshot, enforces idempotency
  /// and per-root limits, then saves the event, Turn, delivery run and audit
  /// record.
  Future<AgentDeliveryAppendResult> append(AgentDeliveryAppendRequest request);

  Future<void> recordRejection(AgentDeliveryRejectionRequest request);
}
