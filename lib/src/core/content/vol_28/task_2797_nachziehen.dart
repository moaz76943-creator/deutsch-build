// Sovereign Polyglot Core - Task 2797 (Clinical Diagnostics)
class Task2797Engine {
  static const int taskId = 2797;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'nachziehen';
  static const String praeteritum = 'zog nach';
  static const String perfekt = 'hat nachgezogen';
  static const String arabicTranslation = 'تدقيق / متابعة الاستنتاج (التواصل الطبي)';
  static const String ipaTranscription = '[nachˈˈtsiːən]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2797_nachziehen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung nachziehen.';
  static const String exampleArabic = 'يجب علينا تدقيق / متابعة الاستنتاج في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
