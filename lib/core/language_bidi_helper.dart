import 'package:flutter/material.dart';

/// محرك مركزي لإدارة اتجاه النصوص وخصائص الـ 100 لغة
class LanguageBiDiHelper {
  // اللغات التي تكتب من اليمين إلى اليسار حول العالم
  static const Set<String> _rtlLanguagePrefixes = {
    'ar', 'fa', 'ur', 'ps', 'sd', 'ku', 'ug', 'ckb'
  };

  /// فحص اتجاه أي لغة عالمية عبر كود BCP-47
  static TextDirection getDirection(String bcp47Code) {
    final prefix = bcp47Code.split('-').first.toLowerCase();
    if (_rtlLanguagePrefixes.contains(prefix)) {
      return TextDirection.rtl;
    }
    return TextDirection.ltr;
  }

  /// التحقق الصارم من استبعاد اللغات المحظورة
  static bool isLanguageAllowed(String bcp47Code) {
    final prefix = bcp47Code.split('-').first.toLowerCase();
    if (prefix == 'he' || prefix == 'iw') {
      return false;
    }
    return true;
  }

  /// تحديد ارتفاع السطر والخط المناسب لكل عائلة لغوية
  static double getLineHeight(String bcp47Code) {
    final prefix = bcp47Code.split('-').first.toLowerCase();
    if (prefix == 'ar' || prefix == 'fa' || prefix == 'ur') {
      return 1.4; // حماية علامات التشكيل العربية وما شابهها من القص
    }
    return 1.2;
  }
}
