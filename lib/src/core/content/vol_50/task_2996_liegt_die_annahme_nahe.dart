// Sovereign Inductive Logic Core - Task 2996
class Task2996Engine {
  static const int taskId = 2996;
  static const String identifier = 'liegt_die_annahme_nahe';
  static const String phraseGerman = 'liegt die Annahme nahe, dass';
  static const String arabicMeaning = 'يتبادر إلى الذهن منطقياً الافتراض بأن';
  static const String cefrLevel = 'B2';
  static const String logicCategory = 'Naheliegende Hypothese';
  static const String audioAssetPath = 'assets/audio/logic/task_2996_liegt_die_annahme_nahe.ogg';
  static const String exampleGerman = 'Bei diesem Lastprofil liegt die Annahme nahe, dass Caching hilft.';
  static const String exampleArabic = 'مع هذا النمط، يتبادر للذهن افتراض جدوى التخزين المؤقت.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'id': identifier, 'phrase': phraseGerman,
    'arabic': arabicMeaning, 'cefr': cefrLevel, 'category': logicCategory,
    'audio': audioAssetPath, 'ex_de': exampleGerman, 'ex_ar': exampleArabic,
  };

  static bool validate() => phraseGerman.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
