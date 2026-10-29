import 'dart:math';

/// Result from an individual lightning round answer.
class BlitzAnswerEvaluation {
  final bool isCorrect;
  final int earnedScore;
  final double activeMultiplier;
  final int consecutiveCorrectCombo;

  const BlitzAnswerEvaluation({
    required this.isCorrect,
    required this.earnedScore,
    required this.activeMultiplier,
    required this.consecutiveCorrectCombo,
  });
}

/// Orchestrates 5-second rapid speed blitz drills with combo multipliers.
class SpeedBlitzDrillEngine {
  final Duration timeLimitPerItem;

  int _currentCombo = 0;
  int _totalBlitzScore = 0;

  SpeedBlitzDrillEngine({
    this.timeLimitPerItem = const Duration(seconds: 5),
  });

  int get currentCombo => _currentCombo;
  int get totalBlitzScore => _totalBlitzScore;

  /// Evaluates an answer under time pressure and awards bonus speed points.
  BlitzAnswerEvaluation submitAnswer({
    required bool isCorrect,
    required Duration timeTaken,
  }) {
    if (!isCorrect || timeTaken > timeLimitPerItem) {
      _currentCombo = 0;
      return const BlitzAnswerEvaluation(
        isCorrect: false,
        earnedScore: 0,
        activeMultiplier: 1.0,
        consecutiveCorrectCombo: 0,
      );
    }

    _currentCombo++;

    // Calculate speed bonus: Faster answers yield higher multiplier
    final remainingMs = (timeLimitPerItem - timeTaken).inMilliseconds;
    final speedBonusFactor = 1.0 + (remainingMs / timeLimitPerItem.inMilliseconds * 1.5);
    final comboBonusFactor = 1.0 + min(_currentCombo * 0.25, 2.0);

    final finalMultiplier = speedBonusFactor * comboBonusFactor;
    final earned = (10 * finalMultiplier).round();
    _totalBlitzScore += earned;

    return BlitzAnswerEvaluation(
      isCorrect: true,
      earnedScore: earned,
      activeMultiplier: double.parse(finalMultiplier.toStringAsFixed(2)),
      consecutiveCorrectCombo: _currentCombo,
    );
  }

  void reset() {
    _currentCombo = 0;
    _totalBlitzScore = 0;
  }
}
