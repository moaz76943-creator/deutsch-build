// Sovereign Polyglot Core - Task 2637 (Clinical Diagnostics)
class Task2637Engine {
  static const int taskId = 2637;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'nachlegen';
  static const String praeteritum = 'legte nach';
  static const String perfekt = 'hat nachgelegt';
  static const String arabicTranslation = 'تدقيق / متابعة التأسيس (التواصل الطبي)';
  static const String ipaTranscription = '[nachˈˈleːɡn̩]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2637_nachlegen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung nachlegen.';
  static const String exampleArabic = 'يجب علينا تدقيق / متابعة التأسيس في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
