// Sovereign Legal & Normative Precision Core - Task 3087
class Task3087Engine {
  static const int taskId = 3087;
  static const String identifier = 'unter_dem_gesichtspunkt_der_autonomie';
  static const String normativePhrase = 'unter dem Gesichtspunkt der Autonomie';
  static const String arabicMeaning = 'من منظور الاستقلالية والسيادة الذاتية الكاملة';
  static const String cefrLevel = 'B2';
  static const String legalCategory = 'Konzeptioneller Fokus';
  static const String audioAssetPath = 'assets/audio/normative/task_3087_unter_dem_gesichtspunkt_der_autonomie.ogg';
  static const String exampleGerman = 'Wir isolieren Prozesse unter dem Gesichtspunkt der Autonomie.';
  static const String exampleArabic = 'نعزل العمليات من منظور ضمان السيادة الذاتية التامة.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'id': identifier, 'phrase': normativePhrase,
    'arabic': arabicMeaning, 'cefr': cefrLevel, 'category': legalCategory,
    'audio': audioAssetPath, 'ex_de': exampleGerman, 'ex_ar': exampleArabic,
  };

  static bool validate() => normativePhrase.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
