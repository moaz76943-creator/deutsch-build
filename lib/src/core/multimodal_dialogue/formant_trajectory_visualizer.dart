import 'dart:math' as math;

/// 2D Acoustic formant coordinate (F1 = vowel height, F2 = vowel backness).
class FormantCoordinate {
  final double f1Hz;
  final double f2Hz;
  final double timestampSec;

  const FormantCoordinate({
    required this.f1Hz,
    required this.f2Hz,
    required this.timestampSec,
  });
}

/// Target vowel acoustic reference ellipse in Hz.
class VowelTargetZone {
  final String vowelIpa; // e.g. /yː/, /iː/, /uː/
  final double targetF1;
  final double targetF2;
  final double toleranceRadiusHz;

  const VowelTargetZone({
    required this.vowelIpa,
    required this.targetF1,
    required this.targetF2,
    this.toleranceRadiusHz = 120.0,
  });

  /// Checks if learner formant coordinate lands inside the target zone.
  bool contains(FormantCoordinate coord) {
    final dF1 = coord.f1Hz - targetF1;
    final dF2 = coord.f2Hz - targetF2;
    final distance = math.sqrt(dF1 * dF1 + dF2 * dF2);
    return distance <= toleranceRadiusHz;
  }
}

/// Provides real-time biofeedback comparing learner vowel trajectories against native articulatory targets.
class FormantTrajectoryVisualizer {
  static const Map<String, VowelTargetZone> standardGermanVowels = {
    'iː': VowelTargetZone(vowelIpa: 'iː', targetF1: 280, targetF2: 2250), // "Tier"
    'yː': VowelTargetZone(vowelIpa: 'yː', targetF1: 300, targetF2: 1750), // "Tür" (rounded front)
    'uː': VowelTargetZone(vowelIpa: 'uː', targetF1: 320, targetF2: 800), // "Tour" (back rounded)
    'aː': VowelTargetZone(vowelIpa: 'aː', targetF1: 750, targetF2: 1200), // "Bahn" (low open)
  };

  /// Evaluates accuracy of learner vowel articulation against target phoneme.
  Map<String, dynamic> evaluateVowelHit({
    required String targetPhoneme,
    required FormantCoordinate learnerSample,
  }) {
    final zone = standardGermanVowels[targetPhoneme];
    if (zone == null) {
      return {'isHit': false, 'error': 'Target phoneme not catalogued'};
    }

    final isInside = zone.contains(learnerSample);
    final dF1 = (learnerSample.f1Hz - zone.targetF1).abs();
    final dF2 = (learnerSample.f2Hz - zone.targetF2).abs();
    final totalDistance = math.sqrt(dF1 * dF1 + dF2 * dF2);

    String feedback = 'Perfekt getroffen!';
    if (!isInside) {
      if (learnerSample.f2Hz < zone.targetF2 - 150) {
        feedback = 'Zunge weiter nach vorne schieben!';
      } else if (learnerSample.f2Hz > zone.targetF2 + 150) {
        feedback = 'Lippen stärker runden!';
      }
    }

    return {
      'target': targetPhoneme,
      'isHit': isInside,
      'distanceHz': double.parse(totalDistance.toStringAsFixed(1)),
      'feedback': feedback,
    };
  }
}
