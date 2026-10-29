import 'dart:async';
import 'dart:convert';

import '../../core/agents/memory_models.dart';
import '../../core/design/flashcards_3d/flashcard_3d_models.dart';
import '../../core/orchestration/orchestration.dart';
import '../../core/storage/offline_progress_service.dart';
import '../../core/storage/runtime_local_state_container.dart';
import '../../core/storage/validation_hash_cache.dart';
import '../../services/preferences_service.dart';

final class Phase10PresentationBridge {
  Phase10PresentationBridge._({
    required AgentEventBus eventBus,
    required OrchestrationKernel kernel,
    required AgentEndpoint endpoint,
    required AgentEventBatchDispatcher batchDispatcher,
    required ValidationHashCache validationCache,
    required OfflineProgressSnapshot initialSnapshot,
  })  : _eventBus = eventBus,
        _kernel = kernel,
        _endpoint = endpoint,
        _batchDispatcher = batchDispatcher,
        _validationCache = validationCache,
        _snapshot = initialSnapshot {
    _subscription = endpoint.allEvents.listen(_handleEvent);
  }

  static const String _uiValidationKey = 'phase10_validation_cache_v1';

  static Future<Phase10PresentationBridge> start() async {
    final eventBus = AgentEventBus();
    final kernel = OrchestrationKernel(
      eventBus: eventBus,
      services: ServiceContainer(),
    );
    final endpoint = _connect(kernel, 'phase10.presentation-ui');

    OfflineProgressSnapshot initial = OfflineProgressSnapshot.empty();
    MemoryAgentStore validationStore = _InMemoryStore();

    try {
      final preferences = await PreferencesService.instance();
      initial = await _readPersistedProgress(
        _PreferencesSystemMemoryStore(preferences),
      );
      validationStore = _PreferencesTextStore(
        preferences,
        _uiValidationKey,
      );
    } on Object {
      initial = OfflineProgressSnapshot.empty();
    }

    final cache = await ValidationHashCache.open(validationStore);
    final batchDispatcher = endpoint.createBatchDispatcher(
      maxBatchSize: 8,
      maxPending: 64,
      flushDelay: const Duration(milliseconds: 2),
    );
    return Phase10PresentationBridge._(
      eventBus: eventBus,
      kernel: kernel,
      endpoint: endpoint,
      batchDispatcher: batchDispatcher,
      validationCache: cache,
      initialSnapshot: initial,
    );
  }

  static Future<Phase10PresentationBridge> isolated({
    required AgentEventBus eventBus,
    required MemoryAgentStore validationStore,
    required OfflineProgressSnapshot initialSnapshot,
  }) async {
    final kernel = OrchestrationKernel(
      eventBus: eventBus,
      services: ServiceContainer(),
    );
    final endpoint = _connect(kernel, 'phase10.presentation-isolated');
    final cache = await ValidationHashCache.open(validationStore);
    final batchDispatcher = endpoint.createBatchDispatcher(
      maxBatchSize: 8,
      maxPending: 64,
      flushDelay: Duration.zero,
    );
    return Phase10PresentationBridge._(
      eventBus: eventBus,
      kernel: kernel,
      endpoint: endpoint,
      batchDispatcher: batchDispatcher,
      validationCache: cache,
      initialSnapshot: initialSnapshot,
    );
  }

  final AgentEventBus _eventBus;
  final OrchestrationKernel _kernel;
  final AgentEndpoint _endpoint;
  final AgentEventBatchDispatcher _batchDispatcher;
  final ValidationHashCache _validationCache;
  final StreamController<OfflineProgressSnapshot> _progressController =
      StreamController<OfflineProgressSnapshot>.broadcast();

  late final StreamSubscription<AgentEvent> _subscription;
  OfflineProgressSnapshot _snapshot;
  int _sequence = 0;
  bool _closed = false;

  OfflineProgressSnapshot get progressSnapshot => _snapshot;
  Stream<OfflineProgressSnapshot> get progressStream =>
      _progressController.stream;
  bool get isClosed => _closed;

  int get validationCacheHits => _validationCache.hits;
  int get validationCacheMisses => _validationCache.misses;
  AgentBatchQueueStats get batchStats => _batchDispatcher.stats;

