// Sovereign Polyglot Core - Task 2838 (Clinical Diagnostics)
class Task2838Engine {
  static const int taskId = 2838;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'vorweisen';
  static const String praeteritum = 'wies vor';
  static const String perfekt = 'hat vorgewiesen';
  static const String arabicTranslation = 'تقديم / تحضير التوجيه (التواصل الطبي)';
  static const String ipaTranscription = '[vorˈˈvaɪ̯zn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2838_vorweisen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung vorweisen.';
  static const String exampleArabic = 'يجب علينا تقديم / تحضير التوجيه في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
