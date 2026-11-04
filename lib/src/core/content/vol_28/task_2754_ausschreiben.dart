// Sovereign Polyglot Core - Task 2754 (Clinical Diagnostics)
class Task2754Engine {
  static const int taskId = 2754;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'ausschreiben';
  static const String praeteritum = 'schrieb aus';
  static const String perfekt = 'hat ausgeschrieben';
  static const String arabicTranslation = 'توسيع / استخراج التدوين (التواصل الطبي)';
  static const String ipaTranscription = '[ausˈˈʃʁaɪ̯bn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2754_ausschreiben.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung ausschreiben.';
  static const String exampleArabic = 'يجب علينا توسيع / استخراج التدوين في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
