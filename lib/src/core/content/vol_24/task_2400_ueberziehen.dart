// Sovereign Polyglot Core - Task 2400 (Software Architecture)
class Task2400Engine {
  static const int taskId = 2400;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'ueberziehen';
  static const String praeteritum = 'ueberzog';
  static const String perfekt = 'hat ueberzogen';
  static const String arabicTranslation = 'مراجعة / نقل الاستنتاج (هندسة البرمجيات)';
  static const String ipaTranscription = '[ueberˈˈtsiːən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2400_ueberziehen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review ueberziehen.';
  static const String exampleArabic = 'يجب علينا مراجعة / نقل الاستنتاج في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
