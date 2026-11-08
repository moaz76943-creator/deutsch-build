// Sovereign System Evaluation Core - Task 2636
class Task2636Engine {
  static const int taskId = 2636;
  static const String identifier = 'im_vertrauen_auf_die_standards';
  static const String phraseGerman = 'im Vertrauen auf die Standards';
  static const String arabicMeaning = 'استناداً إلى الثقة في المعايير الصناعية';
  static const String cefrLevel = 'B1';
  static const String discourseCategory = 'Konformitätsbezug';
  static const String audioAssetPath = 'assets/audio/eval/task_2636_im_vertrauen_auf_die_standards.ogg';
  static const String exampleGerman = 'Im Vertrauen auf offene Standards bleibt der Code portabel.';
  static const String exampleArabic = 'استناداً للمعايير المفتوحة، تظل الشيفرة قابلة للنقل بيسر.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'id': identifier, 'phrase': phraseGerman,
    'arabic': arabicMeaning, 'cefr': cefrLevel, 'category': discourseCategory,
    'audio': audioAssetPath, 'ex_de': exampleGerman, 'ex_ar': exampleArabic,
  };

  static bool validate() => phraseGerman.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
