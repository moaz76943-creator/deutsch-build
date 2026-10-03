import '../models/learner.dart';

class MistakeCoachingItem {
  final String itemId, skill, action;
  final int errorCount, attemptCount;
  const MistakeCoachingItem({
    required this.itemId,
    required this.skill,
    required this.action,
    required this.errorCount,
    required this.attemptCount,
  });
}

class MistakeCoachReport {
  final List<MistakeCoachingItem> items;
  final String headline;
  const MistakeCoachReport({required this.items, required this.headline});
}

class MistakeCoach {
  static MistakeCoachReport from(List<Attempt> attempts) {
    final grouped = <String, List<Attempt>>{};
    for (final a in attempts) grouped.putIfAbsent(a.itemId, () => []).add(a);
    final rows = <MistakeCoachingItem>[];
    for (final e in grouped.entries) {
      final errors = e.value.where((a) => !a.correct).length;
      if (errors == 0) continue;
      final skill = e.value.last.skill;
      final action = skill == 'listening'
          ? 'استمع ثم أعد الجملة بصوتك في تدريب قصير.'
          : skill == 'production'
              ? 'اكتب جملة جديدة ثم قارنها بالنموذج.'
              : skill == 'transfer'
                  ? 'درّب الترجمة من العربية إلى الألمانية دون تلميح.'
                  : 'أعد القاعدة في 3 أسئلة متدرجة قبل الانتقال.';
      rows.add(
        MistakeCoachingItem(
          itemId: e.key,
          skill: skill,
          action: action,
          errorCount: errors,
          attemptCount: e.value.length,
        ),
      );
    }
    rows.sort(
      (a, b) => (b.errorCount * 3 + b.attemptCount).compareTo(
        a.errorCount * 3 + a.attemptCount,
      ),
    );
    return MistakeCoachReport(
      items: rows.take(12).toList(),
      headline: rows.isEmpty
          ? 'لا توجد أخطاء متكررة تحتاج علاجًا الآن.'
          : 'لدينا نقاط متكررة سنحوّلها إلى تدريبات قصيرة.',
    );
  }
}
