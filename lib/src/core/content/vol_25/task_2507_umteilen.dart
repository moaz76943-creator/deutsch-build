// Sovereign Polyglot Core - Task 2507 (Software Architecture)
class Task2507Engine {
  static const int taskId = 2507;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'umteilen';
  static const String praeteritum = 'teilte um';
  static const String perfekt = 'hat umgeteilt';
  static const String arabicTranslation = 'إعادة هيكلة التقسيم (هندسة البرمجيات)';
  static const String ipaTranscription = '[umˈˈtaɪ̯lən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2507_umteilen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review umteilen.';
  static const String exampleArabic = 'يجب علينا إعادة هيكلة التقسيم في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
