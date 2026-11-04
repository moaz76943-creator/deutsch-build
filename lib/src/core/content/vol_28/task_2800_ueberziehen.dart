// Sovereign Polyglot Core - Task 2800 (Clinical Diagnostics)
class Task2800Engine {
  static const int taskId = 2800;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'ueberziehen';
  static const String praeteritum = 'ueberzog';
  static const String perfekt = 'hat ueberzogen';
  static const String arabicTranslation = 'مراجعة / نقل الاستنتاج (التواصل الطبي)';
  static const String ipaTranscription = '[ueberˈˈtsiːən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2800_ueberziehen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung ueberziehen.';
  static const String exampleArabic = 'يجب علينا مراجعة / نقل الاستنتاج في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
