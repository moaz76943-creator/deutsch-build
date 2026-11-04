// Sovereign Polyglot Core - Task 2582 (Clinical Diagnostics)
class Task2582Engine {
  static const int taskId = 2582;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'verplanen';
  static const String praeteritum = 'verplante';
  static const String perfekt = 'hat verplant';
  static const String arabicTranslation = 'توثيق / معالجة التخطيط (التواصل الطبي)';
  static const String ipaTranscription = '[verˈˈplaːnən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2582_verplanen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung verplanen.';
  static const String exampleArabic = 'يجب علينا توثيق / معالجة التخطيط في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
