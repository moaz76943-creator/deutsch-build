import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;


class SpeechResult {
  final String recognizedWords;
  final bool finalResult;
  const SpeechResult({required this.recognizedWords, required this.finalResult});
}

/// Isolates speech_to_text lifecycle quirks from UI consumers.
///
/// A generation token makes late plugin callbacks harmless after stop/dispose,
/// while the operation guard prevents overlapping listen/initialize calls.
class SpeechService {
  final String localeId;
  final stt.SpeechToText engine = stt.SpeechToText();
  SpeechService({this.localeId = 'de_DE'});

  bool initialized = false;
  bool _disposed = false;
  bool _operationBusy = false;
  int _generation = 0;

  Future<bool> initialize() async {
    if (_disposed || _operationBusy) return false;
    _operationBusy = true;
    try {
      initialized = await engine.initialize();
      return !_disposed && initialized;
    } catch (_) {
      initialized = false;
      return false;
    } finally {
      _operationBusy = false;
    }
  }

  Future<bool> listen({required void Function(SpeechResult result) onResult}) async {
    if (_disposed || _operationBusy) return false;
    _operationBusy = true;
    final generation = ++_generation;
    try {
      if (!initialized) {
        initialized = await engine.initialize();
      }
      if (_disposed || !initialized) return false;
      await engine.listen(
        localeId: localeId,
        onResult: (result) {
          if (_disposed || generation != _generation) return;
          try {
            onResult(SpeechResult(recognizedWords: result.recognizedWords, finalResult: result.finalResult));
          } catch (_) {
            // Consumer callback errors must not escape the plugin boundary.
          }
        },
      );
      return !_disposed;
    } catch (_) {
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
      await engine.stop();
    } catch (_) {}
  }

  bool get isListening {
    if (_disposed) return false;
    try {
      return engine.isListening;
    } catch (_) {
      return false;
    }
  }

  void dispose() {
    if (_disposed) return;
    _disposed = true;
    ++_generation;
    initialized = false;
    try {
      engine.stop().catchError((_) {});
    } catch (_) {}
  }
}
