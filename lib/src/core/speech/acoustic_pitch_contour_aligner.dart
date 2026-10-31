import 'dart:math';

/// Result of aligning and scoring pitch intonation contour against native model.
class PitchContourScore {
  final double similarityScore; // 0.0 to 100.0%
  final double meanPitchDeltaHz;
  final bool isIntonationCorrect;

  const PitchContourScore({
    required this.similarityScore,
    required this.meanPitchDeltaHz,
    required this.isIntonationCorrect,
  });
}

/// Aligns fundamental pitch contours (F0) using Dynamic Time Warping (DTW).
class AcousticPitchContourAligner {
  const AcousticPitchContourAligner();

  /// Calculates DTW distance between learner and reference pitch vectors.
  PitchContourScore alignAndScore({
    required List<double> learnerPitchContour,
    required List<double> referencePitchContour,
  }) {
    if (learnerPitchContour.isEmpty || referencePitchContour.isEmpty) {
      return const PitchContourScore(
        similarityScore: 0.0,
        meanPitchDeltaHz: 0.0,
        isIntonationCorrect: false,
      );
    }

    final n = learnerPitchContour.length;
    final m = referencePitchContour.length;

    // Allocate DTW cost matrix
    final dtw = List.generate(n + 1, (_) => List.filled(m + 1, double.infinity));
    dtw[0][0] = 0.0;

    for (int i = 1; i <= n; i++) {
      for (int j = 1; j <= m; j++) {
        final cost = (learnerPitchContour[i - 1] - referencePitchContour[j - 1]).abs();
        dtw[i][j] = cost + min(dtw[i - 1][j], min(dtw[i][j - 1], dtw[i - 1][j - 1]));
      }
    }

    final dtwDistance = dtw[n][m];
    final normalizedDistance = dtwDistance / (n + m);

    // Map distance to 0 - 100% similarity score
    final score = (100.0 * exp(-normalizedDistance / 40.0)).clamp(0.0, 100.0);

    return PitchContourScore(
      similarityScore: double.parse(score.toStringAsFixed(1)),
      meanPitchDeltaHz: double.parse(normalizedDistance.toStringAsFixed(1)),
      isIntonationCorrect: score >= 70.0,
    );
  }
}
