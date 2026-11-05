// Sovereign Functional Verb Core - Task 2219
class Task2219Engine {
  static const int taskId = 2219;
  static const String identifier = 'unter_beweis_stellen';
  static const String phraseGerman = 'unter Beweis stellen';
  static const String arabicMeaning = 'يبرهن ويثبت الجدارة عملياً';
  static const String ipaTranscription = '[ˈʊntɐ bəˈvaɪ̯s ˈʃtɛlən]';
  static const String cefrLevel = 'C1';
  static const String simpleVerbEquivalent = 'beweisen';
  static const String audioAssetPath = 'assets/audio/fvg/task_2219_unter_beweis_stellen.ogg';
  static const String exampleGerman = 'Er hat seine Kompetenz unter Beweis gestellt.';
  static const String exampleArabic = 'أثبت كفاءته وجدارته بالدليل العملي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'id': identifier, 'phrase': phraseGerman,
    'arabic': arabicMeaning, 'ipa': ipaTranscription, 'cefr': cefrLevel,
    'equivalent': simpleVerbEquivalent, 'audio': audioAssetPath,
    'ex_de': exampleGerman, 'ex_ar': exampleArabic,
  };

  static bool validate() => phraseGerman.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
