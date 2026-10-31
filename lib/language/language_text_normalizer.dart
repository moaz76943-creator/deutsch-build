/// Language-specific text normalization contract.
///
/// Learning algorithms depend on this abstraction rather than on rules for
/// any particular language. Implementations belong to the selected language.
abstract interface class LanguageTextNormalizer {
  String answer(String value);
}
