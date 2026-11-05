// Sovereign Syntax Connector Core - Task 2195
class Task2195Engine {
  static const int taskId = 2195;
  static const String identifier = 'anstatt_dass';
  static const String connector = 'anstatt dass';
  static const String arabicMeaning = 'بدلاً من أن';
  static const String cefrLevel = 'B2';
  static const String syntaxRule = 'Subjunktion';
  static const String audioAssetPath = 'assets/audio/connectors/task_2195_anstatt_dass.ogg';
  static const String exampleGerman = 'Er wartete, anstatt dass er handelte.';
  static const String exampleArabic = 'ظل ينتظر بدلاً من أن يبادر بالعمل.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'id': identifier, 'connector': connector,
    'arabic': arabicMeaning, 'cefr': cefrLevel, 'syntax': syntaxRule,
    'audio': audioAssetPath, 'ex_de': exampleGerman, 'ex_ar': exampleArabic,
  };

  static bool validate() => connector.isNotEmpty && exampleGerman.isNotEmpty;
}
