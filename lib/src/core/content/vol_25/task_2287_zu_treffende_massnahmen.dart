// Sovereign Participial Attribute Core - Task 2287
class Task2287Engine {
  static const int taskId = 2287;
  static const String identifier = 'zu_treffende_massnahmen';
  static const String participialPhrase = 'die zu treffenden Maßnahmen';
  static const String arabicMeaning = 'الإجراءات والتدابير الواجب اتخاذها';
  static const String syntacticType = 'Gerundivum (passivisch)';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/partizip/task_2287_zu_treffende_massnahmen.ogg';
  static const String exampleGerman = 'Die zu treffenden Maßnahmen sind verbindlich.';
  static const String exampleArabic = 'التدابير الواجب اتخاذها ملزمة للجميع.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'id': identifier, 'phrase': participialPhrase,
    'arabic': arabicMeaning, 'type': syntacticType, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'ex_de': exampleGerman, 'ex_ar': exampleArabic,
  };

  static bool validate() => participialPhrase.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
