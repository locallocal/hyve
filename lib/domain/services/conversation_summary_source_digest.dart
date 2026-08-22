import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:hyve/domain/models/project_event.dart';

final class ConversationSummarySourceDigest {
  const ConversationSummarySourceDigest();

  String call(Iterable<ProjectEvent> events) {
    final ordered =
        events.toList()..sort(
          (left, right) =>
              left.messageSequence!.compareTo(right.messageSequence!),
        );
    return sha256
        .convert(
          utf8.encode(
            jsonEncode(<Map<String, Object?>>[
              for (final event in ordered)
                <String, Object?>{
                  'id': event.id,
                  'messageSequence': event.messageSequence,
                  'eventType': event.eventType.name,
                  'actorType': event.actorType.name,
                  'actorId': event.actorId,
                  'content': event.content,
                  'terminalState': event.terminalState.name,
                  'hasPartialContent': event.hasPartialContent,
                },
            ]),
          ),
        )
        .toString();
  }
}
