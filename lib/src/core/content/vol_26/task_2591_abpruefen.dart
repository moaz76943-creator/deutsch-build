// Sovereign Polyglot Core - Task 2591 (Clinical Diagnostics)
class Task2591Engine {
  static const int taskId = 2591;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'abpruefen';
  static const String praeteritum = 'pruefte ab';
  static const String perfekt = 'hat abgeprueft';
  static const String arabicTranslation = 'فصل / إتمام التدقيق (التواصل الطبي)';
  static const String ipaTranscription = '[abˈˈpʁyːfn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2591_abpruefen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung abpruefen.';
  static const String exampleArabic = 'يجب علينا فصل / إتمام التدقيق في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
