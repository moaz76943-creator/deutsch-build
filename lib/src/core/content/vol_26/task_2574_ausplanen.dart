// Sovereign Polyglot Core - Task 2574 (Clinical Diagnostics)
class Task2574Engine {
  static const int taskId = 2574;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'ausplanen';
  static const String praeteritum = 'plante aus';
  static const String perfekt = 'hat ausgeplant';
  static const String arabicTranslation = 'توسيع / استخراج التخطيط (التواصل الطبي)';
  static const String ipaTranscription = '[ausˈˈplaːnən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2574_ausplanen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung ausplanen.';
  static const String exampleArabic = 'يجب علينا توسيع / استخراج التخطيط في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
