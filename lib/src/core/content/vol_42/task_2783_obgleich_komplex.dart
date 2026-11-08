// Sovereign Concessive Operator Core - Task 2783
class Task2783Engine {
  static const int taskId = 2783;
  static const String identifier = 'obgleich_komplex';
  static const String phraseGerman = 'obgleich';
  static const String arabicMeaning = 'على الرغم من التعقيد الرياضي والبرمجي المتأصل';
  static const String cefrLevel = 'B2';
  static const String grammaticalCategory = 'Konzessiver Nebensatz';
  static const String audioAssetPath = 'assets/audio/concessive/task_2783_obgleich_komplex.ogg';
  static const String exampleGerman = 'Der Algorithmus konvergiert schnell, obgleich er komplex aufgebaut ist.';
  static const String exampleArabic = 'الخوارزمية تتقارب سريعاً، على الرغم من تعقيد بنيتها.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'id': identifier, 'phrase': phraseGerman,
    'arabic': arabicMeaning, 'cefr': cefrLevel, 'category': grammaticalCategory,
    'audio': audioAssetPath, 'ex_de': exampleGerman, 'ex_ar': exampleArabic,
  };

  static bool validate() => phraseGerman.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
