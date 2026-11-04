/// Task 2067: Passive voice alternatives (sein + zu + Infinitiv, sich lassen + Infinitiv)
class PassiveSubstituteMatcher {
  bool isFeasible(String text) => text.contains('lässt sich') || text.contains('ist zu');
}
