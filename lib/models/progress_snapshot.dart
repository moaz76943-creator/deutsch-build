class ProgressSnapshot {
  final Map<String, double> skillScores;
  final String levelLabel;
  final String weakestSkill;
  final int assessedCount;
  final double overall;

  const ProgressSnapshot({
    required this.skillScores,
    required this.levelLabel,
    required this.weakestSkill,
    required this.assessedCount,
    required this.overall,
  });
}
