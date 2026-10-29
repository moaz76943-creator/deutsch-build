import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../core/agents/polyglot_agent_models.dart';
import '../../core/l10n/l10n.dart';
import '../../core/orchestration/orchestration.dart';

final class LifeFeatureRuntime extends ChangeNotifier {
  LifeFeatureRuntime._({
    required AgentEventBus eventBus,
    required OrchestrationKernel kernel,
    required AgentEndpoint endpoint,
    required DynamicL10nEngine engine,
  })  : _eventBus = eventBus,
        _kernel = kernel,
        _endpoint = endpoint,
        _engine = engine {
    _subscription = endpoint.allEvents.listen(_handleEvent);
  }

  static LifeFeatureRuntime? _shared;

  static LifeFeatureRuntime get shared =>
      _shared ??= _createApplicationRuntime();

  static void ensureSharedStarted() {
    shared;
  }

  factory LifeFeatureRuntime.isolated({
    required AgentEventBus eventBus,
    required String initialUserLanguageTag,
    required String initialSourceLanguageTag,
    required String initialTargetLanguageTag,
  }) {
    final kernel = OrchestrationKernel(
      eventBus: eventBus,
      services: ServiceContainer(),
    );
    final endpoint = kernel.connect(
      AgentDescriptor(
        id: 'features.life-runtime-isolated',
        role: AgentRole.task,
        subscriptions: const <String>{
          AgentTopics.localizationChanged,
          AgentTopics.routeSelected,
          AgentTopics.ttsPrepared,
          AgentTopics.grammarResponse,
        },
        observesTargetedEvents: true,
      ),
    );
    return LifeFeatureRuntime._(
      eventBus: eventBus,
      kernel: kernel,
      endpoint: endpoint,
      engine: DynamicL10nEngine(
        initialState: LocalizationState.fromLanguageTags(
          userLanguageTag: initialUserLanguageTag,
          sourceLanguageTag: initialSourceLanguageTag,
          targetLanguageTag: initialTargetLanguageTag,
        ),
        fallbackLanguageTag: 'en',
      ),
    );
  }

  static LifeFeatureRuntime _createApplicationRuntime() {
    final eventBus = AgentEventBus();
    final kernel = OrchestrationKernel(
      eventBus: eventBus,
      services: ServiceContainer(),
    );
    final endpoint = kernel.connect(
      AgentDescriptor(
        id: 'features.life-runtime',
        role: AgentRole.task,
        subscriptions: const <String>{
          AgentTopics.localizationChanged,
          AgentTopics.routeSelected,
          AgentTopics.ttsPrepared,
          AgentTopics.grammarResponse,
        },
        observesTargetedEvents: true,
      ),
    );
    return LifeFeatureRuntime._(
      eventBus: eventBus,
      kernel: kernel,
      endpoint: endpoint,
      engine: DynamicL10nEngine(
        initialState: LocalizationState.fromLanguageTags(
          userLanguageTag: 'ar',
          sourceLanguageTag: 'ar',
          targetLanguageTag: 'de',
        ),
        fallbackLanguageTag: 'en',
      ),
    );
  }

  final AgentEventBus _eventBus;
  final OrchestrationKernel _kernel;
  final AgentEndpoint _endpoint;
  final DynamicL10nEngine _engine;

  late final StreamSubscription<AgentEvent> _subscription;
  final Map<String, Map<String, L10nMessage>> _literalMessages =
      <String, Map<String, L10nMessage>>{};

  int _requestSequence = 0;
  bool _closed = false;

  L10nRuntimeSnapshot get snapshot => _engine.snapshot;
  bool get isClosed => _closed;

  String resolveUiLiteral(String raw) {
    _ensureOpen();
    final text = raw.trim();
    if (text.isEmpty) return raw;
    final key = _ensureLiteral(
      raw: raw,
      primaryLocale: _inferLiteralLocale(raw),
    );
    return _engine.text(key);
  }

  String resolveDirectionalLiteral(
    String raw, {
    required String languageCode,
  }) {
    _ensureOpen();
    final text = raw.trim();
    if (text.isEmpty) return raw;
    final locale = AppLocale.parse(languageCode).languageTag;
    final key = _ensureLiteral(
      raw: raw,
      primaryLocale: locale,
    );
    return _engine.findMessage(
          key,
          languageTag: locale,
        )?.render() ??
        raw;
  }

  bool isTargetLanguage(String languageTag) {
    final requested = AppLocale.parse(languageTag).languageCode;
    return requested == snapshot.targetLocale.languageCode;
  }

