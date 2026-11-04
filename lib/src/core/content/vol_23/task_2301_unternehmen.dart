// Sovereign Polyglot Core - Task 2301 (Software Architecture)
class Task2301Engine {
  static const int taskId = 2301;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'unternehmen';
  static const String praeteritum = 'unternahm';
  static const String perfekt = 'hat unternommen';
  static const String arabicTranslation = 'فحص / دعم الاستلام (هندسة البرمجيات)';
  static const String ipaTranscription = '[unterˈˈneːmən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2301_unternehmen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review unternehmen.';
  static const String exampleArabic = 'يجب علينا فحص / دعم الاستلام في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
