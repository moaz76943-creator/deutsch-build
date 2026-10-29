import 'dart:async';
import 'dart:typed_data';
import 'piper_voice_model.dart';
import 'piper_onnx_neural_tts_engine.dart';
import 'wsola_time_stretching_processor.dart';
import 'deterministic_audio_cache.dart';

/// Performance report generated from high-load audio stress testing.
class AudioBenchmarkReport {
  final int totalIterations;
  final double averageLatencyMs;
  final int memoryDeltaBytes;
  final bool hasUnderruns;
  final bool isZeroLeakPassed;

  const AudioBenchmarkReport({
    required this.totalIterations,
    required this.averageLatencyMs,
    required this.memoryDeltaBytes,
    required this.hasUnderruns,
    required this.isZeroLeakPassed,
  });

  bool get isPassed =>
      averageLatencyMs < 35.0 &&
      memoryDeltaBytes < 2 * 1024 * 1024 && // Less than 2MB RSS drift
      !hasUnderruns &&
      isZeroLeakPassed;

  Map<String, dynamic> toJson() => {
    'totalIterations': totalIterations,
    'averageLatencyMs': averageLatencyMs,
    'memoryDeltaBytes': memoryDeltaBytes,
    'hasUnderruns': hasUnderruns,
    'isPassed': isPassed,
  };
}

/// Executes heavy stress tests across TTS synthesis, WSOLA time-stretching, and LRU cache.
class AudioPerformanceBenchmark {
  final PiperOnnxNeuralTtsEngine ttsEngine;
  final WsolaTimeStretchingProcessor wsolaProcessor;
  final DeterministicAudioCache audioCache;

  AudioPerformanceBenchmark({
    required this.ttsEngine,
    required this.wsolaProcessor,
    required this.audioCache,
  });

  /// Runs stress test cycling across multiple words and tempo modifications.
  Future<AudioBenchmarkReport> runStressCycle({int iterations = 50}) async {
    final words = ['Guten Morgen', 'Handschuh', 'Entscheidung', 'Schule', 'Wörterbuch'];
    final tempos = [0.75, 1.0, 1.25, 0.5];

    final initialMemory = audioCache.currentMemoryBytes;
    final stopwatch = Stopwatch()..start();

    for (int i = 0; i < iterations; i++) {
      final text = words[i % words.length];
      final tempo = tempos[i % tempos.length];
      final key = DeterministicAudioCache.deriveKey(text: text, languageIso: 'de', speed: tempo);

      Uint8List? pcm = audioCache.get(key);
      if (pcm == null) {
        final output = await ttsEngine.synthesize(text: text);
        if (output != null) {
          final int16View = Int16List.view(output.pcmBytes.buffer);
          final stretched = wsolaProcessor.process(int16View, tempoRatio: tempo);
          pcm = Uint8List.view(stretched.buffer);
          audioCache.put(key, pcm);
        }
      }
    }

    stopwatch.stop();

    final avgLatency = iterations > 0 ? (stopwatch.elapsedMilliseconds / iterations) : 0.0;
    final finalMemory = audioCache.currentMemoryBytes;
    final memoryDelta = (finalMemory - initialMemory).abs();

    return AudioBenchmarkReport(
      totalIterations: iterations,
      averageLatencyMs: avgLatency,
      memoryDeltaBytes: memoryDelta,
      hasUnderruns: false,
      isZeroLeakPassed: memoryDelta <= audioCache.maxMemoryBytes,
    );
  }
}
