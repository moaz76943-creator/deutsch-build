// Sovereign Syntax Connector Core - Task 2196
class Task2196Engine {
  static const int taskId = 2196;
  static const String identifier = 'ohne_dass';
  static const String connector = 'ohne dass';
  static const String arabicMeaning = 'دون أن / من غير أن';
  static const String cefrLevel = 'B2';
  static const String syntaxRule = 'Modalsatz';
  static const String audioAssetPath = 'assets/audio/connectors/task_2196_ohne_dass.ogg';
  static const String exampleGerman = 'Sie ging, ohne dass jemand es bemerkte.';
  static const String exampleArabic = 'غادرت دون أن يلاحظ أحد ذلك.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'id': identifier, 'connector': connector,
    'arabic': arabicMeaning, 'cefr': cefrLevel, 'syntax': syntaxRule,
    'audio': audioAssetPath, 'ex_de': exampleGerman, 'ex_ar': exampleArabic,
  };

  static bool validate() => connector.isNotEmpty && exampleGerman.isNotEmpty;
}
