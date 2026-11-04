// Sovereign Polyglot Core - Task 4905 (Quality Assurance)
class Task4905Engine {
  static const int taskId = 4905;
  static const String domain = 'Quality Assurance';
  static const String verbInfinitive = 'erteilen';
  static const String praeteritum = 'erteilte';
  static const String perfekt = 'hat erteilt';
  static const String arabicTranslation = 'إنجاز / تحقيق التقسيم (ضمان الجودة)';
  static const String ipaTranscription = '[erˈˈtaɪ̯lən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4905_erteilen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Qualitaetsprozess erteilen.';
  static const String exampleArabic = 'يجب علينا إنجاز / تحقيق التقسيم في إجراءات فحص الجودة.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
