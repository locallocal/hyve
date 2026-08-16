import 'package:hyve/domain/models/app_failure.dart';

enum CommandPhase { idle, submitting, succeeded, failed }

final class CommandState {
  const CommandState._(this.phase, this.failure);

  const CommandState.idle() : this._(CommandPhase.idle, null);
  const CommandState.submitting() : this._(CommandPhase.submitting, null);
  const CommandState.succeeded() : this._(CommandPhase.succeeded, null);
  const CommandState.failed(AppFailure failure)
    : this._(CommandPhase.failed, failure);

  final CommandPhase phase;
  final AppFailure? failure;

  bool get isSubmitting => phase == CommandPhase.submitting;
}
