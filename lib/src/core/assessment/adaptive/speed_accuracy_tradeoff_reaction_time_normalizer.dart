/// Task 1408: Log-normal response time model penalizing rapid guessing
class SpeedAccuracyNormalizer {
  bool isRapidGuess(int reactionTimeMs) => reactionTimeMs < 1200;
}
