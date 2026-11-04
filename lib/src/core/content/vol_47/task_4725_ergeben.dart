// Sovereign Polyglot Core - Task 4725 (Quality Assurance)
class Task4725Engine {
  static const int taskId = 4725;
  static const String domain = 'Quality Assurance';
  static const String verbInfinitive = 'ergeben';
  static const String praeteritum = 'ergab';
  static const String perfekt = 'hat ergeben';
  static const String arabicTranslation = 'إنجاز / تحقيق التسليم (ضمان الجودة)';
  static const String ipaTranscription = '[erˈˈɡeːbn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4725_ergeben.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Qualitaetsprozess ergeben.';
  static const String exampleArabic = 'يجب علينا إنجاز / تحقيق التسليم في إجراءات فحص الجودة.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
