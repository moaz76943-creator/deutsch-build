// Sovereign Concessive Operator Core - Task 2781
class Task2781Engine {
  static const int taskId = 2781;
  static const String identifier = 'wennschon_denn';
  static const String phraseGerman = 'wennschon ..., denn';
  static const String arabicMeaning = 'إن كان لا بد من المضي قدماً فليكن على أتم وجه';
  static const String cefrLevel = 'C1';
  static const String grammaticalCategory = 'Proportionale Einräumung';
  static const String audioAssetPath = 'assets/audio/concessive/task_2781_wennschon_denn.ogg';
  static const String exampleGerman = 'Wennschon refaktoriert wird, denn mit vollständiger Typensicherheit.';
  static const String exampleArabic = 'إن كان لا بد من إعادة الهيكلة، فلتكن بأمان نوعي كامل.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'id': identifier, 'phrase': phraseGerman,
    'arabic': arabicMeaning, 'cefr': cefrLevel, 'category': grammaticalCategory,
    'audio': audioAssetPath, 'ex_de': exampleGerman, 'ex_ar': exampleArabic,
  };

  static bool validate() => phraseGerman.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
