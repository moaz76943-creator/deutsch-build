// Sovereign Polyglot Core - Task 4732 (Quality Assurance)
class Task4732Engine {
  static const int taskId = 4732;
  static const String domain = 'Quality Assurance';
  static const String verbInfinitive = 'anhalten';
  static const String praeteritum = 'hielt an';
  static const String perfekt = 'hat angehalten';
  static const String arabicTranslation = 'بدء / توجيه الالتزام (ضمان الجودة)';
  static const String ipaTranscription = '[anˈˈhaltn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4732_anhalten.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Qualitaetsprozess anhalten.';
  static const String exampleArabic = 'يجب علينا بدء / توجيه الالتزام في إجراءات فحص الجودة.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
