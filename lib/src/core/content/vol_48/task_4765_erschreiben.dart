// Sovereign Polyglot Core - Task 4765 (Quality Assurance)
class Task4765Engine {
  static const int taskId = 4765;
  static const String domain = 'Quality Assurance';
  static const String verbInfinitive = 'erschreiben';
  static const String praeteritum = 'erschrieb';
  static const String perfekt = 'hat erschrieben';
  static const String arabicTranslation = 'إنجاز / تحقيق التدوين (ضمان الجودة)';
  static const String ipaTranscription = '[erˈˈʃʁaɪ̯bn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4765_erschreiben.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Qualitaetsprozess erschreiben.';
  static const String exampleArabic = 'يجب علينا إنجاز / تحقيق التدوين في إجراءات فحص الجودة.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
