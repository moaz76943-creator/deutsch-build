// Sovereign Polyglot Core - Task 4764 (Quality Assurance)
class Task4764Engine {
  static const int taskId = 4764;
  static const String domain = 'Quality Assurance';
  static const String verbInfinitive = 'beschreiben';
  static const String praeteritum = 'beschrieb';
  static const String perfekt = 'hat beschrieben';
  static const String arabicTranslation = 'تأكيد / تزويد التدوين (ضمان الجودة)';
  static const String ipaTranscription = '[beˈˈʃʁaɪ̯bn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4764_beschreiben.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Qualitaetsprozess beschreiben.';
  static const String exampleArabic = 'يجب علينا تأكيد / تزويد التدوين في إجراءات فحص الجودة.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
