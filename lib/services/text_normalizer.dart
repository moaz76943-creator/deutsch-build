import '../language/german/german_text_normalizer.dart';

/// Compatibility facade for legacy service callers.
///
/// New code should receive LanguageTextNormalizer from the selected LanguagePack.
/// This facade exists only to keep the staged migration source-compatible.
final class TextNormalizer {
  static String answer(String value) =>
      const GermanTextNormalizer().answer(value);
}
