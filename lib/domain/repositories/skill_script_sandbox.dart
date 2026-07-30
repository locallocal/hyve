import 'package:stars/domain/models/models.dart';

abstract interface class SkillScriptSandbox {
  Future<SkillSandboxStatus> probe();

  Future<SkillScriptExecutionResult> execute(
    SkillScriptExecutionRequest request,
    AgentCancellationToken cancellationToken,
  );
}
