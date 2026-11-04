// Sovereign Polyglot Core - Task 2908 (Clinical Diagnostics)
class Task2908Engine {
  static const int taskId = 2908;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'weiterteilen';
  static const String praeteritum = 'teilte weiter';
  static const String perfekt = 'hat weitergeteilt';
  static const String arabicTranslation = 'مواصلة / تمرير التقسيم (التواصل الطبي)';
  static const String ipaTranscription = '[weiterˈˈtaɪ̯lən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2908_weiterteilen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung weiterteilen.';
  static const String exampleArabic = 'يجب علينا مواصلة / تمرير التقسيم في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
