// Sovereign Polyglot Core - Task 4769 (Quality Assurance)
class Task4769Engine {
  static const int taskId = 4769;
  static const String domain = 'Quality Assurance';
  static const String verbInfinitive = 'zusammenschreiben';
  static const String praeteritum = 'schrieb zusammen';
  static const String perfekt = 'hat zusammengeschrieben';
  static const String arabicTranslation = 'تجميع / توحيد التدوين (ضمان الجودة)';
  static const String ipaTranscription = '[zusammenˈˈʃʁaɪ̯bn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4769_zusammenschreiben.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Qualitaetsprozess zusammenschreiben.';
  static const String exampleArabic = 'يجب علينا تجميع / توحيد التدوين في إجراءات فحص الجودة.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
