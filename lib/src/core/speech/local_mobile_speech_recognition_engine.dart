import 'dart:async';
import 'dart:typed_data';

/// State of on-device speech recognizer.
enum SpeechRecognizerState {
  uninitialized,
  ready,
  listening,
  processing,
  stopped,
}

/// Result of an offline speech recognition hypothesis.
class SpeechRecognitionHypothesis {
  final String text;
  final double confidence; // 0.0 to 1.0
  final bool isFinal;
  final Duration latency;

  const SpeechRecognitionHypothesis({
    required this.text,
    required this.confidence,
    required this.isFinal,
    required this.latency,
  });
}

/// Low-level platform bridge contract for native Whisper / Sherpa-ONNX STT.
abstract class MobileSttBridge {
  Future<bool> initializeModel(String languageIso);
  Future<void> feedPcmChunk(Int16List pcmData);
  Future<String> finalizeTranscription();
  Future<void> releaseModel();
}

/// Sovereign offline on-device speech-to-text recognition engine.
class LocalMobileSpeechRecognitionEngine {
  final MobileSttBridge bridge;
  SpeechRecognizerState _state = SpeechRecognizerState.uninitialized;

  LocalMobileSpeechRecognitionEngine({required this.bridge});

  SpeechRecognizerState get state => _state;

  /// Loads speech recognition weights for target language.
  Future<bool> initialize(String languageIso) async {
    final success = await bridge.initializeModel(languageIso);
    if (success) {
      _state = SpeechRecognizerState.ready;
    }
    return success;
  }

  /// Processes streamed 16-bit PCM audio chunks (16kHz mono).
  Future<void> acceptAudioChunk(Int16List pcmChunk) async {
    if (_state != SpeechRecognizerState.listening && _state != SpeechRecognizerState.ready) {
      return;
    }
    _state = SpeechRecognizerState.listening;
    await bridge.feedPcmChunk(pcmChunk);
  }

  /// Finalizes recognition and returns transcribed hypothesis.
  Future<SpeechRecognitionHypothesis> finalizeRecognition() async {
    _state = SpeechRecognizerState.processing;
    final stopwatch = Stopwatch()..start();

    final text = await bridge.finalizeTranscription();
    stopwatch.stop();

    _state = SpeechRecognizerState.stopped;

    return SpeechRecognitionHypothesis(
      text: text,
      confidence: 0.95,
      isFinal: true,
      latency: stopwatch.elapsed,
    );
  }

  Future<void> dispose() async {
    await bridge.releaseModel();
    _state = SpeechRecognizerState.uninitialized;
  }
}
