// مسار الملف: lib/core/gamification_manager.dart

/// حالة المستخدم الحالية (النقاط والأيام المتتالية)
class GamificationState {
  final int currentStreak;
  final int totalXp;
  final String lastActivityDate;

  const GamificationState({
    required this.currentStreak,
    required this.totalXp,
    required this.lastActivityDate,
  });
}

/// المحرك المرجعي الوحيد (Single Source of Truth) لحساب النقاط والالتزام اليومي.
/// يُمنع استخدام SharedPreferences لحساب الـ Streak خارج هذا المحرك.
class GamificationEngine {
  /// دالة مركزية لمعالجة النقاط بعد كل مراجعة ناجحة ومكتملة من محرك SRS
  /// لا يتم منح النقاط لمجرد تقليب البطاقة، بل لنجاح التخزين.
  static GamificationState processReviewReward({
    required GamificationState currentState,
    required DateTime now,
    required bool isSuccess,
  }) {
    // توحيد صيغة التاريخ لضمان عدم تأثر السلسلة باختلاف المناطق الزمنية (Timezones)
    final todayStr =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    int newStreak = currentState.currentStreak;
    // 10 نقاط كحد أقصى للإجابة الناجحة، 0 للإجابة الخاطئة (لا مكافآت مجانية)
    int earnedXp = isSuccess ? 10 : 0;

    if (currentState.lastActivityDate.isEmpty) {
      newStreak = 1;
    } else {
      final lastDate = DateTime.tryParse(currentState.lastActivityDate) ?? now;
      final differenceInDays = now.difference(lastDate).inDays;

      if (differenceInDays == 1) {
        newStreak += 1; // تعزيز السلسلة ليوم جديد
      } else if (differenceInDays > 1) {
        newStreak = 1; // كسر السلسلة وإعادة الضبط عند الانقطاع لأكثر من 48 ساعة
      }
      // إذا كان differenceInDays == 0، فهذا يعني أننا في نفس اليوم، لا نزيد الـ Streak بل نزيد الـ XP فقط.
    }

    return GamificationState(
      currentStreak: newStreak,
      totalXp: currentState.totalXp + earnedXp,
      lastActivityDate: todayStr,
    );
  }
}
