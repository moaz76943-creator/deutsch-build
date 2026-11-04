// Sovereign Polyglot Core - Task 2576 (Clinical Diagnostics)
class Task2576Engine {
  static const int taskId = 2576;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'mitplanen';
  static const String praeteritum = 'plante mit';
  static const String perfekt = 'hat mitgeplant';
  static const String arabicTranslation = 'مشاركة / تنسيق التخطيط (التواصل الطبي)';
  static const String ipaTranscription = '[mitˈˈplaːnən]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2576_mitplanen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung mitplanen.';
  static const String exampleArabic = 'يجب علينا مشاركة / تنسيق التخطيط في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
