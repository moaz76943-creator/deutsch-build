// Sovereign Comparative Syntax Core - Task 2813
class Task2813Engine {
  static const int taskId = 2813;
  static const String identifier = 'nach_massgabe_der_regeln';
  static const String comparativePhrase = 'nach Maßgabe der';
  static const String arabicMeaning = 'بموجب الضوابط والمعايير المعمارية المقررة رسمياً';
  static const String cefrLevel = 'C1';
  static const String syntacticCategory = 'Normative Richtschnur';
  static const String audioAssetPath = 'assets/audio/comparative/task_2813_nach_massgabe_der_regeln.ogg';
  static const String exampleGerman = 'Die Zuweisung erfolgt nach Maßgabe der verfügbaren Hardware-Threads.';
  static const String exampleArabic = 'يتم التخصيص بموجب خيوط المعالجة العتادية المتاحة.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'id': identifier, 'phrase': comparativePhrase,
    'arabic': arabicMeaning, 'cefr': cefrLevel, 'category': syntacticCategory,
    'audio': audioAssetPath, 'ex_de': exampleGerman, 'ex_ar': exampleArabic,
  };

  static bool validate() => comparativePhrase.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
