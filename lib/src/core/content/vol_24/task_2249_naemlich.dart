// Sovereign Adverbial Modifier Core - Task 2249
class Task2249Engine {
  static const int taskId = 2249;
  static const String identifier = 'naemlich';
  static const String adverbGerman = 'nämlich';
  static const String arabicMeaning = 'ذلك أن / للتوضيح والتعليل';
  static const String ipaTranscription = '[ˈnɛːmlɪç]';
  static const String cefrLevel = 'B1';
  static const String grammaticalCategory = 'Begruendung';
  static const String audioAssetPath = 'assets/audio/adv/task_2249_naemlich.ogg';
  static const String exampleGerman = 'Er kommt spaeter, er arbeitet nämlich.';
  static const String exampleArabic = 'سيأتي لاحقاً، ذلك أنه منشغل بالعمل.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'id': identifier, 'adverb': adverbGerman,
    'arabic': arabicMeaning, 'ipa': ipaTranscription, 'cefr': cefrLevel,
    'category': grammaticalCategory, 'audio': audioAssetPath,
    'ex_de': exampleGerman, 'ex_ar': exampleArabic,
  };

  static bool validate() => adverbGerman.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
