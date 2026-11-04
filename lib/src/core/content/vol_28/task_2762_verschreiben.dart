// Sovereign Polyglot Core - Task 2762 (Clinical Diagnostics)
class Task2762Engine {
  static const int taskId = 2762;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'verschreiben';
  static const String praeteritum = 'verschrieb';
  static const String perfekt = 'hat verschrieben';
  static const String arabicTranslation = 'توثيق / معالجة التدوين (التواصل الطبي)';
  static const String ipaTranscription = '[verˈˈʃʁaɪ̯bn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2762_verschreiben.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung verschreiben.';
  static const String exampleArabic = 'يجب علينا توثيق / معالجة التدوين في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
