class LanguageRecord {
  final String code;
  final String nativeName;
  final String englishName;

  const LanguageRecord({
    required this.code,
    required this.nativeName,
    required this.englishName,
  });

  Map<String, dynamic> toJson() => {
    'code': code,
    'nativeName': nativeName,
    'englishName': englishName,
  };

  factory LanguageRecord.fromJson(Map<String, dynamic> json) => LanguageRecord(
    code: json['code'] ?? '',
    nativeName: json['nativeName'] ?? '',
    englishName: json['englishName'] ?? '',
  );
}

class LanguageRegistry {
  static const List<LanguageRecord> supportedLanguages = [
    LanguageRecord(code: 'de', nativeName: 'Deutsch', englishName: 'German'),
    LanguageRecord(code: 'ar', nativeName: 'العربية', englishName: 'Arabic'),
    LanguageRecord(code: 'en', nativeName: 'English', englishName: 'English'),
  ];

  static List<LanguageRecord> getSupportedLanguages() {
    return supportedLanguages;
  }

  static bool isSupported(String code) {
    return supportedLanguages.any((lang) => lang.code == code);
  }
}
