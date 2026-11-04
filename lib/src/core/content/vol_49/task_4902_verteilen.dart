// Sovereign Polyglot Core - Task 4902 (Quality Assurance)
class Task4902Engine {
  static const int taskId = 4902;
  static const String domain = 'Quality Assurance';
  static const String verbInfinitive = 'verteilen';
  static const String praeteritum = 'verteilte';
  static const String perfekt = 'hat verteilt';
  static const String arabicTranslation = 'توثيق / معالجة التقسيم (ضمان الجودة)';
  static const String ipaTranscription = '[verˈˈtaɪ̯lən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4902_verteilen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Qualitaetsprozess verteilen.';
  static const String exampleArabic = 'يجب علينا توثيق / معالجة التقسيم في إجراءات فحص الجودة.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
