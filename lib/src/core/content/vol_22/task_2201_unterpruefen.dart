// Sovereign Polyglot Core - Task 2201 (Software Architecture)
class Task2201Engine {
  static const int taskId = 2201;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'unterpruefen';
  static const String praeteritum = 'unterpruefte';
  static const String perfekt = 'hat unterprueft';
  static const String arabicTranslation = 'فحص / دعم التدقيق (هندسة البرمجيات)';
  static const String ipaTranscription = '[unterˈˈpʁyːfn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2201_unterpruefen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review unterpruefen.';
  static const String exampleArabic = 'يجب علينا فحص / دعم التدقيق في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
