// Sovereign Polyglot Core - Task 4915 (Quality Assurance)
class Task4915Engine {
  static const int taskId = 4915;
  static const String domain = 'Quality Assurance';
  static const String verbInfinitive = 'einschliessen';
  static const String praeteritum = 'schloss ein';
  static const String perfekt = 'hat eingeschlossen';
  static const String arabicTranslation = 'إدراج / دمج الإبرام (ضمان الجودة)';
  static const String ipaTranscription = '[einˈˈʃliːsn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4915_einschliessen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Qualitaetsprozess einschliessen.';
  static const String exampleArabic = 'يجب علينا إدراج / دمج الإبرام في إجراءات فحص الجودة.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
