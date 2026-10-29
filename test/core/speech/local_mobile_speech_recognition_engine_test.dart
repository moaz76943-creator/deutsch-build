import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:deutsch_build/src/core/speech/local_mobile_speech_recognition_engine.dart';

class MockSttBridge implements MobileSttBridge {
  bool initialized = false;
  int chunksReceived = 0;

  @override
  Future<bool> initializeModel(String languageIso) async {
    initialized = true;
    return true;
  }

  @override
  Future<void> feedPcmChunk(Int16List pcmData) async {
    chunksReceived++;
  }

  @override
  Future<String> finalizeTranscription() async => 'Guten Tag Deutschland';

  @override
  Future<void> releaseModel() async {
    initialized = false;
  }
}

void main() {
  group('LocalMobileSpeechRecognitionEngine Tests', () {
    late MockSttBridge bridge;
    late LocalMobileSpeechRecognitionEngine engine;

    setUp(() {
      bridge = MockSttBridge();
      engine = LocalMobileSpeechRecognitionEngine(bridge: bridge);
    });

    test('Initializes STT engine and processes audio streaming chunks offline', () async {
      expect(engine.state, equals(SpeechRecognizerState.uninitialized));

      final ok = await engine.initialize('de');
      expect(ok, isTrue);
      expect(engine.state, equals(SpeechRecognizerState.ready));

      await engine.acceptAudioChunk(Int16List(1600)); // 100ms at 16kHz
      expect(engine.state, equals(SpeechRecognizerState.listening));
      expect(bridge.chunksReceived, equals(1));

      final hypothesis = await engine.finalizeRecognition();
      expect(hypothesis.text, equals('Guten Tag Deutschland'));
      expect(hypothesis.isFinal, isTrue);
      expect(engine.state, equals(SpeechRecognizerState.stopped));
    });
  });
}
