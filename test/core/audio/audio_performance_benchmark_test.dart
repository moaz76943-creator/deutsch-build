import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:deutsch_build/src/core/audio/piper_voice_model.dart';
import 'package:deutsch_build/src/core/audio/piper_onnx_neural_tts_engine.dart';
import 'package:deutsch_build/src/core/audio/wsola_time_stretching_processor.dart';
import 'package:deutsch_build/src/core/audio/deterministic_audio_cache.dart';
import 'package:deutsch_build/src/core/audio/audio_performance_benchmark.dart';

class MockBenchmarkExecutor implements PiperOnnxRuntimeExecutor {
  @override
  Future<bool> loadModel(PiperVoiceModel model) async => true;

  @override
  Future<Uint8List> runInference(String phonemes, {double speed = 1.0}) async {
    return Uint8List(512); // Fast 512-byte test buffer
  }

  @override
  Future<void> unloadModel() async {}
}

void main() {
  group('AudioPerformanceBenchmark Tests', () {
    test('Stress benchmark runs within SLA and bounded memory drift', () async {
      final ttsEngine = PiperOnnxNeuralTtsEngine(executor: MockBenchmarkExecutor())..initialize();
      await ttsEngine.setLanguage('de');

      const wsola = WsolaTimeStretchingProcessor();
      final cache = DeterministicAudioCache(maxMemoryEntries: 32);

      final benchmark = AudioPerformanceBenchmark(
        ttsEngine: ttsEngine,
        wsolaProcessor: wsola,
        audioCache: cache,
      );

      final report = await benchmark.runStressCycle(iterations: 20);

      expect(report.totalIterations, equals(20));
      expect(report.isPassed, isTrue);
      expect(report.hasUnderruns, isFalse);
    });
  });
}
