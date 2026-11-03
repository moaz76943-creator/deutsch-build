import 'multi_script_typography.dart';

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
  ];

  /// Alternatively, a helper to apply only specific fallbacks based on text content
  /// if strict resource bounding is needed.
  static List<String> getFallbackForText(String text) {
    return MultiScriptTypography.getFallbacksForText(text);
  }
}
