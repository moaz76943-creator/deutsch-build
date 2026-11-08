// Sovereign Comparative Syntax Core - Task 2820
class Task2820Engine {
  static const int taskId = 2820;
  static const String identifier = 'korrespondierend_mit_daten';
  static const String comparativePhrase = 'korrespondierend mit';
  static const String arabicMeaning = 'مناظراً ومطابقاً لمخرجات القياسات المعملية';
  static const String cefrLevel = 'C1';
  static const String syntacticCategory = 'Korrelative Kongruenz';
  static const String audioAssetPath = 'assets/audio/comparative/task_2820_korrespondierend_mit_daten.ogg';
  static const String exampleGerman = 'Die Testergebnisse fallen korrespondierend mit der Theorie aus.';
  static const String exampleArabic = 'نتائج الفحص تأتي مناظرة تماماً للنموذج النظري.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'id': identifier, 'phrase': comparativePhrase,
    'arabic': arabicMeaning, 'cefr': cefrLevel, 'category': syntacticCategory,
    'audio': audioAssetPath, 'ex_de': exampleGerman, 'ex_ar': exampleArabic,
  };

  static bool validate() => comparativePhrase.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
