import 'package:flutter/material.dart';
import 'package:hyve/domain/models/models.dart';
import 'package:hyve/ui/features/projects/project_localizations.dart';

final class ProjectEventList extends StatefulWidget {
  const ProjectEventList({
    super.key,
    required this.events,
    required this.turns,
    required this.deliveries,
    required this.runs,
    required this.agentNames,
    this.hasEarlier = false,
    this.loadingEarlier = false,
    this.onLoadEarlier,
  });

  final List<ProjectEvent> events;
  final Map<String, ProjectTurn> turns;
  final Map<String, AgentDelivery> deliveries;
  final Map<String, AgentRun> runs;
  final Map<String, String> agentNames;
  final bool hasEarlier;
  final bool loadingEarlier;
  final VoidCallback? onLoadEarlier;

  @override
  State<ProjectEventList> createState() => _ProjectEventListState();
}

final class _ProjectEventListState extends State<ProjectEventList> {
  final ScrollController _scrollController = ScrollController();

  List<ProjectEvent> get _messages => widget.events
      .where(
        (event) =>
            event.messageSequence != null ||
            event.eventType == ProjectEventType.systemNotice,
      )
      .toList(growable: false);

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollTo(ProjectEvent event) {
    final messages = _messages;
    final targetIndex = messages.indexWhere((candidate) {
      if (event.replyToEventId.isNotEmpty) {
        return candidate.id == event.replyToEventId;
      }
      return candidate.messageSequence == event.replyToMessageSequence;
    });
    if (targetIndex < 0 || !_scrollController.hasClients) return;
    final target = (targetIndex * 104.0).clamp(
      0.0,
      _scrollController.position.maxScrollExtent,
    );
    _scrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final messages = _messages;
    final copy = ProjectLocalizations.of(context);
    if (messages.isEmpty) return Center(child: Text(copy.emptyTimeline));
    return ListView.builder(
      key: const ValueKey<String>('project-event-timeline'),
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: messages.length + (widget.hasEarlier ? 1 : 0),
      itemBuilder: (context, index) {
        if (widget.hasEarlier && index == 0) {
          return Center(
            child: TextButton.icon(
              key: const ValueKey<String>('project-load-earlier-events'),
              onPressed: widget.loadingEarlier ? null : widget.onLoadEarlier,
              icon:
                  widget.loadingEarlier
                      ? const SizedBox.square(
                        dimension: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : const Icon(Icons.history),
              label: Text(copy.loadEarlierEvents),
            ),
          );
        }
        final event = messages[index - (widget.hasEarlier ? 1 : 0)];
        final fromUser = event.actorType == ProjectEventActorType.user;
        final turn = widget.turns[event.turnId];
        if (event.eventType == ProjectEventType.systemNotice) {
          final notice = event.payload as SystemNoticePayload;
          return Align(
            key: ValueKey<String>('project-event-${event.id}'),
            alignment: Alignment.center,
            child: Semantics(
              liveRegion: true,
              child: Container(
                key: ValueKey<String>('project-system-notice-${event.id}'),
                margin: const EdgeInsets.symmetric(vertical: 6),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${notice.code}${notice.detail.isEmpty ? '' : ' · ${notice.detail}'}',
                ),
              ),
            ),
          );
        }
        if (event.eventType == ProjectEventType.agentDelivery) {
          return Align(
            key: ValueKey<String>('project-event-${event.id}'),
            alignment: Alignment.centerLeft,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: ProjectDeliveryCard(
                event: event,
                delivery: widget.deliveries[event.id],
                turn: turn,
                agentNames: widget.agentNames,
                runs: widget.runs,
              ),
            ),
          );
        }
        final actorName =
            event.actorNameSnapshot.isNotEmpty
                ? event.actorNameSnapshot
                : widget.agentNames[event.actorId] ?? event.actorId;
        return Align(
          key: ValueKey<String>('project-event-${event.id}'),
          alignment: fromUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Semantics(
            container: true,
            label: '${fromUser ? copy.user : actorName}: ${event.content}',
            child: Container(
              constraints: const BoxConstraints(maxWidth: 680),
              margin: const EdgeInsets.symmetric(vertical: 5),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color:
                    fromUser
                        ? Theme.of(context).colorScheme.primaryContainer
                        : Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  if (!fromUser)
                    Text(
                      actorName,
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  if (event.replyToEventId.isNotEmpty ||
                      event.replyToMessageSequence != null)
                    ActionChip(
                      key: ValueKey<String>('project-reply-link-${event.id}'),
                      avatar: const Icon(Icons.reply, size: 16),
                      label: Text(
                        copy.replyingTo(event.replyToMessageSequence ?? 0),
                      ),
                      onPressed: () => _scrollTo(event),
                    ),
                  SelectableText(event.content),
                  if (turn?.noParticipant == true)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        copy.noParticipant,
                        key: ValueKey<String>('no-participant-${event.id}'),
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ),
                  if (event.terminalState !=
                      ProjectEventTerminalState.completed)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        event.terminalState.name,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

final class ProjectDeliveryCard extends StatelessWidget {
  const ProjectDeliveryCard({
    super.key,
    required this.event,
    required this.delivery,
    required this.turn,
    required this.agentNames,
    required this.runs,
  });

  final ProjectEvent event;
  final AgentDelivery? delivery;
  final ProjectTurn? turn;
  final Map<String, String> agentNames;
  final Map<String, AgentRun> runs;

  @override
  Widget build(BuildContext context) {
    final copy = ProjectLocalizations.of(context);
    final payload = event.payload as AgentDeliveryPayload;
    final separator = copy.isChinese ? '、' : ', ';
    final targets = event.targetAgentIds
        .map((id) => agentNames[id] ?? id)
        .join(separator);
    final deliveryRun = runs[event.runId];
    final childRuns = runs.values
        .where((run) => run.parentRunId == event.runId)
        .toList(growable: false)
      ..sort((left, right) => left.createdAt.compareTo(right.createdAt));
    return Card(
      key: ValueKey<String>('project-delivery-card-${event.id}'),
      margin: const EdgeInsets.symmetric(vertical: 5),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        key: ValueKey<String>('project-delivery-expansion-${event.id}'),
        leading: const Icon(Icons.forward_to_inbox_outlined),
        title: Text(payload.summary),
        subtitle: Text(
          '${event.actorNameSnapshot} → $targets · ${payload.kind.name}',
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Wrap(
            spacing: 8,
            children: <Widget>[
              Chip(label: Text(payload.kind.name)),
              Chip(label: Text(event.visibility.name)),
              if (payload.requestPublicReply)
                Chip(label: Text(copy.requestedPublicReply)),
            ],
          ),
          const SizedBox(height: 8),
          SelectableText(payload.payload),
          if (payload.projectArtifactVersionIds.isNotEmpty)
            Text(copy.artifactVersions(payload.projectArtifactVersionIds)),
          const SizedBox(height: 12),
          Container(
            key: ValueKey<String>('project-delivery-audit-${event.id}'),
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(copy.auditDetails),
                Text(copy.eventId(event.id)),
                Text(
                  copy.turnId(event.turnId, turn?.status.name ?? copy.unknown),
                ),
                Text(copy.sourceRun(delivery?.sourceRunId ?? '-')),
                Text(
                  copy.deliveryRun(
                    event.runId,
                    deliveryRun?.status.name ?? copy.unknown,
                  ),
                ),
                Text(copy.rootRun(deliveryRun?.rootRunId ?? '-')),
                Text(
                  copy.deliveryDepth(
                    delivery?.depth ?? deliveryRun?.deliveryDepth ?? 0,
                  ),
                ),
                if (childRuns.isNotEmpty)
                  Text(
                    copy.targetRuns(
                      childRuns
                          .map(
                            (run) =>
                                '${agentNames[run.agentId] ?? run.agentId}:${run.status.name}',
                          )
                          .join(separator),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
