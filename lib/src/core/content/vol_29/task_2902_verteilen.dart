// Sovereign Polyglot Core - Task 2902 (Clinical Diagnostics)
class Task2902Engine {
  static const int taskId = 2902;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'verteilen';
  static const String praeteritum = 'verteilte';
  static const String perfekt = 'hat verteilt';
  static const String arabicTranslation = 'توثيق / معالجة التقسيم (التواصل الطبي)';
  static const String ipaTranscription = '[verˈˈtaɪ̯lən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2902_verteilen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung verteilen.';
  static const String exampleArabic = 'يجب علينا توثيق / معالجة التقسيم في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
