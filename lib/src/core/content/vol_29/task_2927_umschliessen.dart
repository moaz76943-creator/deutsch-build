// Sovereign Polyglot Core - Task 2927 (Clinical Diagnostics)
class Task2927Engine {
  static const int taskId = 2927;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'umschliessen';
  static const String praeteritum = 'schloss um';
  static const String perfekt = 'hat umgeschlossen';
  static const String arabicTranslation = 'إعادة هيكلة الإبرام (التواصل الطبي)';
  static const String ipaTranscription = '[umˈˈʃliːsn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2927_umschliessen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung umschliessen.';
  static const String exampleArabic = 'يجب علينا إعادة هيكلة الإبرام في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
