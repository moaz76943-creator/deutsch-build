class CognitiveOverloadShield {
  final double thresholdAccuracy;
  final int minimumAnswersBeforeCheck;

  const CognitiveOverloadShield({
    this.thresholdAccuracy = 0.60,
    this.minimumAnswersBeforeCheck = 10,
  });

  bool isOverloaded({required int totalAnswers, required int correctAnswers}) {
    if (totalAnswers < minimumAnswersBeforeCheck) {
      return false;
    }

    final accuracy = correctAnswers / totalAnswers;
    return accuracy < thresholdAccuracy;
  }
}
