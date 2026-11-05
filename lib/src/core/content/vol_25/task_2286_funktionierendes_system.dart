// Sovereign Participial Attribute Core - Task 2286
class Task2286Engine {
  static const int taskId = 2286;
  static const String identifier = 'funktionierendes_system';
  static const String participialPhrase = 'das reibungslos funktionierende System';
  static const String arabicMeaning = 'النظام الذي يعمل بسلاسة ودون عوائق';
  static const String syntacticType = 'Partizip I mit Adverb';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/partizip/task_2286_funktionierendes_system.ogg';
  static const String exampleGerman = 'Ein reibungslos funktionierendes System spart Zeit.';
  static const String exampleArabic = 'النظام الذي يعمل بسلاسة يوفر الوقت.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'id': identifier, 'phrase': participialPhrase,
    'arabic': arabicMeaning, 'type': syntacticType, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'ex_de': exampleGerman, 'ex_ar': exampleArabic,
  };

  static bool validate() => participialPhrase.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
