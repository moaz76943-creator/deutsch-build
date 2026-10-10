import 'dart:async';

class OfflineAudioDispatcher {
  static int _currentGenerationToken = 0;
  static bool _isPlaying = false;

  static bool get isPlaying => _isPlaying;

  /// تشغيل النطق مع إلغاء أي صوت قيد التشغيل فوراً
  static Future<bool> speakText({
    required String text,
    required String bcp47Locale,
    double speechRate = 0.9,
  }) async {
    final int thisToken = ++_currentGenerationToken;
    _isPlaying = true;

    try {
      // التحقق من أن الطلب ما زال حديثاً ولم يتم تجاوزه بطلب آخر
      if (thisToken != _currentGenerationToken) return false;

      // محاكاة الاتصال بالجسر الأصلي للنظام أوفلاين
      await Future.delayed(const Duration(milliseconds: 100));

      if (thisToken != _currentGenerationToken) return false;
      return true;
    } finally {
      if (thisToken == _currentGenerationToken) {
        _isPlaying = false;
      }
    }
  }

  static void stopCurrentAudio() {
    _currentGenerationToken++;
    _isPlaying = false;
  }
}
