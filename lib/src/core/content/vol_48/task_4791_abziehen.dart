// Sovereign Polyglot Core - Task 4791 (Quality Assurance)
class Task4791Engine {
  static const int taskId = 4791;
  static const String domain = 'Quality Assurance';
  static const String verbInfinitive = 'abziehen';
  static const String praeteritum = 'zog ab';
  static const String perfekt = 'hat abgezogen';
  static const String arabicTranslation = 'فصل / إتمام الاستنتاج (ضمان الجودة)';
  static const String ipaTranscription = '[abˈˈtsiːən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4791_abziehen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Qualitaetsprozess abziehen.';
  static const String exampleArabic = 'يجب علينا فصل / إتمام الاستنتاج في إجراءات فحص الجودة.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
