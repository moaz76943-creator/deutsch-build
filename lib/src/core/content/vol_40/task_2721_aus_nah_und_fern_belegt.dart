// Sovereign System Evaluation Core - Task 2721
class Task2721Engine {
  static const int taskId = 2721;
  static const String identifier = 'aus_nah_und_fern_belegt';
  static const String phraseGerman = 'aus der Fachliteratur belegt';
  static const String arabicMeaning = 'مثبت وموثق باستفاضة في الأدبيات التخصصية المعتمدة';
  static const String cefrLevel = 'C1';
  static const String evaluativeCategory = 'Akademische Evidenz';
  static const String audioAssetPath = 'assets/audio/evaluative/task_2721_aus_nah_und_fern_belegt.ogg';
  static const String exampleGerman = 'Die Skalierbarkeit des Algorithmus ist aus der Fachliteratur belegt.';
  static const String exampleArabic = 'قابلية توسع الخوارزمية مثبتة وموثقة في الأدبيات التخصصية المعتمدة.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'id': identifier, 'phrase': phraseGerman,
    'arabic': arabicMeaning, 'cefr': cefrLevel, 'category': evaluativeCategory,
    'audio': audioAssetPath, 'ex_de': exampleGerman, 'ex_ar': exampleArabic,
  };

  static bool validate() => phraseGerman.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
