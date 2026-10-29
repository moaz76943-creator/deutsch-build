import '../core/content_contract.dart';
import '../models/mistake.dart';
import '../models/learner.dart';
import '../core/date_utils.dart';

class MistakeEngine {
  static MistakeReport from(
    List<Attempt> attempts,
    List<LearningContent> content, {
    DateTime? now,
  }) {
    final at = now ?? DateTime.now();
    final grouped = <String, List<Attempt>>{};
    for (final a in attempts) {
      if (a.itemId.trim().isEmpty) continue;
      grouped.putIfAbsent(a.itemId, () => []).add(a);
    }
    final contentById = <String, LearningContent>{
      for (final item in content) item.id: item,
    };
    final rows = <MistakeRecord>[];
    for (final entry in grouped.entries) {
      final all = entry.value;
      final errors = all.where((a) => !a.correct).toList();
      if (errors.isEmpty) continue;
      final item = contentById[entry.key];
      final latest = all.reduce((a, b) => a.at.isAfter(b.at) ? a : b);
      final category = _classify(all, item);
      final streak = _correctiveStreak(all);
      final recency = _recency(at, latest.at);
      final failureRate = errors.length / all.length;
      final recentFailureRate = _recentFailureRate(all, at);
      final recurrent = errors.length >= 2 || failureRate >= .40;
      final recurrence = errors.length * 18 + (errors.length >= 2 ? 22 : 0);
      final unresolved = (errors.length - streak).clamp(0, errors.length);
      if (streak >= 3 && unresolved == 0) continue;
      final severity = (recurrence +
              unresolved * 10 +
              recency +
              (recentFailureRate * 25).round())
          .clamp(1, 100)
          .toInt();
      rows.add(
        MistakeRecord(
          itemId: entry.key,
          category: category,
          source: _source(entry.key),
          errorCount: errors.length,
          attemptCount: all.length,
          correctiveStreak: streak,
          lastSeenAt: latest.at,
          severity: severity,
          normalizedKey: '${category.name}:${entry.key}',
          failureRate: failureRate,
          recentFailureRate: recentFailureRate,
          diagnosis: _diagnosis(category, recurrent, recentFailureRate),
        ),
      );
    }
    rows.sort((a, b) => b.severity.compareTo(a.severity));
    return MistakeReport(
      items: rows.take(20).toList(),
      headline: rows.isEmpty
          ? 'لا توجد أخطاء تحتاج علاجًا الآن.'
          : 'هذه أكثر الأخطاء تكرارًا؛ سنعالجها بتدريبات قصيرة ثم نعيد قياسها.',
    );
  }

  static MistakeRecord fromWriting({
    required String itemId,
    required String issue,
    DateTime? at,
  }) =>
      MistakeRecord(
        itemId: itemId,
        category: MistakeCategory.writing,
        source: MistakeSource.writing,
        errorCount: 1,
        attemptCount: 1,
        correctiveStreak: 0,
        lastSeenAt: at ?? DateTime.now(),
        severity: 55,
        normalizedKey: 'writing:${issue.trim().toLowerCase()}',
      );

  static MistakeCategory _classify(List<Attempt> all, LearningContent? item) {
    final skill = all.last.skill.toLowerCase();
    if (skill == 'listening') return MistakeCategory.listening;
    if (skill == 'production') return MistakeCategory.production;
    if (skill == 'transfer') return MistakeCategory.translation;
    if (skill == 'writing') return MistakeCategory.writing;
    if (skill == 'grammar') return MistakeCategory.grammar;
    if (item != null && item.grammaticalMarker.isNotEmpty) {
      final expected = item.grammaticalMarker.toLowerCase();
      final wrong = all.any(
        (a) =>
            !a.correct &&
            a.answer.toLowerCase().contains(
                  RegExp(r'^(der|die|das|ein|eine)\b'),
                ) &&
            !a.answer.toLowerCase().startsWith(expected),
      );
      if (wrong) return MistakeCategory.article;
    }
    return MistakeCategory.vocabulary;
  }

  static int _correctiveStreak(List<Attempt> all) {
    var n = 0;
    for (final a in all.reversed) {
      if (!a.correct) break;
      n++;
    }
    return n;
  }

  static int _recency(DateTime now, DateTime seen) {
    final d =
        now.toUtcMidnight.difference(seen.toUtcMidnight).inDays.clamp(0, 30);
    return 30 - d;
  }

  static double _recentFailureRate(List<Attempt> all, DateTime now) {
    var total = 0;
    var failures = 0;
    for (final a in all) {
      if (now.toUtcMidnight.difference(a.at.toUtcMidnight).inDays > 14)
        continue;
      total++;
      if (!a.correct) failures++;
    }
    if (total == 0) return 0;
    return failures / total;
  }

  static String _diagnosis(
    MistakeCategory category,
    bool recurrent,
    double recentRate,
  ) {
    if (recentRate >= .60)
      return 'خطأ نشط ومتكرر؛ نحتاج إصلاحه الآن بتدريب قصير ومتدرّج.';
    if (recurrent)
      return 'خطأ متكرر؛ المشكلة تحتاج تثبيتًا إضافيًا بدل إعادة السؤال نفسه.';
    switch (category) {
      case MistakeCategory.article:
        return 'تشخيص: Artikel؛ ركّز على جنس الاسم ثم استخدمه داخل جملة.';
      case MistakeCategory.grammar:
        return 'تشخيص: قاعدة؛ صحّح النمط ثم طبّقه في سياق جديد.';
      case MistakeCategory.translation:
        return 'تشخيص: نقل المعنى؛ اربط المعنى العربي بالبنية الألمانية.';
      case MistakeCategory.wordOrder:
        return 'تشخيص: ترتيب الجملة؛ ثبّت موقع الفعل ثم أعد بناء الجملة.';
      case MistakeCategory.production:
        return 'تشخيص: إنتاج؛ انتقل من التعرّف إلى الاستعمال الحر.';
      case MistakeCategory.listening:
        return 'تشخيص: استماع؛ أعد ربط الصوت بالشكل المكتوب والمعنى.';
      case MistakeCategory.writing:
        return 'تشخيص: كتابة؛ صحّح البنية ثم اكتب مثالًا جديدًا.';
      case MistakeCategory.vocabulary:
        return 'تشخيص: مفردات؛ ثبّت الكلمة عبر الاسترجاع ثم السياق.';
    }
  }

  static MistakeSource _source(String id) {
    if (id.startsWith('restaurant_') ||
        id.startsWith('station_') ||
        id.startsWith('market_') ||
        id.startsWith('work_') ||
        id.startsWith('doctor_')) return MistakeSource.conversation;
    if (id.startsWith('writing:')) return MistakeSource.writing;
    if (id.startsWith('assessment_')) return MistakeSource.assessment;
    return MistakeSource.practice;
  }
}
