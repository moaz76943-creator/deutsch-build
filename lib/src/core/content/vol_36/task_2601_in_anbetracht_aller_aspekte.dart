// Sovereign Evaluative Operator Core - Task 2601
class Task2601Engine {
  static const int taskId = 2601;
  static const String identifier = 'in_anbetracht_aller_aspekte';
  static const String evaluativePhrase = 'in Anbetracht aller Aspekte';
  static const String arabicMeaning = 'بالنظر الشامل إلى كافة الجوانب والمحددات المعمارية';
  static const String cefrLevel = 'C1';
  static const String discourseCategory = 'Ganzheitliche Evaluation';
  static const String audioAssetPath = 'assets/audio/evaluative/task_2601_in_anbetracht_aller_aspekte.ogg';
  static const String exampleGerman = 'In Anbetracht aller Aspekte ist die Offline-First-Strategie optimal.';
  static const String exampleArabic = 'بالنظر الشامل إلى كافة الجوانب، استراتيجية العمل دون اتصال هي المثلى.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'id': identifier, 'phrase': evaluativePhrase,
    'arabic': arabicMeaning, 'cefr': cefrLevel, 'category': discourseCategory,
    'audio': audioAssetPath, 'ex_de': exampleGerman, 'ex_ar': exampleArabic,
  };

  static bool validate() => evaluativePhrase.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
