// Sovereign Comparative Syntax Core - Task 2814
class Task2814Engine {
  static const int taskId = 2814;
  static const String identifier = 'proportional_zum_aufwand';
  static const String comparativePhrase = 'proportional zu';
  static const String arabicMeaning = 'متناسب طردياً مع حجم ونوعية الجهد البرمجي';
  static const String cefrLevel = 'B2';
  static const String syntacticCategory = 'Lineare Relation';
  static const String audioAssetPath = 'assets/audio/comparative/task_2814_proportional_zum_aufwand.ogg';
  static const String exampleGerman = 'Der Durchsatz steigt proportional zur Anzahl der Worker-Isolate.';
  static const String exampleArabic = 'الإنتاجية ترتفع طردياً مع عدد عوازل المعالجة العاملة.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'id': identifier, 'phrase': comparativePhrase,
    'arabic': arabicMeaning, 'cefr': cefrLevel, 'category': syntacticCategory,
    'audio': audioAssetPath, 'ex_de': exampleGerman, 'ex_ar': exampleArabic,
  };

  static bool validate() => comparativePhrase.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
