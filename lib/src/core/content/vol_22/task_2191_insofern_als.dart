// Sovereign Syntax Connector Core - Task 2191
class Task2191Engine {
  static const int taskId = 2191;
  static const String identifier = 'insofern_als';
  static const String connector = 'insofern ... als';
  static const String arabicMeaning = 'من حيث إن / بقدر ما أن';
  static const String cefrLevel = 'C1';
  static const String syntaxRule = 'Nebensatz (Endstellung)';
  static const String audioAssetPath = 'assets/audio/connectors/task_2191_insofern_als.ogg';
  static const String exampleGerman = 'Das ist richtig, insofern als es belegt ist.';
  static const String exampleArabic = 'هذا صحيح بقدر ما أنه مثبت بالأدلة.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'id': identifier, 'connector': connector,
    'arabic': arabicMeaning, 'cefr': cefrLevel, 'syntax': syntaxRule,
    'audio': audioAssetPath, 'ex_de': exampleGerman, 'ex_ar': exampleArabic,
  };

  static bool validate() => connector.isNotEmpty && exampleGerman.isNotEmpty;
}
