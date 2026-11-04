// Sovereign Polyglot Core - Task 2753 (Clinical Diagnostics)
class Task2753Engine {
  static const int taskId = 2753;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'aufschreiben';
  static const String praeteritum = 'schrieb auf';
  static const String perfekt = 'hat aufgeschrieben';
  static const String arabicTranslation = 'رفع / فتح التدوين (التواصل الطبي)';
  static const String ipaTranscription = '[aufˈˈʃʁaɪ̯bn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2753_aufschreiben.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung aufschreiben.';
  static const String exampleArabic = 'يجب علينا رفع / فتح التدوين في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
