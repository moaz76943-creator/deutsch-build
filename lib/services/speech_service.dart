import '../core/infrastructure/audio/speech_to_text_engine.dart';

export '../core/infrastructure/audio/speech_to_text_engine.dart'
    show SpeechResult;

/// Compatibility facade. Plugin ownership lives exclusively in Infrastructure.
final class SpeechService {
  final String localeId;

  SpeechService({this.localeId = 'de_DE', SpeechToTextEngine? engine})
      : _engine = engine ?? SpeechToTextEngine(localeId: localeId);

  final SpeechToTextEngine _engine;

  bool get initialized => _engine.initialized;

  Future<bool> initialize() => _engine.initialize();

  Future<bool> listen({
    required void Function(SpeechResult result) onResult,
  }) =>
      _engine.listen(onResult: onResult);

  Future<void> stop() => _engine.stop();

  bool get isListening => _engine.isListening;

  void dispose() => _engine.dispose();
}
