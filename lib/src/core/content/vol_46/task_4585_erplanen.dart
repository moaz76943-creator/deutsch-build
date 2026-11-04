// Sovereign Polyglot Core - Task 4585 (Quality Assurance)
class Task4585Engine {
  static const int taskId = 4585;
  static const String domain = 'Quality Assurance';
  static const String verbInfinitive = 'erplanen';
  static const String praeteritum = 'erplante';
  static const String perfekt = 'hat erplant';
  static const String arabicTranslation = 'إنجاز / تحقيق التخطيط (ضمان الجودة)';
  static const String ipaTranscription = '[erˈˈplaːnən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4585_erplanen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Qualitaetsprozess erplanen.';
  static const String exampleArabic = 'يجب علينا إنجاز / تحقيق التخطيط في إجراءات فحص الجودة.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
