// Sovereign System Evaluation Core - Task 2631
class Task2631Engine {
  static const int taskId = 2631;
  static const String identifier = 'in_anbetracht_des_umstands';
  static const String phraseGerman = 'in Anbetracht des Umstands, dass';
  static const String arabicMeaning = 'نظراً للحقيقة الثابتة والملموسة بأن';
  static const String cefrLevel = 'C1';
  static const String discourseCategory = 'Faktische Kausalität';
  static const String audioAssetPath = 'assets/audio/eval/task_2631_in_anbetracht_des_umstands.ogg';
  static const String exampleGerman = 'In Anbetracht des Umstands, dass der Speicher begrenzt ist, cachen wir selektiv.';
  static const String exampleArabic = 'نظراً للحقيقة بأن الذاكرة محدودة، نتبع تخزيناً مؤقتاً انتقائياً.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'id': identifier, 'phrase': phraseGerman,
    'arabic': arabicMeaning, 'cefr': cefrLevel, 'category': discourseCategory,
    'audio': audioAssetPath, 'ex_de': exampleGerman, 'ex_ar': exampleArabic,
  };

  static bool validate() => phraseGerman.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
