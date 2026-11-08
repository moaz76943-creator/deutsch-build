// Sovereign Rigorous Discourse Core - Task 2754
class Task2754Engine {
  static const int taskId = 2754;
  static const String identifier = 'ist_dem_grunde_nach_zulaessig';
  static const String phraseGerman = 'ist dem Grunde nach zulässig';
  static const String arabicMeaning = 'جائز ومقبول من حيث الأصل والأساس النظري';
  static const String cefrLevel = 'C1';
  static const String evaluativeCategory = 'Prinzipielle Zulässigkeit';
  static const String audioAssetPath = 'assets/audio/discourse/task_2754_ist_dem_grunde_nach_zulaessig.ogg';
  static const String exampleGerman = 'Eine parallele Ausführung ist dem Grunde nach absolut zulässig.';
  static const String exampleArabic = 'يعد التنفيذ المتوازي جائزاً ومقبولاً من حيث الأصل والأساس.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'id': identifier, 'phrase': phraseGerman,
    'arabic': arabicMeaning, 'cefr': cefrLevel, 'category': evaluativeCategory,
    'audio': audioAssetPath, 'ex_de': exampleGerman, 'ex_ar': exampleArabic,
  };

  static bool validate() => phraseGerman.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
