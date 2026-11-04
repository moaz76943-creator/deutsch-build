/// Task 1401: 2-Parameter Logistic (2PL) IRT theta ability estimator
class Irt2PlEstimator {
  double calculateProb(double theta, double a, double b) => 1.0 / (1.0 + (a * (b - theta)).abs());
  double updateTheta(double currentTheta, bool isCorrect) => currentTheta + (isCorrect ? 0.2 : -0.2);
}
