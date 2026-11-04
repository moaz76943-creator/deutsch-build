// Sovereign Polyglot Core - Task 2809 (Clinical Diagnostics)
class Task2809Engine {
  static const int taskId = 2809;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'zusammenziehen';
  static const String praeteritum = 'zog zusammen';
  static const String perfekt = 'hat zusammengezogen';
  static const String arabicTranslation = 'تجميع / توحيد الاستنتاج (التواصل الطبي)';
  static const String ipaTranscription = '[zusammenˈˈtsiːən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2809_zusammenziehen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung zusammenziehen.';
  static const String exampleArabic = 'يجب علينا تجميع / توحيد الاستنتاج في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
