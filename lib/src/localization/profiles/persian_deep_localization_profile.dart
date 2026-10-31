/// Indo-European ancestral cognate between Persian and German.
class PersianGermanCognate {
  final String persianWord;
  final String germanWord;
  final String ancestralMeaningAr;

  const PersianGermanCognate({
    required this.persianWord,
    required this.germanWord,
    required this.ancestralMeaningAr,
  });
}

/// Deep localization profile for native Persian (Farsi) speakers learning German.
class PersianDeepLocalizationProfile {
  static const String localeCode = 'fa';
  static const String languageName = 'فارسی (Persian)';
  static const bool isRtl = true;

  static const List<PersianGermanCognate> ancestralCognates = [
    PersianGermanCognate(persianWord: 'مادر (Mādar)', germanWord: 'Mutter', ancestralMeaningAr: 'الأم'),
    PersianGermanCognate(persianWord: 'برادر (Barādar)', germanWord: 'Bruder', ancestralMeaningAr: 'الأخ'),
    PersianGermanCognate(persianWord: 'نام (Nām)', germanWord: 'Name', ancestralMeaningAr: 'الاسم'),
    PersianGermanCognate(persianWord: 'ستاره (Setāreh)', germanWord: 'Stern', ancestralMeaningAr: 'النجم'),
    PersianGermanCognate(persianWord: 'است (Ast)', germanWord: 'Ist', ancestralMeaningAr: 'يكون (فعل الكينونة)'),
  ];

  /// Verifies presence of Persian extended characters (گ، چ، پ، ژ).
  static bool containsPersianSpecificLetters(String text) {
    final persianSpecificRegex = RegExp(r'[گچپژ]');
    return persianSpecificRegex.hasMatch(text);
  }
}
