// Sovereign Polyglot Core - Task 4630 (Quality Assurance)
class Task4630Engine {
  static const int taskId = 4630;
  static const String domain = 'Quality Assurance';
  static const String verbInfinitive = 'feststellen';
  static const String praeteritum = 'stellte fest';
  static const String perfekt = 'hat festgestellt';
  static const String arabicTranslation = 'تثبيت / إقرار التنظيم (ضمان الجودة)';
  static const String ipaTranscription = '[festˈˈʃtɛlən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4630_feststellen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Qualitaetsprozess feststellen.';
  static const String exampleArabic = 'يجب علينا تثبيت / إقرار التنظيم في إجراءات فحص الجودة.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
