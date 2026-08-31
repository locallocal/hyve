import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' as intl;
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:hyve/domain/models/models.dart';
import 'package:hyve/generated/l10n.dart';
import 'package:hyve/ui/core/widgets/common.dart';
import 'package:hyve/ui/core/widgets/profile_avatar.dart';
import 'package:hyve/ui/features/projects/project_localizations.dart';
import 'package:hyve/ui/features/projects/views/project_ui.dart';

final class ProjectEventList extends StatefulWidget {
  const ProjectEventList({
    super.key,
    required this.events,
    required this.turns,
    required this.deliveries,
    required this.runs,
    required this.agentNames,
    this.agentsById = const <String, Agent>{},
    this.currentUserProfile,
    this.hasEarlier = false,
    this.loadingEarlier = false,
    this.onLoadEarlier,
    this.initialScrollOffset = 0,
    this.onScrollOffsetChanged,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    this.emptyIcon,
    this.emptyTitle,
    this.emptyDescription,
    this.emptyAction,
  });

  final List<ProjectEvent> events;
  final Map<String, ProjectTurn> turns;
  final Map<String, AgentDelivery> deliveries;
  final Map<String, AgentRun> runs;
  final Map<String, String> agentNames;
  final Map<String, Agent> agentsById;
  final Profile? currentUserProfile;
  final bool hasEarlier;
  final bool loadingEarlier;
  final VoidCallback? onLoadEarlier;
  final double initialScrollOffset;
  final ValueChanged<double>? onScrollOffsetChanged;
  final EdgeInsetsGeometry padding;
  final IconData? emptyIcon;
  final String? emptyTitle;
  final String? emptyDescription;
  final Widget? emptyAction;

  static bool hasTimelineEntries(Iterable<ProjectEvent> events) =>
      events.any(_isTimelineEntry);

  static bool _isTimelineEntry(ProjectEvent event) =>
      event.messageSequence != null ||
      (event.eventType == ProjectEventType.userMessage &&
          event.terminalState == ProjectEventTerminalState.draft) ||
      event.eventType == ProjectEventType.systemNotice;

  @override
  State<ProjectEventList> createState() => _ProjectEventListState();
}

final class _ProjectEventListState extends State<ProjectEventList> {
  static const double _loadEarlierThreshold = 240;

  late final ScrollController _scrollController;
  late List<ProjectEvent> _messages;
  late Map<Key, int> _messageIndexesByKey;
  bool _autoScrollScheduled = false;
  bool _loadEarlierScheduled = false;

  Object? _latestMessageState(Iterable<ProjectEvent> events) {
    final messages = events.where(ProjectEventList._isTimelineEntry);
    if (messages.isEmpty) return null;
    final latest = messages.last;
    return (latest.id, latest.content, latest.updatedAt);
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController(
      initialScrollOffset: widget.initialScrollOffset,
    )..addListener(_handleScrollChanged);
    _indexMessages();
    if (_messages.isNotEmpty && widget.initialScrollOffset <= 0) {
      _scheduleScrollToLatest(animate: false);
    }
    _scheduleLoadEarlierIfNeeded();
  }

