// Sovereign Precision Operator Core - Task 2848
class Task2848Engine {
  static const int taskId = 2848;
  static const String identifier = 'ausnahmsweise_zulaessig';
  static const String precisionPhrase = 'ausnahmsweise zulässig';
  static const String arabicMeaning = 'جائز ومقبول على سبيل الاستثناء الحصري فقط';
  static const String cefrLevel = 'B2';
  static const String semanticCategory = 'Restriktive Ausnahme';
  static const String audioAssetPath = 'assets/audio/precision/task_2848_ausnahmsweise_zulaessig.ogg';
  static const String exampleGerman = 'Ein synchroner I/O-Schritt ist nur beim Booten ausnahmsweise zulässig.';
  static const String exampleArabic = 'خطوة الإدخال المتزامن مقصورة استثنائياً على مرحلة الإقلاع.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'id': identifier, 'phrase': precisionPhrase,
    'arabic': arabicMeaning, 'cefr': cefrLevel, 'category': semanticCategory,
    'audio': audioAssetPath, 'ex_de': exampleGerman, 'ex_ar': exampleArabic,
  };

  static bool validate() => precisionPhrase.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
