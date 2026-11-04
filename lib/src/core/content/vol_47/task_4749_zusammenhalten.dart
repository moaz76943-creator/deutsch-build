// Sovereign Polyglot Core - Task 4749 (Quality Assurance)
class Task4749Engine {
  static const int taskId = 4749;
  static const String domain = 'Quality Assurance';
  static const String verbInfinitive = 'zusammenhalten';
  static const String praeteritum = 'hielt zusammen';
  static const String perfekt = 'hat zusammengehalten';
  static const String arabicTranslation = 'تجميع / توحيد الالتزام (ضمان الجودة)';
  static const String ipaTranscription = '[zusammenˈˈhaltn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4749_zusammenhalten.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Qualitaetsprozess zusammenhalten.';
  static const String exampleArabic = 'يجب علينا تجميع / توحيد الالتزام في إجراءات فحص الجودة.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
