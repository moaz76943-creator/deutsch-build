import '../models/learner.dart';
import 'srs.dart';

abstract interface class SrsScheduler {
  ReviewCard schedule(
    ReviewCard current, {
    required bool correct,
    required bool hinted,
    DateTime? now,
  });
}

/// Single scheduling contract for active learner-review paths.
///
/// Facets change WHAT is remembered; this scheduler continues to own WHEN the
/// memory returns. It deliberately delegates to the established Srs algorithm.
final class UnifiedSrsScheduler implements SrsScheduler {
  const UnifiedSrsScheduler();

  @override
  ReviewCard schedule(
    ReviewCard current, {
    required bool correct,
    required bool hinted,
    DateTime? now,
  }) => Srs.update(
    current,
    correct: correct,
    hinted: hinted,
    now: now,
  );

  int xpRewardForReview({
    required bool correct,
    required bool hinted,
  }) {
    if (!correct) return 2;
    return hinted ? 6 : 10;
  }
}

const UnifiedSrsScheduler unifiedSrsScheduler = UnifiedSrsScheduler();
