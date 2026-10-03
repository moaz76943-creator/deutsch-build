import 'content_contract.dart';
import '../models/learner.dart';
import 'memory.dart';
import 'mastery.dart';

class DailyFocus {
  final int attempts;
  final int correct;
  final int due;
  final int goal;
  const DailyFocus({
    required this.attempts,
    required this.correct,
    required this.due,
    this.goal = 10,
  });
  double get progress => (attempts / goal).clamp(0, 1).toDouble();
  double get accuracy => attempts == 0 ? 0 : correct / attempts;
  factory DailyFocus.from(LearnerState s) {
    final now = DateTime.now();
    final a = s.attempts
        .where(
          (x) =>
              x.at.year == now.year &&
              x.at.month == now.month &&
              x.at.day == now.day,
        )
        .toList();
    return DailyFocus(
      attempts: a.length,
      correct: a.where((x) => x.correct).length,
      due: s.review.length,
    );
  }
}

class LearningCore {
  static List<T> due<T extends LearningContent>(
    LearnerState s,
    Iterable<T> corpus, {
    required bool Function(T item) isLearnable,
    DateTime? now,
  }) {
    final at = now ?? DateTime.now();
    final dueIds = MemoryQueue.rank(s.meaningReviewCards, now: at, limit: 30);
    final dueItems = <T>[];
    for (final card in dueIds) {
      final item = _byId(corpus, card.itemId);
      if (item != null && isLearnable(item)) {
        dueItems.add(item);
      }
    }
    if (dueItems.isNotEmpty) return dueItems;
    final items = corpus.toList(growable: false);
    final legacy = items
        .where((x) => s.review.contains(x.id) && isLearnable(x))
        .take(20)
        .toList();
    if (legacy.isNotEmpty) return legacy;
    final weak = weakestSkill(s);
    final focused = <T>[];
    final fallback = <T>[];
    for (final item in items) {
      if (s.learned.contains(item.id) || !isLearnable(item)) continue;
      if (item.skill == weak) {
        if (focused.length < 30) focused.add(item);
      } else if (fallback.length < 30) {
        fallback.add(item);
      }
      if (focused.length >= 30 && fallback.length >= 30) break;
    }
    return [...focused, ...fallback].take(30).toList(growable: false);
  }

  static T? _byId<T extends LearningContent>(Iterable<T> corpus, String id) {
    for (final item in corpus) {
      if (item.id == id) return item;
    }
    return null;
  }

  static Map<String, List<Attempt>> _attemptsBySkill(LearnerState s) {
    final buckets = <String, List<Attempt>>{};
    for (final attempt in s.meaningAttempts) {
      (buckets[attempt.skill] ??= <Attempt>[]).add(attempt);
    }
    return buckets;
  }

  static String weakestSkill(LearnerState s) {
    const skills = ['recall', 'listening', 'production', 'transfer'];
    final attemptsBySkill = _attemptsBySkill(s);
    var best = 'recall';
    var value = 2.0;
    for (final skill in skills) {
      final a = attemptsBySkill[skill] ?? const <Attempt>[];
      if (a.length < 2) continue;
      final start = a.length > 12 ? a.length - 12 : 0;
      double weight = 1.0, total = 0, score = 0;
      for (var i = a.length - 1; i >= start; i--) {
        final x = a[i];
        score += (x.correct ? 1 : 0) * weight;
        total += weight;
        weight *= .92;
      }
      final measured = total == 0 ? 0.5 : score / total;
      if (measured < value) {
        value = measured;
        best = skill;
      }
    }
    return best;
  }

