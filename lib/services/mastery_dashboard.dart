import '../core/content_contract.dart';
import '../language/language_content_intelligence.dart';
import '../models/learner.dart';
import 'mastery.dart';
import 'srs.dart';

/// V124: a decision-oriented mastery snapshot, not a cosmetic progress meter.
class MasteryDashboardSnapshot {
  final double readiness;
  final double retentionRisk;
  final double retrievability;
  final double evidenceStrength;
  final String weakestSkill;
  final String nextAction;
  final int nextReviewDays;
  final int masteredItems;
  final int measuredItems;
  final int dueItems;
  final int overdueItems;
  final int activeErrorItems;
  final List<String> priorityItemIds;
  final ContentIntelligenceReport contentReport;

  const MasteryDashboardSnapshot({
    required this.readiness,
    required this.retentionRisk,
    required this.retrievability,
    required this.evidenceStrength,
    required this.weakestSkill,
    required this.nextAction,
    required this.nextReviewDays,
    required this.masteredItems,
    required this.measuredItems,
    required this.dueItems,
    required this.overdueItems,
    required this.activeErrorItems,
    required this.priorityItemIds,
    required this.contentReport,
  });

  String get readinessLabel => readiness >= .85
      ? 'جاهز'
      : readiness >= .65
          ? 'قريب'
          : readiness >= .45
              ? 'يحتاج تثبيتًا'
              : 'يحتاج علاجًا';
  String get actionLabel =>
      const {
        'review': 'راجع العناصر المعرضة للنسيان',
        'learn': 'ابدأ بناء الدليل',
        'recall': 'قوِّ التعرّف',
        'listening': 'قوِّ الاستماع',
        'production': 'قوِّ الإنتاج',
        'transfer': 'قوِّ النقل إلى سياقات جديدة',
        'consolidate': 'ثبّت ما تعلمته قبل التوسع',
      }[nextAction] ??
      nextAction;
}

class MasteryDashboard {
  static MasteryDashboardSnapshot build(
    LearnerState state, {
    required List<LearningContent> corpus,
    required LanguageContentIntelligence contentIntelligence,
    DateTime? now,
  }) {
    final at = now ?? DateTime.now();
    final items = corpus;
    final report = contentIntelligence.analyze(items);
    final cards = state.meaningReviewCards.toList(growable: false);
    final due = cards.where((c) => !c.dueAt.isAfter(at)).length;
    final overdue = cards.where((c) => c.dueAt.isBefore(at)).length;

    var retrievabilitySum = 0.0;
    var retentionSum = 0.0;
    var measured = 0;
    var mastered = 0;
    var activeErrors = 0;
    final skillTotals = <String, double>{};
    final skillCounts = <String, int>{};
    final priorities = <String, double>{};
    final attemptsByItem = <String, List<Attempt>>{};
    for (final attempt in state.meaningAttempts) {
      (attemptsByItem[attempt.itemId] ??= <Attempt>[]).add(attempt);
    }

    final activeItemIds = <String>{
      ...attemptsByItem.keys,
      ...state.meaningReviewCards.map((card) => card.itemId),
    };
    for (final itemId in activeItemIds) {
      final itemAttempts = attemptsByItem[itemId] ?? const <Attempt>[];
      final card = state.reviewCards[itemId];
      final evidence = Mastery.forItemRows(
        itemId,
        itemAttempts,
        reviewCard: card,
        now: at,
      );
      if (evidence.skillScores.isNotEmpty) {
        measured++;
        if (evidence.isMastered) mastered++;
        for (final entry in evidence.skillScores.entries) {
          skillTotals[entry.key] = (skillTotals[entry.key] ?? 0) + entry.value;
          skillCounts[entry.key] = (skillCounts[entry.key] ?? 0) + 1;
        }
      }
      final recentStart = itemAttempts.length > 6 ? itemAttempts.length - 6 : 0;
      var recentErrors = 0;
      for (var i = recentStart; i < itemAttempts.length; i++) {
        if (!itemAttempts[i].correct) recentErrors++;
      }
      if (recentErrors >= 2) activeErrors++;
      if (card != null) {
        retrievabilitySum += Srs.retrievability(card, now: at);
        retentionSum += Mastery.retentionForCard(card);
        priorities[itemId] = Srs.reviewPriority(card, now: at);
      }
    }

    final cardCount = cards.length;
    final retrievability = cardCount == 0
        ? (state.learned.isEmpty ? 0.0 : .82)
        : retrievabilitySum / cardCount;
    final retention = cardCount == 0
        ? (state.learned.isEmpty ? 0.0 : .55)
        : retentionSum / cardCount;
    final skillScores = <String, double>{};
    for (final skill in const [
      'recall',
      'listening',
      'production',
      'transfer',
    ]) {
      final n = skillCounts[skill] ?? 0;
      if (n > 0) skillScores[skill] = (skillTotals[skill] ?? 0) / n;
    }
    final weakest = _weakest(skillScores);
    final evidenceStrength = _evidenceStrength(state, measured);
    final readiness = (skillScores.isEmpty
            ? evidenceStrength * .55 + retrievability * .45
            : skillScores.values.reduce((a, b) => a + b) /
                    skillScores.length *
                    .55 +
                retrievability * .25 +
                retention * .20)
        .clamp(0.0, 1.0)
        .toDouble();
    final retentionRisk = (1 - retrievability) * .72 +
        (due == 0 ? 0 : (due / (cardCount == 0 ? due : cardCount)) * .28);
    final nextAction = _nextAction(
      skillScores,
      retrievability,
      retention,
      state.meaningAttempts.toList(growable: false),
    );
    final nextReviewDays = retrievability <= 0
        ? 0
        : retrievability < .45
            ? 0
            : retrievability < .60
                ? 1
                : retrievability < .75
                    ? 2
                    : retrievability < .85
                        ? 4
                        : 7;
    final ordered = priorities.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return MasteryDashboardSnapshot(
      readiness: readiness,
      retentionRisk: retentionRisk.clamp(0.0, 1.0).toDouble(),
      retrievability: retrievability.clamp(0.0, 1.0).toDouble(),
      evidenceStrength: evidenceStrength,
      weakestSkill: weakest,
      nextAction: nextAction,
      nextReviewDays: nextReviewDays,
      masteredItems: mastered,
      measuredItems: measured,
      dueItems: due,
      overdueItems: overdue,
      activeErrorItems: activeErrors,
      priorityItemIds:
          ordered.take(8).map((x) => x.key).toList(growable: false),
      contentReport: report,
    );
  }

  static double _evidenceStrength(LearnerState state, int measuredItems) {
    final attempts = state.meaningAttempts.length;
    return ((attempts / 60) * .55 + (measuredItems / 40) * .45)
        .clamp(0.0, 1.0)
        .toDouble();
  }

  static String _weakest(Map<String, double> scores) {
    if (scores.isEmpty) return 'recall';
    return scores.entries.reduce((a, b) => a.value <= b.value ? a : b).key;
  }

  static String _nextAction(
    Map<String, double> scores,
    double retrievability,
    double retention,
    List<Attempt> attempts,
  ) {
    if (retrievability < .45) return 'review';
    if (scores.isEmpty) return attempts.isEmpty ? 'learn' : 'recall';
    final weak = _weakest(scores);
    if ((scores[weak] ?? 0) < .65) return weak;
    if (retention < .65) return 'review';
    return 'consolidate';
  }
}
