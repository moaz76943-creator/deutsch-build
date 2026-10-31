import 'dart:math' as math;

/// Sub-millisecond phoneme alignment timestamp.
class AlignmentAnchor {
  final String phoneme;
  final double referenceTimeSec;
  final double learnerTimeSec;
  final double pitchDeltaHz;

  const AlignmentAnchor({
    required this.phoneme,
    required this.referenceTimeSec,
    required this.learnerTimeSec,
    required this.pitchDeltaHz,
  });
}

/// Synchronizes native model audio with learner vocal latency in real-time shadowing.
class ShadowingPacingSynchronizer {
  final double targetLeadTimeSec; // Desired delay between speaker and shadow (typically 0.25s)

  const ShadowingPacingSynchronizer({this.targetLeadTimeSec = 0.25});

  /// Evaluates alignment accuracy and calculates recommended playback stretch factor.
  Map<String, dynamic> synchronizeCadence(List<AlignmentAnchor> anchors) {
    if (anchors.isEmpty) {
      return {
        'recommendedPlaybackSpeed': 1.0,
        'averageLatencyDeviationSec': 0.0,
        'cadenceSyncScore': 0.0,
        'isSynchronous': false,
      };
    }

    double totalLatencyDelta = 0.0;
    double totalPitchError = 0.0;

    for (final anchor in anchors) {
      final actualDelay = anchor.learnerTimeSec - anchor.referenceTimeSec;
      final delayError = (actualDelay - targetLeadTimeSec).abs();
      totalLatencyDelta += delayError;
      totalPitchError += anchor.pitchDeltaHz.abs();
    }

    final avgDelayError = totalLatencyDelta / anchors.length;
    final avgPitchError = totalPitchError / anchors.length;

    // Dynamically adjust audio playback speed (0.80x to 1.15x) to pull learner into sync
    double speedAdjustment = 1.0;
    if (avgDelayError > 0.35) {
      // Learner lagging behind -> slow model audio down
      speedAdjustment = math.max(0.80, 1.0 - (avgDelayError * 0.4));
    } else if (avgDelayError < 0.10) {
      // Learner rushing too close -> slight speedup
      speedAdjustment = math.min(1.10, 1.0 + (0.10 - avgDelayError));
    }

    final syncScore = (100.0 - (avgDelayError * 120.0) - (avgPitchError * 0.15)).clamp(0.0, 100.0);

    return {
      'recommendedPlaybackSpeed': double.parse(speedAdjustment.toStringAsFixed(2)),
      'averageLatencyDeviationSec': double.parse(avgDelayError.toStringAsFixed(3)),
      'cadenceSyncScore': double.parse(syncScore.toStringAsFixed(1)),
      'isSynchronous': syncScore >= 70.0,
    };
  }
}
