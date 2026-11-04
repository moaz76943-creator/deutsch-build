// Sovereign Polyglot Core - Task 2929 (Clinical Diagnostics)
class Task2929Engine {
  static const int taskId = 2929;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'zusammenschliessen';
  static const String praeteritum = 'schloss zusammen';
  static const String perfekt = 'hat zusammengeschlossen';
  static const String arabicTranslation = 'تجميع / توحيد الإبرام (التواصل الطبي)';
  static const String ipaTranscription = '[zusammenˈˈʃliːsn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2929_zusammenschliessen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung zusammenschliessen.';
  static const String exampleArabic = 'يجب علينا تجميع / توحيد الإبرام في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
