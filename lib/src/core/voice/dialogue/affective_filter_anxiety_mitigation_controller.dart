/// Task 1164: Krashen affective filter anxiety monitor
class AffectiveFilterController {
  int consecutiveErrors = 0;
  void recordHesitation() => consecutiveErrors++;
  bool get shouldSimplify => consecutiveErrors >= 2;
  void reset() => consecutiveErrors = 0;
}
