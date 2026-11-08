import 'dart:math' as math;

final class PhoneticFeatureVector {
  final double tongueHeight;
  final double tongueBackness;
  final double lipRounding;
  final double voicing;
  final double nasality;
  final double constrictionDegree;

  const PhoneticFeatureVector({
    required this.tongueHeight,
    required this.tongueBackness,
    required this.lipRounding,
    required this.voicing,
    required this.nasality,
    required this.constrictionDegree,
  });

  bool get isValid =>
      tongueHeight.isFinite && tongueHeight >= 0.0 && tongueHeight <= 1.0 &&
      tongueBackness.isFinite && tongueBackness >= 0.0 && tongueBackness <= 1.0 &&
      lipRounding.isFinite && lipRounding >= 0.0 && lipRounding <= 1.0 &&
      voicing.isFinite && voicing >= 0.0 && voicing <= 1.0 &&
      nasality.isFinite && nasality >= 0.0 && nasality <= 1.0 &&
      constrictionDegree.isFinite && constrictionDegree >= 0.0 && constrictionDegree <= 1.0;
}

sealed class PhoneticEvaluationResult {
  const PhoneticEvaluationResult();
}

final class ValidPhoneticScore extends PhoneticEvaluationResult {
  final double distance;
  final double similarityScore;
  final bool isNativeLike;

  const ValidPhoneticScore({
    required this.distance,
    required this.similarityScore,
    required this.isNativeLike,
  });
}

final class InvalidPhoneticInput extends PhoneticEvaluationResult {
  final String reason;
  const InvalidPhoneticInput(this.reason);
}

final class PhoneticDistanceEngine {
  static const double wTongueHeight = 0.25;
  static const double wTongueBackness = 0.25;
  static const double wLipRounding = 0.15;
  static const double wConstriction = 0.15;
  static const double wVoicing = 0.10;
  static const double wNasality = 0.10;

  static PhoneticEvaluationResult evaluate(
    PhoneticFeatureVector target,
    PhoneticFeatureVector learner,
  ) {
    if (!target.isValid || !learner.isValid) {
      return const InvalidPhoneticInput("Input dimensions must be finite numbers in [0.0, 1.0]");
    }

    final dH = target.tongueHeight - learner.tongueHeight;
    final dB = target.tongueBackness - learner.tongueBackness;
    final dL = target.lipRounding - learner.lipRounding;
    final dC = target.constrictionDegree - learner.constrictionDegree;
    final dV = target.voicing - learner.voicing;
    final dN = target.nasality - learner.nasality;

    final weightedSum = (wTongueHeight * dH * dH) +
        (wTongueBackness * dB * dB) +
        (wLipRounding * dL * dL) +
        (wConstriction * dC * dC) +
        (wVoicing * dV * dV) +
        (wNasality * dN * dN);

    final distance = math.sqrt(weightedSum);
    final similarity = math.max(0.0, (1.0 - distance) * 100.0);

    return ValidPhoneticScore(
      distance: distance,
      similarityScore: similarity,
      isNativeLike: distance < 0.12,
    );
  }
}
