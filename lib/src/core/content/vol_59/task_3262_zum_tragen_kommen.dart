// Sovereign High-Register Idiom Core - Task 3262
class Task3262Engine {
  static const int taskId = 3262;
  static const String identifier = 'zum_tragen_kommen';
  static const String idiomGerman = 'voll zum Tragen kommen';
  static const String arabicMeaning = 'يظهر أثره ومردوده الإيجابي بجلاء ووضوح تام';
  static const String cefrLevel = 'B2';
  static const String pragmaticCategory = 'Wirkungsentfaltung';
  static const String audioAssetPath = 'assets/audio/idioms/task_3262_zum_tragen_kommen.ogg';
  static const String exampleGerman = 'Die Vorteile des Caches kommen bei hoher Last voll zum Tragen.';
  static const String exampleArabic = 'تظهر مزايا الكاش بجلاء تام عند اشتداد الحمل.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'id': identifier, 'phrase': idiomGerman,
    'arabic': arabicMeaning, 'cefr': cefrLevel, 'category': pragmaticCategory,
    'audio': audioAssetPath, 'ex_de': exampleGerman, 'ex_ar': exampleArabic,
  };

  static bool validate() => idiomGerman.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
