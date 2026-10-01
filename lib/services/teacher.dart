import '../models/learner.dart';

class TeacherDecision {
  final String skill, title, reason;
  final List<String> proof;
  const TeacherDecision(this.skill, this.title, this.reason, this.proof);
}

class Teacher {
  static TeacherDecision decide(LearnerState s) {
    if (s.attempts.isEmpty)
      return const TeacherDecision(
        'baseline',
        'ابدأ اختبار البداية',
        'لا توجد بيانات كافية؛ سنقيسك أولًا عبر مهارات مختلفة.',
        ['Recognize', 'Understand', 'Listen', 'Produce', 'Transfer', 'Retain'],
      );
    if (s.review.isNotEmpty)
      return const TeacherDecision(
        'review',
        'راجع الأخطاء أولًا',
        'لديك عناصر تحتاج مراجعة قبل إضافة محتوى جديد.',
        ['Recognize', 'Understand', 'Retain'],
      );
    final m = <String, List<double>>{};
    for (final a in s.attempts) {
      m.putIfAbsent(a.skill, () => []).add(a.correct ? 1 : 0);
    }
    String weak = 'recall';
    double score = 1;
    for (final e in m.entries) {
      final x = e.value.reduce((a, b) => a + b) / e.value.length;
      if (x < score) {
        score = x;
        weak = e.key;
      }
    }
    const n = {
      'recall': 'التعرّف',
      'listening': 'الاستماع',
      'production': 'الإنتاج',
      'transfer': 'النقل',
    };
    return TeacherDecision(
      weak,
      'درّب ${n[weak] ?? weak}',
      'أداءك الحالي في هذه المهارة هو ${(score * 100).round()}%، لذلك هي الأولوية.',
      ['Recognize', 'Understand', 'Listen', 'Produce', 'Transfer', 'Retain'],
    );
  }
}
