// Sovereign Participial Attribute Core - Task 2283
class Task2283Engine {
  static const int taskId = 2283;
  static const String identifier = 'zu_loesende_aufgabe';
  static const String participialPhrase = 'die schwer zu lösende Aufgabe';
  static const String arabicMeaning = 'المهمة التي يصعب حلها / المطلوب حلها';
  static const String syntacticType = 'Gerundivum (zu + Part. I)';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/partizip/task_2283_zu_loesende_aufgabe.ogg';
  static const String exampleGerman = 'Die schwer zu lösende Aufgabe fordert alle.';
  static const String exampleArabic = 'المهمة المستعصية تتطلب تضافر الجهود.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'id': identifier, 'phrase': participialPhrase,
    'arabic': arabicMeaning, 'type': syntacticType, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'ex_de': exampleGerman, 'ex_ar': exampleArabic,
  };

  static bool validate() => participialPhrase.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
