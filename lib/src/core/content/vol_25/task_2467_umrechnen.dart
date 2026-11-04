// Sovereign Polyglot Core - Task 2467 (Software Architecture)
class Task2467Engine {
  static const int taskId = 2467;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'umrechnen';
  static const String praeteritum = 'rechnete um';
  static const String perfekt = 'hat umgerechnet';
  static const String arabicTranslation = 'إعادة هيكلة التقدير (هندسة البرمجيات)';
  static const String ipaTranscription = '[umˈˈʁɛçnən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2467_umrechnen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review umrechnen.';
  static const String exampleArabic = 'يجب علينا إعادة هيكلة التقدير في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
