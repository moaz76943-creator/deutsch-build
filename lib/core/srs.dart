import 'dart:math' as math;

import '../models/learner.dart';
import 'date_utils.dart';

class Srs {
  static const schedule = <int>[1, 2, 4, 7, 12, 18, 30];

  static int nextDays({
    required bool correct,
    required bool hinted,
    required int repetitions,
  }) {
    if (!correct) return 0;
    final r = repetitions < 0 ? 0 : (repetitions > 20 ? 20 : repetitions);
    final rawIndex = r - (hinted ? 1 : 0);
    final index = rawIndex < 0
        ? 0
        : (rawIndex >= schedule.length ? schedule.length - 1 : rawIndex);
    return schedule[index];
  }

  static double retrievability(ReviewCard card, {DateTime? now}) {
    final at = now ?? DateTime.now();
    if (card.lastReviewedAt == null || card.stabilityDays <= 0) return 0;
    final elapsed = math.max(
          0,
          at.toUtcNominal
              .difference(card.lastReviewedAt!.toUtcNominal)
              .inMinutes,
        ) /
        (60 * 24);
    return math.exp(-elapsed / card.stabilityDays).clamp(0.0, 1.0).toDouble();
  }

  static double reviewPriority(ReviewCard card, {DateTime? now}) {
    final at = now ?? DateTime.now();
    final r = retrievability(card, now: at);
    final overdueDays = card.dueAt.isAfter(at)
        ? 0.0
        : at.toUtcNominal.difference(card.dueAt.toUtcNominal).inMinutes /
            (60 * 24);
    final lapsePressure = card.lapses * 0.16 + card.failures * 0.025;
    final difficultyPressure =
        (card.difficulty - 1.0).clamp(0.0, 1.5).toDouble() * 0.08;
    return ((1 - r) * 0.62 +
            overdueDays.clamp(0, 30) / 30 * 0.22 +
            lapsePressure +
            difficultyPressure)
        .clamp(0.0, 2.0)
        .toDouble();
  }

  static ReviewCard update(
    ReviewCard current, {
    required bool correct,
    required bool hinted,
    DateTime? now,
  }) {
    final at = now ?? DateTime.now();
    if (!correct) {
      final stability = (current.stabilityDays <= 0
              ? current.intervalDays.toDouble()
              : current.stabilityDays) *
          .45;
      return current.copyWith(
        repetitions: 0,
        intervalDays: 0,
        lapses: current.lapses + 1,
        failures: current.failures + 1,
        difficulty: _bound(current.difficulty + .12, .5, 2.5),
        stabilityDays: _bound(stability, .25, 3650),
        dueAt: at,
        lastReviewedAt: at,
      );
    }
    final base = current.stabilityDays > 0
        ? current.stabilityDays
        : nextDays(
            correct: true,
            hinted: hinted,
            repetitions: current.repetitions,
          ).toDouble();
    final growth = hinted ? 1.28 : 1.62;
    final difficultyFactor = _bound(
      1.95 - current.difficulty * .22,
      1.35,
      1.85,
    );
    final stability =
        (base * growth * difficultyFactor).clamp(1, 3650).toDouble();
    final scheduled = nextDays(
      correct: true,
      hinted: hinted,
      repetitions: current.repetitions,
    );
    final days = current.repetitions < 2
        ? scheduled
        : _boundInt(stability.round(), 1, 3650);
    return current.copyWith(
      repetitions: current.repetitions + 1,
      intervalDays: days,
      successes: current.successes + 1,
      difficulty: _bound(current.difficulty + (hinted ? .015 : -.025), .5, 2.5),
      stabilityDays: stability,
      dueAt: at.add(Duration(days: days)),
      lastReviewedAt: at,
    );
  }

  static double _bound(double v, double min, double max) =>
      v < min ? min : (v > max ? max : v);
  static int _boundInt(int v, int min, int max) =>
      v < min ? min : (v > max ? max : v);
}
