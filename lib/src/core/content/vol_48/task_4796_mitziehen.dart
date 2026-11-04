// Sovereign Polyglot Core - Task 4796 (Quality Assurance)
class Task4796Engine {
  static const int taskId = 4796;
  static const String domain = 'Quality Assurance';
  static const String verbInfinitive = 'mitziehen';
  static const String praeteritum = 'zog mit';
  static const String perfekt = 'hat mitgezogen';
  static const String arabicTranslation = 'مشاركة / تنسيق الاستنتاج (ضمان الجودة)';
  static const String ipaTranscription = '[mitˈˈtsiːən]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4796_mitziehen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Qualitaetsprozess mitziehen.';
  static const String exampleArabic = 'يجب علينا مشاركة / تنسيق الاستنتاج في إجراءات فحص الجودة.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
