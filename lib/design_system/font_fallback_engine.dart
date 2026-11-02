class FontFallbackEngine {
  /// We provide a single lazy getter for the universal fallback list.
  /// Flutter's text engine natively queries fallbacks lazily character-by-character
  /// without eagerly loading the font assets unless a glyph match is required.
  /// However, to be strictly lazy about list creation, we use a getter or
  /// script-specific getters if we want to restrict fallbacks.

  static const List<String> universalFallback = [
    'Cairo',
    'NotoSansHebrew',
    'NotoSansDevanagari',
    'NotoSansEthiopic',
    'NotoSansGeorgian',
    'NotoSansArmenian',
    'NotoSansSC',
    'NotoSansJP',
    'NotoSansKR',
  ];

  /// Alternatively, a helper to apply only specific fallbacks based on text content
  /// if strict resource bounding is needed.
  static List<String> getFallbackForText(String text) {
    // A more aggressive lazy strategy: only include fallbacks for scripts actually present.
    // In many applications, Flutter's native fallback mechanism is lazy enough, but
    // explicitly bounding the list prevents even font table parsing for unused scripts.
    List<String> fallbacks = [];

    // Arabic / Persian / Urdu (0600–06FF, 0750–077F, 08A0–08FF)
    if (RegExp(r'[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF]').hasMatch(text)) {
      fallbacks.add('Cairo');
    }
    // Hebrew (0590–05FF)
    if (RegExp(r'[\u0590-\u05FF]').hasMatch(text)) {
      fallbacks.add('NotoSansHebrew');
    }
    // Devanagari (0900–097F)
    if (RegExp(r'[\u0900-\u097F]').hasMatch(text)) {
      fallbacks.add('NotoSansDevanagari');
    }
    // Ethiopic (1200–137F, 1380–139F, 2D80–2DDF, AB00–AB2F)
    if (RegExp(r'[\u1200-\u137F\u1380-\u139F\u2D80-\u2DDF\uAB00-\uAB2F]')
        .hasMatch(text)) {
      fallbacks.add('NotoSansEthiopic');
    }
    // Georgian (10A0–10FF, 2D00–2D2F)
    if (RegExp(r'[\u10A0-\u10FF\u2D00-\u2D2F]').hasMatch(text)) {
      fallbacks.add('NotoSansGeorgian');
    }
    // Armenian (0530–058F)
    if (RegExp(r'[\u0530-\u058F]').hasMatch(text)) {
      fallbacks.add('NotoSansArmenian');
    }

    // CJK Unified Ideographs - simplified logic using range,
    // real scenarios might have more specific detection for SC/JP/KR
    // Hiragana/Katakana for JP
    if (RegExp(r'[\u3040-\u309F\u30A0-\u30FF]').hasMatch(text)) {
      fallbacks.add('NotoSansJP');
    }
    // Hangul for KR
    if (RegExp(r'[\uAC00-\uD7AF\u1100-\u11FF\u3130-\u318F]').hasMatch(text)) {
      fallbacks.add('NotoSansKR');
    }
    // Han characters for SC or general CJK
    if (RegExp(r'[\u4E00-\u9FFF]').hasMatch(text)) {
      fallbacks.add('NotoSansSC');
    }

    return fallbacks.isEmpty ? [] : fallbacks;
  }
}
