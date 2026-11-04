// Sovereign Polyglot Core - Task 4745 (Quality Assurance)
class Task4745Engine {
  static const int taskId = 4745;
  static const String domain = 'Quality Assurance';
  static const String verbInfinitive = 'erhalten';
  static const String praeteritum = 'erhielt';
  static const String perfekt = 'hat erhalten';
  static const String arabicTranslation = 'إنجاز / تحقيق الالتزام (ضمان الجودة)';
  static const String ipaTranscription = '[erˈˈhaltn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4745_erhalten.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Qualitaetsprozess erhalten.';
  static const String exampleArabic = 'يجب علينا إنجاز / تحقيق الالتزام في إجراءات فحص الجودة.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
