import 'dart:collection';

enum PendingAttachmentKind { image, file, audio, video }

final class PendingAttachment {
  const PendingAttachment({
    required this.sourcePath,
    required this.kind,
    this.displayName = '',
    this.promoteToProjectArtifact = false,
  });

  final String sourcePath;
  final PendingAttachmentKind kind;
  final String displayName;
  final bool promoteToProjectArtifact;

  PendingAttachment copyWith({bool? promoteToProjectArtifact}) =>
      PendingAttachment(
        sourcePath: sourcePath,
        kind: kind,
        displayName: displayName,
        promoteToProjectArtifact:
            promoteToProjectArtifact ?? this.promoteToProjectArtifact,
      );
}

/// A stable Agent reference embedded in a project message draft.
///
/// [start] and [length] use Dart/Flutter UTF-16 string offsets, matching
/// [TextEditingValue] and [TextSelection].
final class MentionSpan {
  const MentionSpan({
    required this.agentId,
    required this.start,
    required this.length,
    required this.displayTextSnapshot,
  });

  final String agentId;
  final int start;
  final int length;
  final String displayTextSnapshot;

  int get end => start + length;

  MentionSpan shifted(int offset) => MentionSpan(
    agentId: agentId,
    start: start + offset,
    length: length,
    displayTextSnapshot: displayTextSnapshot,
  );
}

final class ProjectMessageDraft {
  ProjectMessageDraft({
    required this.text,
    Iterable<MentionSpan> mentions = const <MentionSpan>[],
    Iterable<PendingAttachment> attachments = const <PendingAttachment>[],
    Iterable<String> projectArtifactVersionIds = const <String>[],
  }) : mentions = List<MentionSpan>.unmodifiable(mentions),
       attachments = List<PendingAttachment>.unmodifiable(attachments),
       projectArtifactVersionIds = List<String>.unmodifiable(
         projectArtifactVersionIds,
       ) {
    _validateMentions();
  }

  final String text;
  final List<MentionSpan> mentions;
  final List<PendingAttachment> attachments;
  final List<String> projectArtifactVersionIds;

  bool get isEmpty =>
      text.trim().isEmpty &&
      attachments.isEmpty &&
      projectArtifactVersionIds.isEmpty;

  List<String> get mentionedAgentIds => List<String>.unmodifiable(
    LinkedHashSet<String>.from(mentions.map((mention) => mention.agentId)),
  );

  void _validateMentions() {
    var previousEnd = 0;
    for (final mention in mentions.toList()..sort(_compareMentionSpans)) {
      if (mention.agentId.trim().isEmpty ||
          mention.start < 0 ||
          mention.length <= 0 ||
          mention.end > text.length) {
        throw ArgumentError('Mention spans must be in bounds and have an id.');
      }
      if (mention.start < previousEnd) {
        throw ArgumentError('Mention spans cannot overlap.');
      }
      if (text.substring(mention.start, mention.end) !=
          mention.displayTextSnapshot) {
        throw ArgumentError(
          'Mention display snapshots must match the draft text.',
        );
      }
      previousEnd = mention.end;
    }
  }
}

int _compareMentionSpans(MentionSpan left, MentionSpan right) =>
    left.start.compareTo(right.start);
