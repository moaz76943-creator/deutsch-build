import '../language/app_text_direction.dart';

/// Localization-specific direction resolver.
///
/// This extends the legacy Arabic-only fallback without changing the existing
/// language contract. Direction remains explicit metadata at runtime.
abstract final class LocaleDirectionProvider {
  static const Set<String> rtlLanguageCodes = <String>{
    'ar',
    'fa',
    'he',
    'ur',
    'ps',
  };

  static AppTextDirection resolve(String localeCode) {
    final primary = _primaryLanguage(localeCode);
    return rtlLanguageCodes.contains(primary)
        ? AppTextDirection.rtl
        : AppTextDirection.ltr;
  }

  static String _primaryLanguage(String localeCode) {
    final normalized = localeCode.trim().toLowerCase();
    if (normalized.isEmpty) {
      throw ArgumentError.value(localeCode, 'localeCode', 'must not be empty');
    }
    return normalized.split(RegExp(r'[-_]')).first;
  }
}
