import 'dart:async';

import '../orchestration/orchestration.dart';
import 'polyglot_agent_models.dart';

final class SysPolyglotMatrixAgent {
  SysPolyglotMatrixAgent._(this.endpoint) {
    _subscription = endpoint
        .events(AgentTopics.localizationChanged)
        .listen(_accept);
  }

  factory SysPolyglotMatrixAgent.start({
    required AgentEndpoint endpoint,
  }) {
    if (endpoint.descriptor.role != AgentRole.polyglot) {
      throw ArgumentError(
        'Polyglot matrix endpoint must use AgentRole.polyglot.',
      );
    }
    if (!endpoint.descriptor.subscribesTo(
      AgentTopics.localizationChanged,
    )) {
      throw ArgumentError(
        'Polyglot matrix endpoint must subscribe to ' +
            AgentTopics.localizationChanged +
            '.',
      );
    }
    return SysPolyglotMatrixAgent._(endpoint);
  }

  final AgentEndpoint endpoint;

  late final StreamSubscription<AgentEvent> _subscription;
  PolyglotMatrixState? _state;
  bool _closed = false;

  PolyglotMatrixState? get state => _state;
  bool get isClosed => _closed;

  void _accept(AgentEvent event) {
    if (_closed) return;

    try {
      final next = PolyglotMatrixState(
        sourceLanguageTag: _requiredLocale(
          event.payload['sourceLocale'],
          'sourceLocale',
        ),
        targetLanguageTag: _requiredLocale(
          event.payload['targetLocale'],
          'targetLocale',
        ),
        revision: _requiredRevision(event.payload['revision']),
      );

      final current = _state;
      if (current != null) {
        if (next.revision < current.revision) {
          return;
        }
        if (next.revision == current.revision) {
          if (next.directedPairKey == current.directedPairKey) {
            return;
          }
          _publishConflict(event, current, next);
          return;
        }
      }

      _state = next;
      endpoint.publish(
        topic: AgentTopics.polyglotMatrixChanged,
        targetRoles: const <AgentRole>{
          AgentRole.grammar,
          AgentRole.voice,
          AgentRole.system,
        },
        context: event.context,
        payload: next.toEventPayload(),
      );
    } on Object catch (error) {
      endpoint.publish(
        topic: AgentTopics.systemError,
        targetRoles: const <AgentRole>{AgentRole.recovery},
        context: event.context,
        payload: <String, Object?>{
          'context': 'polyglot.matrix_update',
          'errorType': error.runtimeType.toString(),
          'message': _bounded(error.toString(), 240),
          'fatal': false,
        },
      );
    }
  }

  void _publishConflict(
    AgentEvent event,
    PolyglotMatrixState current,
    PolyglotMatrixState incoming,
  ) {
    endpoint.publish(
      topic: AgentTopics.systemError,
      targetRoles: const <AgentRole>{AgentRole.recovery},
      context: event.context,
      payload: <String, Object?>{
        'context': 'polyglot.matrix_conflict',
        'errorType': 'RevisionConflict',
        'message':
            'Localization revision ' +
            incoming.revision.toString() +
            ' attempted to replace ' +
            current.directedPairKey +
            ' with ' +
            incoming.directedPairKey +
            '.',
        'fatal': false,
      },
    );
  }

  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    await _subscription.cancel();
  }

  static String _requiredLocale(Object? value, String field) {
    if (value is! String || value.trim().isEmpty) {
      throw FormatException(
        field + ' must be a non-empty language tag.',
      );
    }
    return value.trim();
  }

  static int _requiredRevision(Object? value) {
    if (value is! num) {
      throw const FormatException(
        'localization revision must be numeric.',
      );
    }
    final revision = value.toInt();
    if (revision < 0) {
      throw const FormatException(
        'localization revision must be non-negative.',
      );
    }
    return revision;
  }

  static String _bounded(String value, int maxLength) {
    final normalized = value.trim();
    return normalized.length <= maxLength
        ? normalized
        : normalized.substring(0, maxLength);
  }
}
