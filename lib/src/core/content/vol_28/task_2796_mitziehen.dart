// Sovereign Polyglot Core - Task 2796 (Clinical Diagnostics)
class Task2796Engine {
  static const int taskId = 2796;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'mitziehen';
  static const String praeteritum = 'zog mit';
  static const String perfekt = 'hat mitgezogen';
  static const String arabicTranslation = 'مشاركة / تنسيق الاستنتاج (التواصل الطبي)';
  static const String ipaTranscription = '[mitˈˈtsiːən]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2796_mitziehen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung mitziehen.';
  static const String exampleArabic = 'يجب علينا مشاركة / تنسيق الاستنتاج في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
