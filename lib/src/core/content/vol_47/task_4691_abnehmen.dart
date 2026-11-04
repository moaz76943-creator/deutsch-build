// Sovereign Polyglot Core - Task 4691 (Quality Assurance)
class Task4691Engine {
  static const int taskId = 4691;
  static const String domain = 'Quality Assurance';
  static const String verbInfinitive = 'abnehmen';
  static const String praeteritum = 'nahm ab';
  static const String perfekt = 'hat abgenommen';
  static const String arabicTranslation = 'فصل / إتمام الاستلام (ضمان الجودة)';
  static const String ipaTranscription = '[abˈˈneːmən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4691_abnehmen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Qualitaetsprozess abnehmen.';
  static const String exampleArabic = 'يجب علينا فصل / إتمام الاستلام في إجراءات فحص الجودة.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
