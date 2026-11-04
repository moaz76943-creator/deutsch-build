// Sovereign Polyglot Core - Task 4741 (Quality Assurance)
class Task4741Engine {
  static const int taskId = 4741;
  static const String domain = 'Quality Assurance';
  static const String verbInfinitive = 'unterhalten';
  static const String praeteritum = 'unterhielt';
  static const String perfekt = 'hat unterhalten';
  static const String arabicTranslation = 'فحص / دعم الالتزام (ضمان الجودة)';
  static const String ipaTranscription = '[unterˈˈhaltn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4741_unterhalten.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Qualitaetsprozess unterhalten.';
  static const String exampleArabic = 'يجب علينا فحص / دعم الالتزام في إجراءات فحص الجودة.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
