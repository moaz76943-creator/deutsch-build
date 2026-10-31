import 'dart:math';

/// State of an ongoing survival marathon session.
class SurvivalSessionState {
  final int remainingLives; // Starts at 3
  final int consecutiveCorrect;
  final int totalAnswered;
  final int currentDifficultyTier; // 1 (A1) to 5 (C1)
  final bool isGameOver;

  const SurvivalSessionState({
    required this.remainingLives,
    required this.consecutiveCorrect,
    required this.totalAnswered,
    required this.currentDifficultyTier,
    required this.isGameOver,
  });
}

/// Manages survival marathon drills with 3 lives and progressive difficulty scaling.
class EnduranceSurvivalEngine {
  final int initialLives;

  const EnduranceSurvivalEngine({this.initialLives = 3});

  /// Initializes a fresh survival session.
  SurvivalSessionState startSession() {
    return SurvivalSessionState(
      remainingLives: initialLives,
      consecutiveCorrect: 0,
      totalAnswered: 0,
      currentDifficultyTier: 1,
      isGameOver: false,
    );
  }

  /// Processes an answer submission, deducting a life on mistake or advancing difficulty.
  SurvivalSessionState submitAnswer({
    required SurvivalSessionState state,
    required bool isCorrect,
  }) {
    if (state.isGameOver) return state;

    if (isCorrect) {
      final newConsecutive = state.consecutiveCorrect + 1;
      // Advance difficulty tier every 5 consecutive correct answers (capped at tier 5)
      final newTier = min(5, 1 + (newConsecutive ~/ 5));

      return SurvivalSessionState(
        remainingLives: state.remainingLives,
        consecutiveCorrect: newConsecutive,
        totalAnswered: state.totalAnswered + 1,
        currentDifficultyTier: newTier,
        isGameOver: false,
      );
    } else {
      final newLives = state.remainingLives - 1;
      return SurvivalSessionState(
        remainingLives: newLives,
        consecutiveCorrect: 0, // Reset combo
        totalAnswered: state.totalAnswered + 1,
        currentDifficultyTier: state.currentDifficultyTier,
        isGameOver: newLives <= 0,
      );
    }
  }
}
