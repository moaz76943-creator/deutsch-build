class BiDiTextIsolator {
  // Unicode isolation control characters
  static const String lri = '\u2066'; // Left-to-Right Isolate
  static const String rli = '\u2067'; // Right-to-Left Isolate
  static const String fsi = '\u2068'; // First Strong Isolate
  static const String pdi = '\u2069'; // Pop Directional Isolate

  /// Encloses German text in LRI and Arabic in RLI to strictly prevent text inversion
  static String isolateGerman(String text) => '$lri$text$pdi';
  static String isolateArabic(String text) => '$rli$text$pdi';

  /// Combines German headword and Arabic translation with strict directional boundaries
  static String formatBilingualPair(String german, String arabic) {
    return '${isolateGerman(german)} — ${isolateArabic(arabic)}';
  }
}
