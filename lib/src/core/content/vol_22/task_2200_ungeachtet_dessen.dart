// Sovereign Syntax Connector Core - Task 2200
class Task2200Engine {
  static const int taskId = 2200;
  static const String identifier = 'ungeachtet_dessen';
  static const String connector = 'ungeachtet dessen';
  static const String arabicMeaning = 'على الرغم من ذلك / بصرف النظر عن ذلك';
  static const String cefrLevel = 'C1';
  static const String syntaxRule = 'Adverbialer Konnektor';
  static const String audioAssetPath = 'assets/audio/connectors/task_2200_ungeachtet_dessen.ogg';
  static const String exampleGerman = 'Ungeachtet dessen setzen wir das Projekt fort.';
  static const String exampleArabic = 'بصرف النظر عن ذلك، سنواصل المشروع.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'id': identifier, 'connector': connector,
    'arabic': arabicMeaning, 'cefr': cefrLevel, 'syntax': syntaxRule,
    'audio': audioAssetPath, 'ex_de': exampleGerman, 'ex_ar': exampleArabic,
  };

  static bool validate() => connector.isNotEmpty && exampleGerman.isNotEmpty;
}
