// مسار الملف: lib/core/text/language_identity.dart

enum WritingDirection { ltr, rtl }

/// الهوية اللغوية الكاملة (كما حددها خبير اللسانيات في التقرير)
/// تدعم 100+ لغة وتفصل بين رمز اللغة، ونظام الكتابة، واتجاه النص.
class LanguageIdentity {
  final String languageCode;
  final String? scriptCode;
  final String? regionCode;
  final WritingDirection writingDirection;
  final String typographyProfile;
  final String tokenizerProfile;
  final String normalizationProfile;

  const LanguageIdentity({
    required this.languageCode,
    this.scriptCode,
    this.regionCode,
    required this.writingDirection,
    required this.typographyProfile,
    required this.tokenizerProfile,
    required this.normalizationProfile,
  });

  /// تطبيق صارم لسياسة المحتوى: حظر قطعي لأي نصوص تتبع العبرية (he/iw)
  static bool isLanguageAllowed(String code) {
    final prefix = code.toLowerCase().trim();
    if (prefix.startsWith('he') || prefix.startsWith('iw')) return false;
    return true;
  }
}
