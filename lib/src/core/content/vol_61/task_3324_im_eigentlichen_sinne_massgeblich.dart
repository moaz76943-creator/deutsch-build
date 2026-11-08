// Sovereign Valuation Operator Core - Task 3324
class Task3324Engine {
  static const int taskId = 3324;
  static const String identifier = 'im_eigentlichen_sinne_massgeblich';
  static const String phraseGerman = 'im eigentlichen Sinne maßgeblich';
  static const String arabicMeaning = 'حاسم ومرجعي بالمعنى الدقيق والأصيل للكلمة';
  static const String cefrLevel = 'C1';
  static const String valuationCategory = 'Kategoriale Priorität';
  static const String audioAssetPath = 'assets/audio/valuation/task_3324_im_eigentlichen_sinne_massgeblich.ogg';
  static const String exampleGerman = 'Die Ausführungsgeschwindigkeit ist im eigentlichen Sinne maßgeblich.';
  static const String exampleArabic = 'سرعة التنفيذ هي المعيار الحاسم بالمعنى الحقيقي للكلمة.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'id': identifier, 'phrase': phraseGerman,
    'arabic': arabicMeaning, 'cefr': cefrLevel, 'category': valuationCategory,
    'audio': audioAssetPath, 'ex_de': exampleGerman, 'ex_ar': exampleArabic,
  };

  static bool validate() => phraseGerman.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
