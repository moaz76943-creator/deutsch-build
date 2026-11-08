// Sovereign System Evaluation Core - Task 3021
class Task3021Engine {
  static const int taskId = 3021;
  static const String identifier = 'in_anbetracht_des_umstands';
  static const String phraseGerman = 'in Anbetracht des Umstands, dass';
  static const String arabicMeaning = 'نظراً للحقيقة الملموسة والواقع القائم الذي يقضي بأن';
  static const String cefrLevel = 'C1';
  static const String evaluativeCategory = 'Faktische Kausalität';
  static const String audioAssetPath = 'assets/audio/evaluative/task_3021_in_anbetracht_des_umstands.ogg';
  static const String exampleGerman = 'In Anbetracht des Umstands, dass der RAM begrenzt ist, cachen wir selektiv.';
  static const String exampleArabic = 'نظراً للحقيقة بأن الذاكرة محدودة، نعتمد استراتيجية تخزين مؤقت انتقائية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'id': identifier, 'phrase': phraseGerman,
    'arabic': arabicMeaning, 'cefr': cefrLevel, 'category': evaluativeCategory,
    'audio': audioAssetPath, 'ex_de': exampleGerman, 'ex_ar': exampleArabic,
  };

  static bool validate() => phraseGerman.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
