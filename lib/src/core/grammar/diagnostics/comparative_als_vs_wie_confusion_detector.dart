/// Task 1357: Detects confusion between 'als' (unequal) and 'wie' (equal)
class AlsVsWieDetector {
  String getCorrectParticle(bool isComparative) => isComparative ? 'als' : 'wie';
}
