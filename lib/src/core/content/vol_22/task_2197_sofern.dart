// Sovereign Syntax Connector Core - Task 2197
class Task2197Engine {
  static const int taskId = 2197;
  static const String identifier = 'sofern';
  static const String connector = 'sofern';
  static const String arabicMeaning = 'شريطة أن / إذا ما';
  static const String cefrLevel = 'B2';
  static const String syntaxRule = 'Konditionalsatz';
  static const String audioAssetPath = 'assets/audio/connectors/task_2197_sofern.ogg';
  static const String exampleGerman = 'Wir liefern, sofern die Ware verfuegbar ist.';
  static const String exampleArabic = 'سنقوم بالتوريد شريطة توفر البضائع.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'id': identifier, 'connector': connector,
    'arabic': arabicMeaning, 'cefr': cefrLevel, 'syntax': syntaxRule,
    'audio': audioAssetPath, 'ex_de': exampleGerman, 'ex_ar': exampleArabic,
  };

  static bool validate() => connector.isNotEmpty && exampleGerman.isNotEmpty;
}
