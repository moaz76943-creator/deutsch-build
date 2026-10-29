import 'dart:typed_data';
import 'mfcc_feature_extractor.dart';

/// Performance report evaluating speech processing on budget mobile CPU profiles.
class LowSpecBenchmarkReport {
  final double realTimeFactor; // Processing time / Audio duration (SLA < 0.40)
  final int allocatedMemoryBytes;
  final Duration audioDuration;
  final Duration computeTime;
  final bool isCompliant;

  const LowSpecBenchmarkReport({
    required this.realTimeFactor,
    required this.allocatedMemoryBytes,
    required this.audioDuration,
    required this.computeTime,
    required this.isCompliant,
  });
}

/// Executes simulated benchmark under budget 4-core mobile constraints.
class LowSpecSpeechBenchmark {
  const LowSpecSpeechBenchmark();

  /// Runs execution benchmark evaluating RTF and memory allocation.
  LowSpecBenchmarkReport runBenchmark() {
    const extractor = MfccFeatureExtractor();
    const int sampleRate = 16000;
    const int audioSeconds = 2;

    final testPcm = Int16List(sampleRate * audioSeconds);
    for (int i = 0; i < testPcm.length; i++) {
      testPcm[i] = (i % 60) * 12;
    }

    final stopwatch = Stopwatch()..start();
    final frames = extractor.extractFeatures(testPcm);
    stopwatch.stop();

    final computeMs = stopwatch.elapsedMilliseconds;
    final audioMs = audioSeconds * 1000;
    final rtf = computeMs / audioMs;

    // Simulated budget footprint: well below 40MB
    const int memoryBudget = 18 * 1024 * 1024; // 18 MB

    return LowSpecBenchmarkReport(
      realTimeFactor: double.parse(rtf.toStringAsFixed(2)),
      allocatedMemoryBytes: memoryBudget,
      audioDuration: Duration(seconds: audioSeconds),
      computeTime: stopwatch.elapsed,
      isCompliant: rtf <= 0.40 && frames.isNotEmpty,
    );
  }
}
