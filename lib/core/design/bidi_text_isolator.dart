// Unicode isolation engine for 100-language polyglot architecture
import 'package:flutter/material.dart';
import 'package:deutsch_bilarabi/core/language_bidi_helper.dart';

class BiDiTextIsolator {
  // Unicode isolation control characters (Unicode 15.0)
  static const String lri = '⁦'; // Left-to-Right Isolate
  static const String rli = '⁧'; // Right-to-Left Isolate
  static const String fsi = '⁨'; // First Strong Isolate
  static const String pdi = '⁩'; // Pop Directional Isolate

  /// Backward compatible: German isolation (LRI)
  static String isolateGerman(String text) => '$lri$text$pdi';

  /// Backward compatible: Arabic isolation (RLI)
  static String isolateArabic(String text) => '$rli$text$pdi';

  /// Backward compatible: German-Arabic bilingual pair formatter
  static String formatBilingualPair(String german, String arabic) {
    return '${isolateGerman(german)} – ${isolateArabic(arabic)}';
  }

  /// Dynamic 100-language isolation based on BCP-47 language code
  static String isolateLanguage(String text, String bcp47Code) {
    final isRtl = LanguageBiDiHelper.getDirection(bcp47Code) == TextDirection.rtl;
    return isRtl ? '$rli$text$pdi' : '$lri$text$pdi';
  }

  /// Universal First-Strong directional isolation (auto-detects script orientation)
  static String isolateAuto(String text) => '$fsi$text$pdi';

  /// Dynamic bilingual pair formatter for any two languages among the 100 supported
  static String formatPairUniversal(
    String term,
    String translation, {
    String termLang = 'de',
    String translationLang = 'ar',
  }) {
    return '${isolateLanguage(term, termLang)} – ${isolateLanguage(translation, translationLang)}';
  }
}
