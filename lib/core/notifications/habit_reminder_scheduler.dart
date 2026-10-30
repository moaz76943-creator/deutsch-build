import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:deutsch_bilarabi/services/database_service.dart';
import 'package:sqflite/sqflite.dart';

/// مجدول إشعارات الأوفلاين (Inexact Local Notification Service)
/// لا يتطلب إنترنت ويحترم أوقات نوم المستخدم.
class HabitReminderScheduler {
  static const String _prefRemindersEnabled = 'reminders_enabled';
  static const String _prefReminderHour = 'reminder_hour';
  static const String _prefReminderMinute = 'reminder_minute';
  static const String _prefLastReminderSentDate = 'last_reminder_sent_date';

  /// Save preferences for reminders
  static Future<void> savePreferences({required bool enabled, required int hour, required int minute}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefRemindersEnabled, enabled);
    await prefs.setInt(_prefReminderHour, hour);
    await prefs.setInt(_prefReminderMinute, minute);
  }

  /// Get if reminders are enabled
  static Future<bool> areRemindersEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_prefRemindersEnabled) ?? true;
  }
  
  /// Get user preferred time (hour, minute)
  static Future<Map<String, int>> getPreferredTime() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'hour': prefs.getInt(_prefReminderHour) ?? 20,
      'minute': prefs.getInt(_prefReminderMinute) ?? 0,
    };
  }

  /// Check if user has due reviews (requires review right now or today)
  static Future<bool> hasDueReviews(DateTime now) async {
    try {
      final db = await DatabaseService.instance.progressDb;
      final currentTimeMs = now.millisecondsSinceEpoch;
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM srs_progress WHERE next_due_at <= ? AND status = ?',
        [currentTimeMs, 'learning']
      );
      final count = Sqflite.firstIntValue(result) ?? 0;
      return count > 0;
    } catch (e) {
      debugPrint("Error fetching due reviews: \$e");
      return false;
    }
  }

  /// Check if reminder was already sent today
  static Future<bool> alreadyRemindedToday(DateTime now) async {
    final prefs = await SharedPreferences.getInstance();
    final lastSentStr = prefs.getString(_prefLastReminderSentDate);
    if (lastSentStr == null) return false;
    
    final lastSent = DateTime.tryParse(lastSentStr);
    if (lastSent == null) return false;

    // Check if same local day
    return lastSent.year == now.year &&
           lastSent.month == now.month &&
           lastSent.day == now.day;
  }

  /// Mark reminder as sent today
  static Future<void> markReminderSentToday(DateTime now) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefLastReminderSentDate, now.toIso8601String());
  }

  /// إلغاء التذكيرات إذا اختار المستخدم ذلك
  static Future<void> cancelAllReminders() async {
    final prefs = await getPreferredTime();
    await savePreferences(enabled: false, hour: prefs['hour']!, minute: prefs['minute']!);
    debugPrint("تم إلغاء جميع التذكيرات المحلية.");
  }

  /// يحدد إذا ما كان الوقت مناسباً لإرسال إشعار بناءً على التفضيلات وأوقات الراحة.
  @visibleForTesting
  static bool isEligibleForReminder(
    DateTime now,
    bool remindersEnabled,
    int preferredHour,
    int preferredMinute,
    bool hasDueReviews,
    bool alreadyRemindedToday,
  ) {
    if (!remindersEnabled) return false;
    if (alreadyRemindedToday) return false;
    if (!hasDueReviews) return false;

    // Quiet hours: 10 PM (22) to 8 AM (8)
    if (now.hour >= 22 || now.hour < 8) return false;

    // Check if current time is around or past the preferred time for today.
    // We don't want to remind before the preferred time.
    final preferredTimeMins = preferredHour * 60 + preferredMinute;
    final nowMins = now.hour * 60 + now.minute;

    if (nowMins < preferredTimeMins) return false;

    return true;
  }

  /// جدولة أو تنفيذ التذكير بناءً على الحالة المحلية
  static Future<void> scheduleDailyReminder() async {
    final now = DateTime.now();
    final enabled = await areRemindersEnabled();
    final preferredTime = await getPreferredTime();
    final hasDue = await hasDueReviews(now);
    final alreadySent = await alreadyRemindedToday(now);

    final eligible = isEligibleForReminder(
      now,
      enabled,
      preferredTime['hour']!,
      preferredTime['minute']!,
      hasDue,
      alreadySent
    );

    if (eligible) {
      // In-app fallback since OS-level is missing dependencies
      debugPrint("In-app fallback notification: You have due reviews! (BLOCKED_INTEGRATION for OS-level)");
      await markReminderSentToday(now);
    } else {
      debugPrint("Not eligible for reminder at this time.");
    }
  }

  /// إنشاء تقرير النمو لليوم 30 أو 90 (Day-30 Retention)
  static Future<void> generateGrowthReport(int daysActive) async {
    if (daysActive == 30) {
      // عرض رسالة تحفيزية بإنجازات الشهر الأول
      // "لقد أتقنت X كلمة في Y مجالات!"
    } else if (daysActive == 90) {
      // عرض تقرير الربع السنوي
    }
  }
}
