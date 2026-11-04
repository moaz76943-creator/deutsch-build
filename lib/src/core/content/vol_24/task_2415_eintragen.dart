// Sovereign Polyglot Core - Task 2415 (Software Architecture)
class Task2415Engine {
  static const int taskId = 2415;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'eintragen';
  static const String praeteritum = 'trug ein';
  static const String perfekt = 'hat eingetragen';
  static const String arabicTranslation = 'إدراج / دمج المسؤولية (هندسة البرمجيات)';
  static const String ipaTranscription = '[einˈˈtʁaːɡn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2415_eintragen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review eintragen.';
  static const String exampleArabic = 'يجب علينا إدراج / دمج المسؤولية في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
