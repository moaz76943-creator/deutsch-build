// Sovereign Prepositional Verb Core - Task 2227
class Task2227Engine {
  static const int taskId = 2227;
  static const String identifier = 'befassen_mit';
  static const String verbPreposition = 'sich befassen mit';
  static const String arabicMeaning = 'يتناول بالدراسة والبحث المتعمق';
  static const String governedCase = 'mit + Dat';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/prep_verbs/task_2227_befassen_mit.ogg';
  static const String exampleGerman = 'Das Team befasst sich mit der Architektur.';
  static const String exampleArabic = 'يتناول الفريق دراسة معمارية النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'id': identifier, 'verb_prep': verbPreposition,
    'arabic': arabicMeaning, 'case': governedCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'ex_de': exampleGerman, 'ex_ar': exampleArabic,
  };

  static bool validate() => verbPreposition.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