  Future<TtsVoiceDispatch> requestSpeech({
    required String text,
    required String languageTag,
    double speed = 1.0,
  }) async {
    _ensureOpen();
    final request = TtsVoiceRequest(
      text: text,
      targetLanguageTag: languageTag,
      speed: speed,
    );
    final correlationId = _nextCorrelation('tts');
    final response = _endpoint
        .events(AgentTopics.ttsPrepared)
        .firstWhere(
          (event) => event.context.correlationId == correlationId,
        )
        .timeout(const Duration(seconds: 2));

    _endpoint.publish(
      topic: AgentTopics.ttsRequest,
      targetRoles: const <AgentRole>{AgentRole.voice},
      context: AgentContextSnapshot.empty(correlationId),
      payload: request.toEventPayload(),
    );

    return TtsVoiceDispatch.fromEvent(await response);
  }

  Future<GrammarAgentResult> requestGrammar({
    required UniversalGrammarCapability capability,
    int seed = 0,
    int count = 6,
  }) async {
    _ensureOpen();
    final correlationId = _nextCorrelation('grammar');
    final response = _endpoint
        .events(AgentTopics.grammarResponse)
        .firstWhere(
          (event) => event.context.correlationId == correlationId,
        )
        .timeout(const Duration(seconds: 2));

    _endpoint.publish(
      topic: AgentTopics.grammarRequest,
      targetRoles: const <AgentRole>{AgentRole.grammar},
      context: AgentContextSnapshot.empty(correlationId),
      payload: <String, Object?>{
        'capability': capability.wireName,
        'seed': seed,
        'count': count.clamp(1, 20).toInt(),
      },
    );

    return GrammarAgentResult.fromEvent(await response);
  }

  void _handleEvent(AgentEvent event) {
    if (_closed) return;
    switch (event.topic) {
      case AgentTopics.localizationChanged:
        _applyLocalePayload(event.payload);
        return;
      case AgentTopics.routeSelected:
        if (event.payload['ok'] == true) {
          _applyLocalePayload(event.payload);
        }
        return;
    }
  }

  void _applyLocalePayload(Map<String, Object?> payload) {
    final user = _optionalLanguage(payload['userLocale']);
    final source = _optionalLanguage(
      payload['sourceLocale'] ?? payload['sourceLanguage'],
    );
    final target = _optionalLanguage(
      payload['targetLocale'] ?? payload['targetLanguage'],
    );

    var changed = false;
    if (user != null &&
        user != _engine.snapshot.userLocale.languageTag) {
      _engine.setUserLanguage(user);
      changed = true;
    }
    if (source != null &&
        target != null &&
        (source != _engine.snapshot.sourceLocale.languageTag ||
            target != _engine.snapshot.targetLocale.languageTag)) {
      _engine.setLearningPair(
        sourceLanguageTag: source,
        targetLanguageTag: target,
      );
      changed = true;
    }
    if (changed) notifyListeners();
  }

  String _ensureLiteral({
    required String raw,
    required String primaryLocale,
  }) {
    final key = 'life.literal.' + _fnv1a32(raw);
    _putLiteral(primaryLocale, key, raw);
    _putLiteral('en', key, raw);
    return key;
  }

  void _putLiteral(String localeTag, String key, String raw) {
    final locale = AppLocale.parse(localeTag).languageTag;
    final messages = _literalMessages.putIfAbsent(
      locale,
      () => <String, L10nMessage>{},
    );
    if (messages.containsKey(key)) return;

    messages[key] = L10nMessage(
      key: key,
      template: raw,
    );
    _engine.registerDictionary(
      L10nDictionary(
        locale: AppLocale.parse(locale),
        sourceFormat: L10nSourceFormat.json,
        messages: messages,
      ),
    );
  }

  String _nextCorrelation(String purpose) {
    _requestSequence += 1;
    return 'features.life.' +
        purpose +
        '.' +
        _requestSequence.toString();
  }

  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    await _subscription.cancel();
    await _kernel.close();
    await _engine.close();
    if (identical(_shared, this)) {
      _shared = null;
    }
  }

  void _ensureOpen() {
    if (_closed || _eventBus.isClosed) {
      throw StateError('LifeFeatureRuntime is closed.');
    }
  }

  static String? _optionalLanguage(Object? value) {
    if (value is! String || value.trim().isEmpty) return null;
    return AppLocale.parse(value).languageTag;
  }

  static String _inferLiteralLocale(String raw) {
    if (RegExp(r'[\u0600-\u06ff]').hasMatch(raw)) return 'ar';
    if (RegExp(r'[\u0400-\u04ff]').hasMatch(raw)) return 'ru';
    if (RegExp(r'[\u0370-\u03ff]').hasMatch(raw)) return 'el';
    if (RegExp(r'[\u3040-\u30ff]').hasMatch(raw)) return 'ja';
    if (RegExp(r'[\uac00-\ud7af]').hasMatch(raw)) return 'ko';
    if (RegExp(r'[\u4e00-\u9fff]').hasMatch(raw)) return 'cmn';
    return 'de';
  }

  static String _fnv1a32(String value) {
    var hash = 0x811c9dc5;
    for (final unit in value.codeUnits) {
      hash ^= unit;
      hash = (hash * 0x01000193) & 0xffffffff;
    }
    return hash.toRadixString(16).padLeft(8, '0');
  }
}
