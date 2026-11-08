// Sovereign System Evaluation Core - Task 3024
class Task3024Engine {
  static const int taskId = 3024;
  static const String identifier = 'vor_dem_hintergrund_des_wachstums';
  static const String phraseGerman = 'vor dem Hintergrund des Wachstums';
  static const String arabicMeaning = 'على ضوء التوسع المطرد لحجم المعطيات والعمليات';
  static const String cefrLevel = 'B2';
  static const String evaluativeCategory = 'Wachstumskontext';
  static const String audioAssetPath = 'assets/audio/evaluative/task_3024_vor_dem_hintergrund_des_wachstums.ogg';
  static const String exampleGerman = 'Vor dem Hintergrund des Wachstums wählen wir 64-Bit-Identifikatoren.';
  static const String exampleArabic = 'على ضوء التوسع المطرد للعمليات، نعتمد معرفات ثنائية بعرض 64 بت.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'id': identifier, 'phrase': phraseGerman,
    'arabic': arabicMeaning, 'cefr': cefrLevel, 'category': evaluativeCategory,
    'audio': audioAssetPath, 'ex_de': exampleGerman, 'ex_ar': exampleArabic,
  };

  static bool validate() => phraseGerman.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
