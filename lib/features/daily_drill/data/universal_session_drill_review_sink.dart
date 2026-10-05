import '../../../core/content_contract.dart';
import '../../../core/srs_facets.dart';
import '../../gamification/gamification_repository.dart';
import '../../session/universal_session_orchestrator.dart';
import '../domain/daily_drill_models.dart';
import '../domain/daily_drill_repository.dart';

final class UniversalSessionDrillReviewSink implements DailyDrillReviewSink {
  const UniversalSessionDrillReviewSink({
    required UniversalSessionOrchestrator orchestrator,
    required GamificationRepository gamificationRepository,
  })  : _orchestrator = orchestrator,
        _gamificationRepository = gamificationRepository;

  final UniversalSessionOrchestrator _orchestrator;
  final GamificationRepository _gamificationRepository;

  @override
  Future<DailyDrillReviewReceipt> record({
    required LearningContent item,
    required bool correct,
    required int seconds,
  }) async {
    final snapshot = await _orchestrator.record(
      SessionReviewInput<LearningContent>(
        item: item,
        answer: correct ? 'quick_recall:remembered' : 'quick_recall:missed',
        correct: correct,
        seconds: seconds.clamp(1, 3600).toInt(),
        hinted: false,
        facetType: ReviewFacetType.meaningRecall,
        skillOverride: item.skill,
      ),
    );
    final gamification = await _gamificationRepository.loadSnapshot();
    return DailyDrillReviewReceipt(
      currentStreak: gamification.profile.currentStreak,
      sessionXp: snapshot.sessionXp,
    );
  }
}
