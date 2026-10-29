import 'package:flutter/services.dart';

class AppCognitiveTokens {
  static const Color masculineColor = Color(0xFF2563EB); // أزرق للمذكر
  static const Color feminineColor = Color(0xFFDC2626);  // أحمر للمؤنث
  static const Color neuterColor = Color(0xFF16A34A);    // أخضر للمحايد
  static const Color neutralColor = Color(0xFF6B7280);   // رمادي عام

  static const Color derColor = masculineColor;
  static const Color dieColor = feminineColor;
  static const Color dasColor = neuterColor;

  static const double blurSigmaX = 8.0;
  static const double blurSigmaY = 8.0;
  static const double glassOpacity = 0.15;

  static void triggerLightHaptic() => HapticFeedback.lightImpact();
  static void triggerSuccessHaptic() => HapticFeedback.mediumImpact();
  static void triggerErrorHaptic() => HapticFeedback.heavyImpact();

  /// تمييز الأجناس النحوية ديناميكياً للغات المتعددة
  static Color getGrammaticalColor(String genderOrArticle) {
    final term = genderOrArticle.toLowerCase().trim();
    if (['der', 'le', 'el', 'il', 'm', 'masculine'].contains(term)) {
      return masculineColor;
    }
    if (['die', 'la', 'f', 'feminine'].contains(term)) {
      return feminineColor;
    }
    if (['das', 'lo', 'n', 'neuter'].contains(term)) {
      return neuterColor;
    }
    return neutralColor;
  }

  static Color getArticleColor(String article) => getGrammaticalColor(article);
}
