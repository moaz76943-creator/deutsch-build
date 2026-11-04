// Sovereign Polyglot Core - Task 2293 (Software Architecture)
class Task2293Engine {
  static const int taskId = 2293;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'aufnehmen';
  static const String praeteritum = 'nahm auf';
  static const String perfekt = 'hat aufgenommen';
  static const String arabicTranslation = 'رفع / فتح الاستلام (هندسة البرمجيات)';
  static const String ipaTranscription = '[aufˈˈneːmən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2293_aufnehmen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review aufnehmen.';
  static const String exampleArabic = 'يجب علينا رفع / فتح الاستلام في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
