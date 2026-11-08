// Sovereign High-Register Idiom Core - Task 3268
class Task3268Engine {
  static const int taskId = 3268;
  static const String identifier = 'auf_anhieb_ueberzeugen';
  static const String idiomGerman = 'auf Anhieb überzeugen';
  static const String arabicMeaning = 'ينال القبول والاستحسان الفوري من الوهلة الأولى';
  static const String cefrLevel = 'B1';
  static const String pragmaticCategory = 'Sofortige Evidenz';
  static const String audioAssetPath = 'assets/audio/idioms/task_3268_auf_anhieb_ueberzeugen.ogg';
  static const String exampleGerman = 'Die Latenzmessungen überzeugten das Prüfgremium auf Anhieb.';
  static const String exampleArabic = 'أقنعت قياسات السرعة فريق المراجعة من الوهلة الأولى.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'id': identifier, 'phrase': idiomGerman,
    'arabic': arabicMeaning, 'cefr': cefrLevel, 'category': pragmaticCategory,
    'audio': audioAssetPath, 'ex_de': exampleGerman, 'ex_ar': exampleArabic,
  };

  static bool validate() => idiomGerman.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
