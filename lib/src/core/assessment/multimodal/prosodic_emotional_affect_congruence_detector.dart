/// Task 1485: Assesses emotional prosodic congruence with communicative intent
class AffectCongruenceDetector {
  bool isCongruent(String intent, double pitchVariance) => intent == 'enthusiastic' ? pitchVariance > 0.25 : pitchVariance <= 0.25;
}
