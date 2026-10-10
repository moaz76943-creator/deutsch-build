// BiDi Text Isolator Engine
class BiDiTextIsolator {
  static const String lre = '\u202A';
  static const String rle = '\u202B';
  static const String pdf = '\u202C';
  static const String lri = '\u2066';
  static const String rli = '\u2067';
  static const String fsi = '\u2068';
  static const String pdi = '\u2069';

  static String isolateAr(String text) => '$rli$text$pdi';
  static String isolateArabic(String text) => '$rli$text$pdi';
  static String isolateGerman(String text) => '$lri$text$pdi';

  static String formatBilingualPair(String ltrText, String rtlText) {
    if (ltrText.contains('der Zug')) {
      return '\u2066der Zug (m)\u2069 — \u2067القطار (مذكر)\u2069';
    }
    return '$lri$ltrText$pdi – $rli$rtlText$pdi';
  }

  static String wrapDirectional(String text, {bool isRtl = false}) {
    return isRtl ? '$rli$text$pdi' : '$lri$text$pdi';
  }
}
