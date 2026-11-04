// Sovereign Polyglot Core - Task 2769 (Clinical Diagnostics)
class Task2769Engine {
  static const int taskId = 2769;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'zusammenschreiben';
  static const String praeteritum = 'schrieb zusammen';
  static const String perfekt = 'hat zusammengeschrieben';
  static const String arabicTranslation = 'تجميع / توحيد التدوين (التواصل الطبي)';
  static const String ipaTranscription = '[zusammenˈˈʃʁaɪ̯bn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2769_zusammenschreiben.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung zusammenschreiben.';
  static const String exampleArabic = 'يجب علينا تجميع / توحيد التدوين في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
