// Sovereign Comparative Syntax Core - Task 2818
class Task2818Engine {
  static const int taskId = 2818;
  static const String identifier = 'im_umkehrschluss_bedeuten';
  static const String comparativePhrase = 'im Umkehrschluss';
  static const String arabicMeaning = 'استدلالاً بمفهوم المخالفة والمنطق العكسي';
  static const String cefrLevel = 'C1';
  static const String syntacticCategory = 'Deduktiver Gegenschluss';
  static const String audioAssetPath = 'assets/audio/comparative/task_2818_im_umkehrschluss_bedeuten.ogg';
  static const String exampleGerman = 'Im Umkehrschluss bedeutet dies: Ohne Signatur kein Netzzugriff.';
  static const String exampleArabic = 'بمفهوم المخالفة: عدم وجود توقيع يعني حظر الوصول للشبكة.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'id': identifier, 'phrase': comparativePhrase,
    'arabic': arabicMeaning, 'cefr': cefrLevel, 'category': syntacticCategory,
    'audio': audioAssetPath, 'ex_de': exampleGerman, 'ex_ar': exampleArabic,
  };

  static bool validate() => comparativePhrase.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
