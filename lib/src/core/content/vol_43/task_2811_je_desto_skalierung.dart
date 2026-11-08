// Sovereign Comparative Syntax Core - Task 2811
class Task2811Engine {
  static const int taskId = 2811;
  static const String identifier = 'je_desto_skalierung';
  static const String comparativePhrase = 'je ..., desto';
  static const String arabicMeaning = 'كلما زادت أبعاد المشكلة، كلما تعين التدقيق المعماري';
  static const String cefrLevel = 'C1';
  static const String syntacticCategory = 'Proportionaler Komparativ';
  static const String audioAssetPath = 'assets/audio/comparative/task_2811_je_desto_skalierung.ogg';
  static const String exampleGerman = 'Je größer die Datenmenge, desto wichtiger ist die Vektorindizierung.';
  static const String exampleArabic = 'كلما تضخمت البيانات، كلما زادت أهمية الفهرسة المتجهية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'id': identifier, 'phrase': comparativePhrase,
    'arabic': arabicMeaning, 'cefr': cefrLevel, 'category': syntacticCategory,
    'audio': audioAssetPath, 'ex_de': exampleGerman, 'ex_ar': exampleArabic,
  };

  static bool validate() => comparativePhrase.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
