// Sovereign High-Register Idiom Core - Task 3270
class Task3270Engine {
  static const int taskId = 3270;
  static const String identifier = 'fuegte_sich_gluecklich';
  static const String idiomGerman = 'es fügte sich glücklich';
  static const String arabicMeaning = 'تلاقت المعطيات والظروف التقنية بتوفيق مثالي';
  static const String cefrLevel = 'C1';
  static const String pragmaticCategory = 'Pragmatische Konvergenz';
  static const String audioAssetPath = 'assets/audio/idioms/task_3270_fuegte_sich_gluecklich.ogg';
  static const String exampleGerman = 'Es fügte sich glücklich, dass die NPU-Treiber nativ passten.';
  static const String exampleArabic = 'تلاقت الظروف بتوفيق تام لتوافق مشغلات NPU تلقائياً.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'id': identifier, 'phrase': idiomGerman,
    'arabic': arabicMeaning, 'cefr': cefrLevel, 'category': pragmaticCategory,
    'audio': audioAssetPath, 'ex_de': exampleGerman, 'ex_ar': exampleArabic,
  };

  static bool validate() => idiomGerman.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
