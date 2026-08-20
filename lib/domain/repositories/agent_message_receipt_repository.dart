import 'package:hyve/domain/models/agent_message_receipt.dart';

abstract interface class AgentMessageReceiptRepository {
  Future<AgentMessageReceipt?> getReceipt(
    String projectId,
    String agentId,
    int messageSequence,
  );

  Future<List<AgentMessageReceipt>> getForTurn(String turnId);
}