  @override
  void didUpdateWidget(covariant ProjectEventList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.events, widget.events)) _indexMessages();
    final previousLatest = _latestMessageState(oldWidget.events);
    final currentLatest = _latestMessageState(widget.events);
    if (currentLatest != null && currentLatest != previousLatest) {
      _scheduleScrollToLatest();
    }
    if (widget.hasEarlier && !widget.loadingEarlier) {
      _scheduleLoadEarlierIfNeeded();
    }
  }

  void _indexMessages() {
    _messages = List<ProjectEvent>.unmodifiable(
      widget.events.where(ProjectEventList._isTimelineEntry),
    );
    _messageIndexesByKey = <Key, int>{
      for (var index = 0; index < _messages.length; index++)
        ValueKey<String>('project-event-${_messages[index].id}'):
            _messages.length - index - 1,
    };
  }

  void _handleScrollChanged() {
    if (!_scrollController.hasClients) return;
    widget.onScrollOffsetChanged?.call(_scrollController.offset);
    _loadEarlierIfNeeded();
  }

  void _scheduleLoadEarlierIfNeeded() {
    if (_loadEarlierScheduled) return;
    _loadEarlierScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadEarlierScheduled = false;
      if (!mounted) return;
      _loadEarlierIfNeeded();
    });
  }

  void _loadEarlierIfNeeded() {
    if (!_scrollController.hasClients ||
        !widget.hasEarlier ||
        widget.loadingEarlier) {
      return;
    }
    if (_scrollController.position.extentAfter <= _loadEarlierThreshold) {
      widget.onLoadEarlier?.call();
    }
  }

  void _scheduleScrollToLatest({bool animate = true}) {
    if (_autoScrollScheduled) return;
    _autoScrollScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _autoScrollScheduled = false;
      if (!mounted || !_scrollController.hasClients) return;
      final position = _scrollController.position;
      final target = position.minScrollExtent;
      if ((target - position.pixels).abs() < 0.5) return;
      final disableAnimations =
          MediaQuery.maybeOf(context)?.disableAnimations ?? false;
      if (!animate || disableAnimations) {
        _scrollController.jumpTo(target);
        return;
      }
      unawaited(
        _scrollController
            .animateTo(
              target,
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
            )
            .whenComplete(() {
              if (mounted) _scheduleScrollToLatest();
            }),
      );
    });
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_handleScrollChanged)
      ..dispose();
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
    final reverseIndex = messages.length - targetIndex - 1;
    final target = (reverseIndex * 104.0).clamp(
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
    if (messages.isEmpty) {
      return ProjectEmptyState(
        icon: widget.emptyIcon ?? LucideIcons.messageSquareText,
        title: widget.emptyTitle ?? copy.emptyTimelineTitle,
        description: widget.emptyDescription ?? copy.emptyTimeline,
        action: widget.emptyAction,
      );
    }
    final timeline = ListView.builder(
      key: const ValueKey<String>('project-event-timeline'),
      controller: _scrollController,
      reverse: true,
      padding: widget.padding,
      itemCount: messages.length + (widget.hasEarlier ? 1 : 0),
      findChildIndexCallback: (key) => _messageIndexesByKey[key],
      itemBuilder: (context, index) {
        if (widget.hasEarlier && index == messages.length) {
          return Center(
            child: ProjectActionButton(
              key: const ValueKey<String>('project-load-earlier-events'),
              onPressed: widget.loadingEarlier ? null : widget.onLoadEarlier,
              leading:
                  widget.loadingEarlier
                      ? const SizedBox.square(
                        dimension: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : const Icon(LucideIcons.history, size: 16),
              label: copy.loadEarlierEvents,
              variant: ProjectActionVariant.ghost,
            ),
          );
        }
        final event = messages[messages.length - index - 1];
        final fromUser = event.actorType == ProjectEventActorType.user;
        final turn = widget.turns[event.turnId];
        if (event.eventType == ProjectEventType.systemNotice) {
          final notice = event.payload as SystemNoticePayload;
          final message =
              '${notice.code}${notice.detail.isEmpty ? '' : ' · ${notice.detail}'}';
          return Align(
            key: ValueKey<String>('project-event-${event.id}'),
            alignment: Alignment.center,
            child: Semantics(
              liveRegion: true,
              child:
                  hasShadProjectTheme(context)
                      ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: ShadAlert.destructive(
                          key: ValueKey<String>(
                            'project-system-notice-${event.id}',
                          ),
                          icon: const Icon(LucideIcons.circleAlert),
                          description: Text(message),
                        ),
                      )
                      : Container(
                        key: ValueKey<String>(
                          'project-system-notice-${event.id}',
                        ),
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(message),
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
        final currentUserProfile = widget.currentUserProfile;
        final currentUserName = currentUserProfile?.name.trim() ?? '';
        final actorName =
            fromUser && currentUserName.isNotEmpty
                ? currentUserName
                : event.actorNameSnapshot.isNotEmpty
                ? event.actorNameSnapshot
                : fromUser
                ? copy.user
                : widget.agentNames[event.actorId] ?? event.actorId;
        final actorAvatar =
            fromUser && currentUserProfile != null
                ? currentUserProfile.avatar.trim().isEmpty
                    ? defaultProfileAvatarAsset
                    : currentUserProfile.avatar.trim()
                : event.actorAvatarSnapshot;
        final messageBubble = _ProjectMessageBubble(
          key: ValueKey<String>('project-message-bubble-${event.id}'),
          constraints: const BoxConstraints(maxWidth: 680),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (event.replyToEventId.isNotEmpty ||
                  event.replyToMessageSequence != null) ...<Widget>[
                ProjectBadge(
                  key: ValueKey<String>('project-reply-link-${event.id}'),
                  icon: LucideIcons.reply,
                  label: copy.replyingTo(event.replyToMessageSequence ?? 0),
                  onPressed: () => _scrollTo(event),
                ),
                const SizedBox(height: 8),
              ],
              SelectableText(event.content),
              if (turn?.noParticipant == true)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    copy.noParticipant,
                    key: ValueKey<String>('no-participant-${event.id}'),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color:
                          ShadTheme.maybeOf(
                            context,
                          )?.colorScheme.mutedForeground ??
                          Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              if (event.terminalState != ProjectEventTerminalState.draft &&
                  event.terminalState != ProjectEventTerminalState.completed)
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
        );
        return Align(
          key: ValueKey<String>('project-event-${event.id}'),
          alignment: fromUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Semantics(
            container: true,
            label: '$actorName: ${event.content}',
            child: _ProjectActorMessage(
              key: ValueKey<String>('project-actor-message-${event.id}'),
              eventId: event.id,
              name: actorName,
              avatarOnRight: fromUser,
              persistentMetadata:
                  event.terminalState == ProjectEventTerminalState.draft,
              agent: fromUser ? null : widget.agentsById[event.actorId],
              fallbackAvatar: actorAvatar,
              metadata: _ProjectMessageMetadata(
                key: ValueKey<String>('project-message-metadata-${event.id}'),
                eventId: event.id,
                content: event.content,
                createdAt: event.createdAt,
                pending: event.terminalState == ProjectEventTerminalState.draft,
              ),
              child: messageBubble,
            ),
          ),
        );
      },
    );
    return ScrollConfiguration(
      key: const ValueKey<String>('project-event-scroll-configuration'),
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: timeline,
    );
  }
}

final class _ProjectActorMessage extends StatefulWidget {
  const _ProjectActorMessage({
    super.key,
    required this.eventId,
    required this.name,
    required this.avatarOnRight,
    required this.persistentMetadata,
    required this.agent,
    required this.fallbackAvatar,
    required this.metadata,
    required this.child,
  });

  final String eventId;
  final String name;
  final bool avatarOnRight;
  final bool persistentMetadata;
  final Agent? agent;
  final String fallbackAvatar;
  final Widget metadata;
  final Widget child;

  @override
  State<_ProjectActorMessage> createState() => _ProjectActorMessageState();
}

final class _ProjectActorMessageState extends State<_ProjectActorMessage> {
  bool _hovered = false;
  bool _focused = false;

  bool get _showMetadata => widget.persistentMetadata || _hovered || _focused;

  void _setHovered(bool value) {
    if (_hovered == value) return;
    setState(() => _hovered = value);
  }

  void _setFocused(bool value) {
    if (_focused == value) return;
    setState(() => _focused = value);
  }

  @override
  Widget build(BuildContext context) {
    final shadTheme = ShadTheme.maybeOf(context);
    final animationDuration =
        MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : const Duration(milliseconds: 100);
    final nameStyle =
        shadTheme == null
            ? Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600)
            : shadTheme.textTheme.small.copyWith(
              color: shadTheme.colorScheme.foreground,
              fontWeight: FontWeight.w600,
            );
    final avatar = Semantics(
      image: true,
      label: widget.name,
      child: ProjectActorAvatar(
        key: ValueKey<String>('project-message-avatar-${widget.eventId}'),
        agent: widget.agent,
        fallbackName: widget.name,
        fallbackAvatar: widget.fallbackAvatar,
      ),
    );
    final content = Flexible(
      child: Column(
        crossAxisAlignment:
            widget.avatarOnRight
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            widget.name,
            key: ValueKey<String>('project-message-actor-${widget.eventId}'),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: widget.avatarOnRight ? TextAlign.end : TextAlign.start,
            style: nameStyle,
          ),
          const SizedBox(height: 6),
          widget.child,
          const SizedBox(height: 4),
          AnimatedOpacity(
            key: ValueKey<String>(
              'project-message-metadata-opacity-${widget.eventId}',
            ),
            opacity: _showMetadata ? 1 : 0,
            duration: animationDuration,
            curve: Curves.easeOut,
            child: ExcludeSemantics(
              excluding: !_showMetadata,
              child: ExcludeFocus(
                excluding: !_showMetadata,
                child: IgnorePointer(
                  ignoring: !_showMetadata,
                  child: widget.metadata,
                ),
              ),
            ),
          ),
        ],
      ),
    );
    return MouseRegion(
      key: ValueKey<String>('project-message-hover-${widget.eventId}'),
      onEnter: (_) => _setHovered(true),
      onExit: (_) => _setHovered(false),
      child: Focus(
        onFocusChange: _setFocused,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 730),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children:
                  widget.avatarOnRight
                      ? <Widget>[content, const SizedBox(width: 10), avatar]
                      : <Widget>[avatar, const SizedBox(width: 10), content],
            ),
          ),
        ),
      ),
    );
  }
}

