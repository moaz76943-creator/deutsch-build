// Sovereign Polyglot Core - Task 4730 (Quality Assurance)
class Task4730Engine {
  static const int taskId = 4730;
  static const String domain = 'Quality Assurance';
  static const String verbInfinitive = 'festgeben';
  static const String praeteritum = 'gab fest';
  static const String perfekt = 'hat festgegeben';
  static const String arabicTranslation = 'تثبيت / إقرار التسليم (ضمان الجودة)';
  static const String ipaTranscription = '[festˈˈɡeːbn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4730_festgeben.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Qualitaetsprozess festgeben.';
  static const String exampleArabic = 'يجب علينا تثبيت / إقرار التسليم في إجراءات فحص الجودة.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
