// Sovereign Comparative Syntax Core - Task 2817
class Task2817Engine {
  static const int taskId = 2817;
  static const String identifier = 'kontraer_zur_erwartung';
  static const String comparativePhrase = 'konträr zu';
  static const String arabicMeaning = 'على النقيض تماماً من التقديرات والتكهنات الأولية';
  static const String cefrLevel = 'C1';
  static const String syntacticCategory = 'Gegensätzliche Divergenz';
  static const String audioAssetPath = 'assets/audio/comparative/task_2817_kontraer_zur_erwartung.ogg';
  static const String exampleGerman = 'Konträr zur Erwartung verbraucht der neue Parser weniger RAM.';
  static const String exampleArabic = 'على النقيض من التوقعات، يستهلك المحلل الجديد ذاكرة أقل.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'id': identifier, 'phrase': comparativePhrase,
    'arabic': arabicMeaning, 'cefr': cefrLevel, 'category': syntacticCategory,
    'audio': audioAssetPath, 'ex_de': exampleGerman, 'ex_ar': exampleArabic,
  };

  static bool validate() => comparativePhrase.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
