// Sovereign Prepositional Verb Core - Task 2223
class Task2223Engine {
  static const int taskId = 2223;
  static const String identifier = 'ankommen_auf';
  static const String verbPreposition = 'ankommen auf';
  static const String arabicMeaning = 'يتوقف على / يعتمد أساساً على';
  static const String governedCase = 'auf + Akk';
  static const String cefrLevel = 'B1';
  static const String audioAssetPath = 'assets/audio/prep_verbs/task_2223_ankommen_auf.ogg';
  static const String exampleGerman = 'Es kommt auf praezise Planung an.';
  static const String exampleArabic = 'الأمر يعتمد على التخطيط الدقيق.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'id': identifier, 'verb_prep': verbPreposition,
    'arabic': arabicMeaning, 'case': governedCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'ex_de': exampleGerman, 'ex_ar': exampleArabic,
  };

  static bool validate() => verbPreposition.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
