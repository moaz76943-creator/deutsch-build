import '../language_text_normalizer.dart';

/// German answer normalization kept outside the language-agnostic core.
final class GermanTextNormalizer implements LanguageTextNormalizer {
  const GermanTextNormalizer();

  @override
  String answer(String value) => value
      .toLowerCase()
      .replaceAll('ä', 'a')
      .replaceAll('ö', 'o')
      .replaceAll('ü', 'u')
      .replaceAll('ß', 'ss')
      .replaceAll(RegExp(r'[.!?,;:،؛؟]'), '')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}
