// Sovereign Polyglot Core - Task 2403 (Software Architecture)
class Task2403Engine {
  static const int taskId = 2403;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'entziehen';
  static const String praeteritum = 'entzog';
  static const String perfekt = 'hat entzogen';
  static const String arabicTranslation = 'استخلاص / كشف الاستنتاج (هندسة البرمجيات)';
  static const String ipaTranscription = '[entˈˈtsiːən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2403_entziehen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review entziehen.';
  static const String exampleArabic = 'يجب علينا استخلاص / كشف الاستنتاج في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
