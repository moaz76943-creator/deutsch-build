import '../../../core/content_contract.dart';
import '../../../core/srs/srs_models.dart';
import '../../../domain/adaptive_agent/adaptive_srs_agent.dart';
import '../../../language/language_content_intelligence.dart';
import '../../../models/learner.dart';
import '../../../models/mistake.dart';
import '../../../services/mistake_engine.dart';

final class LearnerDashboardBundle {
  final LearnerDashboardAnalytics analytics;
  final Map<String, MistakeRecord> mistakesByItem;

  const LearnerDashboardBundle({
    required this.analytics,
    required this.mistakesByItem,
  });
}

/// Bridges persisted learner evidence into the pure dashboard domain.
abstract final class DashboardAnalyticsBuilder {
  static LearnerDashboardBundle build<T extends LearningContent>({
    required LearnerState state,
    required List<T> corpus,
    required LanguageContentIntelligence contentIntelligence,
    required DateTime nowUtc,
    int timezoneOffsetMinutes = 0,
    int reviewLimit = 10,
  }) {
    if (!nowUtc.isUtc) {
      throw ArgumentError('nowUtc must be in UTC');
    }

    final report = MistakeEngine.from(
      state.attempts,
      corpus,
      now: nowUtc,
    );
    final srsStates = <String, SrsItemState>{};
    for (final card in state.meaningReviewCards) {
      srsStates[card.itemId] = SrsItemState(
        intervalDays: card.intervalDays,
        repetitions: card.repetitions,
        dueDate: card.dueAt.toUtc(),
        lastReviewedDate: card.lastReviewedAt?.toUtc(),
        state: _cardState(card.memoryState),
      );
    }

    final levels = <String, String>{};
    final skills = <String, String>{};
    final labels = <String, String>{};
    for (final item in corpus) {
      levels[item.id] = _levelCode(contentIntelligence.profile(item).inferredLevel);
      skills[item.id] = item.skill;
      labels[item.id] = item.grammaticalMarker.trim().isEmpty
          ? item.sourceText
          : '${item.grammaticalMarker} ${item.sourceText}';
    }

    final masteredIds = <String>{
      for (final entry in srsStates.entries)
        if (entry.value.state == CardState.mastered) entry.key,
    };
    final correctAttempts = state.attempts.where((a) => a.correct).length;
    final analytics = AdaptiveSrsAgent().analyze(
      activityTimesUtc: state.attempts.map((a) => a.at.toUtc()),
      mistakes: report.items,
      states: srsStates,
      totalAttempts: state.attempts.length,
      correctAttempts: correctAttempts,
      curriculumLevelByItem: levels,
      masteredItemIds: masteredIds,
      nowUtc: nowUtc,
      timezoneOffsetMinutes: timezoneOffsetMinutes,
      reviewLimit: reviewLimit,
      skillByItem: skills,
      displayLabelByItem: labels,
    );

    return LearnerDashboardBundle(
      analytics: analytics,
      mistakesByItem: Map<String, MistakeRecord>.unmodifiable(
        {for (final mistake in report.items) mistake.itemId: mistake},
      ),
    );
  }

  static CardState _cardState(MemoryState state) => switch (state) {
        MemoryState.newCard => CardState.newCard,
        MemoryState.learning || MemoryState.relearning => CardState.learning,
        MemoryState.young => CardState.reviewing,
        MemoryState.mature => CardState.mastered,
      };

  static String _levelCode(ContentLevel level) => switch (level) {
        ContentLevel.a1 => 'A1',
        ContentLevel.a2 => 'A2',
        ContentLevel.b1 => 'B1',
        ContentLevel.unknown => 'unknown',
      };
}
