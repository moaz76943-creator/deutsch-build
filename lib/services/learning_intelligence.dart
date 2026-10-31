import '../core/content_contract.dart';
import '../models/learner.dart';
import '../language/language_content_intelligence.dart';
import '../models/mistake.dart';
import 'adaptive_teacher.dart';
import 'mastery.dart';
import 'memory.dart';
import 'mistake_engine.dart';
import 'srs.dart';

/// V126: one bounded decision layer for the learning engines.
/// It does not replace SRS, mastery or mistake analysis; it reconciles them
/// into one actionable recommendation for a content item.
class LearningDecision {
  final String itemId;
  final String recommendedMode;
  final double priority;
  final String reason;
  final bool newContentAllowed;
  final double mastery;
  final double retrievability;
  final double mistakePressure;

  const LearningDecision({
    required this.itemId,
    required this.recommendedMode,
    required this.priority,
    required this.reason,
    required this.newContentAllowed,
    required this.mastery,
    required this.retrievability,
    required this.mistakePressure,
  });
}

class LearningIntelligence {
  static List<LearningDecision> rankSession(
    List<LearningContent> items,
    LearnerState state, {
    required LanguageContentIntelligence contentIntelligence,
    DateTime? now,
    int limit = 20,
  }) {
    final at = now ?? DateTime.now();
    final teacher = AdaptiveTeacher.next(state, now: at);
    final meaningAttempts = state.meaningAttempts.toList(growable: false);
    final mistakes = MistakeEngine.from(meaningAttempts, items, now: at).items;
    final mistakeById = {for (final m in mistakes) m.itemId: m};
    final dueIds = {
      for (final card in MemoryQueue.rank(
        state.meaningReviewCards,
        now: at,
        limit: 100,
      ))
        card.itemId,
    };
    final attemptsByItem = <String, List<Attempt>>{};
    for (final attempt in meaningAttempts) {
      (attemptsByItem[attempt.itemId] ??= <Attempt>[]).add(attempt);
    }
    final ranked = <LearningDecision>[];
    final cap = limit.clamp(1, 100).toInt();
    for (final item in items) {
      final decision = decide(
        item: item,
        state: state,
        attempts: attemptsByItem[item.id] ?? const <Attempt>[],
        teacher: teacher,
        mistake: mistakeById[item.id],
        contentIntelligence: contentIntelligence,
        now: at,
      );
      final adjusted = dueIds.contains(item.id)
          ? LearningDecision(
              itemId: decision.itemId,
              recommendedMode: 'review',
              priority: (decision.priority + 20).clamp(0.0, 200.0).toDouble(),
              reason: decision.reason,
              newContentAllowed: decision.newContentAllowed,
              mastery: decision.mastery,
              retrievability: decision.retrievability,
              mistakePressure: decision.mistakePressure,
            )
          : decision;
      ranked.add(adjusted);
      if (ranked.length > cap * 2) {
        ranked.sort((a, b) => b.priority.compareTo(a.priority));
        ranked.removeRange(cap, ranked.length);
      }
    }
    ranked.sort((a, b) => b.priority.compareTo(a.priority));
    return ranked.take(cap).toList(growable: false);
  }

  static LearningDecision decide({
    required LearningContent item,
    required LearnerState state,
    required List<Attempt> attempts,
    required TeacherAction teacher,
    MistakeRecord? mistake,
    required LanguageContentIntelligence contentIntelligence,
    DateTime? now,
  }) {
    final at = now ?? DateTime.now();
    final card = state.reviewCards[item.id];
    final evidence = Mastery.forItemRows(
      item.id,
      attempts,
      reviewCard: card,
      now: at,
    );
    final profile = contentIntelligence.profile(item);
    final retrievability = card == null ? 0.0 : _safeRetrievability(card, at);
    final mistakePressure = mistake == null
        ? 0.0
        : ((mistake.severity / 100) * .55 + mistake.recentFailureRate * .45)
            .clamp(0.0, 1.0)
            .toDouble();
    final newAllowed = teacher.newContentReadiness >= .55 &&
        teacher.reviewPressure < .75 &&
        teacher.recentFailureRate < .45;

    var mode = 'new';
    var priority = 25.0;
    var reason = 'محتوى جديد مناسب لجاهزية التعلم الحالية.';
    if (card != null && !card.dueAt.isAfter(at)) {
      mode = 'review';
      priority = 120 + MemoryQueue.priority(card, at);
      reason = 'مراجعة مستحقة؛ نحمي الذاكرة قبل إضافة حمل جديد.';
    } else if (mistake != null && mistakePressure >= .38) {
      mode = _modeForMistake(mistake.category);
      if (mistake.recentFailureRate >= .60) mode = 'repair';
      priority = 85 + mistake.severity * .65 + mistake.recentFailureRate * 30;
      reason = mistake.diagnosis;
    } else if (evidence.skillScores.isNotEmpty &&
        evidence.nextAction != 'consolidate') {
      mode = evidence.nextAction;
      priority = 65 + (1 - evidence.overall) * 45;
      reason = 'الإتقان غير مكتمل؛ نركز على ${evidence.nextAction} بدل التوسع.';
    } else if (!newAllowed && attempts.isEmpty) {
      mode = 'consolidate';
      priority = 48 + teacher.reviewPressure * 20;
      reason = 'نؤجل المحتوى الجديد لأن ضغط المراجعة أو الأخطاء الحديثة مرتفع.';
    } else if (profile.inferredLevel == ContentLevel.b1 &&
        teacher.newContentReadiness < .75) {
      mode = 'consolidate';
      priority = 42;
      reason = 'محتوى أعلى صعوبة؛ نؤجله حتى ترتفع جاهزية المحتوى الجديد.';
    } else if (evidence.isMastered) {
      mode = 'consolidate';
      priority = 40 + (1 - retrievability) * 30;
      reason = 'العنصر متقن؛ نستخدمه للتثبيت والسياق بدل التكرار الخام.';
    }

    return LearningDecision(
      itemId: item.id,
      recommendedMode: mode,
      priority: priority.clamp(0.0, 200.0).toDouble(),
      reason: reason,
      newContentAllowed: newAllowed,
      mastery: evidence.overall,
      retrievability: retrievability,
      mistakePressure: mistakePressure,
    );
  }

  static double _safeRetrievability(ReviewCard card, DateTime now) =>
      SrsAdapter.retrievability(card, now);

  static String _modeForMistake(MistakeCategory category) {
    switch (category) {
      case MistakeCategory.article:
      case MistakeCategory.vocabulary:
        return 'recall';
      case MistakeCategory.listening:
        return 'listening';
      case MistakeCategory.production:
      case MistakeCategory.writing:
        return 'production';
      case MistakeCategory.translation:
      case MistakeCategory.grammar:
      case MistakeCategory.wordOrder:
        return 'transfer';
    }
  }
}

/// Tiny adapter keeps the decision layer independent of SRS implementation
/// details and gives us one seam for future retention-model upgrades.
class SrsAdapter {
  static double retrievability(ReviewCard card, DateTime now) =>
      Srs.retrievability(card, now: now);
}
