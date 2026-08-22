import 'dart:async';

import 'package:hyve/domain/models/agent.dart';
import 'package:hyve/domain/models/app_failure.dart';
import 'package:hyve/domain/models/conversation_memory.dart';
import 'package:hyve/domain/models/conversation_summary.dart';
import 'package:hyve/domain/models/message.dart';
import 'package:hyve/domain/repositories/conversation_summary_repository.dart';
import 'package:hyve/domain/repositories/project_context_summarizer.dart';
import 'package:hyve/domain/repositories/project_event_repository.dart';
import 'package:hyve/domain/repositories/project_repository.dart';
import 'package:hyve/domain/services/conversation_summary_source_digest.dart';
import 'package:hyve/domain/services/token_estimator.dart';

typedef ProjectContextSummarizerFactory =
    ProjectContextSummarizer Function(Agent agent);
typedef ConversationSummaryClock = DateTime Function();
typedef ConversationSummaryUsagePersister =
    Future<void> Function(
      String operationId,
      String projectId,
      Agent agent,
      ModelTokenUsage usage,
    );

enum CompactConversationMessagesResult {
  committed,
  noCandidates,
  revisionConflict,
  invalidSourceRange,
  invalidSummary,
}

/// Builds immutable summaries only from a continuous Project message range.
final class CompactConversationMessages {
  CompactConversationMessages({
    required ProjectRepository projectRepository,
    required ProjectEventRepository eventRepository,
    required ConversationSummaryRepository summaryRepository,
    required ProjectContextSummarizerFactory summarizerFactory,
    TokenEstimator tokenEstimator = const ConservativeTokenEstimator(),
    ConversationSummarySourceDigest sourceDigest =
        const ConversationSummarySourceDigest(),
    ConversationSummaryClock? clock,
    ConversationSummaryUsagePersister? usagePersister,
    this.protectedRecentMessages = 8,
    this.maximumMessagesPerSegment = 24,
  }) : _projectRepository = projectRepository,
       _eventRepository = eventRepository,
       _summaryRepository = summaryRepository,
       _summarizerFactory = summarizerFactory,
       _tokenEstimator = tokenEstimator,
       _sourceDigest = sourceDigest,
       _clock = clock ?? DateTime.now,
       _usagePersister = usagePersister;

  final ProjectRepository _projectRepository;
  final ProjectEventRepository _eventRepository;
  final ConversationSummaryRepository _summaryRepository;
  final ProjectContextSummarizerFactory _summarizerFactory;
  final TokenEstimator _tokenEstimator;
  final ConversationSummarySourceDigest _sourceDigest;
  final ConversationSummaryClock _clock;
  final ConversationSummaryUsagePersister? _usagePersister;
  final int protectedRecentMessages;
  final int maximumMessagesPerSegment;
  final Map<String, Future<void>> _tails = <String, Future<void>>{};
  int _idSequence = 0;

  Future<CompactConversationMessagesResult> call({
    required Agent agent,
    required String projectId,
    ConversationSummaryKind kind = ConversationSummaryKind.rolling,
    int? startMessageSequence,
    int? endMessageSequence,
    bool manual = false,
    bool rebuild = false,
  }) {
    final previous = _tails[projectId] ?? Future<void>.value();
    final result = previous
        .catchError((_) {})
        .then(
          (_) => _compact(
            agent: agent,
            projectId: projectId,
            kind: kind,
            startMessageSequence: startMessageSequence,
            endMessageSequence: endMessageSequence,
            manual: manual,
            rebuild: rebuild,
          ),
        );
    final tail = result.then<void>((_) {}, onError: (_, _) {});
    _tails[projectId] = tail;
    tail.whenComplete(() {
      if (identical(_tails[projectId], tail)) _tails.remove(projectId);
    });
    return result;
  }

  Future<CompactConversationMessagesResult> _compact({
    required Agent agent,
    required String projectId,
    required ConversationSummaryKind kind,
    required int? startMessageSequence,
    required int? endMessageSequence,
    required bool manual,
    required bool rebuild,
  }) async {
    await _summaryRepository.setCompactionStatus(
      projectId,
      manual
          ? ConversationSummaryCompactionStatus.synchronous
          : ConversationSummaryCompactionStatus.background,
    );
    try {
      if (rebuild) await _summaryRepository.clear(projectId);
      final result = await _compactCore(
        agent: agent,
        projectId: projectId,
        kind: kind,
        startMessageSequence: startMessageSequence,
        endMessageSequence: endMessageSequence,
      );
      if (result != CompactConversationMessagesResult.committed) {
        await _summaryRepository.setCompactionStatus(
          projectId,
          result == CompactConversationMessagesResult.invalidSummary ||
                  result == CompactConversationMessagesResult.invalidSourceRange
              ? ConversationSummaryCompactionStatus.failed
              : ConversationSummaryCompactionStatus.idle,
          lastError: result.name,
        );
      }
      return result;
    } on Object catch (error) {
      await _summaryRepository.setCompactionStatus(
        projectId,
        ConversationSummaryCompactionStatus.failed,
        lastError:
            AppFailure.from(error, code: 'conversation_summary_failed').code,
      );
      rethrow;
    }
  }

