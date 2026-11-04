// Sovereign Polyglot Core - Task 4590 (Quality Assurance)
class Task4590Engine {
  static const int taskId = 4590;
  static const String domain = 'Quality Assurance';
  static const String verbInfinitive = 'festplanen';
  static const String praeteritum = 'plante fest';
  static const String perfekt = 'hat festgeplant';
  static const String arabicTranslation = 'تثبيت / إقرار التخطيط (ضمان الجودة)';
  static const String ipaTranscription = '[festˈˈplaːnən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4590_festplanen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Qualitaetsprozess festplanen.';
  static const String exampleArabic = 'يجب علينا تثبيت / إقرار التخطيط في إجراءات فحص الجودة.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