final class _ProjectMessageMetadata extends StatelessWidget {
  const _ProjectMessageMetadata({
    super.key,
    required this.eventId,
    required this.content,
    required this.createdAt,
    required this.pending,
  });

  final String eventId;
  final String content;
  final DateTime createdAt;
  final bool pending;

  Future<void> _copyMessage(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: content));
    if (!context.mounted) return;
    showHyveNotice(context, S.of(context).messageCopied);
  }

  @override
  Widget build(BuildContext context) {
    if (pending) {
      return SizedBox(
        height: 44,
        child: Align(
          alignment: Alignment.centerRight,
          child: ProjectBadge(
            key: ValueKey<String>('project-message-pending-$eventId'),
            icon: LucideIcons.clock3,
            label: ProjectLocalizations.of(context).sending,
            variant: ProjectBadgeVariant.secondary,
          ),
        ),
      );
    }
    final shadTheme = ShadTheme.maybeOf(context);
    final localeName = Localizations.localeOf(context).toString();
    final formattedTimestamp = intl.DateFormat.yMd(
      localeName,
    ).add_Hms().format(createdAt.toLocal());
    final copyLabel = MaterialLocalizations.of(context).copyButtonLabel;
    final timestampStyle =
        shadTheme?.textTheme.muted ??
        Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          formattedTimestamp,
          key: ValueKey<String>('project-message-time-$eventId'),
          style: timestampStyle,
        ),
        const SizedBox(width: 4),
        ProjectIconAction(
          key: ValueKey<String>('project-message-copy-$eventId'),
          icon: LucideIcons.copy,
          label: copyLabel,
          onPressed:
              content.isEmpty ? null : () => unawaited(_copyMessage(context)),
        ),
      ],
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
    return ProjectSurfaceCard(
      key: ValueKey<String>('project-delivery-card-${event.id}'),
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: EdgeInsets.zero,
      child: ProjectDisclosure(
        key: ValueKey<String>('project-delivery-expansion-${event.id}'),
        leading: const Icon(LucideIcons.send),
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
              ProjectBadge(label: payload.kind.name),
              ProjectBadge(label: event.visibility.name),
              if (payload.requestPublicReply)
                ProjectBadge(
                  label: copy.requestedPublicReply,
                  variant: ProjectBadgeVariant.secondary,
                ),
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
            decoration: BoxDecoration(
              color:
                  ShadTheme.maybeOf(context)?.colorScheme.muted ??
                  Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(6),
            ),
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

final class _ProjectMessageBubble extends StatelessWidget {
  const _ProjectMessageBubble({
    super.key,
    required this.constraints,
    required this.child,
  });

  final BoxConstraints constraints;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final shadTheme = ShadTheme.maybeOf(context);
    final materialScheme = Theme.of(context).colorScheme;
    if (shadTheme != null) {
      final foreground = shadTheme.colorScheme.cardForeground;
      return ConstrainedBox(
        constraints: constraints,
        child: ShadCard(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          backgroundColor: shadTheme.colorScheme.muted,
          radius: shadTheme.radius,
          border: ShadBorder.none,
          shadows: const <BoxShadow>[],
          child: DefaultTextStyle.merge(
            style: TextStyle(color: foreground),
            child: IconTheme.merge(
              data: IconThemeData(color: foreground),
              child: child,
            ),
          ),
        ),
      );
    }
    return Container(
      constraints: constraints,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: materialScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
      child: DefaultTextStyle.merge(
        style: TextStyle(color: materialScheme.onSurface),
        child: IconTheme.merge(
          data: IconThemeData(color: materialScheme.onSurface),
          child: child,
        ),
      ),
    );
  }
}
