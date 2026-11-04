// Sovereign Polyglot Core - Task 2755 (Clinical Diagnostics)
class Task2755Engine {
  static const int taskId = 2755;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'einschreiben';
  static const String praeteritum = 'schrieb ein';
  static const String perfekt = 'hat eingeschrieben';
  static const String arabicTranslation = 'إدراج / دمج التدوين (التواصل الطبي)';
  static const String ipaTranscription = '[einˈˈʃʁaɪ̯bn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2755_einschreiben.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung einschreiben.';
  static const String exampleArabic = 'يجب علينا إدراج / دمج التدوين في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
