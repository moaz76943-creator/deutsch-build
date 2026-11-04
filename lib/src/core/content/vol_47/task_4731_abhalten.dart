// Sovereign Polyglot Core - Task 4731 (Quality Assurance)
class Task4731Engine {
  static const int taskId = 4731;
  static const String domain = 'Quality Assurance';
  static const String verbInfinitive = 'abhalten';
  static const String praeteritum = 'hielt ab';
  static const String perfekt = 'hat abgehalten';
  static const String arabicTranslation = 'فصل / إتمام الالتزام (ضمان الجودة)';
  static const String ipaTranscription = '[abˈˈhaltn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4731_abhalten.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Qualitaetsprozess abhalten.';
  static const String exampleArabic = 'يجب علينا فصل / إتمام الالتزام في إجراءات فحص الجودة.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
