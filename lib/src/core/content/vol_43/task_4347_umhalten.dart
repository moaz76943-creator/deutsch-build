// Sovereign Polyglot Core - Task 4347 (Supply Chain)
class Task4347Engine {
  static const int taskId = 4347;
  static const String domain = 'Supply Chain';
  static const String verbInfinitive = 'umhalten';
  static const String praeteritum = 'hielt um';
  static const String perfekt = 'hat umgehalten';
  static const String arabicTranslation = 'إعادة هيكلة الالتزام (سلاسل الإمداد)';
  static const String ipaTranscription = '[umˈˈhaltn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4347_umhalten.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Logistikzentrale umhalten.';
  static const String exampleArabic = 'يجب علينا إعادة هيكلة الالتزام في مركز العمليات اللوجستية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
