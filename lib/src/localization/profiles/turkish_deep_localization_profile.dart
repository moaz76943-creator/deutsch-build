/// Vowel harmony type in Turkish agglutinative morphology.
enum VowelClass { front, back }

/// Deep localization profile for native Turkish speakers learning German syntax and morphology.
class TurkishDeepLocalizationProfile {
  static const String localeCode = 'tr';
  static const String languageName = 'Türkçe (Turkish)';
  static const bool isRtl = false;
  static const String defaultWordOrder = 'SOV';

  static const Set<String> frontVowels = {'e', 'i', 'ö', 'ü'};
  static const Set<String> backVowels = {'a', 'ı', 'o', 'u'};

  /// Determines front or back vowel classification for 2-way vowel harmony.
  static VowelClass classifyVowelHarmony(String word) {
    for (int i = word.length - 1; i >= 0; i--) {
      final ch = word[i].toLowerCase();
      if (frontVowels.contains(ch)) return VowelClass.front;
      if (backVowels.contains(ch)) return VowelClass.back;
    }
    return VowelClass.front;
  }

  /// Syntactic guidance mapping Turkish verb-final (SOV) to German V2 main clause word order.
  static String getSyntacticTransferWarning() {
    return 'Dikkat: Türkçede fiil cümlenin sonundadır (SOV), ancak Almanca ana cümlede çekimli fiil daima 2. sıradadır (V2 kuralı). '
        'Örnek: "Ben bugün elma yiyorum" -> "Ich esse heute einen Apfel." (Ich heute esse DEĞİL!)';
  }
}
