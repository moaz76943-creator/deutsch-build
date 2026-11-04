// Sovereign Polyglot Core - Task 2805 (Clinical Diagnostics)
class Task2805Engine {
  static const int taskId = 2805;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'erziehen';
  static const String praeteritum = 'erzog';
  static const String perfekt = 'hat erzogen';
  static const String arabicTranslation = 'إنجاز / تحقيق الاستنتاج (التواصل الطبي)';
  static const String ipaTranscription = '[erˈˈtsiːən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2805_erziehen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung erziehen.';
  static const String exampleArabic = 'يجب علينا إنجاز / تحقيق الاستنتاج في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
