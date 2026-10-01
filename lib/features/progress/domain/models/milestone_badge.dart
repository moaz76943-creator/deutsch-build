class MilestoneBadge {
  final String id;
  final String title;
  final String description;
  final int requiredStreakDays;
  final DateTime unlockedAt;

  const MilestoneBadge({
    required this.id,
    required this.title,
    required this.description,
    required this.requiredStreakDays,
    required this.unlockedAt,
  });
}
