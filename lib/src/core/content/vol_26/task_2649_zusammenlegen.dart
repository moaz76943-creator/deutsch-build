// Sovereign Polyglot Core - Task 2649 (Clinical Diagnostics)
class Task2649Engine {
  static const int taskId = 2649;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'zusammenlegen';
  static const String praeteritum = 'legte zusammen';
  static const String perfekt = 'hat zusammengelegt';
  static const String arabicTranslation = 'تجميع / توحيد التأسيس (التواصل الطبي)';
  static const String ipaTranscription = '[zusammenˈˈleːɡn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2649_zusammenlegen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung zusammenlegen.';
  static const String exampleArabic = 'يجب علينا تجميع / توحيد التأسيس في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
