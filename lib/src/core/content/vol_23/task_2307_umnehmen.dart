// Sovereign Polyglot Core - Task 2307 (Software Architecture)
class Task2307Engine {
  static const int taskId = 2307;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'umnehmen';
  static const String praeteritum = 'nahm um';
  static const String perfekt = 'hat umgenommen';
  static const String arabicTranslation = 'إعادة هيكلة الاستلام (هندسة البرمجيات)';
  static const String ipaTranscription = '[umˈˈneːmən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2307_umnehmen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review umnehmen.';
  static const String exampleArabic = 'يجب علينا إعادة هيكلة الاستلام في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
