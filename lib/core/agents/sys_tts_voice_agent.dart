import 'dart:async';

import '../infrastructure/audio/flutter_tts_audio_engine.dart';
import '../orchestration/orchestration.dart';
import '../../language/language_speech_profile.dart';
import 'polyglot_agent_models.dart';

final class TtsBackendResult {
  const TtsBackendResult.completed()
      : completed = true,
        failureReason = null;

  TtsBackendResult.failed(String reason)
      : completed = false,
        failureReason = _normalizeFailure(reason);

  final bool completed;
  final String? failureReason;

  static String _normalizeFailure(String value) {
    final normalized = value.trim();
    return normalized.isEmpty ? 'playback_failed' : normalized;
  }
}

abstract interface class TtsVoiceBackendPort {
  String get backendId;

  Future<TtsBackendResult> speak(TtsVoiceRequest request);

  Future<void> stop();

  Future<void> dispose();
}

final class FlutterTtsVoiceBackend implements TtsVoiceBackendPort {
  FlutterTtsVoiceBackend({FlutterOfflineTtsEngine? engine})
      : _engine = engine ?? FlutterOfflineTtsEngine();

  final FlutterOfflineTtsEngine _engine;
  bool _closed = false;

  @override
  String get backendId => 'flutter_tts.offline.v1';

  @override
  Future<TtsBackendResult> speak(TtsVoiceRequest request) async {
    if (_closed) return TtsBackendResult.failed('backend_closed');

    final profile = _TargetLanguageSpeechProfile(
      request.targetLanguageTag,
    );
    final rate = (profile.defaultSpeechRate * request.speed)
        .clamp(0.1, 1.0)
        .toDouble();

    try {
      final spoken = await _engine.speak(
        text: request.text,
        profile: profile,
        rate: rate,
      );
      return spoken
          ? const TtsBackendResult.completed()
          : TtsBackendResult.failed('unsupported_language_or_voice');
    } on Object {
      return TtsBackendResult.failed('playback_failed');
    }
  }

  @override
  Future<void> stop() async {
    if (_closed) return;
    try {
      await _engine.stop();
    } on Object {
      return;
    }
  }

  @override
  Future<void> dispose() async {
    if (_closed) return;
    _closed = true;
    try {
      await _engine.dispose();
    } on Object {
      return;
    }
  }
}

final class _TargetLanguageSpeechProfile
    implements LanguageSpeechProfile {
  _TargetLanguageSpeechProfile(String languageTag)
      : _languageTag = _normalizeTag(languageTag);

  final String _languageTag;

  @override
  String get languageCode => _languageTag;

  @override
  List<String> get preferredTtsLocales {
    final base = _languageTag.split('-').first;
    return List<String>.unmodifiable(
      <String>{
        _languageTag,
        if (base.isNotEmpty) base,
      },
    );
  }

  @override
  double get defaultSpeechRate => 0.46;

  @override
  String get offlineVoiceUnavailableMessage =>
      'offline_voice_unavailable';

  static String _normalizeTag(String value) =>
      value.trim().replaceAll('_', '-');
}

final class SysTtsVoiceAgent {
  SysTtsVoiceAgent._({
    required this.endpoint,
    required TtsVoiceBackendPort backend,
  }) : _backend = backend {
    _subscription = endpoint.allEvents.listen(_accept);
  }

  factory SysTtsVoiceAgent.start({
    required AgentEndpoint endpoint,
    TtsVoiceBackendPort? backend,
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
    return SysTtsVoiceAgent._(
      endpoint: endpoint,
      backend: backend ?? FlutterTtsVoiceBackend(),
    );
  }

  final AgentEndpoint endpoint;
  final TtsVoiceBackendPort _backend;

  late final StreamSubscription<AgentEvent> _subscription;
  PolyglotMatrixState? _matrix;
  Future<void> _speechTail = Future<void>.value();
  int _generation = 0;
  bool _isSpeaking = false;
  bool _closed = false;

  bool get isClosed => _closed;
  PolyglotMatrixState? get matrix => _matrix;
  String get backendId => _backend.backendId;

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
      _queuePlayback(event, request);
    } on Object catch (error) {
      _publishSystemError(
        event: event,
        context: 'tts.request',
        error: error,
      );
    }
  }

  void _queuePlayback(
    AgentEvent event,
    TtsVoiceRequest request,
  ) {
    final generation = ++_generation;
    if (_isSpeaking) {
      unawaited(_safeStop());
    }

    _speechTail = _speechTail.then<void>((_) async {
      if (_closed) return;

      if (generation != _generation) {
        _publishFailed(
          event: event,
          request: request,
          reason: 'superseded',
        );
        return;
      }

      _isSpeaking = true;
      late final TtsBackendResult result;
      try {
        result = await _backend.speak(request);
      } finally {
        _isSpeaking = false;
      }

      if (_closed) return;

      if (generation != _generation) {
        _publishFailed(
          event: event,
          request: request,
          reason: 'superseded',
        );
        return;
      }

      if (result.completed) {
        _publishCompleted(event: event, request: request);
      } else {
        _publishFailed(
          event: event,
          request: request,
          reason: result.failureReason ?? 'playback_failed',
        );
      }
    }).catchError((Object error, StackTrace stackTrace) {
      if (_closed) return;
      _isSpeaking = false;
      _publishFailed(
        event: event,
        request: request,
        reason: 'backend_error',
      );
    });
  }

  Future<void> _safeStop() async {
    try {
      await _backend.stop();
    } on Object {
      return;
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
        'backend': _backend.backendId,
        'providerReady': accepted,
        if (rejectionReason != null)
          'rejectionReason': rejectionReason,
      },
    );
  }

  void _publishCompleted({
    required AgentEvent event,
    required TtsVoiceRequest request,
  }) {
    endpoint.publish(
      topic: AgentTopics.ttsCompleted,
      targetRoles: const <AgentRole>{
        AgentRole.system,
        AgentRole.task,
      },
      context: event.context,
      payload: <String, Object?>{
        ...request.toEventPayload(),
        'backend': _backend.backendId,
        'completed': true,
      },
    );
  }

  void _publishFailed({
    required AgentEvent event,
    required TtsVoiceRequest request,
    required String reason,
  }) {
    endpoint.publish(
      topic: AgentTopics.ttsFailed,
      targetRoles: const <AgentRole>{
        AgentRole.system,
        AgentRole.task,
      },
      context: event.context,
      payload: <String, Object?>{
        ...request.toEventPayload(),
        'backend': _backend.backendId,
        'completed': false,
        'reason': _bounded(reason, 120),
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
    ++_generation;
    await _subscription.cancel();
    await _safeStop();
    try {
      await _speechTail;
    } on Object {
      // Playback failures are already contained and surfaced as events.
    }
    await _backend.dispose();
  }

  static String _bounded(String value, int maxLength) {
    final normalized = value.trim();
    return normalized.length <= maxLength
        ? normalized
        : normalized.substring(0, maxLength);
  }
}
