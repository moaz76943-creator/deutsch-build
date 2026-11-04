import 'package:deutsch_bilarabi/core/srs_scheduler.dart';
import 'package:deutsch_bilarabi/core/srs_facets.dart';
import 'package:deutsch_bilarabi/models/learner.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
      'scheduler preserves facet identity, input state and injected review clock',
      () {
    final now = DateTime.utc(2026, 11, 4, 12);
    final original = ReviewCard(
        itemId: 'test-only',
        facetType: ReviewFacetType.gender,
        variantKey: 'noun',
        dueAt: now);
    final reviewed = unifiedSrsScheduler.schedule(original,
        correct: true, hinted: false, now: now);
    expect(original.repetitions, 0);
    expect(reviewed.repetitions, 1);
    expect(reviewed.facetType, ReviewFacetType.gender);
    expect(reviewed.variantKey, 'noun');
    expect(reviewed.lastReviewedAt, now);
    expect(reviewed.dueAt.isAfter(now), isTrue);
    expect(unifiedSrsScheduler.xpRewardForReview(correct: true, hinted: false),
        10);
    expect(
        unifiedSrsScheduler.xpRewardForReview(correct: true, hinted: true), 6);
    expect(unifiedSrsScheduler.xpRewardForReview(correct: false, hinted: false),
        2);
  });
}
