import '../models/learner.dart';

class MistakeBucket {
  final String skill;
  final int errors, attempts;
  const MistakeBucket({
    required this.skill,
    required this.errors,
    required this.attempts,
  });
  double get errorRate => attempts == 0 ? 0 : errors / attempts;
}

class MistakeReport {
  final List<MistakeBucket> bySkill;
  final List<String> weakItems;
  const MistakeReport({required this.bySkill, required this.weakItems});
}

class MistakeAnalysis {
  static MistakeReport from(List<Attempt> attempts) {
    final grouped = <String, List<Attempt>>{};
    for (final a in attempts) grouped.putIfAbsent(a.skill, () => []).add(a);
    final buckets = grouped.entries
        .map(
          (e) => MistakeBucket(
            skill: e.key,
            errors: e.value.where((a) => !a.correct).length,
            attempts: e.value.length,
          ),
        )
        .toList()
      ..sort((a, b) => (b.errorRate).compareTo(a.errorRate));
    final itemErrors = <String, int>{};
    for (final a in attempts.where((a) => !a.correct))
      itemErrors[a.itemId] = (itemErrors[a.itemId] ?? 0) + 1;
    final weakItems = itemErrors.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return MistakeReport(
      bySkill: buckets,
      weakItems: weakItems.take(12).map((e) => e.key).toList(),
    );
  }
}
