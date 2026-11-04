// Sovereign Polyglot Core - Task 2604 (Clinical Diagnostics)
class Task2604Engine {
  static const int taskId = 2604;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'bepruefen';
  static const String praeteritum = 'bepruefte';
  static const String perfekt = 'hat beprueft';
  static const String arabicTranslation = 'تأكيد / تزويد التدقيق (التواصل الطبي)';
  static const String ipaTranscription = '[beˈˈpʁyːfn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2604_bepruefen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung bepruefen.';
  static const String exampleArabic = 'يجب علينا تأكيد / تزويد التدقيق في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
