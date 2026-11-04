// Sovereign Polyglot Core - Task 2837 (Clinical Diagnostics)
class Task2837Engine {
  static const int taskId = 2837;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'nachweisen';
  static const String praeteritum = 'wies nach';
  static const String perfekt = 'hat nachgewiesen';
  static const String arabicTranslation = 'تدقيق / متابعة التوجيه (التواصل الطبي)';
  static const String ipaTranscription = '[nachˈˈvaɪ̯zn̩]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2837_nachweisen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung nachweisen.';
  static const String exampleArabic = 'يجب علينا تدقيق / متابعة التوجيه في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
