// Sovereign Polyglot Core - Task 2835 (Clinical Diagnostics)
class Task2835Engine {
  static const int taskId = 2835;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'einweisen';
  static const String praeteritum = 'wies ein';
  static const String perfekt = 'hat eingewiesen';
  static const String arabicTranslation = 'إدراج / دمج التوجيه (التواصل الطبي)';
  static const String ipaTranscription = '[einˈˈvaɪ̯zn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2835_einweisen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung einweisen.';
  static const String exampleArabic = 'يجب علينا إدراج / دمج التوجيه في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
