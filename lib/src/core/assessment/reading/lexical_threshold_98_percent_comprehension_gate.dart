/// Task 1468: Verifies 98% vocabulary coverage threshold for unassisted reading
class LexicalCoverageGate {
  bool has98PercentCoverage(int knownTokens, int totalTokens) => totalTokens > 0 ? (knownTokens / totalTokens) >= 0.98 : false;
}
