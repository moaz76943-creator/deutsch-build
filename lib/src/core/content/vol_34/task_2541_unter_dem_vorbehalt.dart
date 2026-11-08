// Sovereign Pragmatic Operator Core - Task 2541
class Task2541Engine {
  static const int taskId = 2541;
  static const String identifier = 'unter_dem_vorbehalt';
  static const String pragmaticOperator = 'unter dem Vorbehalt, dass';
  static const String arabicMeaning = 'بشرط احترازي معلق على استيفاء معيار أمني';
  static const String cefrLevel = 'C1';
  static const String semanticCategory = 'Restriktive Kondition';
  static const String audioAssetPath = 'assets/audio/pragmatics/task_2541_unter_dem_vorbehalt.ogg';
  static const String exampleGerman = 'Die Freigabe erfolgt unter dem Vorbehalt, dass der Pentest besteht.';
  static const String exampleArabic = 'تتم الموافقة بشرط اجتياز فحص الاختراق الأمني.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'id': identifier, 'phrase': pragmaticOperator,
    'arabic': arabicMeaning, 'cefr': cefrLevel, 'category': semanticCategory,
    'audio': audioAssetPath, 'ex_de': exampleGerman, 'ex_ar': exampleArabic,
  };

  static bool validate() => pragmaticOperator.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
