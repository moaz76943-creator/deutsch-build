import 'package:shared_preferences/shared_preferences.dart';

class AtomicAttemptManager {
  static const String _prefixProcessed = 'attempt_processed_';

  /// يتحقق مما إذا كانت المحاولة عولجت مسبقاً لمنع التكرار
  static Future<bool> isAttemptProcessed(String attemptId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('$_prefixProcessed$attemptId') ?? false;
  }

  /// تسجيل المحاولة كمعالجة بشكل ذري
  static Future<void> markAttemptProcessed(String attemptId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('$_prefixProcessed$attemptId', true);
  }
}
