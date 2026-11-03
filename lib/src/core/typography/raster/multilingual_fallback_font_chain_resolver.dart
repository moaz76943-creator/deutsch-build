/// Task 1226: Hierarchical fallback font resolver across multi-script chains
class FallbackFontChainResolver {
  String resolveFontFamily(String script) {
    if (script == 'Arabic') return 'NotoSansArabic';
    if (script == 'Devanagari') return 'NotoSansDevanagari';
    return 'Roboto';
  }
}
