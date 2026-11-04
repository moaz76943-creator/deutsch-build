// Sovereign Polyglot Core - Task 4729 (Quality Assurance)
class Task4729Engine {
  static const int taskId = 4729;
  static const String domain = 'Quality Assurance';
  static const String verbInfinitive = 'zusammengeben';
  static const String praeteritum = 'gab zusammen';
  static const String perfekt = 'hat zusammengegeben';
  static const String arabicTranslation = 'تجميع / توحيد التسليم (ضمان الجودة)';
  static const String ipaTranscription = '[zusammenˈˈɡeːbn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4729_zusammengeben.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Qualitaetsprozess zusammengeben.';
  static const String exampleArabic = 'يجب علينا تجميع / توحيد التسليم في إجراءات فحص الجودة.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
