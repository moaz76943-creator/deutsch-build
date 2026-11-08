// Sovereign Scientific Epistemology Core - Task 3112
class Task3112Engine {
  static const int taskId = 3112;
  static const String identifier = 'sparsamkeitsprinzip_ockham';
  static const String methodologyPhrase = 'unterliegt dem Sparsamkeitsprinzip';
  static const String arabicMeaning = 'يخضع لمبدأ نصل أوكام بترجيح التفسير الأبسط والأكفأ';
  static const String cefrLevel = 'C1';
  static const String epistemologicalCategory = 'Methodologische Sparsamkeit';
  static const String audioAssetPath = 'assets/audio/epistemology/task_3112_sparsamkeitsprinzip_ockham.ogg';
  static const String exampleGerman = 'Das schlanke Protokolldesign unterliegt dem Sparsamkeitsprinzip.';
  static const String exampleArabic = 'تصميم البروتوكول الرشيق يخضع لمبدأ التفسير الأبسط والأكفأ.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'id': identifier, 'phrase': methodologyPhrase,
    'arabic': arabicMeaning, 'cefr': cefrLevel, 'category': epistemologicalCategory,
    'audio': audioAssetPath, 'ex_de': exampleGerman, 'ex_ar': exampleArabic,
  };

  static bool validate() => methodologyPhrase.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
