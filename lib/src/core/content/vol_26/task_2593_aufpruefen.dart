// Sovereign Polyglot Core - Task 2593 (Clinical Diagnostics)
class Task2593Engine {
  static const int taskId = 2593;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'aufpruefen';
  static const String praeteritum = 'pruefte auf';
  static const String perfekt = 'hat aufgeprueft';
  static const String arabicTranslation = 'رفع / فتح التدقيق (التواصل الطبي)';
  static const String ipaTranscription = '[aufˈˈpʁyːfn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2593_aufpruefen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung aufpruefen.';
  static const String exampleArabic = 'يجب علينا رفع / فتح التدقيق في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
