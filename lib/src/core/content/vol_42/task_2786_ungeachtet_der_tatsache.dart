// Sovereign Concessive Operator Core - Task 2786
class Task2786Engine {
  static const int taskId = 2786;
  static const String identifier = 'ungeachtet_der_tatsache';
  static const String phraseGerman = 'ungeachtet der Tatsache, dass';
  static const String arabicMeaning = 'بصرف النظر كلياً عن الحقيقة القائلة بأن';
  static const String cefrLevel = 'C1';
  static const String grammaticalCategory = 'Präpositionaler Konzessivsatz';
  static const String audioAssetPath = 'assets/audio/concessive/task_2786_ungeachtet_der_tatsache.ogg';
  static const String exampleGerman = 'Ungeachtet der Tatsache, dass RAM knapp ist, halten wir den Index im Cache.';
  static const String exampleArabic = 'بصرف النظر عن ضيق الذاكرة، نبقي الفهرس في الكاش.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'id': identifier, 'phrase': phraseGerman,
    'arabic': arabicMeaning, 'cefr': cefrLevel, 'category': grammaticalCategory,
    'audio': audioAssetPath, 'ex_de': exampleGerman, 'ex_ar': exampleArabic,
  };

  static bool validate() => phraseGerman.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
