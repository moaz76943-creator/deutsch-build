// Sovereign Polyglot Core - Task 4831 (Quality Assurance)
class Task4831Engine {
  static const int taskId = 4831;
  static const String domain = 'Quality Assurance';
  static const String verbInfinitive = 'abweisen';
  static const String praeteritum = 'wies ab';
  static const String perfekt = 'hat abgewiesen';
  static const String arabicTranslation = 'فصل / إتمام التوجيه (ضمان الجودة)';
  static const String ipaTranscription = '[abˈˈvaɪ̯zn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4831_abweisen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Qualitaetsprozess abweisen.';
  static const String exampleArabic = 'يجب علينا فصل / إتمام التوجيه في إجراءات فحص الجودة.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
