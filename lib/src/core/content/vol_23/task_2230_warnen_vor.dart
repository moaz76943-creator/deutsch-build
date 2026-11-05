// Sovereign Prepositional Verb Core - Task 2230
class Task2230Engine {
  static const int taskId = 2230;
  static const String identifier = 'warnen_vor';
  static const String verbPreposition = 'warnen vor';
  static const String arabicMeaning = 'يحذر مسبقاً من خطر أو خطأ';
  static const String governedCase = 'vor + Dat';
  static const String cefrLevel = 'B1';
  static const String audioAssetPath = 'assets/audio/prep_verbs/task_2230_warnen_vor.ogg';
  static const String exampleGerman = 'Man warnt vor ungesicherten Netzwerken.';
  static const String exampleArabic = 'يجري التحذير من الشبكات غير الآمنة.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'id': identifier, 'verb_prep': verbPreposition,
    'arabic': arabicMeaning, 'case': governedCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'ex_de': exampleGerman, 'ex_ar': exampleArabic,
  };

  static bool validate() => verbPreposition.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
