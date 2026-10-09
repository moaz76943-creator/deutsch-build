import 'package:flutter/services.dart';

class AppCognitiveTokens {
  static const Color derColor = Color(0xFF2563EB); // مذكر - أزرق
  static const Color dieColor = Color(0xFFDC2626); // مؤنث - أحمر
  static const Color dasColor = Color(0xFF16A34A); // محايد - أخضر

  static const double blurSigmaX = 8.0;
  static const double blurSigmaY = 8.0;
  static const double glassOpacity = 0.15;

  static void triggerLightHaptic() => HapticFeedback.lightImpact();
  static void triggerSuccessHaptic() => HapticFeedback.mediumImpact();
  static void triggerErrorHaptic() => HapticFeedback.heavyImpact();

  static Color getArticleColor(String article) {
    switch (article.toLowerCase().trim()) {
      case 'der':
        return derColor;
      case 'die':
        return dieColor;
      case 'das':
        return dasColor;
      default:
        return const Color(0xFF6B7280);
    }
  }
}
