// Sovereign Polyglot Core - Task 2901 (Clinical Diagnostics)
class Task2901Engine {
  static const int taskId = 2901;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'unterteilen';
  static const String praeteritum = 'unterteilte';
  static const String perfekt = 'hat unterteilt';
  static const String arabicTranslation = 'فحص / دعم التقسيم (التواصل الطبي)';
  static const String ipaTranscription = '[unterˈˈtaɪ̯lən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2901_unterteilen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung unterteilen.';
  static const String exampleArabic = 'يجب علينا فحص / دعم التقسيم في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
