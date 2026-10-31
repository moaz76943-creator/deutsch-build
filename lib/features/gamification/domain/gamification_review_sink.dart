import 'gamification_models.dart';

abstract interface class GamificationReviewSink {
  Future<void> recordReview(GamificationReviewEvent event);
  Future<void> clearGamification();
}

final class NoopGamificationReviewSink implements GamificationReviewSink {
  const NoopGamificationReviewSink();

  @override
  Future<void> recordReview(GamificationReviewEvent event) async {}

  @override
  Future<void> clearGamification() async {}
}
