// Sovereign Adverbial Modifier Core - Task 2247
class Task2247Engine {
  static const int taskId = 2247;
  static const String identifier = 'keineswegs';
  static const String adverbGerman = 'keineswegs';
  static const String arabicMeaning = 'على الإطلاق / ليس بتاتاً';
  static const String ipaTranscription = '[ˈkaɪ̯nəsˌveːks]';
  static const String cefrLevel = 'B2';
  static const String grammaticalCategory = 'Negationsverstaerker';
  static const String audioAssetPath = 'assets/audio/adv/task_2247_keineswegs.ogg';
  static const String exampleGerman = 'Die Methode ist keineswegs veraltet.';
  static const String exampleArabic = 'المنهجية ليست قديمة على الإطلاق.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'id': identifier, 'adverb': adverbGerman,
    'arabic': arabicMeaning, 'ipa': ipaTranscription, 'cefr': cefrLevel,
    'category': grammaticalCategory, 'audio': audioAssetPath,
    'ex_de': exampleGerman, 'ex_ar': exampleArabic,
  };

  static bool validate() => adverbGerman.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
