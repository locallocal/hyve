part of 'message_list.dart';

class ReasoningSection extends StatefulWidget {
  final String reasoning;
  final bool isDesktop;
  final bool isStreaming;
  final int? durationMs;
  final MessageActionViewModel? actionViewModel;

  const ReasoningSection({
    super.key,
    required this.reasoning,
    this.isDesktop = false,
    this.isStreaming = false,
    this.durationMs,
    this.actionViewModel,
  });

  @override
  State<ReasoningSection> createState() => _ReasoningSectionState();
}

class ProcessInfoSection extends StatefulWidget {
  final MessageProcessInfo processInfo;
  final ModelTokenUsage tokenUsage;
  final bool isDesktop;
  final bool isStreaming;
  final bool hasReasoningContent;

  const ProcessInfoSection({
    super.key,
    required this.processInfo,
    this.tokenUsage = ModelTokenUsage.empty,
    this.isDesktop = false,
    this.isStreaming = false,
    this.hasReasoningContent = false,
  });

  static const desktopDetailsMaxHeight = 320.0;

  @override
  State<ProcessInfoSection> createState() => _ProcessInfoSectionState();
}

class _ProcessInfoSectionState extends State<ProcessInfoSection> {
  static const _itemValue = 'execution-status';

  late final ShadAccordionController<String> _desktopController;
  late final ScrollController _detailsScrollController;

  @override
  void initState() {
    super.initState();
    _desktopController = ShadAccordionController<String>(
      widget.isDesktop && widget.isStreaming ? _itemValue : null,
    );
    _detailsScrollController = ScrollController();
  }

