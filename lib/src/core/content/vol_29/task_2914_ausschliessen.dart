// Sovereign Polyglot Core - Task 2914 (Clinical Diagnostics)
class Task2914Engine {
  static const int taskId = 2914;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'ausschliessen';
  static const String praeteritum = 'schloss aus';
  static const String perfekt = 'hat ausgeschlossen';
  static const String arabicTranslation = 'توسيع / استخراج الإبرام (التواصل الطبي)';
  static const String ipaTranscription = '[ausˈˈʃliːsn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2914_ausschliessen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung ausschliessen.';
  static const String exampleArabic = 'يجب علينا توسيع / استخراج الإبرام في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
