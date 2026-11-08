// Sovereign Evaluative Operator Core - Task 2604
class Task2604Engine {
  static const int taskId = 2604;
  static const String identifier = 'unter_zugrundelegung_der_daten';
  static const String evaluativePhrase = 'unter Zugrundelegung der Daten';
  static const String arabicMeaning = 'بناءً على الاستناد المباشر إلى البيانات المقاسة ميدانياً';
  static const String cefrLevel = 'C1';
  static const String discourseCategory = 'Empirische Fundierung';
  static const String audioAssetPath = 'assets/audio/evaluative/task_2604_unter_zugrundelegung_der_daten.ogg';
  static const String exampleGerman = 'Unter Zugrundelegung der Daten sank der Speicherverbrauch um 40 Prozent.';
  static const String exampleArabic = 'استناداً للبيانات، انخفض استهلاك الذاكرة بمقدار أربعين بالمئة.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'id': identifier, 'phrase': evaluativePhrase,
    'arabic': arabicMeaning, 'cefr': cefrLevel, 'category': discourseCategory,
    'audio': audioAssetPath, 'ex_de': exampleGerman, 'ex_ar': exampleArabic,
  };

  static bool validate() => evaluativePhrase.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