  Future<ValidationCacheResult> validateCard(Flashcard3DData card) {
    _ensureOpen();
    final source = _snapshot.sourceLanguageTag ?? card.backLanguageCode;
    final target = _snapshot.targetLanguageTag ?? card.frontLanguageCode;
    final content = <String>[
      card.frontText,
      card.backText,
      card.article ?? '',
      card.frontSupportingText ?? '',
      card.backSupportingText ?? '',
    ].join('\u0000');

    return _validationCache.validateOnce(
      scopeKey:
          '${source.toLowerCase()}->${target.toLowerCase()}'
          '|flashcard|${card.id}',
      content: content,
      validatorVersion: 'phase10.card.v1',
      validator: () async => _isStructurallyValid(card),
    );
  }

  void recordCardInteraction({
    required String cardId,
    required double score,
    required int points,
    String taskId = 'task-46',
    bool completed = false,
  }) {
    _ensureOpen();
    final normalizedTask = taskId.trim();
    if (!_isCanonicalTaskId(normalizedTask)) {
      throw ArgumentError.value(
        taskId,
        'taskId',
        'must be one of task-01..task-50',
      );
    }

    final now = DateTime.now().millisecondsSinceEpoch;
    final payload = <String, Object?>{
      'taskId': normalizedTask,
      'score': score.clamp(0.0, 1.0).toDouble(),
      'completed': completed,
      'attempts': 1,
      'points': points.clamp(0, 1000).toInt(),
      'occurredAtEpochMs': now,
      'source': 'phase10.flashcard',
      'cardId': cardId.trim(),
    };

    _applyProgressPayload(payload);
    final correlationId = _nextCorrelation('progress');
    unawaited(
      _batchDispatcher
          .submit(
            AgentBatchEvent(
              dedupeKey: correlationId,
              topic: AgentTopics.learningProgress,
              targetRoles: const <AgentRole>{AgentRole.memory},
              context: AgentContextSnapshot.empty(correlationId),
              payload: payload,
            ),
          )
          .catchError((Object _) {}),
    );
  }

