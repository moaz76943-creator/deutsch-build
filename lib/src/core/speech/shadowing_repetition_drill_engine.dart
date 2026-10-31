import 'dart:math';

/// State of a shadowing training exercise.
enum ShadowingDrillState {
  ready,
  playingReference,
  shadowingCapture,
  evaluating,
  completed,
}

/// Evaluation report from a shadowing repetition attempt.
class ShadowingPerformanceReport {
  final Duration latencyOffset; // Learner shadow delay (target: 300-600ms)
  final double pacingSyncScore; // 0.0 to 100.0%
  final double durationRatio;   // learner duration / reference duration
  final String feedback;

  const ShadowingPerformanceReport({
    required this.latencyOffset,
    required this.pacingSyncScore,
    required this.durationRatio,
    required this.feedback,
  });
}

/// Manages shadowing drills with synchronized dual-track pacing analysis.
class ShadowingRepetitionDrillEngine {
  final Duration targetLatencyOffset; // Standard 400ms shadow offset

  const ShadowingRepetitionDrillEngine({
    this.targetLatencyOffset = const Duration(milliseconds: 400),
  });

  /// Evaluates learner's timing synchronicity in repeating after the native audio.
  ShadowingPerformanceReport evaluateShadowing({
    required Duration referenceAudioDuration,
    required Duration learnerSpokenDuration,
    required Duration observedLatencyOffset,
  }) {
    final refMs = referenceAudioDuration.inMilliseconds;
    final learnerMs = learnerSpokenDuration.inMilliseconds;
    final offsetMs = observedLatencyOffset.inMilliseconds;
    final targetMs = targetLatencyOffset.inMilliseconds;

    final durationRatio = refMs > 0 ? (learnerMs / refMs) : 1.0;
    final offsetDiff = (offsetMs - targetMs).abs();

    // Score higher if offset is near 400ms and duration ratio is near 1.0
    final double offsetScore = max(0.0, 50.0 - (offsetDiff * 0.1));
    final double durationScore = max(0.0, 50.0 - (durationRatio - 1.0).abs() * 50.0);
    final double totalScore = (offsetScore + durationScore).clamp(0.0, 100.0);

    String feedback;
    if (totalScore >= 80) {
      feedback = 'رائع! محاكاة متزامنة وتناغم صوتي ممتاز مع المتحدث الأصلي.';
    } else if (totalScore >= 60) {
      feedback = 'جيد، ولكن حاول ملاحقة المتحدث الأصلي بزمن تأخير أقصر (Shadowing Offset).';
    } else {
      feedback = 'يحتاج لتحسين: هناك فارق زمني كبير بين استماعك وبدء تكرار الجملة.';
    }

    return ShadowingPerformanceReport(
      latencyOffset: observedLatencyOffset,
      pacingSyncScore: double.parse(totalScore.toStringAsFixed(1)),
      durationRatio: double.parse(durationRatio.toStringAsFixed(2)),
      feedback: feedback,
    );
  }
}
