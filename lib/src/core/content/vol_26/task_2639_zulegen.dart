// Sovereign Polyglot Core - Task 2639 (Clinical Diagnostics)
class Task2639Engine {
  static const int taskId = 2639;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'zulegen';
  static const String praeteritum = 'legte zu';
  static const String perfekt = 'hat zugelegt';
  static const String arabicTranslation = 'توجيه / إغلاق التأسيس (التواصل الطبي)';
  static const String ipaTranscription = '[zuˈˈleːɡn̩]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2639_zulegen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung zulegen.';
  static const String exampleArabic = 'يجب علينا توجيه / إغلاق التأسيس في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
