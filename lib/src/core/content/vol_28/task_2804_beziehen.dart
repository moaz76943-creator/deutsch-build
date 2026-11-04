// Sovereign Polyglot Core - Task 2804 (Clinical Diagnostics)
class Task2804Engine {
  static const int taskId = 2804;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'beziehen';
  static const String praeteritum = 'bezog';
  static const String perfekt = 'hat bezogen';
  static const String arabicTranslation = 'تأكيد / تزويد الاستنتاج (التواصل الطبي)';
  static const String ipaTranscription = '[beˈˈtsiːən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2804_beziehen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung beziehen.';
  static const String exampleArabic = 'يجب علينا تأكيد / تزويد الاستنتاج في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
