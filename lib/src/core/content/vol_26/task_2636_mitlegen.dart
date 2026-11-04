// Sovereign Polyglot Core - Task 2636 (Clinical Diagnostics)
class Task2636Engine {
  static const int taskId = 2636;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'mitlegen';
  static const String praeteritum = 'legte mit';
  static const String perfekt = 'hat mitgelegt';
  static const String arabicTranslation = 'مشاركة / تنسيق التأسيس (التواصل الطبي)';
  static const String ipaTranscription = '[mitˈˈleːɡn̩]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2636_mitlegen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung mitlegen.';
  static const String exampleArabic = 'يجب علينا مشاركة / تنسيق التأسيس في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
