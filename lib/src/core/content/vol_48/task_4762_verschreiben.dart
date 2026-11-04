// Sovereign Polyglot Core - Task 4762 (Quality Assurance)
class Task4762Engine {
  static const int taskId = 4762;
  static const String domain = 'Quality Assurance';
  static const String verbInfinitive = 'verschreiben';
  static const String praeteritum = 'verschrieb';
  static const String perfekt = 'hat verschrieben';
  static const String arabicTranslation = 'توثيق / معالجة التدوين (ضمان الجودة)';
  static const String ipaTranscription = '[verˈˈʃʁaɪ̯bn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4762_verschreiben.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Qualitaetsprozess verschreiben.';
  static const String exampleArabic = 'يجب علينا توثيق / معالجة التدوين في إجراءات فحص الجودة.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