  Future<CompactConversationMessagesResult> _compactCore({
    required Agent agent,
    required String projectId,
    required ConversationSummaryKind kind,
    required int? startMessageSequence,
    required int? endMessageSequence,
  }) async {
    final project = await _projectRepository.getProject(projectId);
    if (project == null || project.lastMessageSequence == 0) {
      return CompactConversationMessagesResult.noCandidates;
    }
    final state = await _summaryRepository.getState(projectId);
    late final int start;
    late final int end;
    if (kind == ConversationSummaryKind.rangeExtract) {
      if (startMessageSequence == null || endMessageSequence == null) {
        return CompactConversationMessagesResult.invalidSourceRange;
      }
      start = startMessageSequence;
      end = endMessageSequence;
    } else {
      start = state.coveredThroughMessageSequence + 1;
      final maximumEnd = project.lastMessageSequence - protectedRecentMessages;
      if (maximumEnd < start) {
        return CompactConversationMessagesResult.noCandidates;
      }
      end = (start + maximumMessagesPerSegment - 1).clamp(start, maximumEnd);
    }
    if (start < 1 || end < start || end > project.lastMessageSequence) {
      return CompactConversationMessagesResult.invalidSourceRange;
    }
    final events = await _eventRepository.getMessageRange(
      projectId,
      startMessageSequence: start,
      endMessageSequence: end,
    );
    if (events.length != end - start + 1 ||
        !_isContinuous(events, start: start, end: end)) {
      return CompactConversationMessagesResult.invalidSourceRange;
    }
    final now = _clock();
    final id = _nextId('summary', now);
    final previous =
        kind == ConversationSummaryKind.rolling
            ? await _summaryRepository.getActiveRollingSummaries(
              projectId,
              throughMessageSequence: start - 1,
            )
            : const <ProjectConversationSummary>[];
    final result = await _summarizerFactory(agent).summarize(
      ProjectContextSummaryRequest(
        projectId: projectId,
        segmentId: id,
        kind: kind,
        sourceEvents: events,
        previousSummaries: previous,
        targetTokens: 2048,
      ),
    );
    await _usagePersister?.call(
      'conversation_summary:$id',
      projectId,
      agent,
      result.usage,
    );
    final markdown = result.markdown.trim();
    if (markdown.isEmpty || markdown.length > 200000) {
      return CompactConversationMessagesResult.invalidSummary;
    }
    final profile = ModelContextProfile(
      contextWindowTokens: _contextWindow(agent),
    );
    final setId =
        kind == ConversationSummaryKind.rolling
            ? (state.activeSummarySetId.isEmpty
                ? _nextId('summary-set', now)
                : state.activeSummarySetId)
            : _nextId('range-set', now);
    final segment = ConversationSummarySegment(
      id: id,
      projectId: projectId,
      summarySetId: setId,
      sourceStartMessageSequence: start,
      sourceEndMessageSequence: end,
      kind: kind,
      sourceEventIds: events.map((event) => event.id),
      sourceDigest: _sourceDigest(events),
      fileName: '$id.md',
      contentDigest: '',
      estimatedTokenCount: await _tokenEstimator.estimateText(
        profile,
        markdown,
      ),
      provider: result.provider,
      model: result.model,
      promptVersion: 1,
      createdAt: now,
      updatedAt: now,
    );
    final summary = ProjectConversationSummary(
      segment: segment,
      markdown: markdown,
    );
    if (kind == ConversationSummaryKind.rangeExtract) {
      await _summaryRepository.saveRangeExtract(summary);
      return CompactConversationMessagesResult.committed;
    }
    return await _summaryRepository.commitRolling(
          expectedRevision: state.revision,
          summary: summary,
        )
        ? CompactConversationMessagesResult.committed
        : CompactConversationMessagesResult.revisionConflict;
  }

  bool _isContinuous(
    List<dynamic> events, {
    required int start,
    required int end,
  }) {
    var expected = start;
    for (final dynamic event in events) {
      if (event.messageSequence != expected++) return false;
    }
    return expected - 1 == end;
  }

  String _nextId(String prefix, DateTime now) {
    _idSequence = (_idSequence + 1) & 0x7fffffff;
    return '${prefix}_${now.microsecondsSinceEpoch}_$_idSequence';
  }

  int _contextWindow(Agent agent) {
    final value = agent.parameters['contextWindowTokens'];
    return value is int && value > 0 ? value : 32768;
  }
}
