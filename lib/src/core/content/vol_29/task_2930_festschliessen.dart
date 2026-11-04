// Sovereign Polyglot Core - Task 2930 (Clinical Diagnostics)
class Task2930Engine {
  static const int taskId = 2930;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'festschliessen';
  static const String praeteritum = 'schloss fest';
  static const String perfekt = 'hat festgeschlossen';
  static const String arabicTranslation = 'تثبيت / إقرار الإبرام (التواصل الطبي)';
  static const String ipaTranscription = '[festˈˈʃliːsn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2930_festschliessen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung festschliessen.';
  static const String exampleArabic = 'يجب علينا تثبيت / إقرار الإبرام في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