  Future<void> flush() async {
    _ensureOpen();
    await _batchDispatcher.flush();
    await _validationCache.flush();
  }

  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    await _batchDispatcher.close();
    await _subscription.cancel();
    await _validationCache.close();
    await _kernel.close();
    await _progressController.close();
  }

  void _handleEvent(AgentEvent event) {
    if (_closed) return;
    switch (event.topic) {
      case AgentTopics.learningProgress:
        _applyProgressPayload(event.payload);
        return;
      case AgentTopics.polyglotMatrixChanged:
        _applyPairPayload(event.payload);
        return;
    }
  }

  void _applyProgressPayload(Map<String, Object?> payload) {
    final taskId = payload['taskId'];
    if (taskId is! String || !_isCanonicalTaskId(taskId)) return;

    final rawScore = payload['score'];
    final score = rawScore is num
        ? rawScore.toDouble().clamp(0.0, 1.0).toDouble()
        : 0.0;
    final rawPoints = payload['points'];
    final pointsDelta = rawPoints is num
        ? rawPoints.toInt().clamp(0, 1000).toInt()
        : _defaultPoints(score, payload['completed'] == true);
    final completed = payload['completed'] == true;
    final rawTimestamp = payload['occurredAtEpochMs'];
    final timestamp = rawTimestamp is num
        ? rawTimestamp.toInt().clamp(0, 4102444800000).toInt()
        : DateTime.now().millisecondsSinceEpoch;

    final tasks = <String, Map<String, Object?>>{
      for (final entry in _snapshot.tasks.entries)
        entry.key: entry.value.toJson(),
    };
    final current = _snapshot.tasks[taskId];
    final currentPoints = current?.points ?? 0;
    final currentScore = current?.bestScore ?? 0;
    final nextScore = score > currentScore ? score : currentScore;
    final nextCompleted = (current?.completed ?? false) || completed;
    final nextPoints =
        (currentPoints + pointsDelta).clamp(0, 1000000000).toInt();

    tasks[taskId] = <String, Object?>{
      'taskId': taskId,
      'points': nextPoints,
      'bestScore': nextScore,
      'completed': nextCompleted,
      'mastery': nextCompleted
          ? TaskMasteryStatus.mastered.name
          : (nextPoints > 0 || nextScore > 0)
              ? TaskMasteryStatus.learning.name
              : TaskMasteryStatus.notStarted.name,
      'updatedAtEpochMs': timestamp,
    };

    _snapshot = _decodeSnapshot(
      source: _snapshot.sourceLanguageTag,
      target: _snapshot.targetLanguageTag,
      tasks: tasks.values,
      updatedAtEpochMs: timestamp,
    );
    _emit();
  }

  void _applyPairPayload(Map<String, Object?> payload) {
    final source = _language(
      payload['sourceLanguage'] ?? payload['sourceLocale'],
    );
    final target = _language(
      payload['targetLanguage'] ?? payload['targetLocale'],
    );
    if (source == null || target == null) return;

    _snapshot = _decodeSnapshot(
      source: source,
      target: target,
      tasks: _snapshot.tasks.values.map((task) => task.toJson()),
      updatedAtEpochMs: DateTime.now().millisecondsSinceEpoch,
    );
    _emit();
  }

  void _emit() {
    if (!_closed && !_progressController.isClosed) {
      _progressController.add(_snapshot);
    }
  }

  String _nextCorrelation(String purpose) {
    _sequence += 1;
    return 'phase10.$purpose.$_sequence';
  }

  void _ensureOpen() {
    if (_closed || _eventBus.isClosed) {
      throw StateError('Phase10PresentationBridge is closed.');
    }
  }

  static AgentEndpoint _connect(
    OrchestrationKernel kernel,
    String id,
  ) =>
      kernel.connect(
        AgentDescriptor(
          id: id,
          role: AgentRole.task,
          subscriptions: const <String>{
            AgentTopics.learningProgress,
            AgentTopics.polyglotMatrixChanged,
          },
          observesTargetedEvents: true,
        ),
      );

  static Future<OfflineProgressSnapshot> _readPersistedProgress(
    MemoryAgentStore physicalStore,
  ) async {
    final container = await RuntimeLocalStateContainer.open(physicalStore);
    try {
      final encoded = await container.namespace('progress').read();
      return OfflineProgressSnapshot.decode(encoded);
    } on Object {
      return OfflineProgressSnapshot.empty();
    } finally {
      await container.close();
    }
  }

  static OfflineProgressSnapshot _decodeSnapshot({
    required String? source,
    required String? target,
    required Iterable<Map<String, Object?>> tasks,
    required int updatedAtEpochMs,
  }) =>
      OfflineProgressSnapshot.decode(
        jsonEncode(
          <String, Object?>{
            'schemaVersion': OfflineProgressSnapshot.schemaVersion,
            'sourceLanguageTag': source,
            'targetLanguageTag': target,
            'updatedAtEpochMs': updatedAtEpochMs,
            'tasks': tasks.toList(growable: false),
          },
        ),
      );

  static String? _language(Object? value) {
    if (value is! String || value.trim().isEmpty) return null;
    final normalized = value.trim().replaceAll('_', '-');
    return RegExp(
      r'^[A-Za-z]{2,8}(?:-[A-Za-z0-9]{1,8})*$',
    ).hasMatch(normalized)
        ? normalized
        : null;
  }

  static bool _isCanonicalTaskId(String value) {
    final match = RegExp(r'^task-(\d{2})$').firstMatch(value.trim());
    if (match == null) return false;
    final number = int.tryParse(match.group(1) ?? '');
    return number != null && number >= 1 && number <= 50;
  }

  static int _defaultPoints(double score, bool completed) {
    final base = (score.clamp(0.0, 1.0) * 100).round();
    final bonus = completed ? 25 : 0;
    return (base + bonus).clamp(0, 125).toInt();
  }

  static bool _isStructurallyValid(Flashcard3DData card) {
    if (card.id.trim().isEmpty ||
        card.frontText.trim().isEmpty ||
        card.backText.trim().isEmpty) {
      return false;
    }
    return _language(card.frontLanguageCode) != null &&
        _language(card.backLanguageCode) != null;
  }
}

final class _PreferencesSystemMemoryStore implements MemoryAgentStore {
  const _PreferencesSystemMemoryStore(this.preferences);

  final PreferencesService preferences;

  @override
  Future<String?> read() async =>
      preferences.readSystemMemoryAgentState();

  @override
  Future<void> write(String encoded) async {
    final written =
        await preferences.writeSystemMemoryAgentState(encoded);
    if (!written) {
      throw StateError('System memory storage write failed.');
    }
  }
}

final class _PreferencesTextStore implements MemoryAgentStore {
  const _PreferencesTextStore(this.preferences, this.key);

  final PreferencesService preferences;
  final String key;

  @override
  Future<String?> read() async => preferences.getString(key);

  @override
  Future<void> write(String encoded) async {
    final written = await preferences.setString(key, encoded);
    if (!written) {
      throw StateError('Local phase10 storage write failed.');
    }
  }
}

final class _InMemoryStore implements MemoryAgentStore {
  String? _value;

  @override
  Future<String?> read() async => _value;

  @override
  Future<void> write(String encoded) async {
    _value = encoded;
  }
}
