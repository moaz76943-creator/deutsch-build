// Sovereign Polyglot Core - Task 2764 (Clinical Diagnostics)
class Task2764Engine {
  static const int taskId = 2764;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'beschreiben';
  static const String praeteritum = 'beschrieb';
  static const String perfekt = 'hat beschrieben';
  static const String arabicTranslation = 'تأكيد / تزويد التدوين (التواصل الطبي)';
  static const String ipaTranscription = '[beˈˈʃʁaɪ̯bn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2764_beschreiben.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung beschreiben.';
  static const String exampleArabic = 'يجب علينا تأكيد / تزويد التدوين في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
