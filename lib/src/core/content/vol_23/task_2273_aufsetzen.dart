// Sovereign Polyglot Core - Task 2273 (Software Architecture)
class Task2273Engine {
  static const int taskId = 2273;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'aufsetzen';
  static const String praeteritum = 'setzte auf';
  static const String perfekt = 'hat aufgesetzt';
  static const String arabicTranslation = 'رفع / فتح التنفيذ (هندسة البرمجيات)';
  static const String ipaTranscription = '[aufˈˈzɛtsn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2273_aufsetzen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review aufsetzen.';
  static const String exampleArabic = 'يجب علينا رفع / فتح التنفيذ في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
