// Sovereign Polyglot Core - Task 2925 (Clinical Diagnostics)
class Task2925Engine {
  static const int taskId = 2925;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'erschliessen';
  static const String praeteritum = 'erschloss';
  static const String perfekt = 'hat erschlossen';
  static const String arabicTranslation = 'إنجاز / تحقيق الإبرام (التواصل الطبي)';
  static const String ipaTranscription = '[erˈˈʃliːsn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2925_erschliessen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung erschliessen.';
  static const String exampleArabic = 'يجب علينا إنجاز / تحقيق الإبرام في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
