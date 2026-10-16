# كتابة ملف عازل نصوص BiDi بتسلسلات هروب قياسية متطابقة 100%
bidi_dart_code = r'''// BiDi Text Isolator Engine
class BiDiTextIsolator {
  static const String lre = '\u202A';
  static const String rle = '\u202B';
  static const String pdf = '\u202C';
  static const String lri = '\u2066';
  static const String rli = '\u2067';
  static const String fsi = '\u2068';
  static const String pdi = '\u2069';

  static String isolateAr(String text) => '$rli$text$pdi';

  static String formatBilingualPair(String ltrText, String rtlText) {
    return '$ltrText - $rli$rtlText$pdi';
  }

  static String wrapDirectional(String text, {bool isRtl = false}) {
    return isRtl ? '$rli$text$pdi' : '$lri$text$pdi';
  }
}
'''

with open('lib/core/design/bidi_text_isolator.dart', 'w', encoding='utf-8') as f:
    f.write(bidi_dart_code)

print("✓ تم تثبيت BiDiTextIsolator بتسلسلات اليونيكود المتوافقة مع الاختبارات والفاحص.")
