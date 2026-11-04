// Sovereign Polyglot Core - Task 2221 (Software Architecture)
class Task2221Engine {
  static const int taskId = 2221;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'unterstellen';
  static const String praeteritum = 'unterstellte';
  static const String perfekt = 'hat unterstellt';
  static const String arabicTranslation = 'فحص / دعم التنظيم (هندسة البرمجيات)';
  static const String ipaTranscription = '[unterˈˈʃtɛlən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2221_unterstellen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review unterstellen.';
  static const String exampleArabic = 'يجب علينا فحص / دعم التنظيم في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
