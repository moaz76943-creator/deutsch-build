// Sovereign Polyglot Core - Task 2717 (Clinical Diagnostics)
class Task2717Engine {
  static const int taskId = 2717;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'nachgeben';
  static const String praeteritum = 'gab nach';
  static const String perfekt = 'hat nachgegeben';
  static const String arabicTranslation = 'تدقيق / متابعة التسليم (التواصل الطبي)';
  static const String ipaTranscription = '[nachˈˈɡeːbn̩]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2717_nachgeben.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung nachgeben.';
  static const String exampleArabic = 'يجب علينا تدقيق / متابعة التسليم في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
