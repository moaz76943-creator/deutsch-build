// Sovereign High-Register Idiom Core - Task 3264
class Task3264Engine {
  static const int taskId = 3264;
  static const String identifier = 'von_langer_hand_geplant';
  static const String idiomGerman = 'von langer Hand geplant';
  static const String arabicMeaning = 'مخطط ومدبر له بمنهجية استباقية بعيدة المدى';
  static const String cefrLevel = 'B2';
  static const String pragmaticCategory = 'Proaktive Vorausschau';
  static const String audioAssetPath = 'assets/audio/idioms/task_3264_von_langer_hand_geplant.ogg';
  static const String exampleGerman = 'Die Datenbankmigration war technisch von langer Hand geplant.';
  static const String exampleArabic = 'كان ترحيل قاعدة البيانات مخططاً له بدقة من قبل.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'id': identifier, 'phrase': idiomGerman,
    'arabic': arabicMeaning, 'cefr': cefrLevel, 'category': pragmaticCategory,
    'audio': audioAssetPath, 'ex_de': exampleGerman, 'ex_ar': exampleArabic,
  };

  static bool validate() => idiomGerman.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
