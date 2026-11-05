// Sovereign Syntax Connector Core - Task 2192
class Task2192Engine {
  static const int taskId = 2192;
  static const String identifier = 'je_nachdem_ob';
  static const String connector = 'je nachdem, ob';
  static const String arabicMeaning = 'بحسب ما إذا / وفقاً لـ';
  static const String cefrLevel = 'B2';
  static const String syntaxRule = 'Indirekter Fragesatz';
  static const String audioAssetPath = 'assets/audio/connectors/task_2192_je_nachdem_ob.ogg';
  static const String exampleGerman = 'Wir entscheiden je nachdem, ob die Mittel reichen.';
  static const String exampleArabic = 'سنقرر بحسب ما إذا كانت الموارد كافية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'id': identifier, 'connector': connector,
    'arabic': arabicMeaning, 'cefr': cefrLevel, 'syntax': syntaxRule,
    'audio': audioAssetPath, 'ex_de': exampleGerman, 'ex_ar': exampleArabic,
  };

  static bool validate() => connector.isNotEmpty && exampleGerman.isNotEmpty;
}
