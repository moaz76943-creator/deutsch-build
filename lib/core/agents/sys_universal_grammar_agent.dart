import 'dart:async';

import '../grammar_engines/comparative_superlative_engine.dart';
import '../grammar_engines/grammar_engine_models.dart';
import '../grammar_engines/konjunktiv_ii_engine.dart';
import '../localization/locale_provider.dart';
import '../orchestration/orchestration.dart';
import 'polyglot_agent_models.dart';

abstract interface class UniversalGrammarEngineFacade {
  String get engineId;

  Set<UniversalGrammarCapability> get capabilities;

  List<Map<String, Object?>> execute({
    required UniversalGrammarCapability capability,
    required int seed,
    required int count,
  });
}

final class SysUniversalGrammarAgent {
  SysUniversalGrammarAgent._(this.endpoint) {
    _subscription = endpoint.allEvents.listen(_accept);
  }

  factory SysUniversalGrammarAgent.start({
    required AgentEndpoint endpoint,
  }) {
    if (endpoint.descriptor.role != AgentRole.grammar) {
      throw ArgumentError(
        'Universal grammar endpoint must use AgentRole.grammar.',
      );
    }
    if (!endpoint.descriptor.subscribesTo(
          AgentTopics.polyglotMatrixChanged,
        ) ||
        !endpoint.descriptor.subscribesTo(AgentTopics.grammarRequest)) {
      throw ArgumentError(
        'Universal grammar endpoint must subscribe to matrix and '
        'grammar request topics.',
      );
    }
    return SysUniversalGrammarAgent._(endpoint);
  }

  final AgentEndpoint endpoint;

  late final StreamSubscription<AgentEvent> _subscription;
  UniversalGrammarEngineFacade? _engine;
  PolyglotMatrixState? _matrix;
  bool _closed = false;

  bool get isClosed => _closed;
  String? get activeEngineId => _engine?.engineId;
  PolyglotMatrixState? get matrix => _matrix;

  void _accept(AgentEvent event) {
    if (_closed) return;

    switch (event.topic) {
      case AgentTopics.polyglotMatrixChanged:
        _handleMatrix(event);
        return;
      case AgentTopics.grammarRequest:
        _handleRequest(event);
        return;
    }
  }

  void _handleMatrix(AgentEvent event) {
    try {
      final state = PolyglotMatrixState.fromEvent(event);
      _matrix = state;
      _engine = _engineFor(state.targetLanguageTag);

      final capabilities = _engine?.capabilities
              .map((item) => item.wireName)
              .toList(growable: false) ??
          const <String>[];

      endpoint.publish(
        topic: AgentTopics.grammarEngineChanged,
        targetRoles: const <AgentRole>{AgentRole.system},
        context: event.context,
        payload: <String, Object?>{
          'targetLanguage': state.targetLanguageTag,
          'directedPair': state.directedPairKey,
          'engineId': _engine?.engineId ??
              'unavailable.' + state.targetLanguageCode,
          'available': _engine != null,
          'capabilities': capabilities,
          'matrixRevision': state.revision,
        },
      );
    } on Object catch (error) {
      _publishSystemError(
        event: event,
        context: 'grammar.matrix_update',
        error: error,
      );
    }
  }

  void _handleRequest(AgentEvent event) {
    final rawCapability = event.payload['capability'];
    final capabilityLabel =
        rawCapability is String && rawCapability.trim().isNotEmpty
            ? rawCapability.trim()
            : 'unknown';
    final state = _matrix;
    final engine = _engine;

    if (state == null) {
      _publishFailure(
        event: event,
        capability: capabilityLabel,
        targetLanguage: 'und',
        engineId: 'unavailable',
        errorCode: 'matrix_not_ready',
        message:
            'No polyglot matrix state is available for grammar routing.',
      );
      return;
    }

    if (engine == null) {
      _publishFailure(
        event: event,
        capability: capabilityLabel,
        targetLanguage: state.targetLanguageTag,
        engineId: 'unavailable.' + state.targetLanguageCode,
        errorCode: 'engine_unavailable',
        message:
            'No grammar engine is registered for target language ' +
            state.targetLanguageTag +
            '.',
      );
      return;
    }

    try {
      final capability = UniversalGrammarCapability.parse(rawCapability);
      if (!engine.capabilities.contains(capability)) {
        _publishFailure(
          event: event,
          capability: capability.wireName,
          targetLanguage: state.targetLanguageTag,
          engineId: engine.engineId,
          errorCode: 'capability_unavailable',
          message:
              'Grammar capability is not available in the selected engine.',
        );
        return;
      }

      final seed = _boundedInt(
        event.payload['seed'],
        fallback: 0,
        min: -1000000000,
        max: 1000000000,
      );
      final count = _boundedInt(
        event.payload['count'],
        fallback: 6,
        min: 1,
        max: 20,
      );

      final items = engine.execute(
        capability: capability,
        seed: seed,
        count: count,
      );

      endpoint.publish(
        topic: AgentTopics.grammarResponse,
        targetRoles: const <AgentRole>{AgentRole.system},
        context: event.context,
        payload: <String, Object?>{
          'ok': true,
          'capability': capability.wireName,
          'targetLanguage': state.targetLanguageTag,
          'engineId': engine.engineId,
          'items': items,
        },
      );
    } on Object catch (error) {
      _publishFailure(
        event: event,
        capability: capabilityLabel,
        targetLanguage: state.targetLanguageTag,
        engineId: engine.engineId,
        errorCode: 'invalid_request',
        message: _bounded(error.toString(), 240),
      );
    }
  }