  static T? weakestItemForSkill<T extends LearningContent>(
    LearnerState s,
    String skill,
    Iterable<T> corpus, {
    required bool Function(T item) isLearnable,
    DateTime? now,
  }) {
    final attemptsByItem = <String, List<Attempt>>{};
    for (final attempt in s.attempts) {
      (attemptsByItem[attempt.itemId] ??= <Attempt>[]).add(attempt);
    }
    final at = now ?? DateTime.now();
    T? best;
    T? fallback;
    var bestScore = double.infinity;
    final items = corpus.toList(growable: false);
    for (final item in items) {
      if (item.skill != skill || !isLearnable(item)) continue;
      final itemAttempts = attemptsByItem[item.id];
      if (itemAttempts == null || itemAttempts.isEmpty) {
        fallback ??= item;
        continue;
      }
      final evidence = Mastery.forItemRows(
        item.id,
        itemAttempts,
        reviewCard: s.reviewCards[item.id],
        now: at,
      );
      final score = evidence.skillScores.isEmpty
          ? 0.0
          : (evidence.overall * .70 + evidence.retention * .30)
              .clamp(0.0, 1.0)
              .toDouble();
      if (best == null || score < bestScore) {
        best = item;
        bestScore = score;
        if (bestScore <= 0) break;
      }
    }
    return best ?? fallback;
  }

  static Map<String, double> skillScores(LearnerState s) {
    const skills = ['recall', 'listening', 'production', 'transfer'];
    final attemptsBySkill = _attemptsBySkill(s);
    return {
      for (final k in skills)
        k: _score(attemptsBySkill[k] ?? const <Attempt>[]),
    };
  }

  static double _score(List<Attempt> a) {
    if (a.isEmpty) return 0;
    final start = a.length > 20 ? a.length - 20 : 0;
    double w = 1, total = 0, score = 0;
    for (var i = a.length - 1; i >= start; i--) {
      final x = a[i];
      score += (x.correct ? 1 : 0) * w;
      total += w;
      w *= .94;
    }
    return total == 0 ? 0 : _clamp(score / total);
  }

  static double _clamp(double x) => x < 0
      ? 0
      : x > 1
          ? 1
          : x;
  static bool proofMastered(LearnerState s, String id) {
    final a =
        s.meaningAttempts.where((x) => x.itemId == id && x.correct).toList();
    final skills = a.map((x) => x.skill).toSet();
    return skills.containsAll([
          'recall',
          'listening',
          'production',
          'transfer',
        ]) &&
        a.length >= 5 &&
        !s.review.contains(id);
  }
}

class NextAction {
  final String skill, title, reason, cta;
  const NextAction(this.skill, this.title, this.reason, this.cta);
  factory NextAction.from(LearnerState s) {
    if (s.attempts.isEmpty)
      return const NextAction(
        'baseline',
        'اختبار البداية',
        'سنقيس مهاراتك أولًا بدل التخمين.',
        'ابدأ الاختبار',
      );
    if (s.review.isNotEmpty)
      return const NextAction(
        'review',
        'مراجعة ذكية',
        'لديك أخطاء لم تثبت قدرتك على تجاوزها بعد.',
        'ابدأ المراجعة',
      );
    final k = LearningCore.weakestSkill(s);
    const labels = {
      'recall': 'التعرّف',
      'listening': 'الاستماع',
      'production': 'الإنتاج',
      'transfer': 'النقل',
    };
    return NextAction(
      k,
      'درّب ${labels[k]}',
      'هذه أضعف مهارة مقاسة لديك حاليًا.',
      'ابدأ التدريب',
    );
  }
}

class WeeklyReport {
  final int attempts, correct, learned, reviews;
  final double accuracy;
  const WeeklyReport({
    required this.attempts,
    required this.correct,
    required this.learned,
    required this.reviews,
    required this.accuracy,
  });
  factory WeeklyReport.from(LearnerState s) {
    final since = DateTime.now().subtract(const Duration(days: 7));
    final a = s.attempts.where((x) => x.at.isAfter(since)).toList();
    return WeeklyReport(
      attempts: a.length,
      correct: a.where((x) => x.correct).length,
      learned: s.learned.length,
      reviews: s.review.length,
      accuracy: a.isEmpty ? 0 : a.where((x) => x.correct).length / a.length,
    );
  }
}
