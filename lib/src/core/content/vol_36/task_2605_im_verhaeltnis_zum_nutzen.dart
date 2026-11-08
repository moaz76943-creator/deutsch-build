// Sovereign Evaluative Operator Core - Task 2605
class Task2605Engine {
  static const int taskId = 2605;
  static const String identifier = 'im_verhaeltnis_zum_nutzen';
  static const String evaluativePhrase = 'im Verhältnis zum Nutzen';
  static const String arabicMeaning = 'بالمقارنة النسبية مع المردود الفعلي والنفع المحقق';
  static const String cefrLevel = 'B2';
  static const String discourseCategory = 'Relationale Bewertung';
  static const String audioAssetPath = 'assets/audio/evaluative/task_2605_im_verhaeltnis_zum_nutzen.ogg';
  static const String exampleGerman = 'Der Aufwand steht in einem exzellenten Verhältnis zum Nutzen.';
  static const String exampleArabic = 'الجهد المبذول يحقق عائداً نفعياً ممتازاً ومتناسباً.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'id': identifier, 'phrase': evaluativePhrase,
    'arabic': arabicMeaning, 'cefr': cefrLevel, 'category': discourseCategory,
    'audio': audioAssetPath, 'ex_de': exampleGerman, 'ex_ar': exampleArabic,
  };

  static bool validate() => evaluativePhrase.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