  UniversalGrammarEngineFacade? _engineFor(String targetLanguageTag) {
    final languageCode = AppLocale.parse(targetLanguageTag).languageCode;
    return switch (languageCode) {
      'de' => const _GermanGrammarEngineFacade(),
      _ => null,
    };
  }

  void _publishFailure({
    required AgentEvent event,
    required String capability,
    required String targetLanguage,
    required String engineId,
    required String errorCode,
    required String message,
  }) {
    endpoint.publish(
      topic: AgentTopics.grammarResponse,
      targetRoles: const <AgentRole>{AgentRole.system},
      context: event.context,
      payload: <String, Object?>{
        'ok': false,
        'capability': capability,
        'targetLanguage': targetLanguage,
        'engineId': engineId,
        'items': const <Object?>[],
        'errorCode': errorCode,
        'message': message,
      },
    );
  }

  void _publishSystemError({
    required AgentEvent event,
    required String context,
    required Object error,
  }) {
    endpoint.publish(
      topic: AgentTopics.systemError,
      targetRoles: const <AgentRole>{AgentRole.recovery},
      context: event.context,
      payload: <String, Object?>{
        'context': context,
        'errorType': error.runtimeType.toString(),
        'message': _bounded(error.toString(), 240),
        'fatal': false,
      },
    );
  }

  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    await _subscription.cancel();
  }

  static int _boundedInt(
    Object? value, {
    required int fallback,
    required int min,
    required int max,
  }) {
    if (value == null) return fallback;
    if (value is! num) {
      throw const FormatException(
        'Numeric grammar parameters must be numbers.',
      );
    }
    return value.toInt().clamp(min, max).toInt();
  }

  static String _bounded(String value, int maxLength) {
    final normalized = value.trim();
    return normalized.length <= maxLength
        ? normalized
        : normalized.substring(0, maxLength);
  }
}

final class _GermanGrammarEngineFacade
    implements UniversalGrammarEngineFacade {
  const _GermanGrammarEngineFacade();

  static const KonjunktivIiEngine _konjunktiv =
      KonjunktivIiEngine();
  static const ComparativeSuperlativeEngine _comparative =
      ComparativeSuperlativeEngine();

  @override
  String get engineId => 'german.core.v1';

  @override
  Set<UniversalGrammarCapability> get capabilities =>
      const <UniversalGrammarCapability>{
        UniversalGrammarCapability.konjunktivIi,
        UniversalGrammarCapability.comparativeSuperlative,
      };

  @override
  List<Map<String, Object?>> execute({
    required UniversalGrammarCapability capability,
    required int seed,
    required int count,
  }) {
    final items = switch (capability) {
      UniversalGrammarCapability.konjunktivIi =>
        _konjunktiv.generateExamples(seed: seed, count: count),
      UniversalGrammarCapability.comparativeSuperlative =>
        _comparative.generateExamples(seed: seed, count: count),
    };

    return List<Map<String, Object?>>.unmodifiable(
      items.map(_serializeTrainingItem),
    );
  }

  static Map<String, Object?> _serializeTrainingItem(
    GrammarTrainingItem item,
  ) =>
      <String, Object?>{
        'id': item.id,
        'category': item.category,
        'promptAr': item.promptAr,
        'sentenceWithBlank': item.sentenceWithBlank,
        'expectedAnswer': item.expectedAnswer,
        'fullSentence': item.fullSentence,
        'explanationAr': item.explanationAr,
        'acceptedAlternatives':
            List<String>.unmodifiable(item.acceptedAlternatives),
      };
}
