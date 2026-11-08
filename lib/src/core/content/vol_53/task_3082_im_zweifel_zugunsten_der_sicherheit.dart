// Sovereign Legal & Normative Precision Core - Task 3082
class Task3082Engine {
  static const int taskId = 3082;
  static const String identifier = 'im_zweifel_zugunsten_der_sicherheit';
  static const String normativePhrase = 'im Zweifel zugunsten maximaler Sicherheit';
  static const String arabicMeaning = 'عند التردد والاشتباه يُرجح جانب الأمان الأقصى';
  static const String cefrLevel = 'B2';
  static const String legalCategory = 'Defensive Priorisierung';
  static const String audioAssetPath = 'assets/audio/normative/task_3082_im_zweifel_zugunsten_der_sicherheit.ogg';
  static const String exampleGerman = 'Wir sperren Ports im Zweifel zugunsten maximaler Sicherheit.';
  static const String exampleArabic = 'نغلق المنافذ عند الاشتباه ترجيحاً لجانب الأمان الأقصى.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'id': identifier, 'phrase': normativePhrase,
    'arabic': arabicMeaning, 'cefr': cefrLevel, 'category': legalCategory,
    'audio': audioAssetPath, 'ex_de': exampleGerman, 'ex_ar': exampleArabic,
  };

  static bool validate() => normativePhrase.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
