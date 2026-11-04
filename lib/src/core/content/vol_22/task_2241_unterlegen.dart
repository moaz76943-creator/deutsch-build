// Sovereign Polyglot Core - Task 2241 (Software Architecture)
class Task2241Engine {
  static const int taskId = 2241;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'unterlegen';
  static const String praeteritum = 'unterlegte';
  static const String perfekt = 'hat unterlegt';
  static const String arabicTranslation = 'فحص / دعم التأسيس (هندسة البرمجيات)';
  static const String ipaTranscription = '[unterˈˈleːɡn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2241_unterlegen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review unterlegen.';
  static const String exampleArabic = 'يجب علينا فحص / دعم التأسيس في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
