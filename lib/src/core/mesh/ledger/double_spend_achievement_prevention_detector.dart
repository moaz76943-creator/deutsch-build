/// Task 1576: Prevents duplicate mastery claims and replay attacks
class DoubleAchievementDetector {
  final Set<String> _claimedTokens = {};
  bool tryClaim(String token) => _claimedTokens.add(token);
}
