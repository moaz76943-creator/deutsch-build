// Sovereign Polyglot Core - Task 4605 (Quality Assurance)
class Task4605Engine {
  static const int taskId = 4605;
  static const String domain = 'Quality Assurance';
  static const String verbInfinitive = 'erpruefen';
  static const String praeteritum = 'erpruefte';
  static const String perfekt = 'hat erprueft';
  static const String arabicTranslation = 'إنجاز / تحقيق التدقيق (ضمان الجودة)';
  static const String ipaTranscription = '[erˈˈpʁyːfn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4605_erpruefen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Qualitaetsprozess erpruefen.';
  static const String exampleArabic = 'يجب علينا إنجاز / تحقيق التدقيق في إجراءات فحص الجودة.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
