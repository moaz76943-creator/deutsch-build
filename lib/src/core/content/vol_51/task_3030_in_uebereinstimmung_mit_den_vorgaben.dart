// Sovereign System Evaluation Core - Task 3030
class Task3030Engine {
  static const int taskId = 3030;
  static const String identifier = 'in_uebereinstimmung_mit_den_vorgaben';
  static const String phraseGerman = 'in Übereinstimmung mit den Vorgaben';
  static const String arabicMeaning = 'بما يطابق حرفياً الشروط الفنية والمتطلبات المقررة';
  static const String cefrLevel = 'B2';
  static const String evaluativeCategory = 'Normative Ausrichtung';
  static const String audioAssetPath = 'assets/audio/evaluative/task_3030_in_uebereinstimmung_mit_den_vorgaben.ogg';
  static const String exampleGerman = 'Der Ablauf erfolgt in Übereinstimmung mit den architektonischen Vorgaben.';
  static const String exampleArabic = 'يسير التنفيذ بما يطابق حرفياً الشروط والمعايير المعمارية المقررة.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'id': identifier, 'phrase': phraseGerman,
    'arabic': arabicMeaning, 'cefr': cefrLevel, 'category': evaluativeCategory,
    'audio': audioAssetPath, 'ex_de': exampleGerman, 'ex_ar': exampleArabic,
  };

  static bool validate() => phraseGerman.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
