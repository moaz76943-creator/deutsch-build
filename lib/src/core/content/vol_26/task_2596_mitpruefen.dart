// Sovereign Polyglot Core - Task 2596 (Clinical Diagnostics)
class Task2596Engine {
  static const int taskId = 2596;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'mitpruefen';
  static const String praeteritum = 'pruefte mit';
  static const String perfekt = 'hat mitgeprueft';
  static const String arabicTranslation = 'مشاركة / تنسيق التدقيق (التواصل الطبي)';
  static const String ipaTranscription = '[mitˈˈpʁyːfn̩]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2596_mitpruefen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung mitpruefen.';
  static const String exampleArabic = 'يجب علينا مشاركة / تنسيق التدقيق في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
