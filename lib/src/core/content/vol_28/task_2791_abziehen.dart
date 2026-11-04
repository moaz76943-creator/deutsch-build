// Sovereign Polyglot Core - Task 2791 (Clinical Diagnostics)
class Task2791Engine {
  static const int taskId = 2791;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'abziehen';
  static const String praeteritum = 'zog ab';
  static const String perfekt = 'hat abgezogen';
  static const String arabicTranslation = 'فصل / إتمام الاستنتاج (التواصل الطبي)';
  static const String ipaTranscription = '[abˈˈtsiːən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2791_abziehen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung abziehen.';
  static const String exampleArabic = 'يجب علينا فصل / إتمام الاستنتاج في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
