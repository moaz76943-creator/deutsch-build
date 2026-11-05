// Sovereign Syntax Connector Core - Task 2198
class Task2198Engine {
  static const int taskId = 2198;
  static const String identifier = 'indem';
  static const String connector = 'indem';
  static const String arabicMeaning = 'من خلال / عن طريق أن';
  static const String cefrLevel = 'B2';
  static const String syntaxRule = 'Instrumentalsatz';
  static const String audioAssetPath = 'assets/audio/connectors/task_2198_indem.ogg';
  static const String exampleGerman = 'Man spart Zeit, indem man automatisiert.';
  static const String exampleArabic = 'يوفر المرء الوقت من خلال الأتمتة.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'id': identifier, 'connector': connector,
    'arabic': arabicMeaning, 'cefr': cefrLevel, 'syntax': syntaxRule,
    'audio': audioAssetPath, 'ex_de': exampleGerman, 'ex_ar': exampleArabic,
  };

  static bool validate() => connector.isNotEmpty && exampleGerman.isNotEmpty;
}
