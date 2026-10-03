import '../models/learner.dart';
import '../core/date_utils.dart';

enum TeacherActionType { baseline, review, repair, newContent, consolidation }

class TeacherAction {
  final TeacherActionType type;
  final String skill;
  final String title;
  final String reason;
  final int itemCount;
  final double confidence;
  final double reviewPressure;
  final double newContentReadiness;
  final double recentFailureRate;
  const TeacherAction({
    required this.type,
    required this.skill,
    required this.title,
    required this.reason,
    required this.itemCount,
    this.confidence = .5,
    this.reviewPressure = 0,
    this.newContentReadiness = 1,
    this.recentFailureRate = 0,
  });
}

class AdaptiveTeacher {
  static const skills = ['recall', 'listening', 'production', 'transfer'];

  static TeacherAction next(LearnerState state, {DateTime? now}) {
    final at = now ?? DateTime.now();
    final meaningAttempts = state.meaningAttempts.toList(growable: false);
    final attemptsBySkill = <String, List<Attempt>>{};
    var recentFailureCount = 0;
    var recentAttemptCount = 0;
    for (final a in meaningAttempts) {
      (attemptsBySkill[a.skill] ??= <Attempt>[]).add(a);
      if (at.toUtcMidnight.difference(a.at.toUtcMidnight).inDays <= 14) {
        recentAttemptCount++;
        if (!a.correct) recentFailureCount++;
      }
    }
    final scoresBySkill = <String, double>{};
    for (final skill in skills) {
      scoresBySkill[skill] = _scoreForAttempts(attemptsBySkill[skill]);
    }
    final recentFailureRate =
        recentAttemptCount == 0 ? 0.0 : recentFailureCount / recentAttemptCount;
    final due = _dueCount(state, at);
    final reviewPressure = _reviewPressure(state, at, due);
    final newContentReadiness = _newContentReadiness(
      recentFailureRate,
      reviewPressure,
    );
    final weak = _weakest(state, attemptsBySkill, scoresBySkill);

    if (due > 0 || state.review.isNotEmpty) {
      final count = due.clamp(2, 10).toInt();
      return TeacherAction(
        type: TeacherActionType.review,
        skill: weak,
        title: 'مراجعة مستحقة',
        reason: reviewPressure >= .7
            ? 'ضغط المراجعة مرتفع؛ سنخفض الحمل الجديد ونثبت العناصر المعرضة للنسيان أولًا.'
            : 'لديك عناصر حان وقت تثبيتها قبل إضافة حمل جديد.',
        itemCount: count,
        confidence: _confidence(state),
        reviewPressure: reviewPressure,
        newContentReadiness: newContentReadiness,
        recentFailureRate: recentFailureRate,
      );
    }
    if (state.attempts.isEmpty) {
      return const TeacherAction(
        type: TeacherActionType.baseline,
        skill: 'recall',
        title: 'قياس البداية',
        reason: 'سنقيس أكثر من مهارة قبل بناء الخطة الشخصية.',
        itemCount: 8,
        confidence: .35,
        reviewPressure: 0,
        newContentReadiness: .5,
      );
    }
    final score = scoresBySkill[weak] ?? .5;
    if (score < .62 || recentFailureRate >= .60) {
      return TeacherAction(
        type: TeacherActionType.repair,
        skill: weak,
        title: 'علاج نقطة الضعف',
        reason: recentFailureRate >= .60
            ? 'الأخطاء الحديثة مرتفعة؛ سنوقف التوسع مؤقتًا ونركز على إصلاح السبب.'
            : 'أداؤك الحديث في هذه المهارة منخفض، لذلك سنركز عليها الآن.',
        itemCount: recentFailureRate >= .60 ? 5 : 8,
        confidence: _confidence(state),
        reviewPressure: reviewPressure,
        newContentReadiness: newContentReadiness,
        recentFailureRate: recentFailureRate,
      );
    }
    if (score < .82 || recentFailureRate >= .40) {
      return TeacherAction(
        type: TeacherActionType.consolidation,
        skill: weak,
        title: 'تثبيت المهارة',
        reason:
            'المهارة تتحسن، لكنها تحتاج تنويعًا ومزيدًا من الاسترجاع قبل رفع الصعوبة.',
        itemCount: 6,
        confidence: _confidence(state),
        reviewPressure: reviewPressure,
        newContentReadiness: newContentReadiness,
        recentFailureRate: recentFailureRate,
      );
    }
    return TeacherAction(
      type: TeacherActionType.newContent,
      skill: weak,
      title: 'محتوى جديد محسوب',
      reason: newContentReadiness < .75
          ? 'الأداء جيد، لكننا سنضيف محتوى جديدًا تدريجيًا مع الحفاظ على التثبيت.'
          : 'المهارات المقاسة مستقرة بما يكفي لإضافة محتوى جديد تدريجيًا.',
      itemCount: newContentReadiness >= .75 ? 8 : 6,
      confidence: _confidence(state),
      reviewPressure: reviewPressure,
      newContentReadiness: newContentReadiness,
      recentFailureRate: recentFailureRate,
    );
  }

