// Sovereign Polyglot Core - Task 2215 (Software Architecture)
class Task2215Engine {
  static const int taskId = 2215;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'einstellen';
  static const String praeteritum = 'stellte ein';
  static const String perfekt = 'hat eingestellt';
  static const String arabicTranslation = 'إدراج / دمج التنظيم (هندسة البرمجيات)';
  static const String ipaTranscription = '[einˈˈʃtɛlən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2215_einstellen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review einstellen.';
  static const String exampleArabic = 'يجب علينا إدراج / دمج التنظيم في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
