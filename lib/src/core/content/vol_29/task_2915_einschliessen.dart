// Sovereign Polyglot Core - Task 2915 (Clinical Diagnostics)
class Task2915Engine {
  static const int taskId = 2915;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'einschliessen';
  static const String praeteritum = 'schloss ein';
  static const String perfekt = 'hat eingeschlossen';
  static const String arabicTranslation = 'إدراج / دمج الإبرام (التواصل الطبي)';
  static const String ipaTranscription = '[einˈˈʃliːsn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2915_einschliessen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung einschliessen.';
  static const String exampleArabic = 'يجب علينا إدراج / دمج الإبرام في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
