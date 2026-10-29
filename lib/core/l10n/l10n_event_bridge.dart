import 'dart:async';

import '../orchestration/orchestration.dart';
import 'dynamic_l10n_engine.dart';
import 'l10n_models.dart';

final class L10nEventBridge {
  L10nEventBridge({
    required this.engine,
    required this.endpoint,
  }) {
    if (endpoint.descriptor.role != AgentRole.localization) {
      throw ArgumentError(
        'L10nEventBridge endpoint must use AgentRole.localization.',
      );
    }
    if (!endpoint.descriptor
        .subscribesTo(AgentTopics.localizationChangeRequested)) {
      throw ArgumentError(
        'L10nEventBridge endpoint must subscribe to '
        'localization.change_requested.',
      );
    }

    _engineSubscription = engine.changes.listen(_publishChange);
    _requestSubscription = endpoint
        .events(AgentTopics.localizationChangeRequested)
        .listen(_handleRequest);
  }

  final DynamicL10nEngine engine;
  final AgentEndpoint endpoint;

  late final StreamSubscription<L10nEngineChange> _engineSubscription;
  late final StreamSubscription<AgentEvent> _requestSubscription;
  AgentContextSnapshot? _activeRequestContext;
  bool _closed = false;

  bool get isClosed => _closed;

  void _handleRequest(AgentEvent event) {
    if (_closed) return;
    _activeRequestContext = event.context;
    try {
      final userLocale = _optionalString(event.payload['userLocale']);
      final sourceLocale = _optionalString(event.payload['sourceLocale']);
      final targetLocale = _optionalString(event.payload['targetLocale']);
      final fallbackLocale =
          _optionalString(event.payload['fallbackLocale']);

      if ((sourceLocale == null) != (targetLocale == null)) {
        throw const FormatException(
          'sourceLocale and targetLocale must be supplied together.',
        );
      }

      if (userLocale != null) {
        engine.setUserLanguage(userLocale);
      }
      if (sourceLocale != null && targetLocale != null) {
        engine.setLearningPair(
          sourceLanguageTag: sourceLocale,
          targetLanguageTag: targetLocale,
        );
      }
      if (fallbackLocale != null) {
        engine.setFallbackLanguage(fallbackLocale);
      }
    } on Object catch (error) {
      endpoint.publish(
        topic: AgentTopics.systemError,
        targetRoles: const <AgentRole>{AgentRole.recovery},
        context: event.context,
        payload: <String, Object?>{
          'context': 'l10n.change_request',
          'errorType': error.runtimeType.toString(),
          'message': _bounded(error.toString(), 240),
          'fatal': false,
        },
      );
    } finally {
      _activeRequestContext = null;
    }
  }

  void _publishChange(L10nEngineChange change) {
    if (_closed) return;
    final current = change.current;
    final loadedLocales = current.loadedLocales.toList(growable: false)
      ..sort();

    endpoint.publish(
      topic: AgentTopics.localizationChanged,
      targetRoles: const <AgentRole>{
        AgentRole.design,
        AgentRole.routing,
      },
      context: _activeRequestContext,
      payload: <String, Object?>{
        'reason': change.reason.name,
        'revision': current.revision,
        'userLocale': current.userLocale.languageTag,
        'sourceLocale': current.sourceLocale.languageTag,
        'targetLocale': current.targetLocale.languageTag,
        'fallbackLocale': current.fallbackLocale.languageTag,
        'direction': current.direction,
        'isRtl': current.isRtl,
        'loadedLocales': loadedLocales,
        if (change.dictionaryLocale != null)
          'dictionaryLocale': change.dictionaryLocale,
      },
    );
  }

  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    await _requestSubscription.cancel();
    await _engineSubscription.cancel();
  }

  static String _bounded(String value, int maxLength) {
    final normalized = value.trim();
    return normalized.length <= maxLength
        ? normalized
        : normalized.substring(0, maxLength);
  }

  static String? _optionalString(Object? value) {
    if (value == null) return null;
    if (value is! String) {
      throw const FormatException(
        'Localization request locale values must be strings.',
      );
    }
    final normalized = value.trim();
    if (normalized.isEmpty) {
      throw const FormatException(
        'Localization request locale values must not be empty.',
      );
    }
    return normalized;
  }
}
