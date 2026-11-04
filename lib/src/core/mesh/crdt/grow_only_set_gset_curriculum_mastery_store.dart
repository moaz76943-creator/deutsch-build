/// Task 1531: Grow-Only Set (G-Set) CRDT for completed lesson achievements
class GSetCurriculumStore {
  final Set<String> _achievements = {};
  void addAchievement(String id) => _achievements.add(id);
  bool hasAchievement(String id) => _achievements.contains(id);
  Set<String> merge(Set<String> remote) => _achievements..addAll(remote);
}
