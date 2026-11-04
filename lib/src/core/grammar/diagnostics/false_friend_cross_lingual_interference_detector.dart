/// Task 1346: Detects false friends (e.g. 'bekommen' vs 'become')
class FalseFriendDetector {
  String? checkFalseFriend(String word) => word == 'bekommen' ? 'Note: bekommen means receive, not become (werden)' : null;
}