  static String _weakest(
    LearnerState state,
    Map<String, List<Attempt>> attemptsBySkill,
    Map<String, double> scoresBySkill,
  ) {
    var selected = 'recall';
    var selectedScore = 1.0;
    var measured = false;
    for (final skill in skills) {
      final attempts = attemptsBySkill[skill];
      if (attempts == null || attempts.length < 2) continue;
      measured = true;
      final score = scoresBySkill[skill] ?? .5;
      if (score < selectedScore) {
        selectedScore = score;
        selected = skill;
      }
    }
    if (measured) return selected;
    return state.meaningAttempts.isEmpty
        ? 'recall'
        : state.meaningAttempts.last.skill;
  }

  static double _scoreForAttempts(List<Attempt>? attempts) {
    if (attempts == null || attempts.isEmpty) return .5;
    final recent = attempts.length > 20
        ? attempts.sublist(attempts.length - 20)
        : attempts;
    var weight = 1.0;
    var total = 0.0;
    var score = 0.0;
    for (final attempt in recent.reversed) {
      final hintPenalty = attempt.hinted ? .82 : 1.0;
      score += (attempt.correct ? 1 : 0) * weight * hintPenalty;
      total += weight;
      weight *= .93;
    }
    return total == 0 ? .5 : (score / total).clamp(0.0, 1.0);
  }

  static int _dueCount(LearnerState state, DateTime now) {
    var due = 0;
    for (final card in state.meaningReviewCards) {
      if (!card.dueAt.isAfter(now)) due++;
    }
    return due;
  }

  static double _reviewPressure(
    LearnerState state,
    DateTime now,
    int dueCount,
  ) {
    final total = state.meaningReviewCards.length;
    if (total == 0) return 0;
    final dueRatio = dueCount / total;
    var recentFailureCount = 0;
    var recentAttemptCount = 0;
    for (final a in state.attempts) {
      if (now.toUtcMidnight.difference(a.at.toUtcMidnight).inDays <= 14) {
        recentAttemptCount++;
        if (!a.correct) recentFailureCount++;
      }
    }
    final failureRatio =
        recentAttemptCount == 0 ? 0.0 : recentFailureCount / recentAttemptCount;
    return (dueRatio * .6 + failureRatio * .4).clamp(0.0, 1.0);
  }

  static double _newContentReadiness(
    double recentFailureRate,
    double reviewPressure,
  ) {
    if (recentFailureRate >= .60 || reviewPressure >= .85) return 0;
    if (recentFailureRate >= .40 || reviewPressure >= .65) return .35;
    if (recentFailureRate >= .20 || reviewPressure >= .40) return .70;
    return 1.0;
  }

  static double _confidence(LearnerState state) {
    final attempts = state.meaningAttempts.length;
    return (attempts / 40).clamp(.35, .95).toDouble();
  }
}
