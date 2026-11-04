// Sovereign Polyglot Core - Task 4582 (Quality Assurance)
class Task4582Engine {
  static const int taskId = 4582;
  static const String domain = 'Quality Assurance';
  static const String verbInfinitive = 'verplanen';
  static const String praeteritum = 'verplante';
  static const String perfekt = 'hat verplant';
  static const String arabicTranslation = 'توثيق / معالجة التخطيط (ضمان الجودة)';
  static const String ipaTranscription = '[verˈˈplaːnən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4582_verplanen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Qualitaetsprozess verplanen.';
  static const String exampleArabic = 'يجب علينا توثيق / معالجة التخطيط في إجراءات فحص الجودة.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