  @override
  void didUpdateWidget(covariant ProcessInfoSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.isDesktop || oldWidget.isStreaming == widget.isStreaming) {
      return;
    }
    final isOpen = _desktopController.value.contains(_itemValue);
    if (widget.isStreaming != isOpen) {
      _desktopController.toggle(_itemValue);
    }
  }

  @override
  void dispose() {
    _desktopController.dispose();
    _detailsScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);
    final headerMetrics = <Widget>[];
    final summaryChips = <Widget>[];

    if (!widget.hasReasoningContent &&
        widget.processInfo.reasoningStatus.isNotEmpty) {
      summaryChips.add(
        _ProcessChip(
          icon: LucideIcons.brain,
          label: _reasoningStatusLabel(
            strings,
            widget.processInfo.reasoningStatus,
          ),
        ),
      );
    }

    if (widget.processInfo.durationMs != null) {
      headerMetrics.add(
        _ProcessHeaderMetric(
          icon: LucideIcons.clock3,
          label: strings.processDuration(
            _formatDuration(widget.processInfo.durationMs!),
          ),
        ),
      );
    }

    if (widget.tokenUsage.inputTokens > 0 ||
        widget.tokenUsage.outputTokens > 0) {
      headerMetrics
        ..add(
          _ProcessHeaderMetric(
            icon: Icons.login_rounded,
            label: '${strings.inputTokens} ${widget.tokenUsage.inputTokens}',
          ),
        )
        ..add(
          _ProcessHeaderMetric(
            icon: Icons.logout_rounded,
            label: '${strings.outputTokens} ${widget.tokenUsage.outputTokens}',
          ),
        );
    }

    if (widget.processInfo.toolCalls.isNotEmpty) {
      summaryChips.add(
        _ProcessChip(
          icon: LucideIcons.wrench,
          label: strings.processToolCount(
            widget.processInfo.toolCalls.length.toString(),
          ),
        ),
      );
    }

    final mcpToolCallCount =
        widget.processInfo.toolCalls
            .where((call) => call.source == ToolSource.mcp.name)
            .length;
    if (mcpToolCallCount > 0) {
      summaryChips.add(
        _ProcessChip(
          icon: LucideIcons.plug,
          label: '${strings.toolSourceMcp} $mcpToolCallCount',
        ),
      );
    }

    if (widget.processInfo.commandExecutions.isNotEmpty) {
      summaryChips.add(
        _ProcessChip(
          icon: LucideIcons.terminal,
          label: strings.processCommandCount(
            widget.processInfo.commandExecutions.length.toString(),
          ),
        ),
      );
    }

    if (widget.processInfo.fileEdits.isNotEmpty) {
      summaryChips.add(
        _ProcessChip(
          icon: LucideIcons.filePenLine,
          label: strings.processFileCount(
            widget.processInfo.fileEdits.length.toString(),
          ),
        ),
      );
    }

    if (widget.processInfo.skillActivations.isNotEmpty) {
      summaryChips.add(
        _ProcessChip(
          icon: LucideIcons.wrench,
          label:
              '${strings.messageSkills} '
              '${widget.processInfo.skillActivations.length}',
        ),
      );
    }

    final details =
        summaryChips.isEmpty &&
                widget.processInfo.toolCalls.isEmpty &&
                widget.processInfo.commandExecutions.isEmpty &&
                widget.processInfo.fileEdits.isEmpty &&
                widget.processInfo.skillActivations.isEmpty
            ? null
            : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (summaryChips.isNotEmpty)
                  Wrap(spacing: 8, runSpacing: 8, children: summaryChips),
                if (widget.processInfo.toolCalls.isNotEmpty) ...[
                  SizedBox(height: summaryChips.isNotEmpty ? 12 : 0),
                  _ProcessListCard<MessageToolCall>(
                    title: strings.toolCalls,
                    icon: LucideIcons.wrench,
                    items: widget.processInfo.toolCalls,
                    titleBuilder: _toolCallTitle,
                    subtitleBuilder: (item) => _toolCallSubtitle(strings, item),
                    statusBuilder: (item) => item.status,
                  ),
                ],
                if (widget.processInfo.commandExecutions.isNotEmpty) ...[
                  SizedBox(height: summaryChips.isNotEmpty ? 12 : 0),
                  _ProcessListCard<MessageCommandExecution>(
                    title: strings.commandExecutions,
                    icon: LucideIcons.terminal,
                    items: widget.processInfo.commandExecutions,
                    titleBuilder: (item) => item.command,
                    subtitleBuilder:
                        (item) => _joinMeta([
                          if (item.detail.isNotEmpty)
                            _processDetailLabel(strings, item.detail),
                          if (item.durationMs != null)
                            strings.processDuration(
                              _formatDuration(item.durationMs!),
                            ),
                        ]),
                    statusBuilder: (item) => item.status,
                  ),
                ],
                if (widget.processInfo.fileEdits.isNotEmpty) ...[
                  SizedBox(height: summaryChips.isNotEmpty ? 12 : 0),
                  _ProcessListCard<MessageFileEdit>(
                    title: strings.fileStatus,
                    icon: LucideIcons.fileText,
                    items: widget.processInfo.fileEdits,
                    titleBuilder:
                        (item) => item.path.split(Platform.pathSeparator).last,
                    subtitleBuilder:
                        (item) => _joinMeta([
                          if (item.detail.isNotEmpty)
                            _processDetailLabel(strings, item.detail),
                          if (item.type.isNotEmpty)
                            _fileTypeLabel(strings, item.type),
                        ]),
                    statusBuilder: (item) => item.status,
                  ),
                ],
                if (widget.processInfo.skillActivations.isNotEmpty) ...[
                  SizedBox(height: summaryChips.isNotEmpty ? 12 : 0),
                  _ProcessListCard<MessageSkillActivation>(
                    title: strings.messageSkills,
                    icon: LucideIcons.wrench,
                    items: widget.processInfo.skillActivations,
                    titleBuilder: (item) => item.name,
                    subtitleBuilder:
                        (item) => _joinMeta([
                          _skillActivationTriggerLabel(strings, item.trigger),
                          if (item.contentDigest.isNotEmpty)
                            item.contentDigest.substring(
                              0,
                              item.contentDigest.length.clamp(0, 12),
                            ),
                        ]),
                    statusBuilder: (item) => item.status,
                  ),
                ],
              ],
            );

    final subtitleContent =
        headerMetrics.isEmpty
            ? null
            : Wrap(
              key: const ValueKey<String>('execution-header-metrics'),
              spacing: 16,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: headerMetrics,
            );

    if (!widget.isDesktop || details == null) {
      return _StatusCardSection(
        isDesktop: widget.isDesktop,
        icon:
            widget.isDesktop
                ? LucideIcons.sparkles
                : Icons.auto_awesome_motion_rounded,
        title: strings.executionStatus,
        subtitle: _buildSubtitle(strings),
        subtitleContent: subtitleContent,
        child: details,
      );
    }

    final disableAnimations = MediaQuery.disableAnimationsOf(context);
    return ShadCard(
      key: const ValueKey<String>('desktop-execution-status'),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      backgroundColor: StarsDesktopTokens.of(context).controlFill,
      radius: StarsDesktopThemeSpec.statusRadius,
      border: ShadBorder.all(color: StarsDesktopTokens.of(context).separator),
      child: ShadAccordion<String>(
        controller: _desktopController,
        maintainState: true,
        children: [
          ShadAccordionItem<String>(
            value: _itemValue,
            separator: const SizedBox.shrink(),
            padding: const EdgeInsets.symmetric(vertical: 12),
            duration:
                disableAnimations
                    ? Duration.zero
                    : const Duration(milliseconds: 180),
            underlineTitleOnHover: false,
            iconData: LucideIcons.chevronDown,
            title: ListenableBuilder(
              listenable: _desktopController,
              builder:
                  (context, child) => Semantics(
                    expanded: _desktopController.value.contains(_itemValue),
                    child: child,
                  ),
              child: _StatusCardHeader(
                isDesktop: true,
                icon: LucideIcons.sparkles,
                title: strings.executionStatus,
                subtitle: _buildSubtitle(strings),
                subtitleContent: subtitleContent,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxHeight: ProcessInfoSection.desktopDetailsMaxHeight,
                ),
                child: Scrollbar(
                  controller: _detailsScrollController,
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    key: const ValueKey<String>('execution-details-scroll'),
                    controller: _detailsScrollController,
                    primary: false,
                    padding: const EdgeInsets.only(right: 8),
                    child: details,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _buildSubtitle(S strings) {
    final parts = <String>[];
    if (widget.processInfo.toolCalls.isNotEmpty) {
      parts.add(
        strings.processToolCount(
          widget.processInfo.toolCalls.length.toString(),
        ),
      );
    }
    if (widget.processInfo.commandExecutions.isNotEmpty) {
      parts.add(
        strings.processCommandCount(
          widget.processInfo.commandExecutions.length.toString(),
        ),
      );
    }
    if (widget.processInfo.fileEdits.isNotEmpty) {
      parts.add(
        strings.processFileCount(
          widget.processInfo.fileEdits.length.toString(),
        ),
      );
    }
    if (widget.processInfo.skillActivations.isNotEmpty) {
      parts.add(
        '${strings.messageSkills} '
        '${widget.processInfo.skillActivations.length}',
      );
    }
    return parts.isEmpty ? strings.structuredProcessInfo : parts.join(' · ');
  }
}

const _processMetricTextStyle = TextStyle(
  fontSize: 12,
  height: 1.2,
  fontWeight: FontWeight.w400,
  leadingDistribution: TextLeadingDistribution.even,
);

class _ProcessHeaderMetric extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ProcessHeaderMetric({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final color = StarsDesktopTokens.of(context).secondaryText;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox.square(
          dimension: 14,
          child: Center(child: Icon(icon, size: 14, color: color)),
        ),
        const SizedBox(width: 6),
        Text(label, style: _processMetricTextStyle.copyWith(color: color)),
      ],
    );
  }
}

class _ProcessChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ProcessChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return ShadBadge.outline(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox.square(
            dimension: 14,
            child: Center(
              child: Icon(
                icon,
                size: 14,
                color: StarsDesktopTokens.of(context).secondaryText,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: _processMetricTextStyle.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProcessListCard<T> extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<T> items;
  final String Function(T item) titleBuilder;
  final String Function(T item) subtitleBuilder;
  final String Function(T item) statusBuilder;

  const _ProcessListCard({
    required this.title,
    required this.icon,
    required this.items,
    required this.titleBuilder,
    required this.subtitleBuilder,
    required this.statusBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: StarsDesktopTokens.of(context).separator),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: StarsDesktopTokens.of(context).secondaryText,
              ),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 10),
          ...items.asMap().entries.map((entry) {
            final item = entry.value;
            final subtitle = subtitleBuilder(item);
            final hasSubtitle = subtitle.isNotEmpty;
            return Padding(
              padding: EdgeInsets.only(
                bottom: entry.key == items.length - 1 ? 0 : 10,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          titleBuilder(item),
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        if (hasSubtitle) ...[
                          const SizedBox(height: 2),
                          Text(
                            subtitle,
                            style: TextStyle(
                              fontSize: 12,
                              color:
                                  StarsDesktopTokens.of(context).secondaryText,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  _StatusBadge(status: statusBuilder(item)),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final normalized = status.isEmpty ? 'unknown' : status;
    final variant = switch (normalized) {
      'completed' ||
      'created' ||
      'attached' ||
      'succeeded' ||
      'activated' => ShadBadgeVariant.secondary,
      'failed' ||
      'error' ||
      'denied' ||
      'timedOut' => ShadBadgeVariant.destructive,
      _ => ShadBadgeVariant.outline,
    };

    return ShadBadge.raw(
      variant: variant,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      child: Text(
        _statusLabel(S.of(context), normalized),
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}

String _statusLabel(S strings, String status) {
  switch (status) {
    case 'completed':
      return strings.statusCompleted;
    case 'created':
      return strings.statusGenerated;
    case 'attached':
      return strings.statusAttached;
    case 'streaming':
      return strings.statusInProgress;
    case 'running':
      return strings.statusRunning;
    case 'requested':
      return strings.statusRequested;
    case 'awaitingApproval':
      return strings.statusAwaitingApproval;
    case 'cancelled':
      return strings.statusCancelled;
    case 'denied':
      return strings.statusDenied;
    case 'timedOut':
      return strings.statusTimedOut;
    case 'duplicate':
      return strings.statusDuplicate;
    case 'skipped':
      return strings.statusSkipped;
    case 'activated':
      return strings.statusActivated;
    case 'unknown':
      return strings.statusUnknown;
    case 'succeeded':
      return strings.statusCompleted;
    case 'failed':
    case 'error':
      return strings.statusFailed;
    case 'recorded':
      return strings.statusRecorded;
    default:
      return strings.statusUnknown;
  }
}

String _reasoningStatusLabel(S strings, String status) {
  switch (status) {
    case 'completed':
      return strings.reasoningCompleted;
    case 'cancelled':
      return strings.reasoningInterrupted;
    case 'streaming':
      return strings.reasoningInProgress;
    default:
      return strings.processInformation;
  }
}

String _fileTypeLabel(S strings, String type) {
  switch (type) {
    case 'image':
      return strings.uploadImage;
    case 'audio':
      return strings.fileTypeSpeech;
    case 'music':
      return strings.fileTypeMusic;
    case 'video':
      return strings.fileTypeVideo;
    default:
      return strings.uploadFile;
  }
}

String _joinMeta(List<String> parts) {
  final filtered = parts.where((item) => item.isNotEmpty).toSet().toList();
  return filtered.join(' · ');
}

String _toolCallTitle(MessageToolCall item) {
  if (item.source != ToolSource.mcp.name || item.mcpServerName.trim().isEmpty) {
    return item.name;
  }
  final toolName = item.title.trim().isEmpty ? item.name : item.title.trim();
  return '${item.mcpServerName.trim()} · $toolName';
}

String _toolCallSubtitle(S strings, MessageToolCall item) => _joinMeta([
  if (item.source.isNotEmpty || item.riskLevel.isNotEmpty)
    _joinMeta([
      _toolSourceLabel(strings, item.source),
      _toolRiskLabel(strings, item.riskLevel),
    ]),
  if (item.argumentsSummary.isNotEmpty) item.argumentsSummary,
  if (item.detail.isNotEmpty) _processDetailLabel(strings, item.detail),
  if (item.resultSummary.isNotEmpty && item.errorCode.isEmpty)
    _processDetailLabel(strings, item.resultSummary),
  if (item.approvalStatus.isNotEmpty)
    _toolApprovalLabel(strings, item.approvalStatus),
  if (item.durationMs != null)
    strings.processDuration(_formatDuration(item.durationMs!)),
]);

String _toolSourceLabel(S strings, String source) {
  switch (source) {
    case 'builtIn':
      return strings.toolSourceBuiltIn;
    case 'mcp':
      return strings.toolSourceMcp;
    case 'skillScript':
      return strings.toolSourceSkillScript;
    case '':
      return '';
    default:
      return strings.statusUnknown;
  }
}

String _toolRiskLabel(S strings, String riskLevel) {
  switch (riskLevel) {
    case 'readOnly':
      return strings.toolRiskReadOnly;
    case 'write':
      return strings.toolRiskWrite;
    case 'destructive':
      return strings.toolRiskDestructive;
    case '':
      return '';
    default:
      return strings.statusUnknown;
  }
}

String _toolApprovalLabel(S strings, String approvalStatus) {
  switch (approvalStatus) {
    case 'allowOnce':
      return strings.toolApprovalAllowOnce;
    case 'deny':
      return strings.toolApprovalDenied;
    case '':
      return '';
    default:
      return strings.statusUnknown;
  }
}

String _skillActivationTriggerLabel(S strings, String trigger) {
  switch (trigger) {
    case 'model':
      return strings.autoActivation;
    case 'manual':
      return strings.manualActivation;
    case 'always':
      return strings.alwaysActivation;
    case '':
      return '';
    default:
      return strings.statusUnknown;
  }
}

String _processDetailLabel(S strings, String detail) {
  switch (detail) {
    case 'completed':
    case 'succeeded':
      return strings.statusCompleted;
    case 'created':
      return strings.statusGenerated;
    case 'attached':
      return strings.statusAttached;
    case 'streaming':
      return strings.statusInProgress;
    case 'requested':
      return strings.statusRequested;
    case 'awaitingApproval':
      return strings.statusAwaitingApproval;
    case 'running':
      return strings.statusRunning;
    case 'cancelled':
      return strings.statusCancelled;
    case 'denied':
      return strings.statusDenied;
    case 'timedOut':
      return strings.statusTimedOut;
    case 'duplicate':
      return strings.statusDuplicate;
    case 'skipped':
      return strings.statusSkipped;
    case 'activated':
      return strings.statusActivated;
    case 'recorded':
      return strings.statusRecorded;
    case 'failed':
    case 'error':
      return strings.statusFailed;
    case 'unknown':
      return strings.statusUnknown;
    case 'skill_provider_timeout':
    case 'provider_timeout':
    case 'tool_approval_timeout':
    case 'tool_execution_timeout':
    case 'Tool approval timed out.':
    case 'Tool execution timed out.':
      return strings.statusTimedOut;
    case 'tool_approval_denied':
    case 'tool_policy_denied':
    case 'tool_not_requested_by_active_skill':
    case 'process_execution_disabled':
    case 'destructive_tools_disabled':
    case 'The tool call was blocked by application policy.':
    case 'The user denied the tool call.':
      return strings.statusDenied;
    case 'agent_run_cancelled':
      return strings.statusCancelled;
    case 'duplicate_call_id_conflict':
    case 'duplicate_call_reused':
    case 'The call id was already used with different arguments.':
      return strings.statusDuplicate;
    case 'skill_provider_error':
    case 'provider_error':
    case 'invalid_candidate':
    case 'tool_retry_limit_reached':
    case 'tool_not_available':
    case 'invalid_tool_arguments':
    case 'tool_execution_failed':
    case 'invalid_tool_output':
    case 'unsupported':
    case 'The requested tool is not available for this run.':
    case 'Tool arguments failed schema validation.':
    case 'Tool execution failed.':
    case 'Tool output failed schema validation.':
      return strings.statusFailed;
  }

  final looksLikeInternalCode = RegExp(
    r'^[a-z][a-z0-9]*(?:_[a-z0-9]+)+$',
  ).hasMatch(detail);
  return looksLikeInternalCode ? strings.statusFailed : detail;
}

String _formatDuration(int durationMs) {
  if (durationMs < 1000) {
    return '${durationMs}ms';
  }
  final seconds = durationMs / 1000;
  return '${seconds.toStringAsFixed(seconds >= 10 ? 0 : 1)}s';
}
