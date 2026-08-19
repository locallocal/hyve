import 'dart:collection';

enum ProjectMembershipStatus { active, paused, removed }

enum ProjectStorageAccess { none, read, readWrite }

final class ProjectMembership {
  ProjectMembership({
    required this.projectId,
    required this.agentId,
    this.status = ProjectMembershipStatus.active,
    required this.position,
    this.projectStorageAccess = ProjectStorageAccess.read,
    Map<String, Object?> capabilityRestrictions = const <String, Object?>{},
    this.membershipGeneration = 1,
    this.joinMessageSequence = 0,
    required this.joinedAt,
    this.removedAt,
    required this.updatedAt,
  }) : capabilityRestrictions = UnmodifiableMapView(
         Map<String, Object?>.from(capabilityRestrictions),
       ) {
    if (projectId.trim().isEmpty || agentId.trim().isEmpty) {
      throw ArgumentError('Membership projectId and agentId are required.');
    }
    if (position < 0 || membershipGeneration < 1 || joinMessageSequence < 0) {
      throw ArgumentError('Membership counters cannot be negative.');
    }
    if (status == ProjectMembershipStatus.removed && removedAt == null) {
      throw ArgumentError('A removed membership requires removedAt.');
    }
    if (status != ProjectMembershipStatus.removed && removedAt != null) {
      throw ArgumentError('Only a removed membership can have removedAt.');
    }
  }

  final String projectId;
  final String agentId;
  final ProjectMembershipStatus status;
  final int position;
  final ProjectStorageAccess projectStorageAccess;
  final Map<String, Object?> capabilityRestrictions;
  final int membershipGeneration;
  final int joinMessageSequence;
  final DateTime joinedAt;
  final DateTime? removedAt;
  final DateTime updatedAt;

  ProjectMembership copyWith({
    ProjectMembershipStatus? status,
    int? position,
    ProjectStorageAccess? projectStorageAccess,
    Map<String, Object?>? capabilityRestrictions,
    int? membershipGeneration,
    int? joinMessageSequence,
    DateTime? joinedAt,
    DateTime? removedAt,
    bool clearRemovedAt = false,
    DateTime? updatedAt,
  }) {
    return ProjectMembership(
      projectId: projectId,
      agentId: agentId,
      status: status ?? this.status,
      position: position ?? this.position,
      projectStorageAccess: projectStorageAccess ?? this.projectStorageAccess,
      capabilityRestrictions:
          capabilityRestrictions ?? this.capabilityRestrictions,
      membershipGeneration: membershipGeneration ?? this.membershipGeneration,
      joinMessageSequence: joinMessageSequence ?? this.joinMessageSequence,
      joinedAt: joinedAt ?? this.joinedAt,
      removedAt: clearRemovedAt ? null : removedAt ?? this.removedAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
