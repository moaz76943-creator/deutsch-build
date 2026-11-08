// Sovereign Legal & Normative Precision Core - Task 3081
class Task3081Engine {
  static const int taskId = 3081;
  static const String identifier = 'vorbehaltlich_anderslautender_vereinbarung';
  static const String normativePhrase = 'vorbehaltlich anderslautender Vereinbarungen';
  static const String arabicMeaning = 'ما لم يتقرر خلاف ذلك صراحة بموجب اتفاق مسبق';
  static const String cefrLevel = 'C1';
  static const String legalCategory = 'Dispositive Einschränkung';
  static const String audioAssetPath = 'assets/audio/normative/task_3081_vorbehaltlich_anderslautender_vereinbarung.ogg';
  static const String exampleGerman = 'Die Parameter gelten vorbehaltlich anderslautender Vereinbarungen.';
  static const String exampleArabic = 'تسري هذه المعايير ما لم يتقرر خلاف ذلك صراحة.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'id': identifier, 'phrase': normativePhrase,
    'arabic': arabicMeaning, 'cefr': cefrLevel, 'category': legalCategory,
    'audio': audioAssetPath, 'ex_de': exampleGerman, 'ex_ar': exampleArabic,
  };

  static bool validate() => normativePhrase.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
