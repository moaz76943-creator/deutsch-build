// Sovereign Participial Attribute Core - Task 2284
class Task2284Engine {
  static const int taskId = 2284;
  static const String identifier = 'zugrunde_liegendes_prinzip';
  static const String participialPhrase = 'das zugrunde liegende Prinzip';
  static const String arabicMeaning = 'المبدأ الذي يقوم عليه الأساس النظري';
  static const String syntacticType = 'Partizip I mit Kompositum';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/partizip/task_2284_zugrunde_liegendes_prinzip.ogg';
  static const String exampleGerman = 'Das zugrunde liegende Prinzip ist universell.';
  static const String exampleArabic = 'المبدأ الذي يستند إليه النظام مبدأ شامل.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'id': identifier, 'phrase': participialPhrase,
    'arabic': arabicMeaning, 'type': syntacticType, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'ex_de': exampleGerman, 'ex_ar': exampleArabic,
  };

  static bool validate() => participialPhrase.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
