abstract interface class AgentReferenceBoundary {}

abstract final class AgentTopics {
  static const String taskRequest = 'task.request';
  static const String designRequest = 'design.request';
  static const String routeRequest = 'route.request';
  static const String routeSelected = 'route.selected';
  static const String cardsRequest = 'cards.request';
  static const String contextUpdated = 'context.updated';
  static const String learningProgress = 'learning.progress';
  static const String learningMistake = 'learning.mistake';
  static const String memorySnapshot = 'memory.snapshot';
  static const String systemError = 'system.error';
  static const String systemRecovery = 'system.recovery';
  static const String localizationChangeRequested =
      'localization.change_requested';
  static const String localizationChanged = 'localization.changed';
  static const String polyglotMatrixChanged = 'polyglot.matrix_changed';
  static const String grammarRequest = 'grammar.request';
  static const String grammarEngineChanged = 'grammar.engine_changed';
  static const String grammarResponse = 'grammar.response';
  static const String ttsRequest = 'tts.request';
  static const String ttsPrepared = 'tts.prepared';
  static const String ttsCompleted = 'tts.completed';
  static const String ttsFailed = 'tts.failed';
}

enum AgentRole {
  task,
  design,
  routing,
  cards,
  memory,
  recovery,
  system,
  localization,
  polyglot,
  grammar,
  voice,
}

final class AgentDescriptor {
  AgentDescriptor({
    required String id,
    required this.role,
    required Set<String> subscriptions,
    this.observesTargetedEvents = false,
  })  : id = id.trim(),
        subscriptions = Set<String>.unmodifiable(
          subscriptions.map(_validatedTopic),
        ) {
    if (this.id.isEmpty ||
        !RegExp(r'^[a-z0-9]+(?:[._-][a-z0-9]+)*$').hasMatch(this.id)) {
      throw ArgumentError.value(
        id,
        'id',
        'Agent id must be a lowercase path token.',
      );
    }
    if (this.subscriptions.isEmpty) {
      throw ArgumentError(
        'An agent must subscribe to at least one event topic.',
      );
    }
  }

  final String id;
  final AgentRole role;
  final Set<String> subscriptions;
  final bool observesTargetedEvents;

  bool subscribesTo(String topic) => subscriptions.contains(topic);
}

final class AgentContextSnapshot {
  AgentContextSnapshot({
    required String correlationId,
    Map<String, Object?> values = const <String, Object?>{},
    this.pairEpoch = 0,
    this.generation = 0,
  })  : correlationId = correlationId.trim(),
        values = _freezeMap(values) {
    if (this.correlationId.isEmpty) {
      throw ArgumentError.value(
        correlationId,
        'correlationId',
        'Correlation id must not be empty.',
      );
    }
    if (pairEpoch < 0) {
      throw ArgumentError.value(
        pairEpoch,
        'pairEpoch',
        'Pair epoch must not be negative.',
      );
    }
    if (generation < 0) {
      throw ArgumentError.value(
        generation,
        'generation',
        'Generation must not be negative.',
      );
    }
  }

  factory AgentContextSnapshot.empty(
    String correlationId, {
    int pairEpoch = 0,
    int generation = 0,
  }) =>
      AgentContextSnapshot(
        correlationId: correlationId,
        pairEpoch: pairEpoch,
        generation: generation,
      );

  final String correlationId;
  final Map<String, Object?> values;
  final int pairEpoch;
  final int generation;

  AgentContextSnapshot merge(Map<String, Object?> delta) =>
      AgentContextSnapshot(
        correlationId: correlationId,
        values: <String, Object?>{...values, ...delta},
        pairEpoch: pairEpoch,
        generation: generation,
      );

  AgentContextSnapshot withTemporal({
    int? pairEpoch,
    int? generation,
  }) =>
      AgentContextSnapshot(
        correlationId: correlationId,
        values: values,
        pairEpoch: pairEpoch ?? this.pairEpoch,
        generation: generation ?? this.generation,
      );
}

final class AgentEvent {
  AgentEvent({
    required this.sequence,
    required String topic,
    required String sourceAgentId,
    required this.sourceRole,
    required Set<AgentRole> targetRoles,
    required this.context,
    required Map<String, Object?> payload,
  })  : topic = _validatedTopic(topic),
        sourceAgentId = sourceAgentId.trim(),
        targetRoles = Set<AgentRole>.unmodifiable(targetRoles),
        payload = _freezeMap(payload) {
    if (sequence < 1) {
      throw ArgumentError.value(sequence, 'sequence', 'Must be positive.');
    }
    if (this.sourceAgentId.isEmpty) {
      throw ArgumentError.value(
        sourceAgentId,
        'sourceAgentId',
        'Source agent id must not be empty.',
      );
    }
  }

  final int sequence;
  final String topic;
  final String sourceAgentId;
  final AgentRole sourceRole;
  final Set<AgentRole> targetRoles;
  final AgentContextSnapshot context;
  final Map<String, Object?> payload;

  bool isAddressedTo(AgentRole role) =>
      targetRoles.isEmpty || targetRoles.contains(role);
}

String _validatedTopic(String topic) {
  final normalized = topic.trim().toLowerCase();
  if (normalized.isEmpty ||
      !RegExp(r'^[a-z0-9]+(?:[._-][a-z0-9]+)*$').hasMatch(normalized)) {
    throw ArgumentError.value(
      topic,
      'topic',
      'Event topics must be lowercase dot/dash/underscore paths.',
    );
  }
  return normalized;
}

Map<String, Object?> _freezeMap(Map<String, Object?> source) =>
    Map<String, Object?>.unmodifiable(
      <String, Object?>{
        for (final entry in source.entries)
          entry.key: _freezeValue(entry.value),
      },
    );

Object? _freezeValue(Object? value) {
  if (value == null || value is String || value is num || value is bool) {
    return value;
  }
  if (value is Map) {
    final copy = <String, Object?>{};
    for (final entry in value.entries) {
      if (entry.key is! String) {
        throw ArgumentError('Event/context map keys must be strings.');
      }
      copy[entry.key as String] = _freezeValue(entry.value);
    }
    return Map<String, Object?>.unmodifiable(copy);
  }
  if (value is List) {
    return List<Object?>.unmodifiable(
      value.map<Object?>((item) => _freezeValue(item)),
    );
  }
  throw ArgumentError(
    'Agent event data must use JSON-like scalar/list/map values only; '
    'object references are not allowed.',
  );
}
