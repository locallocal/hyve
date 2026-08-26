import 'dart:async';

import 'package:hyve/domain/models/models.dart';
import 'package:hyve/domain/repositories/agent_memory_evolution_repository.dart';
import 'package:hyve/domain/repositories/agent_memory_repository.dart';
import 'package:hyve/domain/repositories/agent_repository.dart';
import 'package:hyve/ui/core/view_models/disposable_change_notifier.dart';

final class AgentMemoryViewModel extends DisposableChangeNotifier {
  AgentMemoryViewModel({
    required this.agentId,
    required AgentRepository agentRepository,
    required AgentMemoryRepository memoryRepository,
    required AgentMemoryEvolutionRepository evolutionRepository,
  }) : _agentRepository = agentRepository,
       _memoryRepository = memoryRepository,
       _evolutionRepository = evolutionRepository {
    _subscription = _memoryRepository.changes
        .where((changedAgentId) => changedAgentId == agentId)
        .listen((_) => unawaited(load()));
  }

  final String agentId;
  final AgentRepository _agentRepository;
  final AgentMemoryRepository _memoryRepository;
  final AgentMemoryEvolutionRepository _evolutionRepository;
  StreamSubscription<String>? _subscription;

  Agent? _agent;
  List<AgentMemory> _items = const <AgentMemory>[];
  List<AgentMemoryEvolutionRun> _evolutionRuns =
      const <AgentMemoryEvolutionRun>[];
  bool _loading = false;
  bool _compacting = false;
  AppFailure? _error;
  int _generation = 0;

  Agent? get agent => _agent;
  List<AgentMemory> get items => _items;
  List<AgentMemoryEvolutionRun> get evolutionRuns => _evolutionRuns;
  bool get loading => _loading;
  bool get compacting => _compacting;
  AppFailure? get error => _error;
  bool get autoEvolutionEnabled =>
      _agent?.memoryPolicy.autoEvolutionEnabled ?? false;
  List<AgentMemory> get summaryItems => List<AgentMemory>.unmodifiable(
    _items.where((memory) => memory.isRecallable),
  );

  Future<void> load() async {
    if (isDisposed) return;
    final generation = ++_generation;
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final results = await Future.wait<Object?>(<Future<Object?>>[
        _agentRepository.getAgent(agentId),
        _memoryRepository.list(agentId),
        _evolutionRepository.getForAgent(agentId, limit: 20),
      ]);
      if (isDisposed || generation != _generation) return;
      _agent = results[0] as Agent?;
      _items = List<AgentMemory>.unmodifiable(results[1]! as List<AgentMemory>);
      _evolutionRuns = List<AgentMemoryEvolutionRun>.unmodifiable(
        results[2]! as List<AgentMemoryEvolutionRun>,
      );
    } on Object catch (error) {
      if (!isDisposed && generation == _generation) {
        _error = AppFailure.from(error, code: 'agent_memory_load_failed');
      }
    } finally {
      if (!isDisposed && generation == _generation) {
        _loading = false;
        notifyListeners();
      }
    }
  }

  Future<void> setAutoEvolutionEnabled(bool enabled) async {
    final current = _agent ?? await _agentRepository.getAgent(agentId);
    if (isDisposed || current == null) return;
    final updated = current.copyWith(
      memoryPolicy: current.memoryPolicy.copyWith(
        autoEvolutionEnabled: enabled,
      ),
      updatedAt: DateTime.now(),
    );
    await _agentRepository.updateAgent(updated);
    if (!isDisposed) await load();
  }

  Future<void> correct(
    AgentMemory memory, {
    required String content,
    required AgentMemoryReuseScope reuseScope,
  }) async {
    await _memoryRepository.correct(
      agentId: agentId,
      memoryId: memory.id,
      content: content,
      reuseScope: reuseScope,
    );
    if (!isDisposed) await load();
  }

  Future<void> approve(AgentMemory memory) => correct(
    memory,
    content: memory.content,
    reuseScope: AgentMemoryReuseScope.crossProject,
  );

  Future<void> forget(AgentMemory memory) async {
    await _memoryRepository.forget(agentId: agentId, memoryId: memory.id);
    if (!isDisposed) await load();
  }

  /// Removes redundant current memories without crossing kind, privacy, or
  /// project-scope boundaries.
  Future<int> compactNow() async {
    if (isDisposed || _compacting) return 0;
    _compacting = true;
    _error = null;
    notifyListeners();
    try {
      final memories = await _memoryRepository.list(agentId);
      final candidates = memories
        .where((memory) => memory.state != AgentMemoryState.forgotten)
        .toList(growable: false)..sort(_compareCompactionPriority);
      final fingerprints = <String>{};
      var compacted = 0;
      for (final memory in candidates) {
        if (fingerprints.add(_compactionFingerprint(memory))) continue;
        await _memoryRepository.forget(agentId: agentId, memoryId: memory.id);
        compacted++;
      }
      if (!isDisposed) await load();
      return compacted;
    } on Object catch (error) {
      if (!isDisposed) {
        _error = AppFailure.from(error, code: 'agent_memory_compaction_failed');
        notifyListeners();
      }
      rethrow;
    } finally {
      if (!isDisposed) {
        _compacting = false;
        notifyListeners();
      }
    }
  }

  @override
  void disposeResources() {
    unawaited(_subscription?.cancel());
  }
}

int _compareCompactionPriority(AgentMemory left, AgentMemory right) {
  final state = _memoryStatePriority(
    left.state,
  ).compareTo(_memoryStatePriority(right.state));
  if (state != 0) return state;
  final confidence = right.confidence.compareTo(left.confidence);
  if (confidence != 0) return confidence;
  final importance = right.importance.compareTo(left.importance);
  if (importance != 0) return importance;
  return right.updatedAt.compareTo(left.updatedAt);
}

int _memoryStatePriority(AgentMemoryState state) => switch (state) {
  AgentMemoryState.active => 0,
  AgentMemoryState.candidate => 1,
  AgentMemoryState.superseded => 2,
  AgentMemoryState.forgotten => 3,
};

String _compactionFingerprint(AgentMemory memory) {
  final normalizedContent = memory.content.trim().toLowerCase().replaceAll(
    RegExp(r'\s+'),
    ' ',
  );
  final scopedProject =
      memory.reuseScope == AgentMemoryReuseScope.sourceProjectOnly
          ? memory.sourceProjectId
          : '';
  return <Object>[
    memory.kind.name,
    memory.reuseScope.name,
    memory.sensitivity.name,
    scopedProject,
    normalizedContent,
  ].join('\u0000');
}
