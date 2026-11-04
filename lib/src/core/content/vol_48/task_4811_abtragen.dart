// Sovereign Polyglot Core - Task 4811 (Quality Assurance)
class Task4811Engine {
  static const int taskId = 4811;
  static const String domain = 'Quality Assurance';
  static const String verbInfinitive = 'abtragen';
  static const String praeteritum = 'trug ab';
  static const String perfekt = 'hat abgetragen';
  static const String arabicTranslation = 'فصل / إتمام المسؤولية (ضمان الجودة)';
  static const String ipaTranscription = '[abˈˈtʁaːɡn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4811_abtragen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Qualitaetsprozess abtragen.';
  static const String exampleArabic = 'يجب علينا فصل / إتمام المسؤولية في إجراءات فحص الجودة.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
