// Sovereign System Evaluation Core - Task 2639
class Task2639Engine {
  static const int taskId = 2639;
  static const String identifier = 'bei_differenzierter_betrachtung';
  static const String phraseGerman = 'bei differenzierter Betrachtung';
  static const String arabicMeaning = 'عند الفحص الدقيق والتحليل المفصل للنتائج';
  static const String cefrLevel = 'C1';
  static const String discourseCategory = 'Analytische Differenzierung';
  static const String audioAssetPath = 'assets/audio/eval/task_2639_bei_differenzierter_betrachtung.ogg';
  static const String exampleGerman = 'Bei differenzierter Betrachtung zeigt sich der wahre Flaschenhals.';
  static const String exampleArabic = 'عند الفحص الدقيق، يتبين عنق الزجاجة الفعلي في النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'id': identifier, 'phrase': phraseGerman,
    'arabic': arabicMeaning, 'cefr': cefrLevel, 'category': discourseCategory,
    'audio': audioAssetPath, 'ex_de': exampleGerman, 'ex_ar': exampleArabic,
  };

  static bool validate() => phraseGerman.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
