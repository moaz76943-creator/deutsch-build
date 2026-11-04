// Sovereign Polyglot Core - Task 4793 (Quality Assurance)
class Task4793Engine {
  static const int taskId = 4793;
  static const String domain = 'Quality Assurance';
  static const String verbInfinitive = 'aufziehen';
  static const String praeteritum = 'zog auf';
  static const String perfekt = 'hat aufgezogen';
  static const String arabicTranslation = 'رفع / فتح الاستنتاج (ضمان الجودة)';
  static const String ipaTranscription = '[aufˈˈtsiːən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4793_aufziehen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Qualitaetsprozess aufziehen.';
  static const String exampleArabic = 'يجب علينا رفع / فتح الاستنتاج في إجراءات فحص الجودة.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
