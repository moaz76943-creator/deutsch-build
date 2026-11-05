// Sovereign Syntax Connector Core - Task 2194
class Task2194Engine {
  static const int taskId = 2194;
  static const String identifier = 'umso_mehr_als';
  static const String connector = 'umso mehr, als';
  static const String arabicMeaning = 'لا سيما وأن / بالأخص لأن';
  static const String cefrLevel = 'C1';
  static const String syntaxRule = 'Kausalsatz';
  static const String audioAssetPath = 'assets/audio/connectors/task_2194_umso_mehr_als.ogg';
  static const String exampleGerman = 'Ich freue mich, umso mehr, als Sie da sind.';
  static const String exampleArabic = 'يسعدني ذلك، لا سيما وأنك حاضر معنا.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'id': identifier, 'connector': connector,
    'arabic': arabicMeaning, 'cefr': cefrLevel, 'syntax': syntaxRule,
    'audio': audioAssetPath, 'ex_de': exampleGerman, 'ex_ar': exampleArabic,
  };

  static bool validate() => connector.isNotEmpty && exampleGerman.isNotEmpty;
}
