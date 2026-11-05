// Sovereign Syntax Connector Core - Task 2199
class Task2199Engine {
  static const int taskId = 2199;
  static const String identifier = 'zumal';
  static const String connector = 'zumal';
  static const String arabicMeaning = 'خاصة وأن / لا سيما أن';
  static const String cefrLevel = 'C1';
  static const String syntaxRule = 'Kausale Begruendung';
  static const String audioAssetPath = 'assets/audio/connectors/task_2199_zumal.ogg';
  static const String exampleGerman = 'Wir bleiben hier, zumal es draussen stuermt.';
  static const String exampleArabic = 'سنبقى هنا، خاصة وأن الجو عاصف بالخارج.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'id': identifier, 'connector': connector,
    'arabic': arabicMeaning, 'cefr': cefrLevel, 'syntax': syntaxRule,
    'audio': audioAssetPath, 'ex_de': exampleGerman, 'ex_ar': exampleArabic,
  };

  static bool validate() => connector.isNotEmpty && exampleGerman.isNotEmpty;
}
