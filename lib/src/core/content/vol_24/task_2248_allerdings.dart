// Sovereign Adverbial Modifier Core - Task 2248
class Task2248Engine {
  static const int taskId = 2248;
  static const String identifier = 'allerdings';
  static const String adverbGerman = 'allerdings';
  static const String arabicMeaning = 'غير أن / ولكن من زاوية أخرى';
  static const String ipaTranscription = '[ʔalɐˈdɪŋs]';
  static const String cefrLevel = 'B1';
  static const String grammaticalCategory = 'Einschraenkung';
  static const String audioAssetPath = 'assets/audio/adv/task_2248_allerdings.ogg';
  static const String exampleGerman = 'Die Idee ist gut, allerdings teuer.';
  static const String exampleArabic = 'الفكرة جيدة، غير أنها مكلفة مالياً.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'id': identifier, 'adverb': adverbGerman,
    'arabic': arabicMeaning, 'ipa': ipaTranscription, 'cefr': cefrLevel,
    'category': grammaticalCategory, 'audio': audioAssetPath,
    'ex_de': exampleGerman, 'ex_ar': exampleArabic,
  };

  static bool validate() => adverbGerman.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
