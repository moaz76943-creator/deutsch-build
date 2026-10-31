/// Deep localization profile for native Malay (Bahasa Melayu) speakers.
class MalayDeepLocalizationProfile {
  static const String localeCode = 'ms';
  static const String languageName = 'Bahasa Melayu (Malay)';
  static const bool isRtl = false;
  static const String defaultWordOrder = 'SVO';

  /// Explains German plural formation in contrast to Malay reduplication (Kata Ganda).
  static String getPluralFormationGuidance() {
    return 'Dalam Bahasa Melayu, kata jamak dibentuk melalui penggandaan (cth: buku -> buku-buku, kanak -> kanak-kanak). '
        'Sebaliknya dalam Bahasa Jerman, bentuk jamak mempunyai pelbagai akhiran (-e, -er, -en, -s) serta perubahan vokal Umlaut '
        '(cth: das Buch -> die Bücher, der Mann -> die Männer).';
  }

  /// Explains natural SVO syntactic harmony between German and Malay main clauses.
  static bool hasSharedMainClauseSvoOrder() => true;
}
