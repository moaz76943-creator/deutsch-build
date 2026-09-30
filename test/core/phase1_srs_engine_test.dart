import 'package:flutter_test/flutter_test.dart';

import 'package:deutsch_bilarabi/core/srs.dart';
import 'package:deutsch_bilarabi/models/learner.dart';

void main() {
  final now = DateTime.utc(2026, 9, 30, 9);

  test('retrievability stays bounded when last review is in the future', () {
    final card = ReviewCard(
      itemId: 'future-review',
      stabilityDays: 4,
      dueAt: now.add(const Duration(days: 2)),
      lastReviewedAt: now.add(const Duration(hours: 6)),
    );

    final value = Srs.retrievability(card, now: now);

    expect(value, inInclusiveRange(0.0, 1.0));
    expect(value, 1.0);
  });

  test('review priority remains bounded for a heavily overdue lapse', () {
    final card = ReviewCard(
      itemId: 'overdue',
      repetitions: 8,
      intervalDays: 30,
      lapses: 100,
      failures: 1000,
      difficulty: 2.5,
      stabilityDays: 1,
      dueAt: now.subtract(const Duration(days: 365)),
      lastReviewedAt: now.subtract(const Duration(days: 365)),
    );

    expect(Srs.reviewPriority(card, now: now), inInclusiveRange(0.0, 2.0));
  });

  test('failed review is immediately due and increments lapse evidence', () {
    final card = ReviewCard(
      itemId: 'failure',
      repetitions: 4,
      intervalDays: 12,
      stabilityDays: 12,
      dueAt: now,
      lastReviewedAt: now.subtract(const Duration(days: 1)),
    );

    final updated = Srs.update(
      card,
      correct: false,
      hinted: false,
      now: now,
    );

    expect(updated.dueAt, now);
    expect(updated.repetitions, 0);
    expect(updated.lapses, 1);
    expect(updated.failures, 1);
  });

  test('hinted success never schedules farther than unhinted success', () {
    final card = ReviewCard(
      itemId: 'hint-bound',
      repetitions: 1,
      intervalDays: 2,
      stabilityDays: 2,
      dueAt: now,
      lastReviewedAt: now.subtract(const Duration(days: 1)),
    );

    final hinted = Srs.update(card, correct: true, hinted: true, now: now);
    final unhinted = Srs.update(card, correct: true, hinted: false, now: now);

    expect(
      hinted.dueAt.difference(now),
      lessThanOrEqualTo(unhinted.dueAt.difference(now)),
    );
  });
}
