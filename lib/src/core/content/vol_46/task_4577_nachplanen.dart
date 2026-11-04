// Sovereign Polyglot Core - Task 4577 (Quality Assurance)
class Task4577Engine {
  static const int taskId = 4577;
  static const String domain = 'Quality Assurance';
  static const String verbInfinitive = 'nachplanen';
  static const String praeteritum = 'plante nach';
  static const String perfekt = 'hat nachgeplant';
  static const String arabicTranslation = 'تدقيق / متابعة التخطيط (ضمان الجودة)';
  static const String ipaTranscription = '[nachˈˈplaːnən]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4577_nachplanen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Qualitaetsprozess nachplanen.';
  static const String exampleArabic = 'يجب علينا تدقيق / متابعة التخطيط في إجراءات فحص الجودة.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
