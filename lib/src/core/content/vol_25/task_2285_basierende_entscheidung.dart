// Sovereign Participial Attribute Core - Task 2285
class Task2285Engine {
  static const int taskId = 2285;
  static const String identifier = 'basierende_entscheidung';
  static const String participialPhrase = 'die auf Fakten basierende Entscheidung';
  static const String arabicMeaning = 'القرار المستند إلى حقائق ملموسة';
  static const String syntacticType = 'Partizip I mit Präposition';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/partizip/task_2285_basierende_entscheidung.ogg';
  static const String exampleGerman = 'Die auf Fakten basierende Entscheidung steht fest.';
  static const String exampleArabic = 'القرار المستند للحقائق بات محسوماً.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'id': identifier, 'phrase': participialPhrase,
    'arabic': arabicMeaning, 'type': syntacticType, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'ex_de': exampleGerman, 'ex_ar': exampleArabic,
  };

  static bool validate() => participialPhrase.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
