// Sovereign Polyglot Core - Task 2401 (Software Architecture)
class Task2401Engine {
  static const int taskId = 2401;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'unterziehen';
  static const String praeteritum = 'unterzog';
  static const String perfekt = 'hat unterzogen';
  static const String arabicTranslation = 'فحص / دعم الاستنتاج (هندسة البرمجيات)';
  static const String ipaTranscription = '[unterˈˈtsiːən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2401_unterziehen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review unterziehen.';
  static const String exampleArabic = 'يجب علينا فحص / دعم الاستنتاج في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
