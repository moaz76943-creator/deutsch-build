/// Language-neutral text direction used by domain models.
enum AppTextDirection {
  ltr,
  rtl;

  String get jsonValue => name;

  /// Parses an explicit wire value when present, otherwise resolves a safe
  /// fallback from the language code.
  static AppTextDirection fromJson(
    Object? value, {
    required String languageCode,
  }) {
    if (value == null) {
      return forLanguage(languageCode);
    }
    if (value is! String) {
      throw FormatException('text direction must be a string');
    }

    switch (value.trim().toLowerCase()) {
      case 'ltr':
        return AppTextDirection.ltr;
      case 'rtl':
        return AppTextDirection.rtl;
      default:
        throw FormatException('unsupported text direction: $value');
    }
  }

  /// Deterministic compatibility fallback used only when metadata is absent.
  /// Arabic resolves to RTL; every other language defaults to LTR.
  static AppTextDirection forLanguage(String languageCode) {
    final normalized = languageCode.trim().toLowerCase();
    final primaryLanguage = normalized.split(RegExp(r'[-_]')).first;
    return primaryLanguage == 'ar'
        ? AppTextDirection.rtl
        : AppTextDirection.ltr;
  }
}
