// Sovereign Comparative Syntax Core - Task 2819
class Task2819Engine {
  static const int taskId = 2819;
  static const String identifier = 'im_direkten_vergleich';
  static const String comparativePhrase = 'im direkten Vergleich';
  static const String arabicMeaning = 'بالمقارنة المباشرة والميدانية بين النموذجين';
  static const String cefrLevel = 'B1';
  static const String syntacticCategory = 'Gegenüberstellung';
  static const String audioAssetPath = 'assets/audio/comparative/task_2819_im_direkten_vergleich.ogg';
  static const String exampleGerman = 'Im direkten Vergleich übertrifft die HNSW-Suche lineare Scans.';
  static const String exampleArabic = 'بالمقارنة المباشرة، يتفوق بحث HNSW على المسح الخطي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'id': identifier, 'phrase': comparativePhrase,
    'arabic': arabicMeaning, 'cefr': cefrLevel, 'category': syntacticCategory,
    'audio': audioAssetPath, 'ex_de': exampleGerman, 'ex_ar': exampleArabic,
  };

  static bool validate() => comparativePhrase.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
