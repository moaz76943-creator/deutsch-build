// Sovereign Polyglot Core - Task 2849 (Clinical Diagnostics)
class Task2849Engine {
  static const int taskId = 2849;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'zusammenweisen';
  static const String praeteritum = 'wies zusammen';
  static const String perfekt = 'hat zusammengewiesen';
  static const String arabicTranslation = 'تجميع / توحيد التوجيه (التواصل الطبي)';
  static const String ipaTranscription = '[zusammenˈˈvaɪ̯zn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2849_zusammenweisen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung zusammenweisen.';
  static const String exampleArabic = 'يجب علينا تجميع / توحيد التوجيه في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
