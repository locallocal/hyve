import 'package:hyve/domain/models/project_message_route.dart';

abstract interface class ProjectMessageRouteRepository {
  /// Atomically allocates event/message sequences and saves the message,
  /// normalized target snapshot, Turn, and missing member cursors.
  Future<RoutedProjectMessage> append(ProjectMessageAppendRequest request);
}
