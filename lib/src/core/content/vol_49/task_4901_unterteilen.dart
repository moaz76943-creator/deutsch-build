// Sovereign Polyglot Core - Task 4901 (Quality Assurance)
class Task4901Engine {
  static const int taskId = 4901;
  static const String domain = 'Quality Assurance';
  static const String verbInfinitive = 'unterteilen';
  static const String praeteritum = 'unterteilte';
  static const String perfekt = 'hat unterteilt';
  static const String arabicTranslation = 'فحص / دعم التقسيم (ضمان الجودة)';
  static const String ipaTranscription = '[unterˈˈtaɪ̯lən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4901_unterteilen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Qualitaetsprozess unterteilen.';
  static const String exampleArabic = 'يجب علينا فحص / دعم التقسيم في إجراءات فحص الجودة.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
