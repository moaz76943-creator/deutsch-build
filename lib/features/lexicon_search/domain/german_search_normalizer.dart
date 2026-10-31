abstract final class GermanSearchNormalizer {
  static Set<String> variants(String input) {
    final base = normalize(input);
    if (base.isEmpty) return const <String>{};

    final transliterated = base
        .replaceAll('ä', 'ae')
        .replaceAll('ö', 'oe')
        .replaceAll('ü', 'ue');
    final folded = transliterated
        .replaceAll('ae', 'a')
        .replaceAll('oe', 'o')
        .replaceAll('ue', 'u');

    return <String>{base, transliterated, folded};
  }

  static String normalize(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll('ß', 'ss')
        .replaceAll(RegExp(r'[\u064B-\u065F\u0670\u06D6-\u06ED]'), '')
        .replaceAll('\u0640', '')
        .replaceAll(RegExp('[أإآ]'), 'ا')
        .replaceAll('ى', 'ي')
        .replaceAll(RegExp(r'''[.,!?;:،؛؟„“"'’()\[\]{}<>/\\|+*=~^]'''), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}
