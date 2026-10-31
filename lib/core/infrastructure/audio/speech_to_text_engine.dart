import 'package:speech_to_text/speech_to_text.dart' as stt;

final class SpeechResult {
  const SpeechResult({
    required this.recognizedWords,
    required this.finalResult,
  });

  final String recognizedWords;
  final bool finalResult;
}

/// Infrastructure adapter that owns the speech_to_text plugin lifecycle.
///
/// A generation token makes late callbacks harmless after stop/dispose while
/// the operation guard prevents overlapping initialize/listen calls.
class SpeechToTextEngine {
  SpeechToTextEngine({this.localeId = 'de_DE', stt.SpeechToText? engine})
      : _engine = engine ?? stt.SpeechToText();

  final String localeId;
  final stt.SpeechToText _engine;
  bool initialized = false;
  bool _disposed = false;
  bool _operationBusy = false;
  int _generation = 0;

  Future<bool> initialize() async {
    if (_disposed || _operationBusy) return false;
    _operationBusy = true;
    try {
      initialized = await _engine.initialize();
      return !_disposed && initialized;
    } on Object {
      initialized = false;
      return false;
    } finally {
      _operationBusy = false;
    }
  }

  Future<bool> listen({
    required void Function(SpeechResult result) onResult,
  }) async {
    if (_disposed || _operationBusy) return false;
    _operationBusy = true;
    final generation = ++_generation;
    try {
      if (!initialized) {
        initialized = await _engine.initialize();
      }
      if (_disposed || !initialized) return false;
      await _engine.listen(
        listenOptions: stt.SpeechListenOptions(localeId: localeId),
        onResult: (result) {
          if (_disposed || generation != _generation) return;
          try {
            onResult(
              SpeechResult(
                recognizedWords: result.recognizedWords,
                finalResult: result.finalResult,
              ),
            );
          } on Object {
            // Consumer callback errors never escape the plugin boundary.
          }
        },
      );
      return !_disposed;
    } on Object {
      initialized = false;
      return false;
    } finally {
      _operationBusy = false;
    }
  }

  Future<void> stop() async {
    if (_disposed) return;
    ++_generation;
    try {
      await _engine.stop();
    } on Object {
      // Device plugin failures remain isolated in infrastructure.
    }
  }

  bool get isListening {
    if (_disposed) return false;
    try {
      return _engine.isListening;
    } on Object {
      return false;
    }
  }

  void dispose() {
    if (_disposed) return;
    _disposed = true;
    ++_generation;
    initialized = false;
    try {
      _engine.stop().catchError((_) {});
    } on Object {
      // Best-effort lifecycle cleanup.
    }
  }
}
