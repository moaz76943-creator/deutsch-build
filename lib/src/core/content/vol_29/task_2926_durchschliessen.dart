// Sovereign Polyglot Core - Task 2926 (Clinical Diagnostics)
class Task2926Engine {
  static const int taskId = 2926;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'durchschliessen';
  static const String praeteritum = 'schloss durch';
  static const String perfekt = 'hat durchgeschlossen';
  static const String arabicTranslation = 'إتمام شامل الإبرام (التواصل الطبي)';
  static const String ipaTranscription = '[durchˈˈʃliːsn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2926_durchschliessen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung durchschliessen.';
  static const String exampleArabic = 'يجب علينا إتمام شامل الإبرام في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
