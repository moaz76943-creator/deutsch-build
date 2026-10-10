enum AppTargetLanguage {
  german('de', 'الألمانية', 'Deutsch'),
  english('en', 'الإنجليزية', 'English'),
  french('fr', 'الفرنسية', 'Français'),
  spanish('es', 'الإسبانية', 'Español');

  final String code;
  final String arabicName;
  final String nativeName;

  const AppTargetLanguage(this.code, this.arabicName, this.nativeName);

  static AppTargetLanguage fromCode(String code) {
    return AppTargetLanguage.values.firstWhere(
      (lang) => lang.code == code,
      orElse: () => AppTargetLanguage.german,
    );
  }
}
