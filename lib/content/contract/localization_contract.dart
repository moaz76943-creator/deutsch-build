// Localization & Direction Contract - Post-V1 Expansion
// Manages text direction, RTL/LTR rules, and locale policies

enum TextDirectionType { ltr, rtl }

class LocalizationContract {
  final String languageCode;
  final TextDirectionType textDirection;
  final bool isSupported;

  const LocalizationContract({
    required this.languageCode,
    required this.textDirection,
    this.isSupported = true,
  });

  static TextDirectionType getDirectionForLanguage(String code) {
    if (code.toLowerCase() == 'ar') {
      return TextDirectionType.rtl;
    }
    return TextDirectionType.ltr;
  }
}
