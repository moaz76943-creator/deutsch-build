// Sovereign Functional Verb Core - Task 2218
class Task2218Engine {
  static const int taskId = 2218;
  static const String identifier = 'zur_verantwortung_ziehen';
  static const String phraseGerman = 'zur Verantwortung ziehen';
  static const String arabicMeaning = 'يحاسب / يحمل المسؤولية';
  static const String ipaTranscription = '[tsuːɐ̯ fɛɐ̯ˈʔantvɔʁtʊŋ ˈtsiːən]';
  static const String cefrLevel = 'C1';
  static const String simpleVerbEquivalent = 'belangen / haftbar machen';
  static const String audioAssetPath = 'assets/audio/fvg/task_2218_zur_verantwortung_ziehen.ogg';
  static const String exampleGerman = 'Man zieht die Verantwortlichen zur Rechenschaft.';
  static const String exampleArabic = 'تتم محاسبة المسؤولين ومساءلتهم.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'id': identifier, 'phrase': phraseGerman,
    'arabic': arabicMeaning, 'ipa': ipaTranscription, 'cefr': cefrLevel,
    'equivalent': simpleVerbEquivalent, 'audio': audioAssetPath,
    'ex_de': exampleGerman, 'ex_ar': exampleArabic,
  };

  static bool validate() => phraseGerman.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
