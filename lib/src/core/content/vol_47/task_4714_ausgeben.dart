// Sovereign Polyglot Core - Task 4714 (Quality Assurance)
class Task4714Engine {
  static const int taskId = 4714;
  static const String domain = 'Quality Assurance';
  static const String verbInfinitive = 'ausgeben';
  static const String praeteritum = 'gab aus';
  static const String perfekt = 'hat ausgegeben';
  static const String arabicTranslation = 'توسيع / استخراج التسليم (ضمان الجودة)';
  static const String ipaTranscription = '[ausˈˈɡeːbn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4714_ausgeben.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Qualitaetsprozess ausgeben.';
  static const String exampleArabic = 'يجب علينا توسيع / استخراج التسليم في إجراءات فحص الجودة.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
