// Sovereign Polyglot Core - Task 4622 (Quality Assurance)
class Task4622Engine {
  static const int taskId = 4622;
  static const String domain = 'Quality Assurance';
  static const String verbInfinitive = 'verstellen';
  static const String praeteritum = 'verstellte';
  static const String perfekt = 'hat verstellt';
  static const String arabicTranslation = 'توثيق / معالجة التنظيم (ضمان الجودة)';
  static const String ipaTranscription = '[verˈˈʃtɛlən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4622_verstellen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Qualitaetsprozess verstellen.';
  static const String exampleArabic = 'يجب علينا توثيق / معالجة التنظيم في إجراءات فحص الجودة.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
