// Sovereign Regulatory Normative Core - Task 2661
class Task2661Engine {
  static const int taskId = 2661;
  static const String identifier = 'zwingend_vorgeschrieben';
  static const String normativePhrase = 'ist zwingend vorgeschrieben';
  static const String arabicMeaning = 'منصوص عليه إلزاماً ولا يقبل الاستثناء';
  static const String cefrLevel = 'C1';
  static const String regulatoryCategory = 'Normative Pflicht';
  static const String audioAssetPath = 'assets/audio/regulatory/task_2661_zwingend_vorgeschrieben.ogg';
  static const String exampleGerman = 'Die Verschlüsselung ruhender Daten ist zwingend vorgeschrieben.';
  static const String exampleArabic = 'تشفير البيانات الخاملة منصوص عليه إلزاماً في المعايير.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'id': identifier, 'phrase': normativePhrase,
    'arabic': arabicMeaning, 'cefr': cefrLevel, 'category': regulatoryCategory,
    'audio': audioAssetPath, 'ex_de': exampleGerman, 'ex_ar': exampleArabic,
  };

  static bool validate() => normativePhrase.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
