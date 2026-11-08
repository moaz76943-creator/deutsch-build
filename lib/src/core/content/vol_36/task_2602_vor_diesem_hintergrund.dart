// Sovereign Evaluative Operator Core - Task 2602
class Task2602Engine {
  static const int taskId = 2602;
  static const String identifier = 'vor_diesem_hintergrund';
  static const String evaluativePhrase = 'vor diesem Hintergrund';
  static const String arabicMeaning = 'على ضوء هذه الخلفية الفنية والسياق التشغيلي';
  static const String cefrLevel = 'B2';
  static const String discourseCategory = 'Kontextuelle Einordnung';
  static const String audioAssetPath = 'assets/audio/evaluative/task_2602_vor_diesem_hintergrund.ogg';
  static const String exampleGerman = 'Vor diesem Hintergrund wurde der Puffer dynamisch rekonfiguriert.';
  static const String exampleArabic = 'على ضوء هذه الخلفية، تمت إعادة ضبط سعة المخزن ديناميكياً.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'id': identifier, 'phrase': evaluativePhrase,
    'arabic': arabicMeaning, 'cefr': cefrLevel, 'category': discourseCategory,
    'audio': audioAssetPath, 'ex_de': exampleGerman, 'ex_ar': exampleArabic,
  };

  static bool validate() => evaluativePhrase.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
