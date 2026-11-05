// Sovereign Participial Attribute Core - Task 2289
class Task2289Engine {
  static const int taskId = 2289;
  static const String identifier = 'vereinbarte_bedingungen';
  static const String participialPhrase = 'die im Vorfeld vereinbarten Bedingungen';
  static const String arabicMeaning = 'الشروط المتفق عليها مسبقاً';
  static const String syntacticType = 'Partizip II mit Temporalphrase';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/partizip/task_2289_vereinbarte_bedingungen.ogg';
  static const String exampleGerman = 'Die im Vorfeld vereinbarten Bedingungen gelten.';
  static const String exampleArabic = 'الشروط المتفق عليها سلفاً تظل سارية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'id': identifier, 'phrase': participialPhrase,
    'arabic': arabicMeaning, 'type': syntacticType, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'ex_de': exampleGerman, 'ex_ar': exampleArabic,
  };

  static bool validate() => participialPhrase.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
