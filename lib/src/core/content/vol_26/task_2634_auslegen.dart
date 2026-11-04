// Sovereign Polyglot Core - Task 2634 (Clinical Diagnostics)
class Task2634Engine {
  static const int taskId = 2634;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'auslegen';
  static const String praeteritum = 'legte aus';
  static const String perfekt = 'hat ausgelegt';
  static const String arabicTranslation = 'توسيع / استخراج التأسيس (التواصل الطبي)';
  static const String ipaTranscription = '[ausˈˈleːɡn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2634_auslegen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung auslegen.';
  static const String exampleArabic = 'يجب علينا توسيع / استخراج التأسيس في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
