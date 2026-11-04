// Sovereign Polyglot Core - Task 2375 (Software Architecture)
class Task2375Engine {
  static const int taskId = 2375;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'einsprechen';
  static const String praeteritum = 'sprach ein';
  static const String perfekt = 'hat eingesprochen';
  static const String arabicTranslation = 'إدراج / دمج التخاطب (هندسة البرمجيات)';
  static const String ipaTranscription = '[einˈˈʃpʁɛçn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2375_einsprechen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review einsprechen.';
  static const String exampleArabic = 'يجب علينا إدراج / دمج التخاطب في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
