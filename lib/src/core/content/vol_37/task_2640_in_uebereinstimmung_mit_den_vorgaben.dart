// Sovereign System Evaluation Core - Task 2640
class Task2640Engine {
  static const int taskId = 2640;
  static const String identifier = 'in_uebereinstimmung_mit_den_vorgaben';
  static const String phraseGerman = 'in Übereinstimmung mit den Vorgaben';
  static const String arabicMeaning = 'بما يتطابق حرفياً مع المتطلبات المحددة';
  static const String cefrLevel = 'B2';
  static const String discourseCategory = 'Normative Ausrichtung';
  static const String audioAssetPath = 'assets/audio/eval/task_2640_in_uebereinstimmung_mit_den_vorgaben.ogg';
  static const String exampleGerman = 'Der Ablauf erfolgt in Übereinstimmung mit den Vorgaben.';
  static const String exampleArabic = 'يسير التنفيذ بما يتطابق كلياً مع الشروط المعتمدة.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'id': identifier, 'phrase': phraseGerman,
    'arabic': arabicMeaning, 'cefr': cefrLevel, 'category': discourseCategory,
    'audio': audioAssetPath, 'ex_de': exampleGerman, 'ex_ar': exampleArabic,
  };

  static bool validate() => phraseGerman.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
