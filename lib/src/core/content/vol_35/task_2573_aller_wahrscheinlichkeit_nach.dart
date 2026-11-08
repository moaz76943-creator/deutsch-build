// Sovereign Evidential Discourse Core - Task 2573
class Task2573Engine {
  static const int taskId = 2573;
  static const String identifier = 'aller_wahrscheinlichkeit_nach';
  static const String evidentialPhrase = 'aller Wahrscheinlichkeit nach';
  static const String arabicMeaning = 'بما يرجحه الظن الغالب استناداً للمؤشرات';
  static const String cefrLevel = 'B2';
  static const String epistemicsCategory = 'Hohe Plausibilität';
  static const String audioAssetPath = 'assets/audio/evidentials/task_2573_aller_wahrscheinlichkeit_nach.ogg';
  static const String exampleGerman = 'Aller Wahrscheinlichkeit nach liegt ein Konfigurationsfehler vor.';
  static const String exampleArabic = 'بما يرجحه الظن الغالب، يرجع السبب لخطأ في الإعدادات.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'id': identifier, 'phrase': evidentialPhrase,
    'arabic': arabicMeaning, 'cefr': cefrLevel, 'category': epistemicsCategory,
    'audio': audioAssetPath, 'ex_de': exampleGerman, 'ex_ar': exampleArabic,
  };

  static bool validate() => evidentialPhrase.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
