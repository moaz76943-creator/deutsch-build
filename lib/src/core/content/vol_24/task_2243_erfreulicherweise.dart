// Sovereign Adverbial Modifier Core - Task 2243
class Task2243Engine {
  static const int taskId = 2243;
  static const String identifier = 'erfreulicherweise';
  static const String adverbGerman = 'erfreulicherweise';
  static const String arabicMeaning = 'من دواعي السرور / لحسن الحظ';
  static const String ipaTranscription = '[ʔɛɐ̯ˈfʁɔɪ̯lɪçɐˌvaɪ̯zə]';
  static const String cefrLevel = 'B2';
  static const String grammaticalCategory = 'Satzadverb';
  static const String audioAssetPath = 'assets/audio/adv/task_2243_erfreulicherweise.ogg';
  static const String exampleGerman = 'Erfreulicherweise stiegen die Resultate.';
  static const String exampleArabic = 'من دواعي السرور أن النتائج ارتفعت.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'id': identifier, 'adverb': adverbGerman,
    'arabic': arabicMeaning, 'ipa': ipaTranscription, 'cefr': cefrLevel,
    'category': grammaticalCategory, 'audio': audioAssetPath,
    'ex_de': exampleGerman, 'ex_ar': exampleArabic,
  };

  static bool validate() => adverbGerman.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
