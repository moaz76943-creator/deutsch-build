// Sovereign System Evaluation Core - Task 2729
class Task2729Engine {
  static const int taskId = 2729;
  static const String identifier = 'bei_differenzierter_betrachtung';
  static const String phraseGerman = 'bei differenzierter Betrachtung';
  static const String arabicMeaning = 'عند الفحص الدقيق والتحليل المفصل للنتائج والبيانات';
  static const String cefrLevel = 'C1';
  static const String evaluativeCategory = 'Analytische Differenzierung';
  static const String audioAssetPath = 'assets/audio/evaluative/task_2729_bei_differenzierter_betrachtung.ogg';
  static const String exampleGerman = 'Bei differenzierter Betrachtung zeigt sich der wahre Durchsatzgewinn.';
  static const String exampleArabic = 'عند الفحص الدقيق، يتضح المردود الحقيقي لمعدل تدفق البيانات.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'id': identifier, 'phrase': phraseGerman,
    'arabic': arabicMeaning, 'cefr': cefrLevel, 'category': evaluativeCategory,
    'audio': audioAssetPath, 'ex_de': exampleGerman, 'ex_ar': exampleArabic,
  };

  static bool validate() => phraseGerman.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
