import 'polyglot_unified_core.dart';
import 'polyglot_search_and_article_engine.dart';

/// مُحلل النطق المحلي (Offline TTS Locale & Clean Spoken Text Resolver)
class PolyglotTtsHelper {
  static const Map<String, String> _localeMap = {
    'de': 'de-DE',
    'en': 'en-US',
    'fr': 'fr-FR',
    'es': 'es-ES',
    'tr': 'tr-TR',
    'ar': 'ar-SA',
  };

  /// إرجاع رمز النطق المعياري لمحرك TTS المحلي على أندرويد دون أي اتصال
  static String resolveBcp47Locale(String isoCode) {
    return _localeMap[isoCode.toLowerCase()] ?? 'de-DE';
  }

  /// تنظيف الجملة من الأقواس التوضيحية أو علامات المقارنة قبل إرسالها لمحرك النطق
  static String sanitizeForSpeech(String sentence) {
    return sentence
        .replaceAll(RegExp(r'\[[^\]]*\]'), '')
        .replaceAll('„', '')
        .replaceAll('“', '')
        .replaceAll('—', ', ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}

/// مصدر بطاقات Anki التفاعلية الملونة دون اتصال (AR-Front / Target-Back أو العكس)
class PolyglotAnkiExporter {
  static String _escapeCsvCell(String value) {
    final sanitized = value.replaceAll('\r\n', ' ').replaceAll('\n', ' ');
    final escaped = sanitized.replaceAll('"', '""');
    return '"$escaped"';
  }

  static String _formatColoredHtmlExpression(PolyglotLearningUnit unit) {
    if (unit.languageCode != 'de') {
      return unit.targetExpression;
    }
    final gender = PolyglotOfflineSearchEngine.detectGermanArticle(unit.targetExpression);
    if (gender == GermanArticleGender.none) {
      return unit.targetExpression;
    }
    final hex = '#${gender.amoledSafeHexColor.toRadixString(16).substring(2).toUpperCase()}';
    return '<span style="color:$hex;font-weight:bold;">${unit.targetExpression}</span> '
        '<small>(${gender.arabicLabel})</small>';
  }

  /// تصدير الوحدات إلى CSV متوافق مع Anki (مع ألوان أدوات التعريف الألمانية والجمل السياقية)
  static String exportAnkiCsv(
    Iterable<PolyglotLearningUnit> units, {
    bool arabicFirst = true,
  }) {
    final buffer = StringBuffer();
    if (arabicFirst) {
      buffer.writeln('Arabic_Front,Target_Expression_HTML,Context_Sentence,Pitfall,Level,Tags');
    } else {
      buffer.writeln('Target_Expression_HTML,Arabic_Back,Context_Sentence,Pitfall,Level,Tags');
    }

    for (final unit in units) {
      final coloredHtml = _formatColoredHtmlExpression(unit);
      final tagsStr = unit.tags.join(' ');
      if (arabicFirst) {
        buffer.writeln([
          _escapeCsvCell(unit.arabicExplanation),
          _escapeCsvCell(coloredHtml),
          _escapeCsvCell(unit.contextualSentence),
          _escapeCsvCell(unit.commonPitfall),
          _escapeCsvCell(unit.level.name.toUpperCase()),
          _escapeCsvCell(tagsStr),
        ].join(','));
      } else {
        buffer.writeln([
          _escapeCsvCell(coloredHtml),
          _escapeCsvCell(unit.arabicExplanation),
          _escapeCsvCell(unit.contextualSentence),
          _escapeCsvCell(unit.commonPitfall),
          _escapeCsvCell(unit.level.name.toUpperCase()),
          _escapeCsvCell(tagsStr),
        ].join(','));
      }
    }
    return buffer.toString();
  }
}
