// Sovereign Polyglot Core - Task 2622 (Clinical Diagnostics)
class Task2622Engine {
  static const int taskId = 2622;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'verstellen';
  static const String praeteritum = 'verstellte';
  static const String perfekt = 'hat verstellt';
  static const String arabicTranslation = 'توثيق / معالجة التنظيم (التواصل الطبي)';
  static const String ipaTranscription = '[verˈˈʃtɛlən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2622_verstellen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung verstellen.';
  static const String exampleArabic = 'يجب علينا توثيق / معالجة التنظيم في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
