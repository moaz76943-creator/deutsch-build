import 'domain/gamification_models.dart';
import 'domain/gamification_review_sink.dart';

abstract interface class GamificationRepository
    implements GamificationReviewSink {
  Future<GamificationSnapshot> loadSnapshot();
  Future<void> close();
}

final class UnavailableGamificationRepository
    implements GamificationRepository {
  const UnavailableGamificationRepository();

  @override
  Future<void> recordReview(GamificationReviewEvent event) async {}

  @override
  Future<void> clearGamification() async {}

  @override
  Future<GamificationSnapshot> loadSnapshot() async =>
      const GamificationSnapshot(
        profile: GamificationProfile(),
        unlocked: <UnlockedMilestone>[],
        badges: GamificationMilestones.defaults,
      );

  @override
  Future<void> close() async {}
}
