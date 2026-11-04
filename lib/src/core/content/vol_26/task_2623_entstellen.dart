// Sovereign Polyglot Core - Task 2623 (Clinical Diagnostics)
class Task2623Engine {
  static const int taskId = 2623;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'entstellen';
  static const String praeteritum = 'entstellte';
  static const String perfekt = 'hat entstellt';
  static const String arabicTranslation = 'استخلاص / كشف التنظيم (التواصل الطبي)';
  static const String ipaTranscription = '[entˈˈʃtɛlən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2623_entstellen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung entstellen.';
  static const String exampleArabic = 'يجب علينا استخلاص / كشف التنظيم في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
