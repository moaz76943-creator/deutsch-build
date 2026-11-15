import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_build/src/core/audio/piper_voice_model.dart';
import 'package:deutsch_build/src/core/audio/piper_onnx_neural_tts_engine.dart';

class MockOnnxExecutor implements PiperOnnxRuntimeExecutor {
  bool isLoaded = false;

  @override
  Future<bool> loadModel(PiperVoiceModel model) async {
    isLoaded = true;
    return true;
  }

  @override
  Future<Uint8List> runInference(String phonemes, {double speed = 1.0}) async {
    // Generate 22050 samples (1 second of 16-bit mono silence/tone for testing)
    return Uint8List(22050 * 2);
  }

  @override
  Future<void> unloadModel() async {
    isLoaded = false;
  }
}

void main() {
  group('PiperOnnxNeuralTtsEngine Tests', () {
    late MockOnnxExecutor executor;
    late PiperOnnxNeuralTtsEngine ttsEngine;

    setUp(() {
      executor = MockOnnxExecutor();
      ttsEngine = PiperOnnxNeuralTtsEngine(executor: executor)..initialize();
    });

    test('Initializes default models and switches language to German', () async {
      expect(ttsEngine.registeredModelsCount, equals(3));

      final success = await ttsEngine.setLanguage('de');
      expect(success, isTrue);
      expect(ttsEngine.activeModel!.speakerName, equals('Thorsten'));
      expect(executor.isLoaded, isTrue);
    });

    test('Synthesizes text to PCM buffer with valid duration', () async {
      await ttsEngine.setLanguage('de');
      final output = await ttsEngine.synthesize(text: 'Guten Tag');

      expect(output, isNotNull);
      expect(output!.sampleRate, equals(22050));
      expect(output.duration.inMilliseconds, equals(1000));
      expect(output.pcmBytes.isNotEmpty, isTrue);
    });

    test('Releases memory upon request', () async {
      await ttsEngine.setLanguage('de');
      expect(executor.isLoaded, isTrue);

      await ttsEngine.releaseMemory();
      expect(executor.isLoaded, isFalse);
      expect(ttsEngine.activeModel, isNull);
    });
  });
}
