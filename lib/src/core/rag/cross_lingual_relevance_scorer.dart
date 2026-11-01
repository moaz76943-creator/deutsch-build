import 'dart:math' as math;

class CrossLingualRelevanceScorer {
  final double slopeA;
  final double interceptB;

  const CrossLingualRelevanceScorer({this.slopeA = 10.0, this.interceptB = -6.5});

  double calibrate(double rawSim) {
    final logit = (slopeA * rawSim) + interceptB;
    if (logit >= 35.0) return 1.0;
    if (logit <= -35.0) return 0.0;
    return 1.0 / (1.0 + math.exp(-logit));
  }
}
