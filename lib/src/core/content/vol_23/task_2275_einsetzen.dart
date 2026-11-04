// Sovereign Polyglot Core - Task 2275 (Software Architecture)
class Task2275Engine {
  static const int taskId = 2275;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'einsetzen';
  static const String praeteritum = 'setzte ein';
  static const String perfekt = 'hat eingesetzt';
  static const String arabicTranslation = 'إدراج / دمج التنفيذ (هندسة البرمجيات)';
  static const String ipaTranscription = '[einˈˈzɛtsn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2275_einsetzen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review einsetzen.';
  static const String exampleArabic = 'يجب علينا إدراج / دمج التنفيذ في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
