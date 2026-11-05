// Sovereign Participial Attribute Core - Task 2281
class Task2281Engine {
  static const int taskId = 2281;
  static const String identifier = 'durchgefuehrte_analyse';
  static const String participialPhrase = 'die durchgeführte Analyse';
  static const String arabicMeaning = 'التحليل المنجز والمنفذ عملياً';
  static const String syntacticType = 'Partizip II (passivisch)';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/partizip/task_2281_durchgefuehrte_analyse.ogg';
  static const String exampleGerman = 'Die von Experten durchgeführte Analyse überzeugt.';
  static const String exampleArabic = 'التحليل الذي أجراه الخبراء مقنع للغاية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'id': identifier, 'phrase': participialPhrase,
    'arabic': arabicMeaning, 'type': syntacticType, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'ex_de': exampleGerman, 'ex_ar': exampleArabic,
  };

  static bool validate() => participialPhrase.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
