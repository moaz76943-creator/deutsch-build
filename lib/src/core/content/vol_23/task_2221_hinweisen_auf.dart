// Sovereign Prepositional Verb Core - Task 2221
class Task2221Engine {
  static const int taskId = 2221;
  static const String identifier = 'hinweisen_auf';
  static const String verbPreposition = 'hinweisen auf';
  static const String arabicMeaning = 'يشير إلى / يلفت الانتباه إلى';
  static const String governedCase = 'auf + Akk';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/prep_verbs/task_2221_hinweisen_auf.ogg';
  static const String exampleGerman = 'Der Experte weist auf die Risiken hin.';
  static const String exampleArabic = 'يشير الخبير إلى المخاطر المحتملة.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'id': identifier, 'verb_prep': verbPreposition,
    'arabic': arabicMeaning, 'case': governedCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'ex_de': exampleGerman, 'ex_ar': exampleArabic,
  };

  static bool validate() => verbPreposition.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
