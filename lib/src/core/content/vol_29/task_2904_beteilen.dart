// Sovereign Polyglot Core - Task 2904 (Clinical Diagnostics)
class Task2904Engine {
  static const int taskId = 2904;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'beteilen';
  static const String praeteritum = 'beteilte';
  static const String perfekt = 'hat beteilt';
  static const String arabicTranslation = 'تأكيد / تزويد التقسيم (التواصل الطبي)';
  static const String ipaTranscription = '[beˈˈtaɪ̯lən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2904_beteilen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung beteilen.';
  static const String exampleArabic = 'يجب علينا تأكيد / تزويد التقسيم في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
