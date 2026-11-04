// Sovereign Polyglot Core - Task 2598 (Clinical Diagnostics)
class Task2598Engine {
  static const int taskId = 2598;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'vorpruefen';
  static const String praeteritum = 'pruefte vor';
  static const String perfekt = 'hat vorgeprueft';
  static const String arabicTranslation = 'تقديم / تحضير التدقيق (التواصل الطبي)';
  static const String ipaTranscription = '[vorˈˈpʁyːfn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2598_vorpruefen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung vorpruefen.';
  static const String exampleArabic = 'يجب علينا تقديم / تحضير التدقيق في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
