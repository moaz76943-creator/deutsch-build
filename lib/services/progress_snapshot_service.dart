import '../models/learner.dart';
import '../models/progress_snapshot.dart';

class ProgressSnapshotService {
  static ProgressSnapshot build(
    List<Attempt> attempts,
    List<AssessmentHistory> history,
  ) {
    final keys = <String>{
      'recall',
      'listening',
      'production',
      'transfer',
      ...attempts.map((a) => a.skill),
    };
    final scores = <String, double>{};
    for (final skill in keys) {
      final rows = attempts.where((a) => a.skill == skill).toList();
      if (rows.isEmpty) {
        scores[skill] = 0;
        continue;
      }
      final recent = rows.length > 12 ? rows.sublist(rows.length - 12) : rows;
      var total = 0.0;
      var weight = 1.0;
      for (final a in recent.reversed) {
        total += (a.correct ? 1.0 : 0.0) * (a.hinted ? .85 : 1.0) * weight;
        weight *= .94;
      }
      scores[skill] = total / _weightSum(recent.length);
    }
    final considered = scores.entries
        .where((e) => attempts.any((a) => a.skill == e.key))
        .toList();
    final overall = considered.isEmpty
        ? (history.isEmpty ? 0.0 : history.first.score / 100)
        : considered.map((e) => e.value).reduce((a, b) => a + b) /
            considered.length;
    final weakest = considered.isEmpty
        ? 'recall'
        : (List.of(
            considered,
          )..sort((a, b) => a.value.compareTo(b.value)))
            .first
            .key;
    return ProgressSnapshot(
      skillScores: scores,
      levelLabel: _level(overall),
      weakestSkill: weakest,
      assessedCount: history.length,
      overall: overall.clamp(0, 1).toDouble(),
    );
  }

  static double _weightSum(int n) {
    var weight = 1.0;
    var sum = 0.0;
    for (var i = 0; i < n; i++) {
      sum += weight;
      weight *= .94;
    }
    return sum == 0 ? 1 : sum;
  }

  static String _level(double score) => score >= .90
      ? 'B2 قوي'
      : score >= .78
          ? 'B1 متقدم'
          : score >= .64
              ? 'A2 متقدم'
              : score >= .48
                  ? 'A2'
                  : score >= .30
                      ? 'A1 متقدم'
                      : 'A1 بداية';
}
