// Sovereign Polyglot Core - Task 4931 (Quality Assurance)
class Task4931Engine {
  static const int taskId = 4931;
  static const String domain = 'Quality Assurance';
  static const String verbInfinitive = 'abbauen';
  static const String praeteritum = 'baute ab';
  static const String perfekt = 'hat abgebaut';
  static const String arabicTranslation = 'فصل / إتمام التطوير (ضمان الجودة)';
  static const String ipaTranscription = '[abˈˈbaʊ̯ən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4931_abbauen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Qualitaetsprozess abbauen.';
  static const String exampleArabic = 'يجب علينا فصل / إتمام التطوير في إجراءات فحص الجودة.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
