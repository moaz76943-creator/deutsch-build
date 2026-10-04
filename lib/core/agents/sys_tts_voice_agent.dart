import 'dart:async';

import '../orchestration/orchestration.dart';
import 'polyglot_agent_models.dart';

abstract interface class TtsVoiceBackendPort {
  String get backendId;

  bool supportsLanguage(String languageTag);

  Future<void> synthesize(TtsVoiceRequest request);
}

final class SysTtsVoiceAgent {
  SysTtsVoiceAgent._(this.endpoint) {
    _subscription = endpoint.allEvents.listen(_accept);
  }

  factory SysTtsVoiceAgent.start({
    required AgentEndpoint endpoint,
  }) {
    if (endpoint.descriptor.role != AgentRole.voice) {
      throw ArgumentError(
        'TTS voice endpoint must use AgentRole.voice.',
      );
    }
    if (!endpoint.descriptor.subscribesTo(
          AgentTopics.polyglotMatrixChanged,
        ) ||
        !endpoint.descriptor.subscribesTo(AgentTopics.ttsRequest)) {
      throw ArgumentError(
        'TTS voice endpoint must subscribe to matrix and TTS request topics.',
      );
    }
    return SysTtsVoiceAgent._(endpoint);
  }

  final AgentEndpoint endpoint;

  late final StreamSubscription<AgentEvent> _subscription;
  PolyglotMatrixState? _matrix;
  bool _closed = false;

  bool get isClosed => _closed;
  PolyglotMatrixState? get matrix => _matrix;

  void _accept(AgentEvent event) {
    if (_closed) return;

    switch (event.topic) {
      case AgentTopics.polyglotMatrixChanged:
        _handleMatrix(event);
        return;
      case AgentTopics.ttsRequest:
        _handleRequest(event);
        return;
    }
  }

  void _handleMatrix(AgentEvent event) {
    try {
      _matrix = PolyglotMatrixState.fromEvent(event);
    } on Object catch (error) {
      _publishSystemError(
        event: event,
        context: 'tts.matrix_update',
        error: error,
      );
    }
  }

  void _handleRequest(AgentEvent event) {
    try {
      final request = TtsVoiceRequest.fromEvent(event);
      final matrix = _matrix;

      if (matrix == null) {
        _publishDispatch(
          event: event,
          request: request,
          accepted: false,
          rejectionReason: 'matrix_not_ready',
        );
        return;
      }

      if (request.targetLanguageTag != matrix.targetLanguageTag) {
        _publishDispatch(
          event: event,
          request: request,
          accepted: false,
          rejectionReason:
              'target_mismatch:' + matrix.targetLanguageTag,
        );
        return;
      }

      _publishDispatch(
        event: event,
        request: request,
        accepted: true,
      );
    } on Object catch (error) {
      _publishSystemError(
        event: event,
        context: 'tts.request',
        error: error,
      );
    }
  }

  void _publishDispatch({
    required AgentEvent event,
    required TtsVoiceRequest request,
    required bool accepted,
    String? rejectionReason,
  }) {
    endpoint.publish(
      topic: AgentTopics.ttsPrepared,
      targetRoles: const <AgentRole>{AgentRole.system},
      context: event.context,
      payload: <String, Object?>{
        'accepted': accepted,
        ...request.toEventPayload(),
        'backend': 'unbound',
        'providerReady': false,
        if (rejectionReason != null)
          'rejectionReason': rejectionReason,
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

  static String _bounded(String value, int maxLength) {
    final normalized = value.trim();
    return normalized.length <= maxLength
        ? normalized
        : normalized.substring(0, maxLength);
  }
}
