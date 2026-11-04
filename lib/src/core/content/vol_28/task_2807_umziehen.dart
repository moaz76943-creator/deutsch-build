// Sovereign Polyglot Core - Task 2807 (Clinical Diagnostics)
class Task2807Engine {
  static const int taskId = 2807;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'umziehen';
  static const String praeteritum = 'zog um';
  static const String perfekt = 'hat umgezogen';
  static const String arabicTranslation = 'إعادة هيكلة الاستنتاج (التواصل الطبي)';
  static const String ipaTranscription = '[umˈˈtsiːən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2807_umziehen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung umziehen.';
  static const String exampleArabic = 'يجب علينا إعادة هيكلة الاستنتاج في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
