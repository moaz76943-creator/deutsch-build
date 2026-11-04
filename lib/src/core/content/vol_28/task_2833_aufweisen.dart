// Sovereign Polyglot Core - Task 2833 (Clinical Diagnostics)
class Task2833Engine {
  static const int taskId = 2833;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'aufweisen';
  static const String praeteritum = 'wies auf';
  static const String perfekt = 'hat aufgewiesen';
  static const String arabicTranslation = 'رفع / فتح التوجيه (التواصل الطبي)';
  static const String ipaTranscription = '[aufˈˈvaɪ̯zn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2833_aufweisen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung aufweisen.';
  static const String exampleArabic = 'يجب علينا رفع / فتح التوجيه في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
