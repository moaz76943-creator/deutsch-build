// Sovereign Polyglot Core - Task 2856 (Clinical Diagnostics)
class Task2856Engine {
  static const int taskId = 2856;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'mitrechnen';
  static const String praeteritum = 'rechnete mit';
  static const String perfekt = 'hat mitgerechnet';
  static const String arabicTranslation = 'مشاركة / تنسيق التقدير (التواصل الطبي)';
  static const String ipaTranscription = '[mitˈˈʁɛçnən]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2856_mitrechnen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung mitrechnen.';
  static const String exampleArabic = 'يجب علينا مشاركة / تنسيق التقدير في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
