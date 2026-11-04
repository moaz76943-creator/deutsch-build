// Sovereign Polyglot Core - Task 2181 (Software Architecture)
class Task2181Engine {
  static const int taskId = 2181;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'unterplanen';
  static const String praeteritum = 'unterplante';
  static const String perfekt = 'hat unterplant';
  static const String arabicTranslation = 'فحص / دعم التخطيط (هندسة البرمجيات)';
  static const String ipaTranscription = '[unterˈˈplaːnən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2181_unterplanen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review unterplanen.';
  static const String exampleArabic = 'يجب علينا فحص / دعم التخطيط في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
