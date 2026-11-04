// Sovereign Polyglot Core - Task 4571 (Quality Assurance)
class Task4571Engine {
  static const int taskId = 4571;
  static const String domain = 'Quality Assurance';
  static const String verbInfinitive = 'abplanen';
  static const String praeteritum = 'plante ab';
  static const String perfekt = 'hat abgeplant';
  static const String arabicTranslation = 'فصل / إتمام التخطيط (ضمان الجودة)';
  static const String ipaTranscription = '[abˈˈplaːnən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4571_abplanen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Qualitaetsprozess abplanen.';
  static const String exampleArabic = 'يجب علينا فصل / إتمام التخطيط في إجراءات فحص الجودة.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
