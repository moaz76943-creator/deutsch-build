// Sovereign Institutional Syntax Core - Task 3060
class Task3060Engine {
  static const int taskId = 3060;
  static const String identifier = 'kraft_gesetzlicher_ermaechtigung';
  static const String institutionalPhrase = 'kraft gesetzlicher Ermächtigung';
  static const String arabicMeaning = 'بموجب الصلاحيات والضوابط التأسيسية المقررة للنواة';
  static const String cefrLevel = 'C1';
  static const String syntacticCategory = 'Normative Legitimation';
  static const String audioAssetPath = 'assets/audio/institutional/task_3060_kraft_gesetzlicher_ermaechtigung.ogg';
  static const String exampleGerman = 'Der Kernel isoliert Prozesse kraft definierter Ermächtigung.';
  static const String exampleArabic = 'تعزل النواة العمليات بموجب الصلاحيات المحددة.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'id': identifier, 'phrase': institutionalPhrase,
    'arabic': arabicMeaning, 'cefr': cefrLevel, 'category': syntacticCategory,
    'audio': audioAssetPath, 'ex_de': exampleGerman, 'ex_ar': exampleArabic,
  };

  static bool validate() => institutionalPhrase.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
