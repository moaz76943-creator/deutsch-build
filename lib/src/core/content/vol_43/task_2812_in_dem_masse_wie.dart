// Sovereign Comparative Syntax Core - Task 2812
class Task2812Engine {
  static const int taskId = 2812;
  static const String identifier = 'in_dem_masse_wie';
  static const String comparativePhrase = 'in dem Maße, wie';
  static const String arabicMeaning = 'بالمقدار ذاته الذي تتطور به المتطلبات والأنظمة';
  static const String cefrLevel = 'C1';
  static const String syntacticCategory = 'Proportionale Entsprechung';
  static const String audioAssetPath = 'assets/audio/comparative/task_2812_in_dem_masse_wie.ogg';
  static const String exampleGerman = 'In dem Maße, wie der Cache wächst, sinkt die mittlere Zugriffslatenz.';
  static const String exampleArabic = 'بالمقدار الذي يتسع به الكاش، ينخفض وسيط زمن الاستجابة.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'id': identifier, 'phrase': comparativePhrase,
    'arabic': arabicMeaning, 'cefr': cefrLevel, 'category': syntacticCategory,
    'audio': audioAssetPath, 'ex_de': exampleGerman, 'ex_ar': exampleArabic,
  };

  static bool validate() => comparativePhrase.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
