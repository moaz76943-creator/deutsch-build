// Sovereign Concessive Operator Core - Task 2782
class Task2782Engine {
  static const int taskId = 2782;
  static const String identifier = 'wenngleich_eingeschraenkt';
  static const String phraseGerman = 'wenngleich';
  static const String arabicMeaning = 'وإن كان ذلك مقترناً بقيود مرحلية معلومة';
  static const String cefrLevel = 'C1';
  static const String grammaticalCategory = 'Konzessive Subjunktion';
  static const String audioAssetPath = 'assets/audio/concessive/task_2782_wenngleich_eingeschraenkt.ogg';
  static const String exampleGerman = 'Der Durchsatz steigt, wenngleich unter erhöhtem Speicherbedarf.';
  static const String exampleArabic = 'الإنتاجية تتصاعد، وإن كان ذلك مصحوباً باستهلاك إضافي للذاكرة.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'id': identifier, 'phrase': phraseGerman,
    'arabic': arabicMeaning, 'cefr': cefrLevel, 'category': grammaticalCategory,
    'audio': audioAssetPath, 'ex_de': exampleGerman, 'ex_ar': exampleArabic,
  };

  static bool validate() => phraseGerman.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
