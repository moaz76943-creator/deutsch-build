// Sovereign Polyglot Core - Task 2798 (Clinical Diagnostics)
class Task2798Engine {
  static const int taskId = 2798;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'vorziehen';
  static const String praeteritum = 'zog vor';
  static const String perfekt = 'hat vorgezogen';
  static const String arabicTranslation = 'تقديم / تحضير الاستنتاج (التواصل الطبي)';
  static const String ipaTranscription = '[vorˈˈtsiːən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2798_vorziehen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung vorziehen.';
  static const String exampleArabic = 'يجب علينا تقديم / تحضير الاستنتاج في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
