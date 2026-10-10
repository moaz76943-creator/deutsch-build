// ignore_for_file: unused_import

/// نموذج تقدم المستخدم ومستوى الإتقان أوفلاين
class UserProgressProfile {
  final int currentStreak;
  final String lastActiveDate; // YYYY-MM-DD
  final int totalXp;
  final Map<String, int> domainMasteryCount; // domainId -> mastered cards count

  const UserProgressProfile({
    required this.currentStreak,
    required this.lastActiveDate,
    required this.totalXp,
    required this.domainMasteryCount,
  });

  int get level => (totalXp / 100).floor() + 1;
}

/// محرك إدارة التحفيز دون أي اتصال سحابي
class GamificationManager {
  static UserProgressProfile calculateDailyStreak({
    required UserProgressProfile currentProfile,
    required DateTime now,
  }) {
    final todayStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    
    if (currentProfile.lastActiveDate == todayStr) {
      return currentProfile;
    }

    if (currentProfile.lastActiveDate.isEmpty) {
      return UserProgressProfile(
        currentStreak: 1,
        lastActiveDate: todayStr,
        totalXp: currentProfile.totalXp + 10,
        domainMasteryCount: currentProfile.domainMasteryCount,
      );
    }

    final lastDate = DateTime.tryParse(currentProfile.lastActiveDate) ?? now;
    final differenceInDays = now.difference(lastDate).inDays;

    int newStreak = currentProfile.currentStreak;
    if (differenceInDays == 1) {
      newStreak += 1;
    } else if (differenceInDays > 1) {
      newStreak = 1; // إعادة ضبط عند الانقطاع
    }

    return UserProgressProfile(
      currentStreak: newStreak,
      lastActiveDate: todayStr,
      totalXp: currentProfile.totalXp + 15,
      domainMasteryCount: currentProfile.domainMasteryCount,
    );
  }

  static double calculateDomainMasteryPercent(int masteredCards, int totalDomainCards) {
    if (totalDomainCards <= 0) return 0.0;
    final percent = (masteredCards / totalDomainCards) * 100.0;
    return percent > 100.0 ? 100.0 : percent;
  }
}
