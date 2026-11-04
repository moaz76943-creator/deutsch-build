/// Task 1464: Calibrates literal recall vs inferential reading questions
class QuestionTypeCalibrator {
  double getDifficultyWeight(bool isInferential) => isInferential ? 1.4 : 1.0;
}
